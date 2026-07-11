import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsAuthGradient', () {
    DecoratedBox washBox(WidgetTester tester) {
      return tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(DsAuthGradient),
          matching: find.byType(DecoratedBox),
        ),
      );
    }

    testWidgets('paints the theme wash stops top to bottom', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(width: 200, height: 200, child: DsAuthGradient()),
      );

      final decoration = washBox(tester).decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient?;
      expect(gradient, isNotNull);
      expect(gradient!.colors, DsTokens.light().authWashGradient);
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
    });

    testWidgets('reads restyled stops from the theme', (tester) async {
      final skinned = DsSkins.engenLight();
      await pumpDs(
        tester,
        const SizedBox(width: 200, height: 200, child: DsAuthGradient()),
        theme: DsTheme.light(tokens: skinned),
      );

      final decoration = washBox(tester).decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient?;
      expect(gradient!.colors, skinned.authWashGradient);
    });

    testWidgets('degrades to a solid fill when a skin supplies one stop',
        (tester) async {
      final oneStop = DsTokens.light().copyWith(
        authWashGradient: const [Color(0xFFEBEEF1)],
      );
      await pumpDs(
        tester,
        const SizedBox(width: 200, height: 200, child: DsAuthGradient()),
        theme: DsTheme.light(tokens: oneStop),
      );

      final decoration = washBox(tester).decoration as BoxDecoration;
      expect(decoration.gradient, isNull);
      expect(decoration.color, const Color(0xFFEBEEF1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays its child over the wash, filling the bounds',
        (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          width: 240,
          height: 180,
          child: DsAuthGradient(child: Center(child: Text('Card'))),
        ),
      );

      expect(find.text('Card'), findsOneWidget);
      expect(
        tester.getSize(find.byType(DsAuthGradient)),
        const Size(240, 180),
      );
    });

    testWidgets('is decorative: the wash exposes no semantics of its own',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const SizedBox(
          width: 200,
          height: 200,
          child: DsAuthGradient(child: Center(child: Text('Sign in'))),
        ),
      );

      // The child's semantics survive; the wash adds none.
      expect(find.bySemanticsLabel('Sign in'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DsAuthGradient),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        const DsAuthGradient(child: Center(child: Text('Narrow'))),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at a wide width', (tester) async {
      await pumpDs(
        tester,
        const DsAuthGradient(child: Center(child: Text('Wide'))),
        surfaceSize: const Size(1920, 800),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
