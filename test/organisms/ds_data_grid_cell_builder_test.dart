import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsDataGrid cellBuilder', () {
    testWidgets('a column with cellBuilder renders the custom widget instead '
        'of the default renderer', (tester) async {
      final columns = <DsGridColumn>[
        DsGridColumn(
          key: 'code',
          title: 'Code',
          cellBuilder: (context, value, row) => Text('CUSTOM-$value'),
        ),
        const DsGridColumn(key: 'name', title: 'Name'),
      ];
      final rows = <DsGridRow>[
        const DsGridRow(id: '1', cells: {'code': 'A', 'name': 'Acme'}),
        const DsGridRow(id: '2', cells: {'code': 'B', 'name': 'Northwind'}),
      ];
      await pumpDs(
        tester,
        SizedBox(
          height: 300,
          width: 600,
          child: DsDataGrid(columns: columns, rows: rows),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();
      expect(find.text('CUSTOM-A'), findsOneWidget);
      expect(find.text('CUSTOM-B'), findsOneWidget);
      // The default text renderer is replaced, so the raw value never shows.
      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('passes the raw cell value through to the builder',
        (tester) async {
      final received = <Object?>[];
      final columns = <DsGridColumn>[
        DsGridColumn(
          key: 'seats',
          title: 'Seats',
          cellBuilder: (context, value, row) {
            received.add(value);
            return Text('#$value');
          },
        ),
      ];
      final rows = <DsGridRow>[
        const DsGridRow(id: '1', cells: {'seats': 7}),
        const DsGridRow(id: '2', cells: {'seats': 42}),
      ];
      await pumpDs(
        tester,
        SizedBox(
          height: 300,
          width: 600,
          child: DsDataGrid(columns: columns, rows: rows),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();
      // The builder receives the untouched values, not a formatted string.
      expect(received.toSet(), <Object?>{7, 42});
      expect(find.text('#7'), findsOneWidget);
      expect(find.text('#42'), findsOneWidget);
    });

    testWidgets('columns without cellBuilder still render normally alongside',
        (tester) async {
      final columns = <DsGridColumn>[
        DsGridColumn(
          key: 'code',
          title: 'Code',
          cellBuilder: (context, value, row) => Text('CUSTOM-$value'),
        ),
        const DsGridColumn(key: 'name', title: 'Name'),
        const DsGridColumn(
          key: 'status',
          title: 'Status',
          type: DsCellType.status,
          width: 120,
        ),
      ];
      final rows = <DsGridRow>[
        const DsGridRow(
          id: '1',
          cells: {'code': 'A', 'name': 'Acme', 'status': 'Active'},
        ),
      ];
      await pumpDs(
        tester,
        SizedBox(
          height: 300,
          width: 600,
          child: DsDataGrid(columns: columns, rows: rows),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();
      expect(find.text('CUSTOM-A'), findsOneWidget);
      // The plain text and status columns keep their default renderers.
      expect(find.text('Acme'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('a date column builder can render a DsExpiryDate with a fixed '
        'clock', (tester) async {
      final now = DateTime(2026, 7, 22);
      final columns = <DsGridColumn>[
        const DsGridColumn(key: 'name', title: 'Name'),
        DsGridColumn(
          key: 'expiry',
          title: 'Expiry',
          type: DsCellType.date,
          width: 180,
          cellBuilder: (context, value, row) => value is DateTime
              ? DsExpiryDate(date: value, now: now, dense: true, showIcon: false)
              : const Text('—'),
        ),
      ];
      final rows = <DsGridRow>[
        DsGridRow(
          id: '1',
          cells: {'name': 'Licence', 'expiry': DateTime(2026, 8, 15)},
        ),
      ];
      await pumpDs(
        tester,
        SizedBox(
          height: 300,
          width: 600,
          child: DsDataGrid(columns: columns, rows: rows, rowHeight: 56),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();
      expect(find.text('15 Aug 2026'), findsOneWidget);
      expect(find.text('in 24 days'), findsOneWidget);
      // The default yyyy-MM-dd date renderer is replaced.
      expect(find.text('2026-08-15'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('passes the row alongside the value, so a cell knows which '
        'record it is', (tester) async {
      final seen = <String, Object?>{};
      final columns = <DsGridColumn>[
        DsGridColumn(
          key: 'seats',
          title: 'Seats',
          cellBuilder: (context, value, row) {
            seen[row.id] = value;
            return Text('${row.cells['name']}: $value');
          },
        ),
      ];
      final rows = <DsGridRow>[
        const DsGridRow(id: 'a', cells: {'name': 'Acme', 'seats': 7}),
        const DsGridRow(id: 'b', cells: {'name': 'Northwind', 'seats': 42}),
      ];
      await pumpDs(
        tester,
        SizedBox(
          height: 300,
          width: 600,
          child: DsDataGrid(columns: columns, rows: rows),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();
      // Each builder call is handed the row its value came from, so a cell can
      // read the row's other fields and report its id back.
      expect(seen, <String, Object?>{'a': 7, 'b': 42});
      expect(find.text('Acme: 7'), findsOneWidget);
      expect(find.text('Northwind: 42'), findsOneWidget);
    });

    testWidgets('an interactive custom cell receives taps and reports its row',
        (tester) async {
      final toggled = <String, bool>{};
      final enabled = <String, bool>{'a': true, 'b': false};
      final columns = <DsGridColumn>[
        const DsGridColumn(key: 'name', title: 'Name'),
        DsGridColumn(
          key: 'enabled',
          title: 'Enabled',
          width: 96,
          align: DsColumnAlign.center,
          cellBuilder: (context, value, row) => DsSwitch(
            value: value == true,
            semanticLabel: 'Enable ${row.cells['name']}',
            onChanged: (next) => toggled[row.id] = next,
          ),
        ),
      ];
      List<DsGridRow> buildRows() => <DsGridRow>[
            for (final entry in enabled.entries)
              DsGridRow(
                id: entry.key,
                cells: {
                  'name': entry.key == 'a' ? 'Acme' : 'Northwind',
                  'enabled': entry.value,
                },
              ),
          ];
      await pumpDs(
        tester,
        SizedBox(
          // Wide enough for the table layout, so both rows are on screen.
          height: 300,
          width: 900,
          child: DsDataGrid(columns: columns, rows: buildRows()),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      // The switch inside the cell is hit-testable: the cell's overflow guard
      // is inert and does not swallow the tap.
      await tester.tap(find.bySemanticsLabel('Enable Northwind'));
      await tester.pumpAndSettle();
      expect(toggled, <String, bool>{'b': true});

      await tester.tap(find.bySemanticsLabel('Enable Acme'));
      await tester.pumpAndSettle();
      expect(toggled, <String, bool>{'b': true, 'a': false});
      expect(tester.takeException(), isNull);
    });

    testWidgets('a custom cell is exempt from inline editing, so its own '
        'controls keep the pointer', (tester) async {
      var edits = 0;
      final columns = <DsGridColumn>[
        const DsGridColumn(key: 'name', title: 'Name', editable: true),
        DsGridColumn(
          key: 'enabled',
          title: 'Enabled',
          width: 96,
          // Opting into editing *and* supplying a builder: the builder wins.
          editable: true,
          cellBuilder: (context, value, row) => DsSwitch(
            value: value == true,
            semanticLabel: 'Enable ${row.cells['name']}',
            onChanged: (_) {},
          ),
        ),
      ];
      final rows = <DsGridRow>[
        const DsGridRow(id: 'a', cells: {'name': 'Acme', 'enabled': true}),
      ];
      await pumpDs(
        tester,
        SizedBox(
          height: 300,
          width: 600,
          child: DsDataGrid(
            columns: columns,
            rows: rows,
            editable: true,
            onCellChanged: (rowId, columnKey, value) => edits++,
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      // The plain editable column still offers its tap-to-edit affordance…
      expect(find.bySemanticsLabel('Edit Name'), findsOneWidget);
      // …while the custom column has none wrapped around the switch.
      expect(find.bySemanticsLabel('Edit Enabled'), findsNothing);
      expect(find.bySemanticsLabel('Enable Acme'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Enable Acme'));
      await tester.pumpAndSettle();
      // No inline editor opened over the switch.
      expect(find.byType(TextField), findsNothing);
      expect(edits, 0);
      expect(tester.takeException(), isNull);
    });
  });
}
