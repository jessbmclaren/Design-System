import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders the primary action and fires onPrimary',
      (tester) async {
    var pressed = 0;
    await pumpDs(
      tester,
      DsFooterActions(
        primaryLabel: 'Continue',
        onPrimary: () => pressed++,
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(pressed, 1);
  });

  testWidgets('lays out a row with the primary action last when wide',
      (tester) async {
    await pumpDs(
      tester,
      SizedBox(
        width: 600,
        child: DsFooterActions(
          backLabel: 'Back',
          onBack: () {},
          primaryLabel: 'Continue',
          onPrimary: () {},
        ),
      ),
    );

    final back = tester.getCenter(find.text('Back'));
    final primary = tester.getCenter(find.text('Continue'));
    expect(back.dx, lessThan(primary.dx));
    expect((back.dy - primary.dy).abs(), lessThan(1));
  });

  testWidgets('stacks with the primary action first below minRowWidth',
      (tester) async {
    await pumpDs(
      tester,
      SizedBox(
        width: 400,
        child: DsFooterActions(
          backLabel: 'Back',
          onBack: () {},
          primaryLabel: 'Continue',
          onPrimary: () {},
        ),
      ),
    );

    final back = tester.getCenter(find.text('Back'));
    final primary = tester.getCenter(find.text('Continue'));
    expect(primary.dy, lessThan(back.dy));
    expect((back.dx - primary.dx).abs(), lessThan(1));
  });

  testWidgets('the layout flips at the minRowWidth threshold',
      (tester) async {
    Widget cluster(double width) => SizedBox(
          width: width,
          child: DsFooterActions(
            backLabel: 'Back',
            onBack: () {},
            primaryLabel: 'Continue',
            onPrimary: () {},
            minRowWidth: 480,
          ),
        );

    await pumpDs(tester, cluster(480));
    expect(
      tester.getCenter(find.text('Back')).dy,
      moreOrLessEquals(tester.getCenter(find.text('Continue')).dy, epsilon: 1),
    );

    await pumpDs(tester, cluster(479));
    expect(
      tester.getCenter(find.text('Continue')).dy,
      lessThan(tester.getCenter(find.text('Back')).dy),
    );
  });

  testWidgets('a null onPrimary disables the primary action', (tester) async {
    await pumpDs(
      tester,
      const DsFooterActions(primaryLabel: 'Continue'),
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('a pending primary shows a spinner and ignores taps',
      (tester) async {
    var pressed = 0;
    await pumpDs(
      tester,
      DsFooterActions(
        primaryLabel: 'Continue',
        onPrimary: () => pressed++,
        primaryPending: true,
      ),
    );

    expect(find.byType(DsSpinner), findsOneWidget);
    await tester.tap(find.text('Continue'), warnIfMissed: false);
    await tester.pump();
    expect(pressed, 0);
  });

  testWidgets('renders the tertiary action centred beneath and fires it',
      (tester) async {
    var saved = 0;
    await pumpDs(
      tester,
      SizedBox(
        width: 600,
        child: DsFooterActions(
          backLabel: 'Back',
          onBack: () {},
          primaryLabel: 'Continue',
          onPrimary: () {},
          tertiaryLabel: 'Save and finish later',
          onTertiary: () => saved++,
        ),
      ),
    );

    final tertiary = tester.getCenter(find.text('Save and finish later'));
    expect(tertiary.dy, greaterThan(tester.getCenter(find.text('Continue')).dy));

    await tester.tap(find.text('Save and finish later'));
    await tester.pump();
    expect(saved, 1);
  });

  testWidgets('omits the back action when backLabel is null', (tester) async {
    await pumpDs(
      tester,
      DsFooterActions(primaryLabel: 'Continue', onPrimary: () {}),
    );

    expect(find.byType(DsButton), findsOneWidget);
  });

  testWidgets('pins leading to the start when wide and centres it beneath '
      'when stacked', (tester) async {
    Widget cluster(double width) => SizedBox(
          width: width,
          child: DsFooterActions(
            leading: const Text('Step 2 of 4'),
            backLabel: 'Back',
            onBack: () {},
            primaryLabel: 'Continue',
            onPrimary: () {},
          ),
        );

    await pumpDs(tester, cluster(600));
    expect(
      tester.getCenter(find.text('Step 2 of 4')).dx,
      lessThan(tester.getCenter(find.text('Back')).dx),
    );

    await pumpDs(tester, cluster(400));
    expect(
      tester.getCenter(find.text('Step 2 of 4')).dy,
      greaterThan(tester.getCenter(find.text('Back')).dy),
    );
  });

  testWidgets('does not overflow at 320x640', (tester) async {
    await pumpDs(
      tester,
      DsFooterActions(
        leading: const Text('Step 2 of 4'),
        backLabel: 'Back',
        onBack: () {},
        primaryLabel: 'Continue with a fairly long label',
        onPrimary: () {},
        tertiaryLabel: 'Save and finish later',
        onTertiary: () {},
      ),
      surfaceSize: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow at a wide width', (tester) async {
    await pumpDs(
      tester,
      DsFooterActions(
        leading: const Text('Step 2 of 4'),
        backLabel: 'Back',
        onBack: () {},
        primaryLabel: 'Continue',
        onPrimary: () {},
        tertiaryLabel: 'Save and finish later',
        onTertiary: () {},
      ),
      surfaceSize: const Size(1200, 640),
    );

    expect(tester.takeException(), isNull);
  });
}
