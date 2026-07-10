import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<BuildContext> _context(
  WidgetTester tester, {
  bool disableAnimations = false,
}) async {
  late BuildContext ctx;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Builder(builder: (context) {
        ctx = context;
        return const SizedBox();
      }),
    ),
  );
  return ctx;
}

void main() {
  testWidgets('durationOf/curveOf collapse under reduced motion', (tester) async {
    final normal = await _context(tester);
    expect(DsMotion.durationOf(normal, DsMotion.base), DsMotion.base);
    expect(DsMotion.curveOf(normal, DsMotion.emphasized), DsMotion.emphasized);
    expect(DsMotion.reduced(normal), isFalse);

    final reduced = await _context(tester, disableAnimations: true);
    expect(DsMotion.durationOf(reduced, DsMotion.base), Duration.zero);
    expect(DsMotion.curveOf(reduced, DsMotion.emphasized), Curves.linear);
    expect(DsMotion.reduced(reduced), isTrue);
  });

  testWidgets('stagger offsets, clamps and respects reduced motion',
      (tester) async {
    final ctx = await _context(tester);
    // The first item never waits.
    expect(DsMotion.stagger(ctx, 0), Duration.zero);
    // Each item is a step later…
    expect(DsMotion.stagger(ctx, 2, step: const Duration(milliseconds: 40)),
        const Duration(milliseconds: 80));
    // …but the tail is clamped so a long list never crawls.
    expect(
      DsMotion.stagger(ctx, 100,
          step: const Duration(milliseconds: 40),
          max: const Duration(milliseconds: 240)),
      const Duration(milliseconds: 240),
    );

    final reduced = await _context(tester, disableAnimations: true);
    expect(DsMotion.stagger(reduced, 3), Duration.zero);
  });
}
