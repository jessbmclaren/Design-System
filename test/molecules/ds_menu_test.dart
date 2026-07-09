import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders the trigger and hides items until opened', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      const DsMenu(
        trigger: Text('Open'),
        items: <DsMenuItem>[
          DsMenuItem(label: 'Edit'),
          DsMenuItem(label: 'Delete'),
        ],
      ),
    );

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('tapping the trigger opens the menu and reveals items', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      const DsMenu(
        trigger: Text('Open'),
        items: <DsMenuItem>[
          DsMenuItem(label: 'Edit', icon: Icons.edit_outlined),
          DsMenuItem(label: 'Delete', icon: Icons.delete_outline),
        ],
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('choosing a row fires its onSelected callback', (
    WidgetTester tester,
  ) async {
    String? chosen;
    await pumpDs(
      tester,
      DsMenu(
        trigger: const Text('Open'),
        items: <DsMenuItem>[
          DsMenuItem(label: 'Edit', onSelected: () => chosen = 'Edit'),
          DsMenuItem(label: 'Delete', onSelected: () => chosen = 'Delete'),
        ],
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    await tester.tap(find.text('Edit'));
    await tester.pump();

    expect(chosen, 'Edit');
  });

  testWidgets('a disabled item cannot be chosen', (WidgetTester tester) async {
    bool tapped = false;
    await pumpDs(
      tester,
      DsMenu(
        trigger: const Text('Open'),
        items: <DsMenuItem>[
          DsMenuItem(
            label: 'Unavailable',
            enabled: false,
            onSelected: () => tapped = true,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    final MenuItemButton button = tester.widget<MenuItemButton>(
      find.widgetWithText(MenuItemButton, 'Unavailable'),
    );
    expect(button.onPressed, isNull);
    expect(tapped, isFalse);
  });

  testWidgets('renders without overflow on a small phone', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      const DsMenu(
        trigger: Text('Open'),
        items: <DsMenuItem>[
          DsMenuItem(label: 'Edit', icon: Icons.edit_outlined),
          DsMenuItem(
            label: 'Delete',
            icon: Icons.delete_outline,
            destructive: true,
          ),
        ],
      ),
      surfaceSize: const Size(320, 900),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a large desktop', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      const DsMenu(
        trigger: Text('Open'),
        items: <DsMenuItem>[
          DsMenuItem(label: 'Edit', icon: Icons.edit_outlined),
          DsMenuItem(
            label: 'Delete',
            icon: Icons.delete_outline,
            destructive: true,
          ),
        ],
      ),
      surfaceSize: const Size(1200, 900),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
