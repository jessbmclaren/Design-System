import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsBrandBloom', () {
    RadialGradient gradientOf(WidgetTester tester) {
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(DsBrandBloom),
          matching: find.byType(DecoratedBox),
        ),
      );
      return (box.decoration as BoxDecoration).gradient! as RadialGradient;
    }

    testWidgets('paints the theme bloom fading to transparent',
        (tester) async {
      await pumpDs(
        tester,
        const SizedBox(width: 200, height: 200, child: DsBrandBloom()),
      );

      final gradient = gradientOf(tester);
      final bloom = DsTokens.light().bloomColor;
      expect(gradient.colors, hasLength(2));
      expect(gradient.colors.first.toARGB32() & 0x00FFFFFF,
          bloom.toARGB32() & 0x00FFFFFF);
      expect(gradient.colors.first.a, moreOrLessEquals(bloom.a * 0.6));
      expect(gradient.colors.last.a, 0);
    });

    testWidgets('positions the glow by alignment and radius', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          width: 200,
          height: 200,
          child: DsBrandBloom(alignment: Alignment.bottomRight, radius: 0.8),
        ),
      );

      final gradient = gradientOf(tester);
      expect(gradient.center, Alignment.bottomRight);
      expect(gradient.radius, 0.8);
    });

    testWidgets('applies a custom peak opacity', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          width: 200,
          height: 200,
          child: DsBrandBloom(opacity: 0.25),
        ),
      );

      final gradient = gradientOf(tester);
      expect(gradient.colors.first.a,
          moreOrLessEquals(DsTokens.light().bloomColor.a * 0.25));
    });

    testWidgets('reads a skin bloom from the theme', (tester) async {
      final skinned = DsSkins.engenLight();
      await pumpDs(
        tester,
        const SizedBox(width: 200, height: 200, child: DsBrandBloom()),
        theme: DsTheme.light(tokens: skinned),
      );

      final gradient = gradientOf(tester);
      expect(gradient.colors.first.toARGB32() & 0x00FFFFFF,
          skinned.bloomColor.toARGB32() & 0x00FFFFFF);
    });

    testWidgets('is decorative: it exposes no semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const SizedBox(width: 200, height: 200, child: DsBrandBloom()),
      );

      expect(
        find.descendant(
          of: find.byType(DsBrandBloom),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        const SizedBox.expand(child: DsBrandBloom()),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at a wide width', (tester) async {
      await pumpDs(
        tester,
        const SizedBox.expand(child: DsBrandBloom()),
        surfaceSize: const Size(1920, 800),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
