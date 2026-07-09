import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// A columns set covering every cell type.
final _columns = <DsGridColumn>[
  const DsGridColumn(key: 'name', title: 'Name', frozen: true, width: 160),
  const DsGridColumn(key: 'status', title: 'Status', type: DsCellType.status, width: 120),
  const DsGridColumn(key: 'owner', title: 'Owner', type: DsCellType.user, width: 160),
  const DsGridColumn(key: 'amount', title: 'Amount', type: DsCellType.currency, currencySymbol: r'$', width: 120),
  const DsGridColumn(key: 'due', title: 'Due', type: DsCellType.date, width: 120),
  const DsGridColumn(key: 'active', title: 'Active', type: DsCellType.checkbox, width: 80),
  const DsGridColumn(key: 'progress', title: 'Progress', type: DsCellType.progress, width: 120),
  const DsGridColumn(key: 'link', title: 'Link', type: DsCellType.link, width: 140),
];

List<DsGridRow> _rows() => [
      DsGridRow(id: '1', cells: {
        'name': 'Acme Corp', 'status': 'Active', 'owner': 'Ada Lovelace',
        'amount': 1240, 'due': DateTime(2026, 7, 1), 'active': true,
        'progress': 0.8, 'link': 'Open',
      }),
      DsGridRow(id: '2', cells: {
        'name': 'Northwind', 'status': 'Pending', 'owner': 'Grace Hopper',
        'amount': 8900, 'due': DateTime(2026, 8, 15), 'active': false,
        'progress': 0.35, 'link': 'Open',
      }),
      DsGridRow(id: '3', cells: {
        'name': 'Globex', 'status': 'Failed', 'owner': 'Alan Turing',
        'amount': 320, 'due': DateTime(2026, 6, 20), 'active': true,
        'progress': 0.1, 'link': 'Open',
      }),
    ];

void main() {
  group('DsDataGrid', () {
    testWidgets('renders headers and cell values (wide)', (tester) async {
      await pumpDs(
        tester,
        SizedBox(height: 400, child: DsDataGrid(columns: _columns, rows: _rows())),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();
      expect(find.text('Acme Corp'), findsOneWidget);
      expect(find.text('Northwind'), findsOneWidget);
      // Status renders as a badge label.
      expect(find.text('Active'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a sortable header cycles sort', (tester) async {
      DsGridSort? sort;
      await pumpDs(
        tester,
        SizedBox(
          height: 400,
          child: DsDataGrid(
            columns: _columns,
            rows: _rows(),
            onSort: (s) => sort = s,
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();
      // Header titles render uppercased ('NAME') but carry the original-case
      // title in their semantics label, so tap by the visible glyph.
      await tester.tap(find.text('NAME').first);
      await tester.pump();
      expect(sort, isNotNull);
      expect(sort!.columnKey, 'name');
    });

    testWidgets('select-all reports every row id', (tester) async {
      Set<String> selected = {};
      await pumpDs(
        tester,
        SizedBox(
          height: 400,
          child: DsDataGrid(
            columns: _columns,
            rows: _rows(),
            selectable: true,
            onSelectionChanged: (s) => selected = s,
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();
      // The select-all header is a custom glyph, tappable by its semantics label.
      await tester.tap(find.bySemanticsLabel('Select all rows'));
      await tester.pump();
      expect(selected.length, 3);
    });

    testWidgets('collapses to stacked cards on a small phone', (tester) async {
      await pumpDs(
        tester,
        DsDataGrid(columns: _columns, rows: _rows(), compactBreakpoint: 640),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();
      // Column titles appear as keys in the stacked cards.
      expect(find.text('Acme Corp'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty state renders when there are no rows', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 300,
          child: DsDataGrid(columns: [
            DsGridColumn(key: 'name', title: 'Name'),
          ], rows: []),
        ),
        surfaceSize: const Size(1000, 600),
      );
      await tester.pump();
      expect(find.textContaining('No records'), findsOneWidget);
    });

    testWidgets('no overflow across device widths', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;
      for (final w in <double>[320, 390, 600, 768, 1024, 1440, 1920]) {
        tester.view.physicalSize = Size(w, 1000);
        await tester.pumpWidget(
          MaterialApp(
            theme: DsTheme.light(),
            home: Scaffold(
              body: SizedBox(
                height: 700,
                child: DsDataGrid(columns: _columns, rows: _rows()),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'overflow at ${w}dp');
      }
    });
  });
}
