import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsResendControl', () {
    testWidgets('it holds the resend behind the cooldown, then offers it', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsResendControl(onResend: () async => const DsResendResult.sent()),
      );
      await tester.pump();

      expect(find.textContaining('Resend in 0:'), findsOneWidget);
      expect(find.text('Resend'), findsNothing);

      await tester.pump(const Duration(seconds: 31));
      await tester.pump();
      expect(find.text('Resend'), findsOneWidget);
    });

    testWidgets('a sent resend restarts the cooldown', (tester) async {
      var sends = 0;
      await pumpDs(
        tester,
        DsResendControl(
          onResend: () async {
            sends++;
            return const DsResendResult.sent();
          },
        ),
      );
      await tester.pump(const Duration(seconds: 31));
      await tester.pump();

      await tester.tap(find.text('Resend'));
      await tester.pump();
      expect(sends, 1);
      // Back behind the cooldown.
      expect(find.textContaining('Resend in 0:'), findsOneWidget);
      expect(find.text('Resend'), findsNothing);
    });

    testWidgets('a rate-limited resend shows the wait and offers nothing', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsResendControl(
          rateLimitedLabel: 'Try again in 5 minutes',
          onResend: () async => const DsResendResult.rateLimited('Try again in 5 minutes'),
        ),
      );
      await tester.pump(const Duration(seconds: 31));
      await tester.pump();

      await tester.tap(find.text('Resend'));
      await tester.pump();
      expect(find.text('Try again in 5 minutes'), findsOneWidget);
      expect(find.text('Resend'), findsNothing);
    });

    testWidgets('it opens straight into rate-limited when told to', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsResendControl(
          onResend: null,
          startRateLimited: true,
          rateLimitedLabel: 'Try again in 5 minutes',
        ),
      );
      await tester.pump();
      expect(find.text('Try again in 5 minutes'), findsOneWidget);
    });

    testWidgets('a failed resend stays offerable so it can be retried', (
      tester,
    ) async {
      var fail = true;
      await pumpDs(
        tester,
        DsResendControl(
          onResend: () async =>
              fail ? const DsResendResult.failed() : const DsResendResult.sent(),
        ),
      );
      await tester.pump(const Duration(seconds: 31));
      await tester.pump();

      await tester.tap(find.text('Resend'));
      await tester.pump();
      // Still offered, not stuck.
      expect(find.text('Resend'), findsOneWidget);

      fail = false;
      await tester.tap(find.text('Resend'));
      await tester.pump();
      expect(find.textContaining('Resend in 0:'), findsOneWidget);
    });

    testWidgets('a null callback disables the resend', (tester) async {
      await pumpDs(
        tester,
        const DsResendControl(onResend: null),
      );
      await tester.pump(const Duration(seconds: 31));
      await tester.pump();
      final link = tester.widget<DsLink>(find.byType(DsLink));
      expect(link.onPressed, isNull);
    });

    testWidgets('under reduced motion the resend is offered straight away', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: const Scaffold(
            body: MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: Center(
                child: DsResendControl(onResend: _sent),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      // No live ticker to animate: offered immediately.
      expect(find.text('Resend'), findsOneWidget);
      expect(find.textContaining('Resend in'), findsNothing);
    });

    testWidgets('it renders at 320dp and stretched wide', (tester) async {
      await pumpDs(
        tester,
        DsResendControl(onResend: () async => const DsResendResult.sent()),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}

Future<DsResendResult> _sent() async => const DsResendResult.sent();
