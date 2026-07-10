import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsFadeSlideIn', () {
    Finder fadeFinder() => find.descendant(
          of: find.byType(DsFadeSlideIn),
          matching: find.byType(FadeTransition),
        );

    double opacityOf(WidgetTester tester) =>
        tester.widget<FadeTransition>(fadeFinder()).opacity.value;

    testWidgets('fades its child in once on mount', (tester) async {
      await pumpDs(
        tester,
        const DsFadeSlideIn(child: Text('Welcome aboard')),
      );

      expect(find.text('Welcome aboard'), findsOneWidget);
      expect(opacityOf(tester), 0);

      await tester.pump(DsMotion.expressive);
      expect(opacityOf(tester), 1);

      // It never replays.
      await tester.pump(DsMotion.expressive);
      expect(opacityOf(tester), 1);
    });

    testWidgets('slides the child up into its resting position',
        (tester) async {
      await pumpDs(
        tester,
        const DsFadeSlideIn(offset: 20, child: Text('Rises')),
      );
      final before = tester.getTopLeft(find.text('Rises'));

      await tester.pump(DsMotion.expressive);
      final after = tester.getTopLeft(find.text('Rises'));

      expect(before.dy - after.dy, moreOrLessEquals(20));
      expect(before.dx, after.dx);
    });

    testWidgets('waits for its delay before starting', (tester) async {
      await pumpDs(
        tester,
        const DsFadeSlideIn(
          delay: Duration(milliseconds: 200),
          child: Text('Second card'),
        ),
      );

      await tester.pump(const Duration(milliseconds: 199));
      expect(opacityOf(tester), 0);

      // The delay elapses, then the entrance runs to completion.
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(DsMotion.expressive);
      expect(opacityOf(tester), 1);
    });

    testWidgets('shows the settled frame under reduced motion',
        (tester) async {
      await pumpDs(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: DsFadeSlideIn(
            delay: Duration(milliseconds: 200),
            child: Text('No choreography'),
          ),
        ),
      );

      // Fully visible on the first frame, delay and all ignored.
      expect(opacityOf(tester), 1);
      expect(find.text('No choreography'), findsOneWidget);
    });

    testWidgets('exposes semantics before the entrance completes',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const DsFadeSlideIn(child: Text('Welcome aboard')),
      );

      // Mid-entrance the child is still transparent yet already announced.
      expect(opacityOf(tester), 0);
      expect(find.bySemanticsLabel('Welcome aboard'), findsOneWidget);

      await tester.pump(DsMotion.expressive);
      handle.dispose();
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        const DsFadeSlideIn(
          child: Text(
            'A longer block of onboarding copy that has to wrap on a '
            'small phone without spilling out of its bounds.',
          ),
        ),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump(DsMotion.expressive);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at a wide width', (tester) async {
      await pumpDs(
        tester,
        const DsFadeSlideIn(child: Text('Wide layout content')),
        surfaceSize: const Size(1920, 800),
      );
      await tester.pump(DsMotion.expressive);

      expect(tester.takeException(), isNull);
    });
  });
}
