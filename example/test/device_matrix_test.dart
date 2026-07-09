// Senior-tester device matrix: pump EVERY live demo across the full span of
// device widths (small phone → large desktop) and assert none overflow or throw.
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ds_docs/content/doc_registry.dart';
import 'package:ds_docs/demos/demo_registry.dart';

/// Representative device widths from a 320dp small phone to a 1920dp desktop.
const _widths = <double>[320, 360, 390, 414, 600, 768, 834, 1024, 1280, 1440, 1920];

void main() {
  // One test per documented page's live demo; each sweeps every width.
  for (final page in allPages) {
    if (!page.hasLiveDemo) continue;
    final demo = demoFor(page.id);
    if (demo == null) continue;

    testWidgets('${page.id} — no overflow from 320dp to 1920dp', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;

      for (final w in _widths) {
        tester.view.physicalSize = Size(w, 1000);
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: DsTheme.light(),
            home: Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: w - 32,
                    child: demoFor(page.id),
                  ),
                ),
              ),
            ),
          ),
        );
        // Settle one-shot delays (spinners) without waiting on animations.
        await tester.pump(const Duration(milliseconds: 350));
        expect(
          tester.takeException(),
          isNull,
          reason: '${page.id} overflowed / threw at width ${w}dp',
        );
      }
    });
  }
}
