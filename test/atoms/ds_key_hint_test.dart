import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders one cap per key', (tester) async {
    await pumpDs(tester, const DsKeyHint(keys: <String>['⌘', '↵']));
    expect(find.text('⌘'), findsOneWidget);
    expect(find.text('↵'), findsOneWidget);
  });

  testWidgets('is hidden from assistive technology by default', (
    tester,
  ) async {
    await pumpDs(tester, const DsKeyHint(keys: <String>['N']));
    expect(find.bySemanticsLabel('N'), findsNothing);
  });

  testWidgets('announces itself when it stands alone', (tester) async {
    await pumpDs(
      tester,
      const DsKeyHint(keys: <String>['N'], semanticLabel: 'Shortcut N'),
    );
    expect(find.bySemanticsLabel('Shortcut N'), findsOneWidget);
  });

  testWidgets('a button hint rides the label without stealing the name', (
    tester,
  ) async {
    await pumpDs(
      tester,
      DsButton(
        label: 'New record',
        onPressed: () {},
        keyHint: const <String>['N'],
      ),
    );

    expect(find.text('N'), findsOneWidget);
    // The button still announces only its own label.
    expect(find.bySemanticsLabel('New record'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('holds every theme at 320dp', (tester) async {
    for (final ThemeData theme in <ThemeData>[
      DsTheme.light(),
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
    ]) {
      await pumpDs(
        tester,
        DsButton(
          label: 'New record',
          onPressed: () {},
          keyHint: const <String>['⌘', '↵'],
        ),
        surfaceSize: const Size(320, 400),
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
