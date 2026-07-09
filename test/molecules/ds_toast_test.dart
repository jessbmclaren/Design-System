import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsToast', () {
    testWidgets('renders the message', (tester) async {
      await pumpDs(tester, const DsToast(message: 'Changes saved'));
      await tester.pump();

      expect(find.text('Changes saved'), findsOneWidget);
    });

    testWidgets('renders the optional leading icon', (tester) async {
      await pumpDs(
        tester,
        const DsToast(
          message: 'Changes saved',
          icon: Icons.check_circle_outline,
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('omits the icon when none is provided', (tester) async {
      await pumpDs(tester, const DsToast(message: 'No icon here'));
      await tester.pump();

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('renders the action label and fires its callback on tap',
        (tester) async {
      var tapped = false;
      await pumpDs(
        tester,
        DsToast(
          message: 'Item deleted',
          action: DsToastAction(
            label: 'Undo',
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('starts no timers when rendered statically', (tester) async {
      await pumpDs(
        tester,
        DsToast(
          message: 'Changes saved',
          icon: Icons.check_circle_outline,
          action: DsToastAction(label: 'Undo', onPressed: () {}),
        ),
      );
      // A single pump with no pending-timer failure proves the widget is
      // purely visual and schedules no auto-dismiss timer of its own.
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        DsToast(
          message: 'A slightly longer confirmation message for the user',
          icon: Icons.check_circle_outline,
          action: DsToastAction(label: 'Undo', onPressed: () {}),
        ),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
