import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const _steps = [
  DsTourStep(
    title: 'Import your data',
    body: 'Bring everything across in one spreadsheet.',
    illustration: Text('Decorative art'),
  ),
  DsTourStep(
    title: 'Organise your records',
    body: 'Group related records so the right people see them.',
  ),
  DsTourStep(
    title: 'You are ready',
    body: 'Everything is in place. Start with your first record.',
  ),
];

void main() {
  group('DsTourCard', () {
    testWidgets('renders the current step and hides Back on the first', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 0,
          onStepChanged: (_) {},
        ),
      );

      expect(find.text('Import your data'), findsOneWidget);
      expect(
        find.text('Bring everything across in one spreadsheet.'),
        findsOneWidget,
      );
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Back'), findsNothing);
    });

    testWidgets('Next and Back report the new index to the caller', (
      tester,
    ) async {
      final changes = <int>[];
      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 1,
          onStepChanged: changes.add,
        ),
      );

      await tester.tap(find.text('Next'));
      expect(changes, [2]);

      await tester.tap(find.text('Back'));
      expect(changes, [2, 0]);
    });

    testWidgets('the last step shows the done label and fires onDone', (
      tester,
    ) async {
      var done = 0;
      final changes = <int>[];
      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 2,
          onStepChanged: changes.add,
          doneLabel: 'Get started',
          onDone: () => done++,
        ),
      );

      expect(find.text('Next'), findsNothing);
      await tester.tap(find.text('Get started'));
      expect(done, 1);
      expect(changes, isEmpty);
    });

    testWidgets('the skip control fires onSkip', (tester) async {
      var skipped = 0;
      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 0,
          onStepChanged: (_) {},
          onSkip: () => skipped++,
        ),
      );

      await tester.tap(find.text('Skip tour'));
      expect(skipped, 1);
    });

    testWidgets('no skip control renders without onSkip', (tester) async {
      await pumpDs(
        tester,
        DsTourCard(steps: _steps, currentStep: 0, onStepChanged: (_) {}),
      );

      expect(find.text('Skip tour'), findsNothing);
    });

    testWidgets('arrow keys navigate while focus is inside the card', (
      tester,
    ) async {
      final changes = <int>[];
      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 1,
          onStepChanged: changes.add,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(changes, [2]);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(changes, [2, 0]);
    });

    testWidgets('arrow keys stop at both ends of the tour', (tester) async {
      final changes = <int>[];
      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 0,
          onStepChanged: changes.add,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(changes, isEmpty);

      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 2,
          onStepChanged: changes.add,
          onDone: () {},
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(changes, isEmpty);
    });

    testWidgets('a null onStepChanged disables every navigation affordance', (
      tester,
    ) async {
      var skipped = 0;
      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 1,
          onStepChanged: null,
          onSkip: () => skipped++,
        ),
      );

      FilledButton buttonFor(String label) => tester.widget<FilledButton>(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(FilledButton),
            ),
          );
      expect(buttonFor('Next').onPressed, isNull);
      expect(buttonFor('Back').onPressed, isNull);

      // Arrow keys are not consumed either; nothing changes.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(find.text('Organise your records'), findsOneWidget);

      // Skip stays live: leaving the tour must not depend on navigation.
      await tester.tap(find.text('Skip tour'));
      expect(skipped, 1);
    });

    testWidgets('a null onDone disables the final action', (tester) async {
      await pumpDs(
        tester,
        DsTourCard(steps: _steps, currentStep: 2, onStepChanged: (_) {}),
      );

      final button = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Done'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('the step transition runs, then settles on the new copy', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsTourCard(steps: _steps, currentStep: 0, onStepChanged: (_) {}),
      );
      await pumpDs(
        tester,
        DsTourCard(steps: _steps, currentStep: 1, onStepChanged: (_) {}),
      );

      // Mid-transition both steps are on screen, the old one fading out.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Import your data'), findsOneWidget);
      expect(find.text('Organise your records'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Import your data'), findsNothing);
      expect(find.text('Organise your records'), findsOneWidget);
    });

    testWidgets('reduced motion swaps steps instantly with nothing ticking', (
      tester,
    ) async {
      Widget reduced(int step) => MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: DsTourCard(
              steps: _steps,
              currentStep: step,
              onStepChanged: (_) {},
            ),
          );

      await pumpDs(tester, reduced(0));
      await pumpDs(tester, reduced(1));
      await tester.pump();

      expect(find.text('Import your data'), findsNothing);
      expect(find.text('Organise your records'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('swiping navigates only when enableSwipe is set', (
      tester,
    ) async {
      final changes = <int>[];
      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 1,
          onStepChanged: changes.add,
        ),
      );

      // Off by default: a swipe moves nothing.
      await tester.fling(find.byType(DsTourCard), const Offset(-200, 0), 1000);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);

      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 1,
          onStepChanged: changes.add,
          enableSwipe: true,
        ),
      );

      await tester.fling(find.byType(DsTourCard), const Offset(-200, 0), 1000);
      await tester.pumpAndSettle();
      expect(changes, [2]);

      await tester.fling(find.byType(DsTourCard), const Offset(200, 0), 1000);
      await tester.pumpAndSettle();
      expect(changes, [2, 0]);
    });

    testWidgets('progress is announced as step x of y', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsTourCard(steps: _steps, currentStep: 0, onStepChanged: (_) {}),
      );

      expect(find.bySemanticsLabel('Step 1 of 3'), findsOneWidget);

      await pumpDs(
        tester,
        DsTourCard(steps: _steps, currentStep: 1, onStepChanged: (_) {}),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Step 2 of 3'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('an unlabelled illustration is decorative to a screen reader', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsTourCard(steps: _steps, currentStep: 0, onStepChanged: (_) {}),
      );

      // The artwork renders but exposes no semantics node.
      expect(find.text('Decorative art'), findsOneWidget);
      expect(find.bySemanticsLabel('Decorative art'), findsNothing);
      handle.dispose();
    });

    testWidgets('a labelled illustration is announced as an image', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsTourCard(
          steps: const [
            DsTourStep(
              title: 'Import your data',
              body: 'Bring everything across in one spreadsheet.',
              illustration: Icon(DsIcons.upload),
              illustrationLabel: 'A spreadsheet being imported',
            ),
          ],
          currentStep: 0,
          onStepChanged: null,
        ),
      );

      expect(
        find.bySemanticsLabel('A spreadsheet being imported'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('the footer stacks below 440dp and holds one row when wide', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 1,
          onStepChanged: (_) {},
        ),
        surfaceSize: const Size(360, 900),
      );

      final bar = find.byType(DsProgressBar);
      final next = find.ancestor(
        of: find.text('Next'),
        matching: find.byType(FilledButton),
      );

      // Compact: the bar sits above a full-width Next.
      expect(
        tester.getBottomLeft(bar).dy,
        lessThan(tester.getTopLeft(next).dy),
      );
      expect(tester.getSize(next).width, greaterThan(250));

      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 1,
          onStepChanged: (_) {},
        ),
        surfaceSize: const Size(1000, 900),
      );

      // Wide: the bar and the actions share a row.
      expect(
        tester.getCenter(find.byType(DsProgressBar)).dy,
        moreOrLessEquals(
          tester
              .getCenter(
                find.ancestor(
                  of: find.text('Next'),
                  matching: find.byType(FilledButton),
                ),
              )
              .dy,
          epsilon: 12,
        ),
      );
    });

    testWidgets('does not overflow at 320dp or stretched wide', (tester) async {
      const wordy = DsTourStep(
        title: 'A rather long step title that has to wrap on a small phone',
        body:
            'A long supporting sentence that keeps going for a while so the '
            'card has to wrap it over several lines without overflowing.',
        illustration: FlutterLogo(size: 220),
      );

      await pumpDs(
        tester,
        DsTourCard(
          steps: const [wordy, ..._steps],
          currentStep: 0,
          onStepChanged: (_) {},
          onSkip: () {},
          doneLabel: 'Add your first record to get going',
        ),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      await pumpDs(
        tester,
        DsTourCard(
          steps: const [wordy, ..._steps],
          currentStep: 3,
          onStepChanged: (_) {},
          onSkip: () {},
          doneLabel: 'Add your first record to get going',
        ),
        surfaceSize: const Size(1400, 900),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the skip control meets the 48dp touch minimum', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsTourCard(
          steps: _steps,
          currentStep: 0,
          onStepChanged: (_) {},
          onSkip: () {},
        ),
      );

      final skip = tester.getSize(
        find.ancestor(
          of: find.text('Skip tour'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(skip.height, greaterThanOrEqualTo(48));
    });

    testWidgets('an out-of-range currentStep clamps instead of throwing', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsTourCard(steps: _steps, currentStep: 9, onStepChanged: (_) {}),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('You are ready'), findsOneWidget);
    });

    testWidgets('renders in dark and skinned themes', (tester) async {
      await pumpDs(
        tester,
        DsTourCard(steps: _steps, currentStep: 0, onStepChanged: (_) {}),
        theme: DsTheme.dark(),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Import your data'), findsOneWidget);

      await pumpDs(
        tester,
        DsTourCard(steps: _steps, currentStep: 0, onStepChanged: (_) {}),
        theme: DsTheme.light(tokens: DsSkins.engenLight()),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(DsProgressBar), findsOneWidget);
    });
  });
}
