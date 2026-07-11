import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders the given glyph', (WidgetTester tester) async {
    await pumpDs(tester, const DsIcon(icon: Icons.check_circle_outline));

    final Icon icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.check_circle_outline);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('applies the requested size and defaults to md',
      (WidgetTester tester) async {
    await pumpDs(
      tester,
      const DsIcon(icon: Icons.warning_amber, size: DsIconSize.xl),
    );
    expect(tester.widget<Icon>(find.byType(Icon)).size, DsIconSize.xl);

    await pumpDs(tester, const DsIcon(icon: Icons.warning_amber));
    expect(tester.widget<Icon>(find.byType(Icon)).size, DsIconSize.md);
  });

  testWidgets('uses the explicit colour when provided',
      (WidgetTester tester) async {
    await pumpDs(
      tester,
      const DsIcon(icon: Icons.star, color: Color(0xFF00FF00)),
    );

    expect(tester.widget<Icon>(find.byType(Icon)).color, const Color(0xFF00FF00));
  });

  testWidgets('falls back to exactly the themed text colour when none is '
      'given', (WidgetTester tester) async {
    await pumpDs(tester, const DsIcon(icon: Icons.info_outline));

    final tokens = DsTokens.of(tester.element(find.byType(DsIcon)));
    expect(tester.widget<Icon>(find.byType(Icon)).color, tokens.colorText);
  });

  testWidgets('a decorative icon is skipped by assistive technology',
      (WidgetTester tester) async {
    final handle = tester.ensureSemantics();
    await pumpDs(tester, const DsIcon(icon: Icons.check_circle_outline));

    // No semanticLabel: the glyph excludes itself, so nothing is announced.
    expect(
      find.descendant(
        of: find.byType(DsIcon),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
    handle.dispose();
  });

  testWidgets('exposes the semantic label to assistive technology',
      (WidgetTester tester) async {
    await pumpDs(
      tester,
      const DsIcon(icon: Icons.warning_amber, semanticLabel: 'Warning'),
    );

    expect(tester.widget<Icon>(find.byType(Icon)).semanticLabel, 'Warning');
    expect(find.bySemanticsLabel('Warning'), findsOneWidget);
  });

  testWidgets('renders without overflow from small phone to large desktop',
      (WidgetTester tester) async {
    await pumpDs(
      tester,
      const DsIcon(icon: Icons.settings),
      surfaceSize: const Size(320, 900),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await pumpDs(
      tester,
      const DsIcon(icon: Icons.settings),
      surfaceSize: const Size(1200, 900),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
