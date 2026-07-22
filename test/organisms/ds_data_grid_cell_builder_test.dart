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
          cellBuilder: (context, value) => Text('CUSTOM-$value'),
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
          cellBuilder: (context, value) {
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
          cellBuilder: (context, value) => Text('CUSTOM-$value'),
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
          cellBuilder: (context, value) => value is DateTime
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
  });
}
