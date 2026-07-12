import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsSpotlight', () {
    testWidgets('renders the title, body and action over the page', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsSpotlight(
          title: 'Verify your business to go live',
          body: 'Verify your company to switch on the tasks below.',
          actionLabel: 'Verify business',
          child: SizedBox.expand(),
        ),
      );

      expect(find.text('Verify your business to go live'), findsOneWidget);
      expect(
        find.text('Verify your company to switch on the tasks below.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(DsButton, 'Verify business'), findsOneWidget);
    });

    testWidgets('the action fires', (tester) async {
      var acted = 0;
      await pumpDs(
        tester,
        DsSpotlight(
          title: 'Verify your business to go live',
          actionLabel: 'Verify business',
          onAction: () => acted++,
          child: const SizedBox.expand(),
        ),
      );

      await tester.tap(find.widgetWithText(DsButton, 'Verify business'));
      expect(acted, 1);
    });

    testWidgets('the washed page is a barrier: its controls are not tappable', (
      tester,
    ) async {
      var behind = 0;
      await pumpDs(
        tester,
        DsSpotlight(
          title: 'Verify your business to go live',
          actionLabel: 'Verify business',
          onAction: () {},
          // A control sitting under the wash, in the top-left away from the
          // bottom message, must not receive taps while the spotlight is up.
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 200,
              height: 100,
              child: DsButton(label: 'Behind', onPressed: () => behind++),
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(DsButton, 'Behind'));
      expect(behind, 0, reason: 'the washed page must not be interactive');
    });

    testWidgets('the washed page is excluded from semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const DsSpotlight(
          title: 'Verify your business to go live',
          actionLabel: 'Verify business',
          child: Text('Behind the wash'),
        ),
      );

      // The page text is still in the widget tree but hidden from a11y.
      expect(find.text('Behind the wash'), findsOneWidget);
      expect(find.bySemanticsLabel('Behind the wash'), findsNothing);
      handle.dispose();
    });

    testWidgets('the title is announced as a header', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const DsSpotlight(
          title: 'Verify your business to go live',
          child: SizedBox.expand(),
        ),
      );

      expect(
        tester.getSemantics(find.text('Verify your business to go live')),
        matchesSemantics(isHeader: true, label: 'Verify your business to go live'),
      );
      handle.dispose();
    });

    testWidgets('docked centres the message; floating anchors right', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsSpotlight(
          title: 'Docked title',
          child: SizedBox.expand(),
        ),
        surfaceSize: const Size(900, 700),
      );
      final dockedX = tester.getCenter(find.text('Docked title')).dx;

      await pumpDs(
        tester,
        const DsSpotlight(
          title: 'Docked title',
          docked: true,
          child: SizedBox.expand(),
        ),
        surfaceSize: const Size(900, 700),
      );
      final centredX = tester.getCenter(find.text('Docked title')).dx;

      // Floating hugs the right; docked pulls the message toward centre.
      expect(centredX, lessThan(dockedX));
    });

    testWidgets('renders without overflow at 320dp and a short viewport', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsSpotlight(
          title: 'Verify your business to go live so everything unlocks',
          body: 'A deliberately long supporting line that must wrap and never '
              'overflow on a small phone at the bottom of the page.',
          actionLabel: 'Verify business',
          child: SizedBox.expand(),
        ),
        surfaceSize: const Size(320, 480),
      );
      expect(tester.takeException(), isNull);

      // A short landscape viewport: the message clamps its inset and scrolls.
      await pumpDs(
        tester,
        const DsSpotlight(
          title: 'Verify your business to go live',
          body: 'Supporting copy.',
          actionLabel: 'Verify business',
          child: SizedBox.expand(),
        ),
        surfaceSize: const Size(720, 320),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
