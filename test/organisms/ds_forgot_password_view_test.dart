import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsForgotPasswordView', () {
    testWidgets('renders the title, description and primary action', (
      tester,
    ) async {
      var pressed = 0;
      await pumpDs(
        tester,
        DsForgotPasswordView(
          title: 'Reset your password',
          description: 'Enter your email and we will send a link.',
          primaryAction: DsSignInAction(
            label: 'Continue',
            onPressed: () => pressed++,
          ),
        ),
      );
      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.textContaining('send a link'), findsOneWidget);
      await tester.tap(find.widgetWithText(DsButton, 'Continue'));
      expect(pressed, 1);
    });

    testWidgets('with no primary action it renders no button, only the footer', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsForgotPasswordView(
          title: 'Check your email',
          footer: Text('Return to sign-in'),
        ),
      );
      // A confirmation step is button-free: the next move is in the inbox.
      expect(find.byType(DsButton), findsNothing);
      expect(find.text('Return to sign-in'), findsOneWidget);
    });

    testWidgets('standalone mode frames its own page with a scroll', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsForgotPasswordView(title: 'Reset your password'),
      );
      expect(
        find.descendant(
          of: find.byType(DsForgotPasswordView),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
    });

    testWidgets('embedded mode adds no scroll, for a host that frames', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: const DsForgotPasswordView(
                title: 'Reset your password',
                embedded: true,
              ),
            ),
          ),
        ),
      );
      // No nested vertical scrollables: the view added none of its own.
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      // Stays within the card measure (DsAuthCardLayout.signInMaxWidth = 420)
      // rather than sprawling to the host width.
      expect(
        tester.getSize(find.byType(DsForgotPasswordView)).width,
        lessThanOrEqualTo(420),
      );
    });

    testWidgets('the close affordance appears only with onClose', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsForgotPasswordView(title: 'Reset your password'),
      );
      expect(find.byTooltip('Close'), findsNothing);

      var closed = 0;
      await pumpDs(
        tester,
        DsForgotPasswordView(
          title: 'Reset your password',
          onClose: () => closed++,
        ),
      );
      await tester.tap(find.byTooltip('Close'));
      expect(closed, 1);
    });

    testWidgets('renders without overflow at 320dp and stretched wide', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsForgotPasswordView(
          title: 'Reset your password',
          description: 'Enter your email and we will send a link.',
          primaryAction: const DsSignInAction(
            label: 'Continue',
            onPressed: null,
          ),
        ),
        surfaceSize: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
      await pumpDs(
        tester,
        const DsForgotPasswordView(title: 'Reset your password'),
        surfaceSize: const Size(1440, 900),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
