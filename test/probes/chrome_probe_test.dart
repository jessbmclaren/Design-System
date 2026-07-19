import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Adversarial probes over the chrome family: the edges a routine test
/// misses — controller swaps, threshold flips mid-life, hostile content,
/// disposal order and state that must not leak between modes.
void main() {
  const List<DsNavItem> items = <DsNavItem>[
    DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
    DsNavItem(label: 'Wallet', icon: DsIcons.wallet, route: 'wallet'),
  ];

  group('DsSearchField probes', () {
    testWidgets('swapping the external controller rewires the listener', (
      tester,
    ) async {
      final TextEditingController first = TextEditingController();
      final TextEditingController second = TextEditingController();
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      await pumpDs(
        tester,
        DsSearchField(controller: first, onChanged: (_) {}),
      );
      await pumpDs(
        tester,
        DsSearchField(controller: second, onChanged: (_) {}),
      );

      // Text in the new controller drives the clear affordance...
      second.text = 'diesel';
      await tester.pump();
      expect(find.byIcon(DsIcons.close), findsOneWidget);

      // ...and text in the detached one no longer does anything.
      second.clear();
      first.text = 'petrol';
      await tester.pump();
      expect(find.byIcon(DsIcons.close), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the caller keeps ownership of its controller', (
      tester,
    ) async {
      final TextEditingController controller = TextEditingController();
      await pumpDs(
        tester,
        DsSearchField(controller: controller, onChanged: (_) {}),
      );
      // Tear the field down, then keep using the controller: the field must
      // not have disposed what it does not own.
      await pumpDs(tester, const SizedBox());
      controller.text = 'still alive';
      expect(controller.text, 'still alive');
      controller.dispose();
    });

    testWidgets('pending wins over the clear affordance', (tester) async {
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

    testWidgets('submits through the keyboard search action', (tester) async {
      String? submitted;
      await pumpDs(
        tester,
        DsSearchField(onChanged: (_) {}, onSubmitted: (String q) => submitted = q),
      );
      await tester.enterText(find.byType(TextField), 'diesel');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(submitted, 'diesel');
    });

    testWidgets('an absurdly long unbroken query never overflows at 320dp', (
      tester,
    ) async {
      final TextEditingController controller =
          TextEditingController(text: 'x' * 500);
      addTearDown(controller.dispose);
      await pumpDs(
        tester,
        DsSearchField(controller: controller, onChanged: (_) {}),
        surfaceSize: const Size(320, 480),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('DsNavRail probes', () {
    testWidgets('an unmatched selectedRoute selects nothing and never throws', (
      tester,
    ) async {
      await pumpDs(
        tester,
        SizedBox(
          height: 300,
          child: DsNavRail(
            items: items,
            selectedRoute: 'nowhere',
            onNavigate: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Home')),
        isNot(
          matchesSemantics(
            label: 'Home',
            isSelected: true,
            hasSelectedState: true,
            isButton: true,
            hasTapAction: true,
            isFocusable: true,
            hasFocusAction: true,
          ),
        ),
      );
    });

    testWidgets('an empty rail renders as bare chrome', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 300,
          child: DsNavRail(
            items: <DsNavItem>[],
            selectedRoute: '',
            onNavigate: null,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('flipping extended mid-life keeps selection coherent', (
      tester,
    ) async {
      for (final bool extended in <bool>[false, true, false]) {
        await pumpDs(
          tester,
          SizedBox(
            height: 400,
            child: DsNavRail(
              items: items,
              selectedRoute: 'wallet',
              onNavigate: (_) {},
              extended: extended,
            ),
          ),
          surfaceSize: const Size(800, 600),
        );
        expect(tester.takeException(), isNull);
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
          reason: 'extended: $extended',
        );
      }
    });

    testWidgets('the last of many destinations is reachable by scrolling', (
      tester,
    ) async {
      String? navigated;
      await pumpDs(
        tester,
        SizedBox(
          height: 300,
          child: DsNavRail(
            items: <DsNavItem>[
              for (int i = 0; i < 25; i++)
                DsNavItem(label: 'Item $i', icon: DsIcons.circle, route: 'r$i'),
            ],
            selectedRoute: 'r0',
            onNavigate: (String route) => navigated = route,
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.bySemanticsLabel('Item 24'),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -200),
      );
      await tester.tap(find.bySemanticsLabel('Item 24'));
      await tester.pump();
      expect(navigated, 'r24');
    });

    testWidgets('a hostile label ellipsizes in the sidebar instead of '
        'overflowing', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          height: 300,
          child: DsNavRail(
            items: <DsNavItem>[
              DsNavItem(
                label: 'W${'e' * 200}',
                icon: DsIcons.wallet,
                route: 'w',
              ),
            ],
            selectedRoute: 'w',
            onNavigate: (_) {},
            extended: true,
          ),
        ),
        surfaceSize: const Size(800, 600),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('DsMenuSheet probes', () {
    testWidgets('the barrier dismisses without firing anything', (
      tester,
    ) async {
      bool fired = false;
      await pumpDs(
        tester,
        Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => DsMenuSheet.show(
              context,
              items: <DsMenuSheetItem>[
                DsMenuSheetItem(label: 'Home', onSelected: () => fired = true),
              ],
            ),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tapAt(const Offset(160, 20));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(fired, isFalse);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('reopening after selection shows fresh state', (tester) async {
      String selected = 'home';
      await pumpDs(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => TextButton(
            onPressed: () => DsMenuSheet.show(
              context,
              items: <DsMenuSheetItem>[
                DsMenuSheetItem(
                  label: 'Home',
                  selected: selected == 'home',
                  onSelected: () => setState(() => selected = 'home'),
                ),
                DsMenuSheetItem(
                  label: 'Wallet',
                  selected: selected == 'wallet',
                  onSelected: () => setState(() => selected = 'wallet'),
                ),
              ],
            ),
            child: const Text('Open'),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Wallet'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
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
    });
  });

  group('DsAppShell probes', () {
    Widget shell({double? rail, double? sidebar}) => DsAppShell(
          navItems: items,
          selectedRoute: 'home',
          onNavigate: (_) {},
          brand: const Text('acme'),
          railBreakpoint: rail ?? DsBreakpoints.medium,
          sidebarBreakpoint: sidebar ?? DsBreakpoints.large,
          body: const SizedBox.expand(child: Center(child: Text('Body'))),
        );

    testWidgets('resizing across both thresholds swaps modes cleanly', (
      tester,
    ) async {
      // Sidebar → rail → sheet → sidebar: no exceptions, right nav each time.
      await pumpDs(tester, shell(), surfaceSize: const Size(1440, 800));
      expect(find.text('Home'), findsOneWidget);

      await pumpDs(tester, shell(), surfaceSize: const Size(800, 600));
      expect(find.text('Home'), findsNothing);
      expect(find.byIcon(DsIcons.home), findsOneWidget);

      await pumpDs(tester, shell(), surfaceSize: const Size(360, 640));
      expect(find.byIcon(DsIcons.home), findsNothing);
      expect(find.byIcon(DsIcons.menu), findsOneWidget);

      await pumpDs(tester, shell(), surfaceSize: const Size(1440, 800));
      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('custom thresholds move the mode boundaries', (tester) async {
      // With LCV-style thresholds (760/1420), 800dp is a rail and 1440dp a
      // sidebar; 700dp drops to the sheet.
      await pumpDs(
        tester,
        shell(rail: 760, sidebar: 1420),
        surfaceSize: const Size(800, 600),
      );
      expect(find.byIcon(DsIcons.home), findsOneWidget);
      expect(find.text('Home'), findsNothing);

      await pumpDs(
        tester,
        shell(rail: 760, sidebar: 1420),
        surfaceSize: const Size(1440, 800),
      );
      expect(find.text('Home'), findsOneWidget);

      await pumpDs(
        tester,
        shell(rail: 760, sidebar: 1420),
        surfaceSize: const Size(700, 600),
      );
      expect(find.byIcon(DsIcons.menu), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the body owns its space: the shell adds no padding or '
        'scrolling', (tester) async {
      final GlobalKey bodyKey = GlobalKey();
      await pumpDs(
        tester,
        DsAppShell(
          navItems: items,
          selectedRoute: 'home',
          onNavigate: (_) {},
          body: SizedBox.expand(key: bodyKey),
        ),
        surfaceSize: const Size(1440, 800),
      );

      final Size bodySize = tester.getSize(find.byKey(bodyKey));
      // Full width minus the extended sidebar, full height minus the bar.
      expect(bodySize.width, 1440 - DsNavRail.extendedWidth);
      expect(bodySize.height, 800 - DsAppShell.topBarHeight);
    });

    testWidgets('a compact bar with brand, search and trailing never '
        'overflows', (tester) async {
      await pumpDs(
        tester,
        DsAppShell(
          navItems: items,
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
            DsIconButton(
              icon: DsIcons.help,
              semanticLabel: 'Help',
              onPressed: () {},
            ),
          ],
          body: const SizedBox.expand(),
        ),
        surfaceSize: const Size(320, 480),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('with navigation disabled the sheet still opens but every '
        'row is inert', (tester) async {
      await pumpDs(
        tester,
        DsAppShell(
          navItems: items,
          selectedRoute: 'home',
          onNavigate: null,
          body: const SizedBox.expand(),
        ),
        surfaceSize: const Size(360, 640),
      );

      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Home'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));
      // Nothing chosen, so the sheet is still up.
      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
