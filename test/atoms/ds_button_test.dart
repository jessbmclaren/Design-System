import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsButton', () {
    testWidgets('renders its label', (tester) async {
      await pumpDs(tester, const DsButton(label: 'Continue'));

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('renders a leading icon when set', (tester) async {
      await pumpDs(
        tester,
        const DsButton(label: 'Add', icon: Icons.add),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsButton(label: 'Save', onPressed: () => taps++),
      );

      await tester.tap(find.byType(DsButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('a null onPressed disables it and swallows taps',
        (tester) async {
      await pumpDs(tester, const DsButton(label: 'Disabled'));

      // Tapping a disabled button must not throw and does nothing observable.
      await tester.tap(find.byType(DsButton), warnIfMissed: false);
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('pending shows a spinner and blocks taps', (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsButton(
          label: 'Saving',
          pending: true,
          onPressed: () => taps++,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // The label is replaced by the spinner while pending.
      expect(find.text('Saving'), findsNothing);

      await tester.tap(find.byType(DsButton), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('all three variants render', (tester) async {
      for (final variant in DsButtonVariant.values) {
        await pumpDs(
          tester,
          DsButton(
            label: 'Action',
            variant: variant,
            onPressed: () {},
          ),
        );
        await tester.pump();

        expect(find.byType(DsButton), findsOneWidget);
        expect(find.text('Action'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('does not overflow at 320dp with fullWidth', (tester) async {
      await pumpDs(
        tester,
        DsButton(
          label: 'Full width action label',
          fullWidth: true,
          icon: Icons.check,
          onPressed: () {},
        ),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
