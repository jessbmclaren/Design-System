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

  group('DsBusinessVerification market depth', () {
    const types = <DsSelectOption<String>>[
      DsSelectOption<String>(value: 'Company', label: 'Company'),
      DsSelectOption<String>(value: 'Sole trader', label: 'Sole trader'),
    ];
    const registered = DsBusinessFieldCopy(
      nameLabel: 'Registered company name',
      identifierLabel: 'Company registration number',
    );
    const unregistered = DsBusinessFieldCopy(
      nameLabel: 'Business name',
      identifierLabel: 'ID number',
    );

    Future<void> pumpFlow(WidgetTester tester) => pumpDs(
          tester,
          const DsBusinessVerification(
            businessTypeOptions: types,
            unregisteredValues: {'Sole trader'},
            registeredCopy: registered,
            unregisteredCopy: unregistered,
          ),
          surfaceSize: const Size(900, 1200),
        );

    Future<void> selectType(WidgetTester tester, String label) async {
      await tester.tap(find.byType(DsSelect<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    testWidgets('reframes the details step for a registered type',
        (tester) async {
      await pumpFlow(tester);
      await selectType(tester, 'Company');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Registered company name'), findsOneWidget);
      expect(find.text('Company registration number'), findsOneWidget);
    });

    testWidgets('reframes and clears the identifier across the divide',
        (tester) async {
      await pumpFlow(tester);
      await selectType(tester, 'Company');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Enter a company registration number (the identifier is the second
      // field on the details step).
      await tester.enterText(find.byType(TextFormField).at(1), '2019/123456/07');
      await tester.pump();

      // Back to the type step and switch to an unregistered type.
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      await selectType(tester, 'Sole trader');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // The unregistered copy applies and the identifier was cleared.
      expect(find.text('Business name'), findsOneWidget);
      expect(find.text('ID number'), findsOneWidget);
      expect(find.text('2019/123456/07'), findsNothing);
    });

    testWidgets('pre-fills the legal name from initialLegalName',
        (tester) async {
      await pumpDs(
        tester,
        const DsBusinessVerification(initialLegalName: 'Acme Logistics'),
        surfaceSize: const Size(900, 1200),
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Acme Logistics'), findsOneWidget);
    });

    testWidgets('shows a role select on the identity step when given options',
        (tester) async {
      await pumpDs(
        tester,
        const DsBusinessVerification(
          roleOptions: <DsSelectOption<String>>[
            DsSelectOption<String>(value: 'Director', label: 'Director'),
          ],
          roleLabel: 'Your role in the business',
        ),
        surfaceSize: const Size(900, 1200),
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Your role in the business'), findsOneWidget);
    });

    testWidgets('a legal-name validator blocks Continue and shows the error',
        (tester) async {
      await pumpDs(
        tester,
        DsBusinessVerification(
          legalNameValidator: (v) =>
              (v == null || v.isEmpty) ? 'Enter your business name' : null,
        ),
        surfaceSize: const Size(900, 1200),
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // On the details step with an empty name: Continue validates and holds.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your business name'), findsOneWidget);
      expect(find.text('Verify identity'), findsNothing);
    });

    Future<void> walkToReceipt(WidgetTester tester) async {
      // Walk to the end: type, details, identity (tick consent), review, submit.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text("I confirm I'm authorised to act for this business"),
      );
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
    }

    testWidgets('the receipt badge defaults to the success tone',
        (tester) async {
      await pumpDs(
        tester,
        const DsBusinessVerification(showReceipt: true),
        surfaceSize: const Size(900, 1200),
      );
      await walkToReceipt(tester);
      final badge = tester.widget<DsIconBadge>(find.byType(DsIconBadge));
      expect(badge.tone, DsIconBadgeTone.success);
    });

    testWidgets('the receipt badge honours a brand-soft override',
        (tester) async {
      await pumpDs(
        tester,
        const DsBusinessVerification(
          showReceipt: true,
          receiptBadgeTone: DsIconBadgeTone.brandSoft,
        ),
        surfaceSize: const Size(900, 1200),
      );
      await walkToReceipt(tester);
      final badge = tester.widget<DsIconBadge>(find.byType(DsIconBadge));
      expect(badge.tone, DsIconBadgeTone.brandSoft);
    });

    testWidgets('handleSystemBack steps back through the flow', (tester) async {
      await pumpDs(
        tester,
        const DsBusinessVerification(handleSystemBack: true),
        surfaceSize: const Size(900, 1200),
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Legal name'), findsWidgets);

      // A system back gesture steps to the previous step, not out of the flow.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Legal name'), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('handleSystemBack backs out of the first step via onCancel',
        (tester) async {
      var cancelled = 0;
      await pumpDs(
        tester,
        DsBusinessVerification(
          handleSystemBack: true,
          onCancel: () => cancelled++,
        ),
        surfaceSize: const Size(900, 1200),
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(cancelled, 1);
    });
  });


  group('rail progress', () {
    testWidgets('renders the rail beside the step body on a wide page', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 800,
          child: DsBusinessVerification(
            progress: DsVerificationProgress.rail,
          ),
        ),
        surfaceSize: const Size(1200, 900),
      );

      expect(find.byType(DsVerificationRail), findsOneWidget);
      // The rail names every section, so the wizard drops its own stepper.
      expect(find.byType(DsProgressStepper), findsNothing);
      expect(find.text('Business type'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the rail tracks the step as the flow advances', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 800,
          child: DsBusinessVerification(
            progress: DsVerificationProgress.rail,
          ),
        ),
        surfaceSize: const Size(1200, 900),
      );

      DsVerificationRail rail() =>
          tester.widget<DsVerificationRail>(find.byType(DsVerificationRail));
      expect(rail().sections.first.state, DsVerificationSectionState.active);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(rail().sections.first.state, DsVerificationSectionState.done);
      expect(rail().sections[1].state, DsVerificationSectionState.active);
    });

    testWidgets('stacks the rail above the body on a narrow page', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 800,
          child: DsBusinessVerification(
            progress: DsVerificationProgress.rail,
          ),
        ),
        surfaceSize: const Size(360, 900),
      );
      expect(find.byType(DsVerificationRail), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the stepper remains the default', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(height: 800, child: DsBusinessVerification()),
        surfaceSize: const Size(1200, 900),
      );
      expect(find.byType(DsVerificationRail), findsNothing);
      expect(find.byType(DsProgressStepper), findsOneWidget);
    });
  });
}
