import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsAnimatedEllipsis', () {
    List<String?> dotTexts(WidgetTester tester) => tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(DsAnimatedEllipsis),
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data)
        .toList();

    testWidgets('cycles the dots while waiting', (tester) async {
      await pumpDs(tester, const DsAnimatedEllipsis());

      // Two texts: the invisible width reservation and the animated dots,
      // which start empty.
      expect(dotTexts(tester), containsAll(<String>['...', '']));

      await tester.pump(DsMotion.slow);
      expect(dotTexts(tester), contains('.'));

      await tester.pump(DsMotion.slow);
      expect(dotTexts(tester), contains('..'));

      await tester.pump(DsMotion.slow);
      expect(dotTexts(tester), equals(<String>['...', '...']));
    });

    testWidgets('keeps a steady footprint while the dots change',
        (tester) async {
      await pumpDs(tester, const DsAnimatedEllipsis());
      final settled = tester.getSize(find.byType(DsAnimatedEllipsis));

      await tester.pump(DsMotion.slow);
      expect(tester.getSize(find.byType(DsAnimatedEllipsis)), settled);

      await tester.pump(DsMotion.slow);
      expect(tester.getSize(find.byType(DsAnimatedEllipsis)), settled);
    });

    testWidgets('renders a static full ellipsis under reduced motion',
        (tester) async {
      await pumpDs(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: DsAnimatedEllipsis(),
        ),
      );

      expect(dotTexts(tester), equals(<String>['...']));

      // Nothing animates: the frame is identical after time passes.
      await tester.pump(DsMotion.slow);
      expect(dotTexts(tester), equals(<String>['...']));
    });

    testWidgets('honours a custom dot count', (tester) async {
      await pumpDs(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: DsAnimatedEllipsis(dotCount: 5),
        ),
      );

      expect(dotTexts(tester), equals(<String>['.....']));
    });

    testWidgets('is excluded from semantics by default', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: DsAnimatedEllipsis(),
        ),
      );

      expect(find.bySemanticsLabel('...'), findsNothing);
      handle.dispose();
    });

    testWidgets('can expose the dots when it stands alone', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: DsAnimatedEllipsis(excludeFromSemantics: false),
        ),
      );

      expect(find.bySemanticsLabel('...'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('sits inline in waiting copy at 320dp', (tester) async {
      await pumpDs(
        tester,
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Preparing your workspace'),
              WidgetSpan(child: DsAnimatedEllipsis()),
            ],
          ),
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('sits inline in waiting copy at a wide width', (tester) async {
      await pumpDs(
        tester,
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Preparing your workspace'),
              WidgetSpan(child: DsAnimatedEllipsis()),
            ],
          ),
        ),
        surfaceSize: const Size(1920, 800),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
