import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// WCAG relative luminance of an sRGB colour.
double _luminance(Color c) {
  double channel(double v) {
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// WCAG contrast ratio between two colours (1..21).
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void _expectRatio(
  Color fg,
  Color bg,
  double minimum,
  String pair,
) {
  final double ratio = _contrast(fg, bg);
  expect(
    ratio,
    greaterThanOrEqualTo(minimum),
    reason: '$pair is ${ratio.toStringAsFixed(2)}:1, needs $minimum:1',
  );
}

const List<DsNavItem> _items = <DsNavItem>[
  DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
  DsNavItem(label: 'Wallet', icon: DsIcons.wallet, route: 'wallet'),
  DsNavItem(label: 'Statements', icon: DsIcons.fileText, route: 'statements'),
];

void main() {
  final Map<String, DsTokens> themes = <String, DsTokens>{
    'light': DsTokens.light(),
    'dark': DsTokens.dark(),
    'engen light': DsSkins.engenLight(),
    'engen dark': DsSkins.engenDark(),
  };

  // --- WCAG contrast: every colour pair the chrome family renders ----------

  for (final MapEntry<String, DsTokens> entry in themes.entries) {
    final String mode = entry.key;
    final DsTokens t = entry.value;

    group('chrome contrast · $mode', () {
      test('sidebar and sheet selected label on the brand tint is AA', () {
        _expectRatio(t.actionPrimaryColorText, t.brandTintColor, 4.5,
            'selected nav label on brandTintColor');
      });

      test('selected rail icon on the brand tint clears the graphic bar', () {
        _expectRatio(t.actionPrimaryColorText, t.brandTintColor, 3.0,
            'selected rail icon on brandTintColor');
      });

      test('idle rail icon on the rail fill clears the graphic bar', () {
        _expectRatio(t.colorSecondaryText, t.colorBackground, 3.0,
            'idle rail icon on colorBackground');
      });

      test('sidebar idle label on the sidebar fill is AA', () {
        _expectRatio(t.colorText, t.formBackgroundColor, 4.5,
            'sidebar idle label on formBackgroundColor');
      });

      test('sidebar idle icon on the sidebar fill clears the graphic bar', () {
        _expectRatio(t.colorSecondaryText, t.formBackgroundColor, 3.0,
            'sidebar idle icon on formBackgroundColor');
      });

      test('sheet row label on the sheet surface is AA', () {
        _expectRatio(t.colorText, t.formBackgroundColor, 4.5,
            'sheet row label on formBackgroundColor');
      });

      test('status bar label on the bar fill is AA', () {
        _expectRatio(t.colorSecondaryText, t.colorBackground, 4.5,
            'status bar label on colorBackground');
      });

      test('top bar text and icons on the bar fill are AA', () {
        _expectRatio(t.colorText, t.colorBackground, 4.5,
            'top bar text on colorBackground');
        _expectRatio(t.colorSecondaryText, t.colorBackground, 3.0,
            'top bar icons on colorBackground');
      });

      test('search glyph on the field fill clears the graphic bar', () {
        _expectRatio(t.colorSecondaryText, t.formBackgroundColor, 3.0,
            'search glyph on formBackgroundColor');
      });

      test('focus ring on both nav fills clears the graphic bar', () {
        _expectRatio(t.formAccentColor, t.colorBackground, 3.0,
            'focus ring on the rail fill');
        _expectRatio(t.formAccentColor, t.formBackgroundColor, 3.0,
            'focus ring on the sidebar fill');
      });
    });
  }

  // --- Tap targets ----------------------------------------------------------

  testWidgets('every rail destination holds a 48dp target', (tester) async {
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
    );

    for (final DsNavItem item in _items) {
      final Rect rect = tester.getRect(find.bySemanticsLabel(item.label));
      expect(rect.height, greaterThanOrEqualTo(48), reason: item.label);
      expect(rect.width, greaterThanOrEqualTo(48), reason: item.label);
    }
  });

  testWidgets('every sidebar destination holds a 48dp row', (tester) async {
    await pumpDs(
      tester,
      SizedBox(
        height: 500,
        child: DsNavRail(
          items: _items,
          selectedRoute: 'home',
          onNavigate: (_) {},
          extended: true,
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    for (final DsNavItem item in _items) {
      final Rect rect = tester.getRect(find.bySemanticsLabel(item.label));
      expect(rect.height, greaterThanOrEqualTo(48), reason: item.label);
    }
  });

  testWidgets('every menu sheet row holds a 48dp target', (tester) async {
    await pumpDs(
      tester,
      Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () => DsMenuSheet.show(
            context,
            items: <DsMenuSheetItem>[
              for (final DsNavItem item in _items)
                DsMenuSheetItem(
                  label: item.label,
                  icon: item.icon,
                  onSelected: () {},
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

    for (final DsNavItem item in _items) {
      final Rect rect = tester.getRect(find.bySemanticsLabel(item.label));
      expect(rect.height, greaterThanOrEqualTo(48), reason: item.label);
    }
  });

  testWidgets('the search clear affordance pads out to a 48dp target', (
    tester,
  ) async {
    final TextEditingController controller =
        TextEditingController(text: 'diesel');
    addTearDown(controller.dispose);
    await pumpDs(
      tester,
      DsSearchField(controller: controller, onChanged: (_) {}),
    );

    final Size target = tester.getSize(
      find.ancestor(
        of: find.byIcon(DsIcons.close),
        matching: find.byType(IconButton),
      ),
    );
    expect(target.height, greaterThanOrEqualTo(48));
    expect(target.width, greaterThanOrEqualTo(48));
  });

  // --- Keyboard operation ---------------------------------------------------

  testWidgets('a rail destination activates from the keyboard', (
    tester,
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

    // Tab to the first destination, then activate with Enter and Space.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(navigated, 'home');

    navigated = null;
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(navigated, 'wallet');
  });

  testWidgets('disabled navigation leaves the focus order', (tester) async {
    await pumpDs(
      tester,
      Column(
        children: <Widget>[
          SizedBox(
            height: 300,
            child: DsNavRail(
              items: _items,
              selectedRoute: 'home',
              onNavigate: null,
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('After')),
        ],
      ),
    );

    // With the rail disabled, the first Tab lands on the button after it.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      Focus.of(tester.element(find.text('After'))).hasFocus,
      isTrue,
      reason: 'a disabled rail must not hold keyboard focus',
    );
  });

  testWidgets('a menu sheet row activates from the keyboard', (tester) async {
    String? chosen;
    await pumpDs(
      tester,
      Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () => DsMenuSheet.show(
            context,
            items: <DsMenuSheetItem>[
              DsMenuSheetItem(
                label: 'Wallet',
                onSelected: () => chosen = 'wallet',
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

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(chosen, 'wallet');
  });

  // --- Text scale -----------------------------------------------------------

  testWidgets('the shell survives 1.3x text scale at 320dp', (tester) async {
    await pumpDs(
      tester,
      DsAppShell(
        navItems: _items,
        selectedRoute: 'home',
        onNavigate: (_) {},
        brand: const Text('acme'),
        search: DsSearchField(onChanged: (_) {}),
        statusBar: const DsStatusBar(label: 'Developers'),
        body: const SizedBox.expand(),
      ),
      surfaceSize: const Size(320, 480),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the extended sidebar survives 1.3x text scale', (tester) async {
    await pumpDs(
      tester,
      SizedBox(
        height: 500,
        child: DsNavRail(
          items: _items,
          selectedRoute: 'home',
          onNavigate: (_) {},
          extended: true,
        ),
      ),
      surfaceSize: const Size(800, 600),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });

  // --- Reduced motion -------------------------------------------------------

  testWidgets('the shell settles to a still frame under reduced motion', (
    tester,
  ) async {
    await pumpDs(
      tester,
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: DsAppShell(
          navItems: _items,
          selectedRoute: 'home',
          onNavigate: (_) {},
          brand: const Text('acme'),
          body: const SizedBox.expand(),
        ),
      ),
      surfaceSize: const Size(1440, 800),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
    expect(tester.binding.transientCallbackCount, 0);
  });

  // --- Right-to-left --------------------------------------------------------

  testWidgets('the shell renders under RTL without overflow', (tester) async {
    await pumpDs(
      tester,
      Directionality(
        textDirection: TextDirection.rtl,
        child: DsAppShell(
          navItems: _items,
          selectedRoute: 'home',
          onNavigate: (_) {},
          brand: const Text('acme'),
          search: DsSearchField(onChanged: (_) {}),
          statusBar: const DsStatusBar(label: 'Developers'),
          body: const SizedBox.expand(),
        ),
      ),
      surfaceSize: const Size(1440, 800),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Home'), findsOneWidget);
  });
}
