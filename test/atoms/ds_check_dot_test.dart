import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  /// The dot's painted border, which carries the unmet tone.
  BoxDecoration decorationOf(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(DsCheckDot),
        matching: find.byType(DecoratedBox),
      ),
    );
    return box.decoration as BoxDecoration;
  }

  Color danger(WidgetTester tester) =>
      DsTokens.of(tester.element(find.byType(DsCheckDot))).colorDanger;
  Color border(WidgetTester tester) =>
      DsTokens.of(tester.element(find.byType(DsCheckDot))).colorBorder;

  group('DsCheckDot', () {
    testWidgets('a met dot carries the check glyph', (tester) async {
      await pumpDs(tester, const DsCheckDot(met: true));
      expect(find.byIcon(DsIcons.check), findsOneWidget);
    });

    testWidgets('an unmet dot is an empty ring, no glyph', (tester) async {
      await pumpDs(tester, const DsCheckDot(met: false));
      expect(find.byIcon(DsIcons.check), findsNothing);
    });

    testWidgets('an unmet dot rings in the border colour by default', (
      tester,
    ) async {
      await pumpDs(tester, const DsCheckDot(met: false));
      expect(decorationOf(tester).border!.top.color, border(tester));
    });

    testWidgets('the danger tone rings in the error colour', (tester) async {
      await pumpDs(
        tester,
        const DsCheckDot(met: false, unmetTone: DsCheckDotTone.danger),
      );
      expect(decorationOf(tester).border!.top.color, danger(tester));
    });

    testWidgets('the tone is ignored once the item is met', (tester) async {
      await pumpDs(
        tester,
        const DsCheckDot(met: true, unmetTone: DsCheckDotTone.danger),
      );
      // A satisfied item never reads as an error, whatever the tone says.
      expect(decorationOf(tester).border!.top.color, isNot(danger(tester)));
      expect(find.byIcon(DsIcons.check), findsOneWidget);
    });

    testWidgets('it is decorative, so the row around it does the speaking', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpDs(tester, const DsCheckDot(met: true));
      // It contributes no node of its own: no label, and no checked state that
      // would be spoken a second time alongside the row's.
      final node = tester.getSemantics(find.byType(DsCheckDot));
      expect(node.label, isEmpty);
      // The row around it owns the checked state, not the dot.
      expect(node, isSemantics(hasCheckedState: false));
      handle.dispose();
    });

    testWidgets('it honours a custom size and scales its glyph with it', (
      tester,
    ) async {
      await pumpDs(tester, const DsCheckDot(met: true, size: 36));
      expect(tester.getSize(find.byType(DsCheckDot)).width, 36);
      expect(tester.widget<Icon>(find.byIcon(DsIcons.check)).size, 24);
    });

    testWidgets('it renders at 320dp and stretched wide', (tester) async {
      await pumpDs(
        tester,
        const DsCheckDot(met: false),
        surfaceSize: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
      await pumpDs(
        tester,
        const DsCheckDot(met: true),
        surfaceSize: const Size(1440, 900),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('it renders in dark and under a skin', (tester) async {
      await pumpDs(tester, const DsCheckDot(met: true), theme: DsTheme.dark());
      expect(find.byIcon(DsIcons.check), findsOneWidget);
      await pumpDs(
        tester,
        const DsCheckDot(met: true),
        theme: DsTheme.light(tokens: DsSkins.engenLight()),
      );
      expect(find.byIcon(DsIcons.check), findsOneWidget);
    });
  });
}
