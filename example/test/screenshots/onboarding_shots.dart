// Scratch screenshot generator for the LCV onboarding surfaces.
//
//   flutter test test/screenshots/onboarding_shots.dart --update-goldens
//
// Renders existing onboarding demos (by page id) to PNGs next to this file so
// they can be reviewed without touching the committed docs images.
import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:ds_docs/demos/demo_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

  const targets = <String, String>{
    'sign-up': 'onb_sign_up',
    'sign-in': 'onb_sign_in',
  };

  targets.forEach((pageId, fileName) {
    testWidgets(pageId, (tester) async {
      const dpr = 2.0;
      const width = 1120.0;
      const logicalHeight = 2000.0;
      tester.view.devicePixelRatio = dpr;
      tester.view.physicalSize = const Size(width * dpr, logicalHeight * dpr);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: DsTheme.light(),
          home: Scaffold(
            backgroundColor: const Color(0xFFF6F8FA),
            body: Center(
              child: SingleChildScrollView(
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: Container(
                    color: const Color(0xFFF6F8FA),
                    padding: const EdgeInsets.all(28),
                    child: SizedBox(width: width, child: demoFor(pageId)!),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 350));

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile('$fileName.png'),
      );
    });
  });
}
