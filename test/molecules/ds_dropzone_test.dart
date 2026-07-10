import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsDropzone', () {
    testWidgets('renders title, hint and browse, and fires onBrowse',
        (tester) async {
      var browsed = 0;
      await pumpDs(
        tester,
        DsDropzone(onBrowse: () => browsed++),
      );
      await tester.pump();

      expect(find.text('Drop a file here, or browse'), findsOneWidget);
      expect(find.text('CSV or Excel, up to 10 MB'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);

      // The browse button triggers onBrowse.
      await tester.tap(find.text('Browse'));
      await tester.pump();
      expect(browsed, 1);

      // Tapping the surface itself also triggers onBrowse.
      await tester.tap(find.text('Drop a file here, or browse'));
      await tester.pump();
      expect(browsed, 2);
    });

    testWidgets('shows the file chip and fires onClear when a file is set',
        (tester) async {
      var cleared = 0;
      await pumpDs(
        tester,
        DsDropzone(
          selectedFileName: 'contacts.csv',
          onClear: () => cleared++,
        ),
      );
      await tester.pump();

      expect(find.text('contacts.csv'), findsOneWidget);
      // The browse button is replaced by the file chip.
      expect(find.text('Browse'), findsNothing);

      await tester.tap(find.byIcon(DsIcons.close));
      await tester.pump();
      expect(cleared, 1);
    });

    testWidgets('honours a custom title and accept hint', (tester) async {
      await pumpDs(
        tester,
        const DsDropzone(
          title: 'Upload contacts',
          acceptHint: 'CSV only',
        ),
      );
      await tester.pump();

      expect(find.text('Upload contacts'), findsOneWidget);
      expect(find.text('CSV only'), findsOneWidget);
    });

    for (final width in <double>[320, 768, 1440]) {
      testWidgets('does not overflow at ${width.toInt()}dp', (tester) async {
        await pumpDs(
          tester,
          SizedBox(
            width: width,
            child: const DsDropzone(
              title:
                  'Drop a comma-separated or Excel spreadsheet here, or browse '
                  'to choose one from your computer',
              acceptHint:
                  'Accepted formats: CSV, TSV or Excel workbooks up to 10 MB',
              selectedFileName:
                  'a-very-long-export-file-name-that-should-truncate.csv',
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
