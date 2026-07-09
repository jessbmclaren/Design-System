import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsAccordion', () {
    testWidgets('renders each item title', (tester) async {
      await pumpDs(
        tester,
        const DsAccordion(
          items: [
            DsAccordionItem(title: 'Shipping', child: Text('Ships fast.')),
            DsAccordionItem(title: 'Returns', child: Text('30-day window.')),
          ],
        ),
      );

      expect(find.text('Shipping'), findsOneWidget);
      expect(find.text('Returns'), findsOneWidget);
    });

    testWidgets('tapping a header expands and reveals the body', (tester) async {
      await pumpDs(
        tester,
        const DsAccordion(
          items: [
            DsAccordionItem(title: 'Shipping', child: Text('Ships fast.')),
          ],
        ),
      );

      // Collapsed: the body has zero height so its content is not visible.
      expect(find.text('Ships fast.'), findsNothing);

      await tester.tap(find.text('Shipping'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Ships fast.'), findsOneWidget);
    });

    testWidgets('initiallyExpanded item starts open', (tester) async {
      await pumpDs(
        tester,
        const DsAccordion(
          items: [
            DsAccordionItem(
              title: 'Open',
              initiallyExpanded: true,
              child: Text('Visible body.'),
            ),
          ],
        ),
      );

      expect(find.text('Visible body.'), findsOneWidget);
    });

    testWidgets('single-open mode closes others when a new one opens',
        (tester) async {
      await pumpDs(
        tester,
        const DsAccordion(
          items: [
            DsAccordionItem(
              title: 'First',
              initiallyExpanded: true,
              child: Text('First body.'),
            ),
            DsAccordionItem(title: 'Second', child: Text('Second body.')),
          ],
        ),
      );

      expect(find.text('First body.'), findsOneWidget);

      await tester.tap(find.text('Second'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // First collapses; second opens.
      expect(find.text('First body.'), findsNothing);
      expect(find.text('Second body.'), findsOneWidget);
    });

    testWidgets('allowMultiple keeps sections open independently',
        (tester) async {
      await pumpDs(
        tester,
        const DsAccordion(
          allowMultiple: true,
          items: [
            DsAccordionItem(
              title: 'First',
              initiallyExpanded: true,
              child: Text('First body.'),
            ),
            DsAccordionItem(title: 'Second', child: Text('Second body.')),
          ],
        ),
      );

      await tester.tap(find.text('Second'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('First body.'), findsOneWidget);
      expect(find.text('Second body.'), findsOneWidget);
    });

    testWidgets('renders without overflow from small phone to large desktop',
        (tester) async {
      const widget = DsAccordion(
        items: [
          DsAccordionItem(
            title: 'A very long accordion header that could wrap or overflow',
            leading: Icon(Icons.info_outline),
            initiallyExpanded: true,
            child: Text('Some descriptive body content for the section.'),
          ),
          DsAccordionItem(title: 'Returns', child: Text('30-day window.')),
        ],
      );

      await pumpDs(tester, widget, surfaceSize: const Size(320, 900));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await pumpDs(tester, widget, surfaceSize: const Size(1200, 900));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  });
}
