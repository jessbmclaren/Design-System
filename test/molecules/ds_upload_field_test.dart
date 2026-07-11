import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsUploadField', () {
    testWidgets('idle state renders the prompt and fires onPick',
        (tester) async {
      var picked = 0;
      await pumpDs(
        tester,
        DsUploadField(
          state: DsUploadFieldState.idle,
          helperText: 'PDF or PNG, up to 10 MB',
          onPick: () => picked++,
        ),
      );

      expect(find.text('Choose a file to upload'), findsOneWidget);
      expect(find.text('PDF or PNG, up to 10 MB'), findsOneWidget);

      await tester.tap(find.text('Choose a file to upload'));
      await tester.pump();
      expect(picked, 1);
    });

    testWidgets('a disabled idle field ignores taps', (tester) async {
      var picked = 0;
      await pumpDs(
        tester,
        DsUploadField(
          state: DsUploadFieldState.idle,
          enabled: false,
          onPick: () => picked++,
        ),
      );

      await tester.tap(find.text('Choose a file to upload'));
      await tester.pump();
      expect(picked, 0);
    });

    testWidgets('uploading shows the file name and a determinate bar',
        (tester) async {
      var picked = 0;
      await pumpDs(
        tester,
        DsUploadField(
          state: DsUploadFieldState.uploading,
          progress: 0.4,
          fileName: 'registration.pdf',
          onPick: () => picked++,
        ),
      );

      expect(find.text('Uploading registration.pdf'), findsOneWidget);
      final bar = tester.widget<DsProgressBar>(find.byType(DsProgressBar));
      expect(bar.value, 0.4);

      // The row is inert while the transfer runs.
      await tester.tap(find.text('Uploading registration.pdf'));
      await tester.pump();
      expect(picked, 0);
    });

    testWidgets('success confirms the file and fires onRemove',
        (tester) async {
      var removed = 0;
      await pumpDs(
        tester,
        DsUploadField(
          state: DsUploadFieldState.success,
          fileName: 'registration.pdf',
          onRemove: () => removed++,
        ),
      );

      expect(find.text('registration.pdf added'), findsOneWidget);

      await tester.tap(find.byIcon(DsIcons.close));
      await tester.pump();
      expect(removed, 1);
    });

    testWidgets('error shows the message and fires onRetry', (tester) async {
      var retried = 0;
      await pumpDs(
        tester,
        DsUploadField(
          state: DsUploadFieldState.error,
          errorText: 'The file is too large.',
          onRetry: () => retried++,
        ),
      );

      expect(find.text('Upload failed'), findsOneWidget);
      expect(find.text('The file is too large.'), findsOneWidget);

      await tester.tap(find.text('Upload failed'));
      await tester.pump();
      expect(retried, 1);
    });

    testWidgets('announces the status line as a polite live region',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const DsUploadField(
          state: DsUploadFieldState.uploading,
          progress: 0.5,
          fileName: 'registration.pdf',
        ),
      );

      expect(
        tester.getSemantics(find.text('Uploading registration.pdf')),
        isSemantics(isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('exposes button semantics only in the actionable states',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsUploadField(
              state: DsUploadFieldState.idle,
              onPick: () {},
            ),
            const DsUploadField(
              state: DsUploadFieldState.uploading,
              fileName: 'a.pdf',
            ),
          ],
        ),
      );

      expect(
        tester.getSemantics(find.text('Choose a file to upload')),
        isSemantics(isButton: true),
      );
      expect(
        tester.getSemantics(find.text('Uploading a.pdf')),
        isSemantics(isButton: false),
      );
      handle.dispose();
    });

    for (final width in <double>[320, 1440]) {
      testWidgets('does not overflow at ${width.toInt()}dp', (tester) async {
        await pumpDs(
          tester,
          SizedBox(
            width: width,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DsUploadField(
                  state: DsUploadFieldState.uploading,
                  progress: 0.7,
                  fileName:
                      'a-very-long-scanned-document-name-that-should-truncate'
                      '-rather-than-wrap.pdf',
                ),
                SizedBox(height: 16),
                DsUploadField(
                  state: DsUploadFieldState.error,
                  errorText:
                      'The upload was interrupted before it could finish, so '
                      'nothing was saved on our side.',
                ),
              ],
            ),
          ),
          surfaceSize: Size(width, 900),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
