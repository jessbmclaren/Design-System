// Senior-tester device matrix: pump EVERY live demo across the full span of
// device widths (small phone → tablet → large desktop), in every theme the
// system ships (the neutral base and the Engen skin, light and dark), and
// assert none overflow or throw. A text-scale gate then re-runs every demo at
// 320dp under a 1.3x scaler, so the components hold when the user asks for
// larger text on the smallest phone.
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ds_docs/content/doc_registry.dart';
import 'package:ds_docs/demos/demo_registry.dart';

/// Representative device widths: small and large phones (320 to 414), tablets
/// in portrait and landscape (600 to 1024) and desktops up to 1920dp.
const _widths = <double>[320, 360, 390, 414, 600, 768, 834, 1024, 1280, 1440, 1920];

/// Every theme the system ships: the white-label base and the Engen skin, in
/// both brightnesses.
final Map<String, ThemeData> _themes = <String, ThemeData>{
  'light': DsTheme.light(),
  'dark': DsTheme.dark(),
  'engen light': DsTheme.light(tokens: DsSkins.engenLight()),
  'engen dark': DsTheme.dark(tokens: DsSkins.engenDark()),
};

Widget _host(ThemeData theme, double width, Widget demo,
    {double textScale = 1.0}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 1000),
          textScaler: TextScaler.linear(textScale),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: width - 32, child: demo),
          ),
        ),
      ),
    ),
  );
}

void main() {
  // One test per (page, theme); each sweeps every width.
  for (final page in allPages) {
    if (!page.hasLiveDemo) continue;
    if (demoFor(page.id) == null) continue;

    for (final entry in _themes.entries) {
      testWidgets('${page.id} — no overflow from 320dp to 1920dp · ${entry.key}',
          (tester) async {
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.view.devicePixelRatio = 1.0;

        for (final w in _widths) {
          tester.view.physicalSize = Size(w, 1000);
          await tester.pumpWidget(_host(entry.value, w, demoFor(page.id)!));
          // Settle one-shot delays (spinners) without waiting on animations.
          await tester.pump(const Duration(milliseconds: 350));
          expect(
            tester.takeException(),
            isNull,
            reason:
                '${page.id} overflowed / threw at ${w.toInt()}dp · ${entry.key}',
          );
        }
      });
    }

    // The text-scale gate: the smallest phone with larger text.
    testWidgets('${page.id} — survives 1.3x text scale at 320dp',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(320, 1200);

      await tester.pumpWidget(
        _host(_themes['light']!, 320, demoFor(page.id)!, textScale: 1.3),
      );
      await tester.pump(const Duration(milliseconds: 350));
      expect(
        tester.takeException(),
        isNull,
        reason: '${page.id} overflowed / threw at 320dp under 1.3x text',
      );
    });
  }
}
