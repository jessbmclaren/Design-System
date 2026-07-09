// Screenshot generator (not an assertion suite).
//
// Run ONLY as a generator — it writes PNGs straight into docs/patterns/img/:
//
//   flutter test test/screenshots/screenshots.dart --update-goldens
//
// It is NOT named `*_test.dart`, so `flutter test` never auto-discovers it;
// it only runs when invoked explicitly, and never fails CI on cross-platform
// pixel differences.
import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:ds_docs/content/doc_registry.dart';
import 'package:ds_docs/demos/demo_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Logical widths to capture for each demo.
const _shots = <String, double>{
  'desktop': 1120,
  'phone': 320,
};

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

  for (final page in allPages) {
    if (!page.hasLiveDemo) continue;
    for (final entry in _shots.entries) {
      final sizeName = entry.key;
      final width = entry.value;

      testWidgets('${page.id} · $sizeName', (tester) async {
        const dpr = 2.0;
        const logicalHeight = 2000.0;
        tester.view.devicePixelRatio = dpr;
        tester.view.physicalSize = Size(width * dpr, logicalHeight * dpr);
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
                      child: SizedBox(
                        width: width,
                        child: demoFor(page.id)!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // Let one-shot delays (spinner reveal, etc.) settle without waiting on
        // any indefinite animation.
        await tester.pump(const Duration(milliseconds: 350));

        await expectLater(
          find.byKey(boundaryKey),
          matchesGoldenFile(
            '../../../docs/patterns/img/${page.id}_$sizeName.png',
          ),
        );
      });
    }
  }
}
