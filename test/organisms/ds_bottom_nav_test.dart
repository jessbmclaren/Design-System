import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const List<DsNavItem> _items = <DsNavItem>[
  DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
  DsNavItem(label: 'Fuel', icon: DsIcons.fuel, route: 'fuel'),
  DsNavItem(label: 'History', icon: DsIcons.time, route: 'history'),
  DsNavItem(label: 'Account', icon: DsIcons.user, route: 'account'),
];

void main() {
  testWidgets('renders every destination with its label', (tester) async {
    await pumpDs(
      tester,
      DsBottomNav(
        items: _items,
        selectedRoute: 'home',
        onNavigate: (_) {},
      ),
    );

    for (final DsNavItem item in _items) {
      expect(find.text(item.label), findsOneWidget);
    }
  });

  testWidgets('choosing a destination reports its route', (tester) async {
    String? navigated;
    await pumpDs(
      tester,
      DsBottomNav(
        items: _items,
        selectedRoute: 'home',
        onNavigate: (String route) => navigated = route,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Fuel'));
    await tester.pump();
    expect(navigated, 'fuel');
  });

  testWidgets('the current destination announces itself as selected', (
    tester,
  ) async {
    await pumpDs(
      tester,
      DsBottomNav(
        items: _items,
        selectedRoute: 'fuel',
        onNavigate: (_) {},
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Fuel')),
      matchesSemantics(
        label: 'Fuel',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')),
      matchesSemantics(
        label: 'Home',
        isButton: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
  });

  testWidgets('a null callback disables the bar and drops it from focus', (
    tester,
  ) async {
    await pumpDs(
      tester,
      const DsBottomNav(
        items: _items,
        selectedRoute: 'home',
        onNavigate: null,
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')),
      matchesSemantics(
        label: 'Home',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasEnabledState: true,
      ),
    );
  });

  testWidgets('every destination holds the 48dp minimum target', (
    tester,
  ) async {
    await pumpDs(
      tester,
      DsBottomNav(
        items: _items,
        selectedRoute: 'home',
        onNavigate: (_) {},
      ),
      surfaceSize: const Size(320, 480),
    );

    for (final DsNavItem item in _items) {
      final Size size = tester.getSize(
        find.ancestor(
          of: find.text(item.label),
          matching: find.byType(ConstrainedBox),
        ).first,
      );
      expect(size.height, greaterThanOrEqualTo(48),
          reason: '${item.label} target is ${size.height}dp tall');
    }
  });

  testWidgets('holds five destinations at 320dp and a wide pane, every theme', (
    tester,
  ) async {
    const List<DsNavItem> five = <DsNavItem>[
      ..._items,
      DsNavItem(label: 'Rewards', icon: DsIcons.reward, route: 'rewards'),
    ];

    for (final ThemeData theme in <ThemeData>[
      DsTheme.light(),
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenMobileLight()),
      DsTheme.dark(tokens: DsSkins.engenMobileDark()),
    ]) {
      for (final double width in <double>[320, 1280]) {
        await pumpDs(
          tester,
          DsBottomNav(
            items: five,
            selectedRoute: 'rewards',
            onNavigate: (_) {},
          ),
          theme: theme,
          surfaceSize: Size(width, 480),
        );
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('collapses its selection animation under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DsTheme.light(tokens: DsSkins.engenMobileLight()),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: DsBottomNav(
              items: _items,
              selectedRoute: 'home',
              onNavigate: (_) {},
            ),
          ),
        ),
      ),
    );

    // With animations disabled the bar settles on its first frame, so no timer
    // is left pending.
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
