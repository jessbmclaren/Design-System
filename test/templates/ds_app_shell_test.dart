import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const List<DsNavItem> _items = <DsNavItem>[
  DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
  DsNavItem(label: 'Wallet', icon: DsIcons.wallet, route: 'wallet'),
];

Widget _shell({
  ValueChanged<String>? onNavigate,
  String selectedRoute = 'home',
  Widget? search,
  List<Widget> trailing = const <Widget>[],
  Widget? statusBar,
}) {
  return DsAppShell(
    navItems: _items,
    selectedRoute: selectedRoute,
    onNavigate: onNavigate,
    brand: const Text('acme'),
    search: search,
    trailing: trailing,
    statusBar: statusBar,
    body: const Center(child: Text('Body')),
  );
}

void main() {
  testWidgets('a large shell keeps the extended sidebar open', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      _shell(onNavigate: (_) {}),
      surfaceSize: const Size(1440, 800),
    );

    // Labels visible means the sidebar is extended; no menu trigger shows.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.byIcon(DsIcons.menu), findsNothing);
    expect(find.text('Body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a medium shell collapses to the icon rail', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      _shell(onNavigate: (_) {}),
      surfaceSize: const Size(800, 600),
    );

    expect(find.byIcon(DsIcons.wallet), findsOneWidget);
    // Icon-only: no visible labels, no menu trigger.
    expect(find.text('Wallet'), findsNothing);
    expect(find.byIcon(DsIcons.menu), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a compact shell moves navigation into the menu sheet', (
    WidgetTester tester,
  ) async {
    String? navigated;
    await pumpDs(
      tester,
      _shell(onNavigate: (String route) => navigated = route),
      surfaceSize: const Size(360, 640),
    );

    // No side navigation; the labelled trigger opens the sheet.
    expect(find.byIcon(DsIcons.wallet), findsNothing);
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Wallet'), findsOneWidget);
    await tester.tap(find.text('Wallet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(navigated, 'wallet');
    expect(find.text('Wallet'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigating from the sidebar reports the route', (
    WidgetTester tester,
  ) async {
    String? navigated;
    await pumpDs(
      tester,
      _shell(onNavigate: (String route) => navigated = route),
      surfaceSize: const Size(1440, 800),
    );

    await tester.tap(find.text('Wallet'));
    await tester.pump();
    expect(navigated, 'wallet');
  });

  testWidgets('the search and trailing slots render in the top bar', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      _shell(
        onNavigate: (_) {},
        search: DsSearchField(onChanged: (_) {}),
        trailing: const <Widget>[Text('Trailing')],
        statusBar: const DsStatusBar(label: 'Developers'),
      ),
      surfaceSize: const Size(1440, 800),
    );

    expect(find.byType(DsSearchField), findsOneWidget);
    expect(find.text('Trailing'), findsOneWidget);
    expect(find.text('Developers'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow at 320dp or 1920dp', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      _shell(onNavigate: (_) {}, search: DsSearchField(onChanged: (_) {})),
      surfaceSize: const Size(320, 480),
    );
    expect(tester.takeException(), isNull);

    await pumpDs(
      tester,
      _shell(onNavigate: (_) {}, search: DsSearchField(onChanged: (_) {})),
      surfaceSize: const Size(1920, 900),
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
        _shell(onNavigate: (_) {}),
        surfaceSize: const Size(1440, 800),
        theme: theme,
      );
      expect(find.text('Body'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
