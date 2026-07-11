import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

import '../helpers.dart';

void main() {
  const steps = [
    DsWizardStep(label: 'Account'),
    DsWizardStep(label: 'Profile'),
    DsWizardStep(label: 'Review'),
  ];

  Widget bounded(Widget child) => SizedBox(height: 700, child: child);

  testWidgets('renders title, subtitle and step body', (tester) async {
    await pumpDs(
      tester,
      bounded(
        const DsOnboardingWizard(
          steps: steps,
          currentIndex: 1,
          title: 'Tell us about you',
          subtitle: 'This helps personalise your setup',
          child: Text('Step body content'),
        ),
      ),
    );

    expect(find.text('Tell us about you'), findsOneWidget);
    expect(find.text('This helps personalise your setup'), findsOneWidget);
    expect(find.text('Step body content'), findsOneWidget);
  });

  testWidgets('fires onNext when the primary action is tapped', (tester) async {
    var nextCount = 0;
    await pumpDs(
      tester,
      bounded(
        DsOnboardingWizard(
          steps: steps,
          currentIndex: 0,
          nextLabel: 'Continue',
          onNext: () => nextCount++,
          child: const Text('Body'),
        ),
      ),
    );

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(nextCount, 1);
  });

  testWidgets('hides Back when onBack is null and shows it otherwise',
      (tester) async {
    await pumpDs(
      tester,
      bounded(
        const DsOnboardingWizard(
          steps: steps,
          currentIndex: 0,
          backLabel: 'Back',
          child: Text('Body'),
        ),
      ),
    );
    expect(find.text('Back'), findsNothing);

    var backCount = 0;
    await pumpDs(
      tester,
      bounded(
        DsOnboardingWizard(
          steps: steps,
          currentIndex: 1,
          backLabel: 'Back',
          onBack: () => backCount++,
          child: const Text('Body'),
        ),
      ),
    );
    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pump();
    expect(backCount, 1);
  });

  testWidgets('does not fire onNext when nextEnabled is false', (tester) async {
    var nextCount = 0;
    await pumpDs(
      tester,
      bounded(
        DsOnboardingWizard(
          steps: steps,
          currentIndex: 0,
          nextLabel: 'Continue',
          nextEnabled: false,
          onNext: () => nextCount++,
          child: const Text('Body'),
        ),
      ),
    );

    await tester.tap(find.text('Continue'), warnIfMissed: false);
    await tester.pump();

    expect(nextCount, 0);
  });

  testWidgets('renders footerLeading content', (tester) async {
    await pumpDs(
      tester,
      bounded(
        const DsOnboardingWizard(
          steps: steps,
          currentIndex: 1,
          footerLeading: Text('Need a hand?'),
          child: Text('Body'),
        ),
      ),
    );

    expect(find.text('Need a hand?'), findsOneWidget);
  });

  testWidgets('shows the stepper for a multi-step flow by default',
      (tester) async {
    await pumpDs(
      tester,
      bounded(
        const DsOnboardingWizard(
          steps: steps,
          currentIndex: 0,
          child: Text('Body'),
        ),
      ),
    );

    expect(find.byType(DsProgressStepper), findsOneWidget);
  });

  testWidgets('hides the stepper when there is a single step',
      (tester) async {
    await pumpDs(
      tester,
      bounded(
        const DsOnboardingWizard(
          steps: [DsWizardStep(label: 'Setup')],
          currentIndex: 0,
          title: 'Set up your workspace',
          child: Text('Body'),
        ),
      ),
    );

    expect(find.byType(DsProgressStepper), findsNothing);
    expect(find.text('Set up your workspace'), findsOneWidget);
  });

  testWidgets('hides the stepper when showStepper is false', (tester) async {
    await pumpDs(
      tester,
      bounded(
        const DsOnboardingWizard(
          steps: steps,
          currentIndex: 0,
          showStepper: false,
          child: Text('Body'),
        ),
      ),
    );

    expect(find.byType(DsProgressStepper), findsNothing);
  });

  testWidgets('renders header content above the stepper', (tester) async {
    await pumpDs(
      tester,
      bounded(
        const DsOnboardingWizard(
          steps: steps,
          currentIndex: 0,
          header: Text('Acme'),
          child: Text('Body'),
        ),
      ),
    );

    expect(find.text('Acme'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Acme')).dy,
      lessThan(tester.getTopLeft(find.byType(DsProgressStepper)).dy),
    );
  });

  testWidgets('renders without overflow on a compact 320dp phone',
      (tester) async {
    await pumpDs(
      tester,
      bounded(
        DsOnboardingWizard(
          steps: steps,
          currentIndex: 1,
          title: 'Tell us about you',
          subtitle: 'Supporting copy',
          onBack: () {},
          onNext: () {},
          footerLeading: const Text('Step 2 of 3'),
          child: const Text('Body'),
        ),
      ),
      surfaceSize: const Size(320, 900),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a wide 1200dp desktop',
      (tester) async {
    await pumpDs(
      tester,
      bounded(
        DsOnboardingWizard(
          steps: steps,
          currentIndex: 1,
          title: 'Tell us about you',
          subtitle: 'Supporting copy',
          onBack: () {},
          onNext: () {},
          footerLeading: const Text('Step 2 of 3'),
          child: const Text('Body'),
        ),
      ),
      surfaceSize: const Size(1200, 900),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
