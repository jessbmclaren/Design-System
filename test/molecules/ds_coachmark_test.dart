import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders title and body', (tester) async {
    await pumpDs(
      tester,
      const DsCoachmark(
        title: 'Filter your results',
        body: 'Narrow the list to just what you need before you export.',
      ),
    );

    expect(find.text('Filter your results'), findsOneWidget);
    expect(
      find.text('Narrow the list to just what you need before you export.'),
      findsOneWidget,
    );
  });

  testWidgets('primary action fires its callback when tapped', (tester) async {
    var tapped = false;
    await pumpDs(
      tester,
      DsCoachmark(
        title: 'Step title',
        primaryActionLabel: 'Next',
        onPrimary: () => tapped = true,
      ),
    );

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('secondary action and dismiss fire their callbacks',
      (tester) async {
    var secondary = false;
    var dismissed = false;
    await pumpDs(
      tester,
      DsCoachmark(
        title: 'Step title',
        secondaryActionLabel: 'Skip',
        onSecondary: () => secondary = true,
        onDismiss: () => dismissed = true,
      ),
    );

    await tester.tap(find.text('Skip'));
    await tester.pump();
    expect(secondary, isTrue);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(dismissed, isTrue);
  });

  testWidgets('reflects step progress in its semantic label', (tester) async {
    await pumpDs(
      tester,
      const DsCoachmark(
        title: 'Guided tour',
        stepIndex: 1,
        stepCount: 3,
      ),
    );

    expect(
      find.bySemanticsLabel('Step 2 of 3'),
      findsOneWidget,
    );
  });

  testWidgets('renders at 320x900 without overflow', (tester) async {
    await pumpDs(
      tester,
      DsCoachmark(
        title: 'Filter your results',
        body: 'Narrow the list to just what you need before you export.',
        stepIndex: 0,
        stepCount: 3,
        primaryActionLabel: 'Next',
        onPrimary: () {},
        secondaryActionLabel: 'Skip',
        onSecondary: () {},
        onDismiss: () {},
      ),
      surfaceSize: const Size(320, 900),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders at 1200x900 without overflow', (tester) async {
    await pumpDs(
      tester,
      DsCoachmark(
        title: 'Filter your results',
        body: 'Narrow the list to just what you need before you export.',
        stepIndex: 0,
        stepCount: 3,
        primaryActionLabel: 'Next',
        onPrimary: () {},
        secondaryActionLabel: 'Skip',
        onSecondary: () {},
        onDismiss: () {},
      ),
      surfaceSize: const Size(1200, 900),
    );

    expect(tester.takeException(), isNull);
  });
}
