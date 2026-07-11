import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

String _plain(WidgetTester tester) => tester
    .widgetList<RichText>(find.byType(RichText))
    .map((r) => r.text.toPlainText())
    .firstWhere((t) => t.contains('acme'));

/// The styles of the mark's leaf spans, in order.
List<TextStyle?> _spanStyles(WidgetTester tester) {
  final rich = tester
      .widgetList<RichText>(find.byType(RichText))
      .firstWhere((r) => r.text.toPlainText().contains('acme'));
  final styles = <TextStyle?>[];
  rich.text.visitChildren((span) {
    if (span is TextSpan && span.text != null) styles.add(span.style);
    return true;
  });
  return styles;
}

/// The colours of the mark's leaf spans, in order.
List<Color?> _spanColors(WidgetTester tester) =>
    _spanStyles(tester).map((style) => style?.color).toList();

void main() {
  group('DsWordmark', () {
    testWidgets('renders the primary and accent parts as one mark',
        (tester) async {
      await pumpDs(tester, const DsWordmark(primary: 'acme', accent: 'id'));
      expect(_plain(tester), 'acmeid');
    });

    testWidgets('renders without an accent', (tester) async {
      await pumpDs(tester, const DsWordmark(primary: 'acme'));
      expect(_plain(tester), 'acme');
    });

    testWidgets('announces the whole mark as a single label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(tester, const DsWordmark(primary: 'acme', accent: 'id'));

      // One node, one name: the two spans never read as separate fragments.
      expect(
        tester.getSemantics(find.byType(DsWordmark)),
        isSemantics(label: 'acmeid'),
      );
      expect(find.bySemanticsLabel('acmeid'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('defaults both spans to the themed text colour',
        (tester) async {
      await pumpDs(tester, const DsWordmark(primary: 'acme', accent: 'id'));

      final tokens = DsTokens.of(tester.element(find.byType(DsWordmark)));
      expect(_spanColors(tester), everyElement(tokens.colorText));
    });

    testWidgets('reads its type metrics from the wordmark tokens',
        (tester) async {
      await pumpDs(
        tester,
        const DsWordmark(primary: 'acme', accent: 'id'),
        theme: DsTheme.light(
          tokens: DsTokens.light().copyWith(
            wordmarkFontSize: 30,
            wordmarkLetterSpacing: 1.5,
            wordmarkHeight: 1.2,
          ),
        ),
      );

      for (final style in _spanStyles(tester)) {
        expect(style?.fontSize, 30);
        expect(style?.letterSpacing, 1.5);
        expect(style?.height, 1.2);
      }
    });

    testWidgets('an explicit fontSize overrides the token', (tester) async {
      await pumpDs(
        tester,
        const DsWordmark(primary: 'acme', accent: 'id', fontSize: 28),
        theme: DsTheme.light(
          tokens: DsTokens.light().copyWith(wordmarkFontSize: 30),
        ),
      );

      for (final style in _spanStyles(tester)) {
        expect(style?.fontSize, 28);
      }
    });

    testWidgets('an explicit colour overrides both spans', (tester) async {
      await pumpDs(
        tester,
        const DsWordmark(
          primary: 'acme',
          accent: 'id',
          color: Color(0xFF336699),
        ),
      );

      expect(_spanColors(tester), everyElement(const Color(0xFF336699)));
    });
  });
}
