import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders its label, value and caption as one announcement', (
    tester,
  ) async {
    await pumpDs(
      tester,
      const DsStatTile(label: 'Open', value: '96', caption: 'up 4'),
    );

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('96'), findsOneWidget);
    expect(find.bySemanticsLabel('Open, 96, up 4'), findsOneWidget);
  });

  testWidgets('a tile with onTap is a selectable button', (tester) async {
    String? chosen;
    await pumpDs(
      tester,
      Row(
        children: <Widget>[
          Expanded(
            child: DsStatTile(
              label: 'Total',
              value: '128',
              onTap: () => chosen = 'total',
            ),
          ),
          Expanded(
            child: DsStatTile(
              label: 'Open',
              value: '96',
              selected: true,
              onTap: () => chosen = 'open',
            ),
          ),
        ],
      ),
      surfaceSize: const Size(700, 400),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Open, 96')),
      matchesSemantics(
        label: 'Open, 96',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Total, 128'));
    await tester.pump();
    expect(chosen, 'total');
  });

  testWidgets('a static tile is not a button', (tester) async {
    await pumpDs(tester, const DsStatTile(label: 'Open', value: '96'));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Open, 96')),
      matchesSemantics(label: 'Open, 96'),
    );
  });

  testWidgets('holds a long label and 320dp without overflow, every theme', (
    tester,
  ) async {
    for (final ThemeData theme in <ThemeData>[
      DsTheme.light(),
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
    ]) {
      await pumpDs(
        tester,
        SizedBox(
          width: 140,
          child: DsStatTile(
            label: 'A remarkably long segment name',
            value: '1,284,000',
            caption: 'compared with last month',
            selected: true,
            onTap: () {},
          ),
        ),
        surfaceSize: const Size(320, 600),
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('survives 1.3x text scale at 320dp', (tester) async {
    await pumpDs(
      tester,
      const SizedBox(
        width: 150,
        child: DsStatTile(label: 'Open', value: '96', caption: 'up 4'),
      ),
      surfaceSize: const Size(320, 600),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });
}
