import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsEmptyState', () {
    testWidgets('renders title, message and icon', (tester) async {
      await pumpDs(
        tester,
        const DsEmptyState(
          title: 'No customers yet',
          message: 'Add your first customer to get started.',
          icon: Icons.people_outline,
        ),
      );

      expect(find.text('No customers yet'), findsOneWidget);
      expect(find.text('Add your first customer to get started.'),
          findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('renders title only, without optional message, icon or action',
        (tester) async {
      await pumpDs(
        tester,
        const DsEmptyState(title: 'Nothing here'),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byType(DsButton), findsNothing);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('action button fires onPressed when tapped', (tester) async {
      var tapped = false;

      await pumpDs(
        tester,
        DsEmptyState(
          title: 'No results',
          action: DsEmptyStateAction(
            label: 'Clear filters',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(DsButton), findsOneWidget);
      expect(tapped, isFalse);

      await tester.tap(find.text('Clear filters'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        DsEmptyState(
          title: 'Your inbox is empty',
          message:
              'Messages you receive will appear here so you can respond to '
              'them quickly and keep everything in one place.',
          icon: Icons.inbox_outlined,
          action: DsEmptyStateAction(
            label: 'Compose message',
            onPressed: () {},
          ),
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
