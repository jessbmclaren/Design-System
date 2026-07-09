import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsButtonGroup', () {
    testWidgets('renders inline actions on a wide surface', (tester) async {
      await pumpDs(
        tester,
        const DsButtonGroup(
          children: [
            DsButton(label: 'Save'),
            DsButton(label: 'Duplicate', variant: DsButtonVariant.secondary),
            DsButton(label: 'Delete', variant: DsButtonVariant.danger),
          ],
        ),
        surfaceSize: const Size(1200, 900),
      );

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Duplicate'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      // Everything fits inline, so there is no overflow affordance.
      expect(find.byIcon(Icons.more_horiz), findsNothing);
    });

    testWidgets('fires a visible action callback when tapped', (tester) async {
      var tapped = false;
      await pumpDs(
        tester,
        DsButtonGroup(
          children: [
            DsButton(label: 'Save', onPressed: () => tapped = true),
            const DsButton(
              label: 'Delete',
              variant: DsButtonVariant.danger,
            ),
          ],
        ),
        surfaceSize: const Size(1200, 900),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('collapses trailing actions into an overflow menu', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsButtonGroup(
          maxVisible: 1,
          children: [
            DsButton(label: 'Save'),
            DsButton(label: 'Duplicate', variant: DsButtonVariant.secondary),
            DsButton(label: 'Delete', variant: DsButtonVariant.danger),
          ],
        ),
        surfaceSize: const Size(1200, 900),
      );

      // Only the first action stays inline; the rest move to the More menu.
      expect(find.text('Save'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets('overflow menu opens and fires a collapsed callback', (
      tester,
    ) async {
      var deleted = false;
      await pumpDs(
        tester,
        DsButtonGroup(
          maxVisible: 1,
          children: [
            const DsButton(label: 'Save'),
            DsButton(
              label: 'Delete',
              variant: DsButtonVariant.danger,
              onPressed: () => deleted = true,
            ),
          ],
        ),
        surfaceSize: const Size(1200, 900),
      );

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pump();

      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(deleted, isTrue);
    });

    testWidgets('renders nothing when there are no children', (tester) async {
      await pumpDs(
        tester,
        const DsButtonGroup(children: []),
        surfaceSize: const Size(1200, 900),
      );

      expect(find.byType(DsButton), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow on a small phone', (tester) async {
      await pumpDs(
        tester,
        const DsButtonGroup(
          children: [
            DsButton(label: 'Save'),
            DsButton(label: 'Duplicate', variant: DsButtonVariant.secondary),
            DsButton(label: 'Delete', variant: DsButtonVariant.danger),
          ],
        ),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow on a large desktop', (tester) async {
      await pumpDs(
        tester,
        const DsButtonGroup(
          children: [
            DsButton(label: 'Save'),
            DsButton(label: 'Duplicate', variant: DsButtonVariant.secondary),
            DsButton(label: 'Delete', variant: DsButtonVariant.danger),
          ],
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
