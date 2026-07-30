// EngenXT home screen specimen generator (not an assertion suite).
//
// Renders the docs demo at phone size so the whole screen can be judged
// against the design rather than a component at a time:
//
//   flutter test test/screenshots/engenxt_home_specimen.dart --update-goldens
//
// It is NOT named `*_test.dart`, so `flutter test` never discovers it.
//
// The mobile skin clears `fontFamily` so a phone sets in its own system face,
// and the harness has no system face to fall back on, which would render every
// run as a filled box. The specimen therefore stands Inter in for the device
// font: judge the colour, shape and scale here, not the letterforms.
import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:ds_docs/demos/engenxt_home_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// The bundled face is registered package-prefixed, and only at 400-700, so the
// display tier's extra-bold is stepped back to bold for the stand-in.
final DsTokens _inter = DsSkins.engenMobileLight().copyWith(
  fontFamily: 'packages/design_system/Inter',
  display: DsSkins.engenMobileLight()
      .display
      .copyWith(fontWeight: FontWeight.w700),
);

Future<void> _loadFonts() async {
  final manifest = json.decode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  for (final entry in manifest) {
    final family = entry['family'] as String;
    final loader = FontLoader(family);
    for (final font in entry['fonts'] as List<dynamic>) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('specimen engenxt-home', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(390 * 2, 760 * 2);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        // Inter stands in for the device face, as above. It is set in both
        // places: on the app, so the inherited DefaultTextStyle carries it, and
        // through the demo, which builds its own phone theme underneath.
        theme: DsTheme.light(tokens: _inter),
        // A Scaffold, because Material is what establishes the DefaultTextStyle
        // the theme's face rides on. In the docs app the page already provides
        // one; a bare specimen does not, and every run that reads its family by
        // inheritance would fall back to the test font without it.
        home: Scaffold(
          backgroundColor: _inter.colorBackground,
          body: Center(child: EngenxtHomeDemo(tokens: _inter)),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('specimen_engenxt-home.png'),
    );
  });
}
