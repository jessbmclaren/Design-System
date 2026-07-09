import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsSparkline', () {
    testWidgets('renders a CustomPaint for its values', (tester) async {
      await pumpDs(tester, const DsSparkline(values: [3, 5, 2, 8, 6, 9, 7]));

      expect(find.byType(DsSparkline), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DsSparkline),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('exposes a Sparkline semantics label', (tester) async {
      await pumpDs(tester, const DsSparkline(values: [1, 2, 3]));

      expect(find.bySemanticsLabel('Sparkline'), findsOneWidget);
    });

    testWidgets('sizes itself to the given width and height', (tester) async {
      await pumpDs(
        tester,
        const DsSparkline(values: [1, 4, 2, 6], width: 120, height: 40),
      );

      final box = tester.getSize(find.byType(DsSparkline));
      expect(box.width, 120);
      expect(box.height, 40);
    });

    testWidgets('renders empty, single and filled variants safely',
        (tester) async {
      await pumpDs(tester, const DsSparkline(values: []));
      expect(tester.takeException(), isNull);

      await pumpDs(tester, const DsSparkline(values: [5]));
      expect(tester.takeException(), isNull);

      await pumpDs(
        tester,
        const DsSparkline(
          values: [2, 8, 3, 9],
          filled: true,
          showEndDot: false,
          color: Colors.teal,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a small phone', (tester) async {
      await pumpDs(
        tester,
        const DsSparkline(values: [3, 5, 2, 8, 6, 9, 7]),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a large desktop', (tester) async {
      await pumpDs(
        tester,
        const DsSparkline(values: [3, 5, 2, 8, 6, 9, 7]),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
