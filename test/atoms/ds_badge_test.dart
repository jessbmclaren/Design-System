import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsBadge', () {
    for (final variant in DsBadgeVariant.values) {
      testWidgets('renders its label for the ${variant.name} variant', (tester) async {
        await pumpDs(
          tester,
          DsBadge(label: 'Status', variant: variant),
        );
        await tester.pump();

        expect(find.text('Status'), findsOneWidget);
      });
    }

    testWidgets('renders an optional icon alongside the label', (tester) async {
      await pumpDs(
        tester,
        const DsBadge(label: 'Verified', icon: Icons.check),
      );
      await tester.pump();

      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('omits the icon when none is provided', (tester) async {
      await pumpDs(
        tester,
        const DsBadge(label: 'Plain'),
      );
      await tester.pump();

      expect(find.text('Plain'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('stays compact with a long label at 320dp', (tester) async {
      await pumpDs(
        tester,
        const DsBadge(
          label: 'A very long descriptive badge label that keeps going',
          icon: Icons.info_outline,
          variant: DsBadgeVariant.warning,
        ),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
