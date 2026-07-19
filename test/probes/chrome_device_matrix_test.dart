import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Senior-tester device matrix for the chrome family: the full shell (which
/// composes the rail, the search field, the status bar and the sheet trigger)
/// pumped across the span of device widths, in the light, dark and Engen
/// themes, asserting no overflow and the right navigation mode at each width.
const List<double> _widths = <double>[
  320, 360, 390, 414, 600, 768, 834, 1024, 1280, 1440, 1920,
];

const List<DsNavItem> _items = <DsNavItem>[
  DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
  DsNavItem(label: 'Wallet', icon: DsIcons.wallet, route: 'wallet'),
  DsNavItem(label: 'Statements', icon: DsIcons.fileText, route: 'statements'),
];

void main() {
  final Map<String, ThemeData> themes = <String, ThemeData>{
    'light': DsTheme.light(),
    'dark': DsTheme.dark(),
    'engen light': DsTheme.light(tokens: DsSkins.engenLight()),
    'engen dark': DsTheme.dark(tokens: DsSkins.engenDark()),
  };

  for (final MapEntry<String, ThemeData> theme in themes.entries) {
    testWidgets(
        'the shell holds every width from 320dp to 1920dp · ${theme.key}', (
      tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;

      for (final double width in _widths) {
        tester.view.physicalSize = Size(width, 900);
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme.value,
            home: DsAppShell(
              navItems: _items,
              selectedRoute: 'home',
              onNavigate: (_) {},
              brand: const Text('acme'),
              search: DsSearchField(onChanged: (_) {}),
              trailing: <Widget>[
                DsIconButton(
                  icon: DsIcons.notifications,
                  semanticLabel: 'Notifications',
                  onPressed: () {},
                ),
              ],
              statusBar: const DsStatusBar(
                icon: DsIcons.terminal,
                label: 'Developers',
              ),
              body: const Center(child: Text('Body')),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 350));

        expect(tester.takeException(), isNull,
            reason: '${theme.key} at ${width.toInt()}dp');

        // The right navigation mode for the width.
        if (width < DsBreakpoints.medium) {
          expect(find.byIcon(DsIcons.menu), findsOneWidget,
              reason: 'sheet trigger expected at ${width.toInt()}dp');
        } else if (width < DsBreakpoints.large) {
          expect(find.byIcon(DsIcons.home), findsOneWidget,
              reason: 'icon rail expected at ${width.toInt()}dp');
          expect(find.text('Home'), findsNothing,
              reason: 'no labels on the rail at ${width.toInt()}dp');
        } else {
          expect(find.text('Home'), findsOneWidget,
              reason: 'extended sidebar expected at ${width.toInt()}dp');
        }
      }
    });
  }
}
