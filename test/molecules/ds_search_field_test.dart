import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders the hint and the search glyph', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      DsSearchField(hintText: 'Search accounts', onChanged: (_) {}),
    );

    expect(find.text('Search accounts'), findsOneWidget);
    expect(find.byIcon(DsIcons.search), findsOneWidget);
    expect(find.byIcon(DsIcons.close), findsNothing);
  });

  testWidgets('typing reports the query and reveals the clear affordance', (
    WidgetTester tester,
  ) async {
    final List<String> changes = <String>[];
    await pumpDs(
      tester,
      DsSearchField(onChanged: changes.add),
    );

    await tester.enterText(find.byType(TextField), 'fuel');
    await tester.pump();

    expect(changes, <String>['fuel']);
    expect(find.byIcon(DsIcons.close), findsOneWidget);
  });

  testWidgets('clearing empties the field and fires both callbacks', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller =
        TextEditingController(text: 'diesel');
    addTearDown(controller.dispose);
    final List<String> changes = <String>[];
    bool cleared = false;

    await pumpDs(
      tester,
      DsSearchField(
        controller: controller,
        onChanged: changes.add,
        onClear: () => cleared = true,
      ),
    );

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(changes, <String>['']);
    expect(cleared, isTrue);
    expect(find.byIcon(DsIcons.close), findsNothing);
  });

  testWidgets('pending shows a spinner instead of the clear affordance', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller =
        TextEditingController(text: 'diesel');
    addTearDown(controller.dispose);

    await pumpDs(
      tester,
      DsSearchField(
        controller: controller,
        onChanged: (_) {},
        pending: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(DsSpinner), findsOneWidget);
    expect(find.byIcon(DsIcons.close), findsNothing);
  });

  testWidgets('a null onChanged disables the field', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller =
        TextEditingController(text: 'diesel');
    addTearDown(controller.dispose);

    await pumpDs(
      tester,
      DsSearchField(controller: controller, onChanged: null),
    );

    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
    // A disabled field offers no clear affordance.
    expect(find.byIcon(DsIcons.close), findsNothing);
  });

  testWidgets('does not overflow at 320dp or wide', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      DsSearchField(
        hintText: 'Search a very long collection of records',
        onChanged: (_) {},
      ),
      surfaceSize: const Size(320, 600),
    );
    expect(tester.takeException(), isNull);

    await pumpDs(
      tester,
      DsSearchField(hintText: 'Search', onChanged: (_) {}),
      surfaceSize: const Size(1920, 600),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark and under a skin', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      DsSearchField(onChanged: (_) {}),
      theme: DsTheme.dark(),
    );
    expect(find.byIcon(DsIcons.search), findsOneWidget);

    await pumpDs(
      tester,
      DsSearchField(onChanged: (_) {}),
      theme: DsTheme.light(tokens: DsSkins.engenLight()),
    );
    expect(find.byIcon(DsIcons.search), findsOneWidget);
  });
}
