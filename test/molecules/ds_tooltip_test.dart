import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

import '../helpers.dart';

void main() {
  group('DsTooltip', () {
    testWidgets('renders its child', (tester) async {
      await pumpDs(
        tester,
        const DsTooltip(
          message: 'Copy to clipboard',
          child: Text('Copy'),
        ),
      );

      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('wraps child in a Tooltip carrying the message', (tester) async {
      await pumpDs(
        tester,
        const DsTooltip(
          message: 'Helpful hint',
          child: Icon(Icons.info_outline),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Helpful hint');
      expect(tooltip.preferBelow, isTrue);
    });

    testWidgets('honours preferBelow override', (tester) async {
      await pumpDs(
        tester,
        const DsTooltip(
          message: 'Above me',
          preferBelow: false,
          child: Text('Anchor'),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.preferBelow, isFalse);
    });

    testWidgets('shows the bubble on long-press', (tester) async {
      await pumpDs(
        tester,
        const DsTooltip(
          message: 'Long pressed hint',
          child: Text('Anchor'),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Anchor')),
      );
      await tester.pump(const Duration(seconds: 1));
      await gesture.up();
      await tester.pump();

      // The message text is now painted inside the overlay bubble in addition
      // to being carried by the Tooltip widget.
      expect(find.text('Long pressed hint'), findsWidgets);
    });

    testWidgets('renders without overflow on a 320dp phone', (tester) async {
      await pumpDs(
        tester,
        const DsTooltip(
          message:
              'A rather long tooltip message that should wrap onto multiple '
              'lines instead of overflowing on a narrow screen.',
          child: Text('Anchor'),
        ),
        surfaceSize: const Size(320, 900),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a large desktop', (tester) async {
      await pumpDs(
        tester,
        const DsTooltip(
          message: 'Contextual help for a wide layout.',
          child: Text('Anchor'),
        ),
        surfaceSize: const Size(1200, 900),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
