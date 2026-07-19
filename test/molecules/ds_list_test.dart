import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsList', () {
    testWidgets('renders its children', (tester) async {
      await pumpDs(
        tester,
        const DsList(
          children: [
            DsListItem(title: 'First'),
            DsListItem(title: 'Second'),
            DsListItem(title: 'Third'),
          ],
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
    });

    testWidgets('draws dividers between children when showDividers is true',
        (tester) async {
      await pumpDs(
        tester,
        const DsList(
          children: [
            DsListItem(title: 'First'),
            DsListItem(title: 'Second'),
            DsListItem(title: 'Third'),
          ],
        ),
      );

      // Three children -> two separating dividers.
      expect(find.byType(DsDivider), findsNWidgets(2));
    });

    testWidgets('draws no dividers when showDividers is false', (tester) async {
      await pumpDs(
        tester,
        const DsList(
          showDividers: false,
          children: [
            DsListItem(title: 'First'),
            DsListItem(title: 'Second'),
            DsListItem(title: 'Third'),
          ],
        ),
      );

      expect(find.byType(DsDivider), findsNothing);
    });

    testWidgets('bordered wraps the list in a bordered container',
        (tester) async {
      await pumpDs(
        tester,
        const DsList(
          bordered: true,
          children: [
            DsListItem(title: 'First'),
            DsListItem(title: 'Second'),
          ],
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('First'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.borderRadius, isNotNull);
      expect(container.clipBehavior, Clip.antiAlias);
    });

    testWidgets('is not bordered by default', (tester) async {
      await pumpDs(
        tester,
        const DsList(
          children: [
            DsListItem(title: 'First'),
          ],
        ),
      );

      // No decorated container wrapping the content.
      expect(
        find.ancestor(
          of: find.text('First'),
          matching: find.byType(Container),
        ),
        findsNothing,
      );
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        const DsList(
          bordered: true,
          children: [
            DsListItem(
              title: 'A rather long list item title that must wrap gracefully',
              subtitle: 'With an equally verbose supporting subtitle line',
            ),
            DsListItem(title: 'Second item'),
            DsListItem(title: 'Third item'),
          ],
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
