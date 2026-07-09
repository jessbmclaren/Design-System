import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsPageHeader', () {
    testWidgets('renders the title', (tester) async {
      await pumpDs(tester, const DsPageHeader(title: 'Invoices'));

      expect(find.text('Invoices'), findsOneWidget);
    });

    testWidgets('renders the subtitle when provided', (tester) async {
      await pumpDs(
        tester,
        const DsPageHeader(
          title: 'Invoices',
          subtitle: 'Manage and review your billing',
        ),
      );

      expect(find.text('Invoices'), findsOneWidget);
      expect(find.text('Manage and review your billing'), findsOneWidget);
    });

    testWidgets('omits the subtitle when not provided', (tester) async {
      await pumpDs(tester, const DsPageHeader(title: 'Invoices'));

      expect(find.text('Manage and review your billing'), findsNothing);
    });

    testWidgets('renders actions', (tester) async {
      await pumpDs(
        tester,
        DsPageHeader(
          title: 'Invoices',
          actions: [
            DsButton(label: 'New', onPressed: () {}),
          ],
        ),
        surfaceSize: const Size(1000, 800),
      );

      expect(find.text('Invoices'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('title and actions coexist on a wide surface', (tester) async {
      await pumpDs(
        tester,
        DsPageHeader(
          title: 'Invoices',
          subtitle: 'Billing overview',
          actions: [
            DsButton(label: 'Export', onPressed: () {}),
            DsButton(label: 'New', onPressed: () {}),
          ],
        ),
        surfaceSize: const Size(1000, 800),
      );

      expect(find.text('Invoices'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow on a narrow 320dp surface', (tester) async {
      await pumpDs(
        tester,
        DsPageHeader(
          title: 'A rather long page header title that must fit',
          subtitle: 'A supporting description that also needs room',
          actions: [
            DsButton(label: 'Export', onPressed: () {}),
            DsButton(label: 'New', onPressed: () {}),
          ],
        ),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(find.text('Export'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
