import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders its title and subtitle as one announcement', (
    tester,
  ) async {
    await pumpDs(
      tester,
      const DsActionTile(
        icon: DsIcons.fuel,
        title: 'I want to fuel',
        subtitle: 'Find a station',
      ),
    );

    expect(find.text('I want to fuel'), findsOneWidget);
    expect(find.text('Find a station'), findsOneWidget);
    expect(
      find.bySemanticsLabel('I want to fuel, Find a station'),
      findsOneWidget,
    );
  });

  testWidgets('a tile with onTap is a button and fires', (tester) async {
    String? chosen;
    await pumpDs(
      tester,
      Row(
        children: <Widget>[
          Expanded(
            child: DsActionTile(
              icon: DsIcons.fuel,
              title: 'Fuel',
              subtitle: 'Find a station',
              onTap: () => chosen = 'fuel',
            ),
          ),
          Expanded(
            child: DsActionTile(
              icon: DsIcons.reward,
              title: 'Rewards',
              onTap: () => chosen = 'rewards',
            ),
          ),
        ],
      ),
      surfaceSize: const Size(700, 400),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Rewards')),
      matchesSemantics(
        label: 'Rewards',
        isButton: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Fuel, Find a station'));
    await tester.pump();
    expect(chosen, 'fuel');
  });

  testWidgets('a tile without onTap is static and not focusable', (
    tester,
  ) async {
    await pumpDs(
      tester,
      const DsActionTile(icon: DsIcons.fuel, title: 'Fuel'),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Fuel')),
      matchesSemantics(label: 'Fuel'),
    );
  });

  testWidgets('the leading mark is hidden from assistive tech', (tester) async {
    // The title already names the job, so a screen reader must not hear the
    // glyph as a second, redundant node.
    await pumpDs(
      tester,
      const DsActionTile(
        icon: DsIcons.fuel,
        title: 'Fuel',
        subtitle: 'Find a station',
      ),
    );
    final SemanticsNode node =
        tester.getSemantics(find.bySemanticsLabel('Fuel, Find a station'));
    int children = 0;
    node.visitChildren((SemanticsNode _) {
      children++;
      return true;
    });
    expect(children, 0);
  });

  testWidgets('holds long content at 140dp and a wide pane, every theme', (
    tester,
  ) async {
    for (final ThemeData theme in <ThemeData>[
      DsTheme.light(),
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
      DsTheme.light(tokens: DsSkins.engenMobileLight()),
    ]) {
      for (final double width in <double>[140, 600]) {
        await pumpDs(
          tester,
          SizedBox(
            width: width,
            child: DsActionTile(
              icon: DsIcons.fuel,
              title: 'A remarkably long shortcut name that will not fit',
              subtitle: 'And a supporting line that is also far too long',
              onTap: () {},
            ),
          ),
          theme: theme,
          surfaceSize: const Size(320, 480),
        );
        expect(tester.takeException(), isNull);
      }
    }
  });
}
