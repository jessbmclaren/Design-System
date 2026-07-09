import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsDataTable', () {
    const columns = [
      DsColumn(label: 'Name'),
      DsColumn(label: 'Amount', numeric: true),
    ];

    const rows = [
      DsDataRow(cells: ['Alice', '100']),
      DsDataRow(cells: ['Bob', '250']),
    ];

    testWidgets('renders headers and cell values in wide table layout',
        (tester) async {
      await pumpDs(
        tester,
        const DsDataTable(columns: columns, rows: rows),
        surfaceSize: const Size(1000, 800),
      );
      await tester.pump();

      // Wide layout uppercases the header labels.
      expect(find.text('NAME'), findsOneWidget);
      expect(find.text('AMOUNT'), findsOneWidget);

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders stacked cards with column labels as keys when compact',
        (tester) async {
      await pumpDs(
        tester,
        const DsDataTable(columns: columns, rows: rows),
        surfaceSize: const Size(320, 800),
      );
      await tester.pump();

      // Compact layout shows the column labels as keys (not uppercased) and
      // repeats them once per row card.
      expect(find.text('Name'), findsNWidgets(2));
      expect(find.text('Amount'), findsNWidgets(2));

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('row onTap fires when tapped in wide layout', (tester) async {
      var tapped = 0;
      await pumpDs(
        tester,
        DsDataTable(
          columns: columns,
          rows: [
            DsDataRow(cells: const ['Alice', '100'], onTap: () => tapped++),
            const DsDataRow(cells: ['Bob', '250']),
          ],
        ),
        surfaceSize: const Size(1000, 800),
      );
      await tester.pump();

      await tester.tap(find.text('Alice'));
      await tester.pump();

      expect(tapped, 1);
    });

    testWidgets('row onTap fires when tapped in compact layout',
        (tester) async {
      var tapped = 0;
      await pumpDs(
        tester,
        DsDataTable(
          columns: columns,
          rows: [
            DsDataRow(cells: const ['Alice', '100'], onTap: () => tapped++),
            const DsDataRow(cells: ['Bob', '250']),
          ],
        ),
        surfaceSize: const Size(320, 800),
      );
      await tester.pump();

      await tester.tap(find.text('Alice'));
      await tester.pump();

      expect(tapped, 1);
    });
  });
}
