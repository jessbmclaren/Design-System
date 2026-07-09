import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const steps = [
    DsStep(label: 'Account'),
    DsStep(label: 'Details'),
    DsStep(label: 'Review'),
  ];

  group('DsProgressStepper', () {
    testWidgets('renders all step labels in the full layout', (tester) async {
      await pumpDs(
        tester,
        const DsProgressStepper(steps: steps, currentIndex: 1),
        surfaceSize: const Size(1000, 800),
      );
      await tester.pump();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
    });

    testWidgets('reflects completed vs current vs upcoming steps', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsProgressStepper(steps: steps, currentIndex: 1),
        surfaceSize: const Size(1000, 800),
      );
      await tester.pump();

      // Completed steps (index < currentIndex) show a check mark.
      expect(find.byIcon(Icons.check), findsOneWidget);
      // Current step (index 1) shows its number "2".
      expect(find.text('2'), findsOneWidget);
      // Upcoming step (index 2) shows its number "3".
      expect(find.text('3'), findsOneWidget);
      // The completed first step shows no "1" number (it is a check).
      expect(find.text('1'), findsNothing);
    });

    testWidgets('marks every step complete when currentIndex == length', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsProgressStepper(steps: steps, currentIndex: 3),
        surfaceSize: const Size(1000, 800),
      );
      await tester.pump();

      expect(find.byIcon(Icons.check), findsNWidgets(3));
    });

    testWidgets('collapses to a compact summary on narrow widths', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsProgressStepper(steps: steps, currentIndex: 1),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      // Compact form shows a "Step X of N" summary and a progress bar.
      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      // The current step's label is still shown for context.
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        const DsProgressStepper(steps: steps, currentIndex: 0),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
