import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders the label, glyph and trailing widgets', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      const DsStatusBar(
        icon: DsIcons.terminal,
        label: 'Developers',
        trailing: <Widget>[Text('v1.0')],
      ),
    );

    expect(find.text('Developers'), findsOneWidget);
    expect(find.byIcon(DsIcons.terminal), findsOneWidget);
    expect(find.text('v1.0'), findsOneWidget);
  });

  testWidgets('transparent drops the fill and hairline', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      const DsStatusBar(label: 'Developers', transparent: true),
    );

    final Container container =
        tester.widget<Container>(find.byType(Container).first);
    expect(container.decoration, isNull);
  });

  testWidgets('does not overflow at 320dp with a long label', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      const DsStatusBar(
        icon: DsIcons.terminal,
        label: 'A very long environment description that cannot fit',
        trailing: <Widget>[Text('build 20260720')],
      ),
      surfaceSize: const Size(320, 200),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark and under a skin', (
    WidgetTester tester,
  ) async {
    for (final ThemeData theme in <ThemeData>[
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
    ]) {
      await pumpDs(
        tester,
        const DsStatusBar(label: 'Developers'),
        theme: theme,
      );
      expect(find.text('Developers'), findsOneWidget);
    }
  });
}
