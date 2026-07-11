import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsTakeover', () {
    testWidgets('renders the foreground card over the background',
        (tester) async {
      await pumpDs(
        tester,
        DsTakeover(
          background: const Center(child: Text('Dashboard')),
          child: const Text('Verify your email'),
        ),
      );

      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('background taps never land', (tester) async {
      var backgroundTaps = 0;
      await pumpDs(
        tester,
        DsTakeover(
          background: Center(
            child: DsButton(
              label: 'Background action',
              onPressed: () => backgroundTaps++,
            ),
          ),
          child: const Text('Card'),
        ),
      );

      await tester.tap(
        find.byType(DsButton),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(backgroundTaps, 0);
    });

    testWidgets('background is excluded from semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsTakeover(
          background: DsButton(label: 'Background action', onPressed: () {}),
          child: const Text('Card'),
        ),
      );

      expect(find.bySemanticsLabel('Background action'), findsNothing);
      expect(find.bySemanticsLabel('Card'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('background cannot take focus', (tester) async {
      final node = FocusNode(debugLabel: 'background-field');
      addTearDown(node.dispose);
      await pumpDs(
        tester,
        DsTakeover(
          background: Focus(focusNode: node, child: const Text('Dashboard')),
          child: const Text('Card'),
        ),
      );

      node.requestFocus();
      await tester.pump();

      expect(node.hasFocus, isFalse);
    });

    testWidgets('foreground controls stay interactive', (tester) async {
      var childTaps = 0;
      await pumpDs(
        tester,
        DsTakeover(
          background: const Text('Dashboard'),
          barrierDismissible: true,
          onDismiss: () {},
          child: DsButton(label: 'Continue', onPressed: () => childTaps++),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(childTaps, 1);
    });

    testWidgets('a barrier tap dismisses only when enabled', (tester) async {
      var dismissed = 0;
      await pumpDs(
        tester,
        DsTakeover(
          background: const Text('Dashboard'),
          barrierDismissible: true,
          onDismiss: () => dismissed++,
          child: const SizedBox(width: 120, height: 120, child: Text('Card')),
        ),
        surfaceSize: const Size(800, 600),
      );

      // Outside the card: dismisses.
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      expect(dismissed, 1);

      // On the card: does not dismiss.
      await tester.tap(find.text('Card'));
      await tester.pump();
      expect(dismissed, 1);
    });

    testWidgets('a barrier tap does nothing while not dismissible',
        (tester) async {
      var dismissed = 0;
      await pumpDs(
        tester,
        DsTakeover(
          background: const Text('Dashboard'),
          onDismiss: () => dismissed++,
          child: const Text('Card'),
        ),
        surfaceSize: const Size(800, 600),
      );

      await tester.tapAt(const Offset(20, 20));
      await tester.pump();

      expect(dismissed, 0);
    });

    testWidgets('paints the theme backdrop scrim by default', (tester) async {
      await pumpDs(
        tester,
        DsTakeover(
          background: const Text('Dashboard'),
          child: const Text('Card'),
        ),
      );

      final scrims = tester
          .widgetList<ColoredBox>(
            find.descendant(
              of: find.byType(DsTakeover),
              matching: find.byType(ColoredBox),
            ),
          )
          .map((box) => box.color);
      expect(scrims, contains(DsTokens.light().overlayBackdropColor));
    });

    testWidgets('accepts a custom scrim colour', (tester) async {
      const scrim = Color(0x330000FF);
      await pumpDs(
        tester,
        DsTakeover(
          background: const Text('Dashboard'),
          scrimColor: scrim,
          child: const Text('Card'),
        ),
      );

      final scrims = tester
          .widgetList<ColoredBox>(
            find.descendant(
              of: find.byType(DsTakeover),
              matching: find.byType(ColoredBox),
            ),
          )
          .map((box) => box.color);
      expect(scrims, contains(scrim));
    });

    testWidgets('a tall card scrolls instead of overflowing', (tester) async {
      await pumpDs(
        tester,
        DsTakeover(
          background: const Text('Dashboard'),
          child: const SizedBox(height: 1200, child: Placeholder()),
        ),
        surfaceSize: const Size(320, 480),
      );

      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at a wide width', (tester) async {
      await pumpDs(
        tester,
        DsTakeover(
          background: const Text('Dashboard'),
          child: const Text('Card'),
        ),
        surfaceSize: const Size(1920, 800),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
