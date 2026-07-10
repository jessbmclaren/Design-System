import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsProgressBar', () {
    testWidgets('renders a determinate bar at the given value', (tester) async {
      await pumpDs(tester, const DsProgressBar(value: 0.5));

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.5);
      expect(indicator.minHeight, 4);
    });

    testWidgets('clamps out-of-range values into 0..1', (tester) async {
      await pumpDs(tester, const DsProgressBar(value: 1.4));
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        1.0,
      );

      await pumpDs(tester, const DsProgressBar(value: -0.2));
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.0,
      );
    });

    testWidgets('honours a custom minHeight', (tester) async {
      await pumpDs(tester, const DsProgressBar(value: 0.5, minHeight: 8));

      expect(
        tester.getSize(find.byType(LinearProgressIndicator)).height,
        8,
      );
    });

    testWidgets('animated fill eases towards the value', (tester) async {
      await pumpDs(tester, const DsProgressBar(value: 0.8, animate: true));

      // Partway through the fill is still short of the target.
      await tester.pump(const Duration(milliseconds: 100));
      final midway = tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value!;
      expect(midway, lessThan(0.8));

      // After the motion window it has settled on the exact value.
      await tester.pump(const Duration(seconds: 1));
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.8,
      );
    });

    testWidgets('animated fill lands instantly under reduced motion', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: DsProgressBar(value: 0.75, animate: true),
        ),
      );
      await tester.pump();

      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.75,
      );
    });

    testWidgets('announces its semantic label', (tester) async {
      await pumpDs(
        tester,
        const DsProgressBar(value: 0.5, semanticLabel: 'Setup progress'),
      );

      expect(find.bySemanticsLabel('Setup progress'), findsOneWidget);
    });

    testWidgets('excludeSemantics drops the bar from the semantics tree', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsProgressBar(
          value: 0.5,
          semanticLabel: 'Setup progress',
          excludeSemantics: true,
        ),
      );

      expect(find.bySemanticsLabel('Setup progress'), findsNothing);
    });

    testWidgets('does not overflow at 320dp or on a wide desktop', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsProgressBar(value: 0.5),
        surfaceSize: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);

      await pumpDs(
        tester,
        const DsProgressBar(value: 0.5),
        surfaceSize: const Size(1200, 900),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
