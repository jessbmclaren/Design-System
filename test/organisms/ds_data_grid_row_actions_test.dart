import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

final List<DsGridRow> _rows = <DsGridRow>[
  const DsGridRow(id: 'a', cells: <String, Object?>{
    'name': 'Alpha',
    'state': 'Active',
  }),
  const DsGridRow(id: 'b', cells: <String, Object?>{
    'name': 'Beta',
    'state': 'Needs review',
  }),
];

Widget _grid({
  List<DsRowAction> Function(DsGridRow row)? rowActions,
  String? Function(DsGridRow row)? statusTooltip,
  Size size = const Size(800, 600),
}) {
  return SizedBox(
    width: size.width - 100,
    height: size.height - 100,
    child: DsDataGrid(
      columns: <DsGridColumn>[
        const DsGridColumn(key: 'name', title: 'Name'),
        DsGridColumn(
          key: 'state',
          title: 'State',
          type: DsCellType.status,
          statusTooltip: statusTooltip,
        ),
      ],
      rows: _rows,
      rowActions: rowActions,
    ),
  );
}

void main() {
  testWidgets('a row menu opens and runs its action', (tester) async {
    String? chosen;
    await pumpDs(
      tester,
      _grid(
        rowActions: (DsGridRow row) => <DsRowAction>[
          DsRowAction(
            label: 'View',
            icon: DsIcons.visibility,
            onSelected: () => chosen = 'view ${row.id}',
          ),
          DsRowAction(
            label: 'Delete',
            icon: DsIcons.delete,
            destructive: true,
            onSelected: () => chosen = 'delete ${row.id}',
          ),
        ],
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.bySemanticsLabel('Row actions'), findsNWidgets(2));

    await tester.tap(find.bySemanticsLabel('Row actions').first);
    await tester.pump();
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pump();
    expect(chosen, 'delete a');
  });

  testWidgets('an empty action list leaves the row without a menu', (
    tester,
  ) async {
    await pumpDs(
      tester,
      _grid(
        rowActions: (DsGridRow row) => row.id == 'a'
            ? <DsRowAction>[
                DsRowAction(
                  label: 'View',
                  icon: DsIcons.visibility,
                  onSelected: () {},
                ),
              ]
            : const <DsRowAction>[],
      ),
      surfaceSize: const Size(800, 600),
    );

    // Only the row that offers actions shows a trigger; the other keeps its
    // aligned but empty slot.
    expect(find.bySemanticsLabel('Row actions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no rowActions renders no actions column at all', (
    tester,
  ) async {
    await pumpDs(tester, _grid(), surfaceSize: const Size(800, 600));
    expect(find.bySemanticsLabel('Row actions'), findsNothing);
  });

  testWidgets('a status tooltip is shown and announced with its state', (
    tester,
  ) async {
    await pumpDs(
      tester,
      _grid(
        statusTooltip: (DsGridRow row) =>
            row.id == 'b' ? 'Missing licence expiry' : null,
      ),
      surfaceSize: const Size(800, 600),
    );

    // The tipped cell announces state and reason together...
    expect(
      find.bySemanticsLabel('Needs review, Missing licence expiry'),
      findsOneWidget,
    );
    // ...and carries a real tooltip for pointer users.
    expect(find.byTooltip('Missing licence expiry'), findsOneWidget);
    // An untipped row keeps its plain badge.
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('row actions ride the compact card layout', (tester) async {
    String? chosen;
    await pumpDs(
      tester,
      SizedBox(
        width: 300,
        height: 500,
        child: DsDataGrid(
          columns: const <DsGridColumn>[
            DsGridColumn(key: 'name', title: 'Name'),
          ],
          rows: _rows,
          rowActions: (DsGridRow row) => <DsRowAction>[
            DsRowAction(
              label: 'View',
              icon: DsIcons.visibility,
              onSelected: () => chosen = row.id,
            ),
          ],
        ),
      ),
      surfaceSize: const Size(320, 600),
    );

    expect(find.bySemanticsLabel('Row actions'), findsNWidgets(2));
    await tester.tap(find.bySemanticsLabel('Row actions').first);
    await tester.pump();
    await tester.tap(find.text('View'));
    await tester.pump();
    expect(chosen, 'a');
    expect(tester.takeException(), isNull);
  });

  testWidgets('holds every theme without overflow', (tester) async {
    for (final ThemeData theme in <ThemeData>[
      DsTheme.light(),
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
    ]) {
      await pumpDs(
        tester,
        _grid(
          rowActions: (_) => <DsRowAction>[
            DsRowAction(
              label: 'View',
              icon: DsIcons.visibility,
              onSelected: () {},
            ),
          ],
          statusTooltip: (_) => 'Reason',
        ),
        surfaceSize: const Size(800, 600),
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
