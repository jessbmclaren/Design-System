import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsDivider', () {
    testWidgets('renders a horizontal rule by default', (tester) async {
      await pumpDs(tester, const DsDivider());

      expect(find.byType(DsDivider), findsOneWidget);

      final SizedBox box = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(Semantics),
          matching: find.byType(SizedBox),
        ).first,
      );
      // A horizontal divider reserves a fixed height equal to its thickness.
      expect(box.height, 1);
      expect(box.width, isNull);
    });

    testWidgets('applies a custom color override', (tester) async {
      const Color custom = Color(0xFF123456);
      await pumpDs(tester, const DsDivider(color: custom));

      final DecoratedBox decorated = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final BoxDecoration decoration = decorated.decoration as BoxDecoration;
      expect(decoration.color, custom);
    });

    testWidgets('vertical axis reserves a fixed width', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 40,
          child: DsDivider(axis: DsDividerAxis.vertical, thickness: 2),
        ),
      );

      // A vertical divider reserves a fixed width equal to its thickness.
      expect(tester.getSize(find.byType(DsDivider)).width, 2);
    });

    testWidgets('is hidden from assistive technologies', (tester) async {
      await pumpDs(tester, const DsDivider());

      // The divider's own Semantics node excludes its (decorative) subtree.
      final Semantics semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(DsDivider),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.excludeSemantics, isTrue);
    });

    testWidgets('renders without overflow on a small phone', (tester) async {
      await pumpDs(
        tester,
        const DsDivider(indent: 8, endIndent: 8, length: 120),
        surfaceSize: const Size(320, 900),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a large desktop', (tester) async {
      await pumpDs(
        tester,
        const DsDivider(indent: 8, endIndent: 8, length: 120),
        surfaceSize: const Size(1200, 900),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
