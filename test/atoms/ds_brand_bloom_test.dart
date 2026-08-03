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

    testWidgets('takes a per-instance colour over the theme bloom',
        (tester) async {
      // A second glow on the same backdrop, carrying the brand's other hue.
      final second = DsSkins.engenLight().colorBrandSecondaryTint;
      await pumpDs(
        tester,
        SizedBox(
          width: 200,
          height: 200,
          child: DsBrandBloom(color: second, opacity: 0.5),
        ),
      );

      final gradient = gradientOf(tester);
      expect(gradient.colors.first.toARGB32() & 0x00FFFFFF,
          second.toARGB32() & 0x00FFFFFF);
      expect(gradient.colors.first.a, moreOrLessEquals(second.a * 0.5));
      expect(gradient.colors.last.a, 0);
      // The theme's own bloom is a different hue, so this is an override
      // rather than a coincidence.
      expect(second.toARGB32() & 0x00FFFFFF,
          isNot(DsTokens.light().bloomColor.toARGB32() & 0x00FFFFFF));
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

    group('pools', () {
      CustomPaint paintOf(WidgetTester tester) => tester.widget<CustomPaint>(
            find.descendant(
              of: find.byType(DsBrandBloom),
              matching: find.byType(CustomPaint),
            ),
          );

      testWidgets('paints a custom multi-pool sweep, wrapped for repaint',
          (tester) async {
        await pumpDs(
          tester,
          const SizedBox(width: 300, height: 200, child: DsBrandBloom.pools()),
        );

        expect(paintOf(tester).painter, isNotNull);
        expect(
          find.descendant(
            of: find.byType(DsBrandBloom),
            matching: find.byType(RepaintBoundary),
          ),
          findsOneWidget,
        );
      });

      testWidgets('is decorative: it exposes no semantics', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpDs(
          tester,
          const SizedBox(width: 300, height: 200, child: DsBrandBloom.pools()),
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

      testWidgets('paints on the neutral base and under a skin without overflow',
          (tester) async {
        // Neutral base: no bloomStops, so it falls back to a soft spread of
        // the single bloom colour.
        expect(DsTokens.light().bloomStops, isEmpty);
        await pumpDs(
          tester,
          const SizedBox.expand(child: DsBrandBloom.pools()),
          surfaceSize: const Size(320, 640),
        );
        expect(tester.takeException(), isNull);
        expect(paintOf(tester).painter, isNotNull);

        // Skinned: the Engen sweep supplies its own ordered stops.
        final skin = DsSkins.engenLight();
        expect(skin.bloomStops, hasLength(5));
        await pumpDs(
          tester,
          const SizedBox.expand(child: DsBrandBloom.pools()),
          theme: DsTheme.light(tokens: skin),
          surfaceSize: const Size(1440, 800),
        );
        expect(tester.takeException(), isNull);
      });
    });
  });
}
