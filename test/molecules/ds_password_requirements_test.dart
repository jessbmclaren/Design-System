import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const capital = 'One uppercase letter';

  Color labelColour(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style!.color!;
  Color danger(WidgetTester tester) =>
      DsTokens.of(tester.element(find.text(capital))).colorDanger;

  group('DsPasswordRequirements', () {
    testWidgets('it renders a row per standard rule', (tester) async {
      await pumpDs(tester, const DsPasswordRequirements(value: ''));
      for (final rule in dsPasswordRules('')) {
        expect(find.text(rule.label), findsOneWidget);
      }
    });

    testWidgets('rows tick as the value satisfies them', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(tester, const DsPasswordRequirements(value: '7xQ!ropVma2z'));
      for (final rule in dsPasswordRules('7xQ!ropVma2z')) {
        expect(
          tester.getSemantics(find.text(rule.label)),
          isSemantics(isChecked: true, hasCheckedState: true),
          reason: '"${rule.label}" should be ticked',
        );
      }
      handle.dispose();
    });

    testWidgets('an unmet row stays neutral while typing, never red', (
      tester,
    ) async {
      // 20 characters, no capital: the one rule deliberately unmet.
      await pumpDs(
        tester,
        const DsPasswordRequirements(value: 'abcdefgh1234567890!!'),
      );
      expect(labelColour(tester, capital), isNot(danger(tester)));
    });

    testWidgets('an unmet row turns red once a submit has been refused', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsPasswordRequirements(
          value: 'abcdefgh1234567890!!',
          attempted: true,
        ),
      );
      expect(labelColour(tester, capital), danger(tester));
    });

    testWidgets('a met row never turns red, even after a refused submit', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsPasswordRequirements(
          value: 'abcdefgh1234567890!!',
          attempted: true,
        ),
      );
      expect(
        labelColour(tester, 'At least 8 characters'),
        isNot(danger(tester)),
      );
    });

    testWidgets('caller rules replace the standard set', (tester) async {
      await pumpDs(
        tester,
        const DsPasswordRequirements(
          value: 'anything',
          rules: <DsPasswordRule>[
            DsPasswordRule('An upper-case and a lower-case letter', false),
          ],
        ),
      );
      expect(
        find.text('An upper-case and a lower-case letter'),
        findsOneWidget,
      );
      expect(find.text(capital), findsNothing);
    });

    testWidgets('extra rules append after the standard set', (tester) async {
      await pumpDs(
        tester,
        const DsPasswordRequirements(
          value: '7xQ!ropVma2z',
          extraRules: <DsPasswordRule>[
            DsPasswordRule('Not found in known data breaches', true),
          ],
        ),
      );
      final rows = tester.widgetList<DsPasswordRequirementRow>(
        find.byType(DsPasswordRequirementRow),
      );
      expect(rows.length, dsPasswordRules('').length + 1);
      expect(rows.last.rule.label, 'Not found in known data breaches');
    });

    testWidgets('the list is one live region, not one per row', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(tester, const DsPasswordRequirements(value: 'abc'));
      final live = tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byType(DsPasswordRequirements),
              matching: find.byType(Semantics),
            ),
          )
          .where((s) => s.properties.liveRegion ?? false);
      // Five rows announcing themselves on every keystroke would talk over
      // each other; the set is announced once.
      expect(live.length, 1);
      handle.dispose();
    });

    testWidgets('itemWidth lays the rows out in a wrapping grid', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const SizedBox(
          width: 400,
          child: DsPasswordRequirements(value: 'abc', itemWidth: 180),
        ),
      );
      expect(find.byType(Wrap), findsOneWidget);
      await pumpDs(tester, const DsPasswordRequirements(value: 'abc'));
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('it renders without overflow at 320dp and stretched wide', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsPasswordRequirements(value: 'abc', attempted: true),
        surfaceSize: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
      await pumpDs(
        tester,
        const DsPasswordRequirements(value: 'abc'),
        surfaceSize: const Size(1440, 900),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('it holds at a large text scale', (tester) async {
      await pumpDs(
        tester,
        const DsPasswordRequirements(value: 'abc'),
        surfaceSize: const Size(320, 900),
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('it renders in dark and under a skin', (tester) async {
      await pumpDs(
        tester,
        const DsPasswordRequirements(value: 'abc'),
        theme: DsTheme.dark(),
      );
      expect(find.text(capital), findsOneWidget);
      await pumpDs(
        tester,
        const DsPasswordRequirements(value: 'abc'),
        theme: DsTheme.light(tokens: DsSkins.engenLight()),
      );
      expect(find.text(capital), findsOneWidget);
    });
  });
}
