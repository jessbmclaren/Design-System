import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Pumps a button that presents a [DsMenuSheet] with [items] when tapped.
Future<void> pumpSheetHost(
  WidgetTester tester,
  List<DsMenuSheetItem> items, {
  Size? surfaceSize,
  ThemeData? theme,
}) async {
  await pumpDs(
    tester,
    Builder(
      builder: (BuildContext context) => TextButton(
        onPressed: () => DsMenuSheet.show(context, items: items),
        child: const Text('Open sheet'),
      ),
    ),
    surfaceSize: surfaceSize,
    theme: theme,
  );
}

void main() {
  testWidgets('opens with every row and closes on selection, then fires', (
    WidgetTester tester,
  ) async {
    String? chosen;
    await pumpSheetHost(tester, <DsMenuSheetItem>[
      DsMenuSheetItem(
        label: 'Home',
        icon: DsIcons.home,
        onSelected: () => chosen = 'home',
      ),
      DsMenuSheetItem(
        label: 'Statements',
        icon: DsIcons.fileText,
        onSelected: () => chosen = 'statements',
      ),
    ]);

    await tester.tap(find.text('Open sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Statements'), findsOneWidget);

    await tester.tap(find.text('Statements'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(chosen, 'statements');
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('announces the selected row and renders it on the brand tint', (
    WidgetTester tester,
  ) async {
    await pumpSheetHost(tester, <DsMenuSheetItem>[
      const DsMenuSheetItem(label: 'Home', selected: true),
      const DsMenuSheetItem(label: 'Wallet'),
    ]);

    await tester.tap(find.text('Open sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')),
      matchesSemantics(
        label: 'Home',
        isSelected: true,
        isButton: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
        hasSelectedState: true,
      ),
    );
  });

  testWidgets('a disabled row ignores taps', (WidgetTester tester) async {
    bool fired = false;
    await pumpSheetHost(tester, <DsMenuSheetItem>[
      DsMenuSheetItem(
        label: 'Home',
        enabled: false,
        onSelected: () => fired = true,
      ),
    ]);

    await tester.tap(find.text('Open sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Home'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));

    expect(fired, isFalse);
    // The sheet stays open because nothing was chosen.
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('does not overflow at 320dp with many long rows', (
    WidgetTester tester,
  ) async {
    await pumpSheetHost(
      tester,
      <DsMenuSheetItem>[
        for (int i = 0; i < 12; i++)
          DsMenuSheetItem(
            label: 'A rather long destination label number $i',
            icon: DsIcons.circle,
          ),
      ],
      surfaceSize: const Size(320, 480),
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark and under a skin', (
    WidgetTester tester,
  ) async {
    for (final ThemeData theme in <ThemeData>[
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
    ]) {
      await pumpSheetHost(
        tester,
        <DsMenuSheetItem>[const DsMenuSheetItem(label: 'Home', selected: true)],
        theme: theme,
      );

      await tester.tap(find.text('Open sheet'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Dismiss so the next theme starts clean.
      await tester.tapAt(const Offset(10, 10));
      await tester.pump(const Duration(milliseconds: 400));
    }
  });
}
