import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const List<DsNavItem> _items = <DsNavItem>[
  DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
  DsNavItem(label: 'Wallet', icon: DsIcons.wallet, route: 'wallet'),
  DsNavItem(label: 'Statements', icon: DsIcons.fileText, route: 'statements'),
];

void main() {
  testWidgets('icon rail renders every destination and reports taps', (
    WidgetTester tester,
  ) async {
    String? navigated;
    await pumpDs(
      tester,
      SizedBox(
        height: 400,
        child: DsNavRail(
          items: _items,
          selectedRoute: 'home',
          onNavigate: (String route) => navigated = route,
        ),
      ),
    );

    expect(find.byIcon(DsIcons.home), findsOneWidget);
    expect(find.byIcon(DsIcons.wallet), findsOneWidget);
    // Icon-only: labels live in tooltips and semantics, not visible text.
    expect(find.text('Wallet'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Wallet'));
    await tester.pump();
    expect(navigated, 'wallet');
  });

  testWidgets('the selected destination is announced as selected', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      SizedBox(
        height: 400,
        child: DsNavRail(
          items: _items,
          selectedRoute: 'wallet',
          onNavigate: (_) {},
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Wallet')),
      matchesSemantics(
        label: 'Wallet',
        isSelected: true,
        isButton: true,
        hasSelectedState: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')),
      matchesSemantics(
        label: 'Home',
        isSelected: false,
        isButton: true,
        hasSelectedState: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
  });

  testWidgets('extended shows labels and honours header and trailing slots', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      SizedBox(
        height: 500,
        child: DsNavRail(
          items: _items,
          selectedRoute: 'home',
          onNavigate: (_) {},
          extended: true,
          header: const Text('Workspace'),
          trailing: const Text('Signed in'),
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Statements'), findsOneWidget);
    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Signed in'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a null onNavigate disables every destination', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      const SizedBox(
        height: 400,
        child: DsNavRail(
          items: _items,
          selectedRoute: 'home',
          onNavigate: null,
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Wallet'), warnIfMissed: false);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolls rather than overflowing on a short viewport', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      DsNavRail(
        items: <DsNavItem>[
          for (int i = 0; i < 20; i++)
            DsNavItem(label: 'Item $i', icon: DsIcons.circle, route: 'r$i'),
        ],
        selectedRoute: 'r0',
        onNavigate: (_) {},
      ),
      surfaceSize: const Size(320, 400),
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
        SizedBox(
          height: 400,
          child: DsNavRail(
            items: _items,
            selectedRoute: 'home',
            onNavigate: (_) {},
          ),
        ),
        theme: theme,
      );
      expect(find.byIcon(DsIcons.home), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
