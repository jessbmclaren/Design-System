import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsBusinessVerification', () {
    testWidgets('renders the first step chrome and content', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(height: 800, child: DsBusinessVerification()),
      );

      expect(find.text('Verify your business'), findsOneWidget);
      expect(find.text('Business type'), findsWidgets);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('advancing moves to the business details step', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(height: 800, child: DsBusinessVerification()),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Business details'), findsWidgets);
      expect(find.text('Legal name'), findsWidgets);
    });

    testWidgets('going back returns to the previous step', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(height: 800, child: DsBusinessVerification()),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Business details'), findsWidgets);

      await tester.tap(find.text('Back'));
      await tester.pump();
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Legal name'), findsNothing);
    });

    testWidgets('identity step gates advancing on the consent checkbox',
        (tester) async {
      await pumpDs(
        tester,
        const SizedBox(height: 800, child: DsBusinessVerification()),
      );

      // Step 0 -> 1 -> 2 (identity).
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      const consentLabel = "I confirm I'm authorised to act for this business";
      expect(find.text(consentLabel), findsOneWidget);

      // Tick consent, which enables advancing.
      await tester.tap(find.text(consentLabel));
      await tester.pump();

      await tester.tap(find.text('Continue'));
      await tester.pump();

      // Now on the review step.
      expect(find.text('Review your details'), findsOneWidget);
    });

    testWidgets('submitting the flow fires onSubmitted and shows success',
        (tester) async {
      var submitted = false;
      await pumpDs(
        tester,
        SizedBox(
          height: 800,
          child: DsBusinessVerification(
            onSubmitted: () => submitted = true,
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      await tester
          .tap(find.text("I confirm I'm authorised to act for this business"));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      // Review step shows a Submit action.
      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(submitted, isTrue);
      expect(find.text('Verification submitted'), findsOneWidget);
    });

    testWidgets('renders without overflow on a small phone', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(height: 800, child: DsBusinessVerification()),
        surfaceSize: const Size(320, 900),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a large desktop', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(height: 800, child: DsBusinessVerification()),
        surfaceSize: const Size(1200, 900),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
