import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const _columns = <DsGridColumn>[
  DsGridColumn(key: 'name', title: 'Name'),
  DsGridColumn(key: 'seats', title: 'Seats', type: DsCellType.number),
];

const _rows = <DsGridRow>[
  DsGridRow(id: 'a', cells: {'name': 'Acme', 'seats': 7}),
  DsGridRow(id: 'b', cells: {'name': 'Northwind', 'seats': 42}),
];

/// The distance from one row's baseline to the next — the pitch the grid
/// actually laid out with, which is what a reader perceives as row height.
/// Measured between rows rather than inside one, so the row's 1px separator
/// does not skew it.
double _rowPitch(WidgetTester tester) {
  return tester.getTopLeft(find.text('Northwind')).dy -
      tester.getTopLeft(find.text('Acme')).dy;
}

Future<void> _pumpGrid(
  WidgetTester tester, {
  DsGridDensity density = DsGridDensity.cosy,
  double? rowHeight,
}) async {
  await pumpDs(
    tester,
    SizedBox(
      height: 400,
      width: 900,
      child: DsDataGrid(
        columns: _columns,
        rows: _rows,
        density: density,
        rowHeight: rowHeight,
      ),
    ),
    surfaceSize: const Size(1200, 800),
  );
  await tester.pump();
}

void main() {
  group('DsDataGrid density', () {
    testWidgets('defaults to cosy, so an existing grid is unchanged', (
      tester,
    ) async {
      await _pumpGrid(tester);
      expect(
        _rowPitch(tester),
        DsGridDensity.cosy.rowHeightFrom(DsTokens.light()),
      );
      expect(DsGridDensity.cosy.rowHeightFrom(DsTokens.light()), 44);
    });

    testWidgets('each density lays rows out at its own height', (tester) async {
      for (final DsGridDensity density in DsGridDensity.values) {
        await _pumpGrid(tester, density: density);
        expect(
          _rowPitch(tester),
          density.rowHeightFrom(DsTokens.light()),
          reason: 'row height for $density',
        );
        expect(tester.takeException(), isNull, reason: 'overflow at $density');
      }
    });

    testWidgets('an explicit rowHeight overrides the density', (tester) async {
      await _pumpGrid(tester, density: DsGridDensity.compact, rowHeight: 72);
      expect(_rowPitch(tester), 72);
    });

    testWidgets('the header tracks the row height, so the frozen and '
        'scrolling panes stay aligned', (tester) async {
      const columns = <DsGridColumn>[
        DsGridColumn(key: 'name', title: 'Name', frozen: true),
        DsGridColumn(key: 'seats', title: 'Seats', type: DsCellType.number),
      ];
      for (final DsGridDensity density in DsGridDensity.values) {
        await pumpDs(
          tester,
          SizedBox(
            height: 400,
            width: 900,
            child: DsDataGrid(columns: columns, rows: _rows, density: density),
          ),
          surfaceSize: const Size(1200, 800),
        );
        await tester.pump();

        // The frozen column's first row and the scrolling column's first row
        // sit on the same baseline at every density.
        expect(
          tester.getTopLeft(find.text('Acme')).dy,
          tester.getTopLeft(find.text('7')).dy,
          reason: 'panes disagree at $density',
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('a skin restyles every density, because the heights are '
        'tokens rather than constants', (tester) async {
      // A denser brand: the same vocabulary, different heights.
      final DsTokens dense = DsTokens.light().copyWith(
        tableRowHeightComfortable: 48,
        tableRowHeightCosy: 36,
        tableRowHeightCompact: 28,
      );
      for (final DsGridDensity density in DsGridDensity.values) {
        await pumpDs(
          tester,
          SizedBox(
            height: 400,
            width: 900,
            child: DsDataGrid(
              columns: _columns,
              rows: _rows,
              density: density,
            ),
          ),
          surfaceSize: const Size(1200, 800),
          theme: DsTheme.light(tokens: dense),
        );
        await tester.pump();
        expect(
          _rowPitch(tester),
          density.rowHeightFrom(dense),
          reason: 'the skin\'s height for $density',
        );
        // …and it really is different from the base.
        expect(
          density.rowHeightFrom(dense),
          isNot(density.rowHeightFrom(DsTokens.light())),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('compact renders without overflow at a wide width and 320dp', (
      tester,
    ) async {
      for (final double width in <double>[320, 1440]) {
        await pumpDs(
          tester,
          SizedBox(
            height: 400,
            width: width,
            child: const DsDataGrid(
              columns: _columns,
              rows: _rows,
              density: DsGridDensity.compact,
            ),
          ),
          surfaceSize: Size(width, 800),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: 'overflow at ${width}dp',
        );
      }
    });
  });
}
