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

    testWidgets('backing out of the first step fires onCancel',
        (tester) async {
      var cancelled = 0;
      await pumpDs(
        tester,
        SizedBox(
          height: 800,
          child: DsBusinessVerification(onCancel: () => cancelled++),
        ),
      );

      expect(find.text('Back'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pump();

      expect(cancelled, 1);
      expect(find.text('Business type'), findsWidgets,
          reason: 'cancelling leaves the flow on its first step');
    });

    testWidgets('without onCancel the first step has no back affordance',
        (tester) async {
      await pumpDs(
        tester,
        const SizedBox(height: 800, child: DsBusinessVerification()),
      );

      expect(find.text('Back'), findsNothing);
    });

    testWidgets('a replaced identity body lifts the consent gate',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          height: 800,
          child: DsBusinessVerification(
            stepBodyBuilder: (context, stepIndex, body) =>
                stepIndex == 2 ? const Text('Custom identity step') : body,
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Custom identity step'), findsOneWidget);

      // The stock consent checkbox is gone with the stock body, so the flow
      // must not stay gated on it.
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Review your details'), findsOneWidget);
    });

    testWidgets('canAdvance overrides a step\'s stock gating', (tester) async {
      var allow = false;
      late StateSetter setHarnessState;
      await pumpDs(
        tester,
        SizedBox(
          height: 800,
          child: StatefulBuilder(
            builder: (context, setState) {
              setHarnessState = setState;
              return DsBusinessVerification(
                canAdvance: (stepIndex) => stepIndex == 0 ? allow : null,
              );
            },
          ),
        ),
      );

      // The override gates step 0, which the stock flow never does.
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Legal name'), findsNothing);

      setHarnessState(() => allow = true);
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Legal name'), findsWidgets);
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

    testWidgets('shows the takeover header and fires onClose', (tester) async {
      var closed = 0;
      await pumpDs(
        tester,
        SizedBox(
          height: 800,
          child: DsBusinessVerification(onClose: () => closed++),
        ),
      );

      // The header carries the title, so it appears exactly once.
      expect(find.text('Verify your business'), findsOneWidget);

      await tester.tap(find.byIcon(DsIcons.close));
      await tester.pump();
      expect(closed, 1);
    });

    testWidgets('stepBodyBuilder can extend a step body', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          height: 800,
          child: DsBusinessVerification(
            stepBodyBuilder: (context, stepIndex, body) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                body,
                if (stepIndex == 0) const Text('Trading name (optional)'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Trading name (optional)'), findsOneWidget);

      // The extension is scoped to step 0, so advancing removes it.
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Trading name (optional)'), findsNothing);
    });

    testWidgets('the details step collects a structured address',
        (tester) async {
      await pumpDs(
        tester,
        const SizedBox(height: 800, child: DsBusinessVerification()),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Registered address'), findsOneWidget);
      expect(find.text('Street address'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Postal code'), findsOneWidget);
    });

    testWidgets('wires the upload slot into the identity step',
        (tester) async {
      var picked = 0;
      await pumpDs(
        tester,
        SizedBox(
          height: 800,
          child: DsBusinessVerification(
            uploadState: DsUploadFieldState.idle,
            onUploadPick: () => picked++,
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Identity document'), findsOneWidget);

      await tester.ensureVisible(find.text('Upload an identity document'));
      await tester.tap(find.text('Upload an identity document'));
      await tester.pump();
      expect(picked, 1);
    });

    testWidgets('with showReceipt, onSubmitted waits for the continue action',
        (tester) async {
      var submitted = 0;
      await pumpDs(
        tester,
        SizedBox(
          height: 800,
          child: DsBusinessVerification(
            showReceipt: true,
            onSubmitted: () => submitted++,
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
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // The receipt is up and the flow has not completed yet.
      expect(find.text('Verification submitted'), findsOneWidget);
      expect(submitted, 0);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(submitted, 1);
    });

    testWidgets('closing from the receipt completes rather than cancels',
        (tester) async {
      var submitted = 0;
      var closed = 0;
      await pumpDs(
        tester,
        SizedBox(
          height: 800,
          child: DsBusinessVerification(
            showReceipt: true,
            onClose: () => closed++,
            onSubmitted: () => submitted++,
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
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // The submission already happened, so the close affordance must not
      // forget it.
      await tester.tap(find.byIcon(DsIcons.close));
      await tester.pump();
      expect(submitted, 1);
      expect(closed, 0);
    });
  });
}
