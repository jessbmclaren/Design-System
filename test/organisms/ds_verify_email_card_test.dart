import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsVerifyEmailCard', () {
    testWidgets('inbox state shows the heading, address and resend action', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsVerifyEmailCard(email: 'sam@example.com'),
      );

      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.textContaining('sam@example.com'), findsOneWidget);
      expect(find.widgetWithText(DsButton, 'Resend email'), findsOneWidget);
      // No continue action while unverified.
      expect(find.widgetWithText(DsButton, 'Continue'), findsNothing);
    });

    testWidgets('verified state shows the confirmation and continue action', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsVerifyEmailCard(email: 'sam@example.com', verified: true),
      );

      expect(find.text('Email verified'), findsOneWidget);
      expect(find.textContaining('has been verified'), findsOneWidget);
      expect(find.widgetWithText(DsButton, 'Continue'), findsOneWidget);
      expect(find.widgetWithText(DsButton, 'Resend email'), findsNothing);
    });

    testWidgets('resend fires its callback', (tester) async {
      var resent = 0;
      await pumpDs(
        tester,
        DsVerifyEmailCard(email: 'sam@example.com', onResend: () => resent++),
      );

      await tester.tap(find.widgetWithText(DsButton, 'Resend email'));
      expect(resent, 1);
    });

    testWidgets('continue fires its callback in the verified state', (
      tester,
    ) async {
      var continued = 0;
      await pumpDs(
        tester,
        DsVerifyEmailCard(
          email: 'sam@example.com',
          verified: true,
          onContinue: () => continued++,
        ),
      );

      await tester.tap(find.widgetWithText(DsButton, 'Continue'));
      expect(continued, 1);
    });

    testWidgets('a pending resend blocks a second tap', (tester) async {
      var resent = 0;
      await pumpDs(
        tester,
        DsVerifyEmailCard(
          email: 'sam@example.com',
          resendPending: true,
          onResend: () => resent++,
        ),
      );

      await tester.tap(find.byType(DsButton));
      expect(resent, 0, reason: 'a pending button must not fire');
    });

    testWidgets('the inbox close affordance appears only with onClose', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsVerifyEmailCard(email: 'sam@example.com'),
      );
      expect(find.byTooltip('Close'), findsNothing);

      var closed = 0;
      await pumpDs(
        tester,
        DsVerifyEmailCard(email: 'sam@example.com', onClose: () => closed++),
      );
      expect(find.byTooltip('Close'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      expect(closed, 1);
    });

    testWidgets('the verified close completes rather than dismisses', (
      tester,
    ) async {
      var continued = 0;
      var closed = 0;
      await pumpDs(
        tester,
        DsVerifyEmailCard(
          email: 'sam@example.com',
          verified: true,
          onContinue: () => continued++,
          onClose: () => closed++,
        ),
      );

      // Verified: the corner close is routed to onContinue, never onClose.
      await tester.tap(find.byTooltip('Close'));
      expect(continued, 1);
      expect(closed, 0);
    });

    testWidgets('a blank email falls back to neutral copy', (tester) async {
      await pumpDs(tester, const DsVerifyEmailCard(email: '   '));
      // The fallback address lands in the body sentence.
      expect(find.textContaining('Check your email'), findsOneWidget);
    });

    testWidgets('the verified heading is announced as a live region', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const DsVerifyEmailCard(email: 'sam@example.com', verified: true),
      );

      expect(
        tester.getSemantics(find.text('Email verified')),
        matchesSemantics(isHeader: true, isLiveRegion: true, label: 'Email verified'),
      );
      handle.dispose();
    });

    testWidgets('renders without overflow at 320dp and stretched wide', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsVerifyEmailCard(email: 'a-very-long-address@example-company.com'),
        surfaceSize: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);

      await pumpDs(
        tester,
        const DsVerifyEmailCard(email: 'sam@example.com'),
        surfaceSize: const Size(1440, 900),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
