import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const List<DsGridColumn> _columns = <DsGridColumn>[
  DsGridColumn(key: 'city', title: 'City'),
  DsGridColumn(key: 'employees', title: 'Employees', type: DsCellType.number),
];

void main() {
  testWidgets('summarises the primary rule and the tie-break count', (
    tester,
  ) async {
    await pumpDs(
      tester,
      DsSortPill(
        columns: _columns,
        sorts: const <DsGridSort>[
          DsGridSort(columnKey: 'city', ascending: false),
          DsGridSort(columnKey: 'employees'),
        ],
        onChanged: (_) {},
      ),
    );

    expect(find.text('Sorted by City +1'), findsOneWidget);
  });

  testWidgets('reads as its empty label while nothing is sorted', (
    tester,
  ) async {
    await pumpDs(
      tester,
      DsSortPill(
        columns: _columns,
        sorts: const <DsGridSort>[],
        onChanged: (_) {},
      ),
    );
    expect(find.text('Sort'), findsOneWidget);
  });

  testWidgets('opens the builder and reports edited rules', (tester) async {
    List<DsGridSort>? emitted;
    await pumpDs(
      tester,
      DsSortPill(
        columns: _columns,
        sorts: const <DsGridSort>[DsGridSort(columnKey: 'city')],
        onChanged: (List<DsGridSort> next) => emitted = next,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Sorted by City'));
    await tester.pump();
    expect(find.byType(DsSortBuilder), findsOneWidget);

    await tester.tap(find.text('Add sort'));
    await tester.pump();

    expect(emitted, isNotNull);
    expect(emitted!.length, 2);
    expect(emitted![1].columnKey, 'employees');
  });

  testWidgets('a null onChanged disables the pill', (tester) async {
    await pumpDs(
      tester,
      const DsSortPill(
        columns: _columns,
        sorts: <DsGridSort>[],
        onChanged: null,
      ),
    );

    await tester.tap(find.text('Sort'));
    await tester.pump();
    expect(find.byType(DsSortBuilder), findsNothing);
  });

  testWidgets('does not overflow at 320dp with a long column title', (
    tester,
  ) async {
    await pumpDs(
      tester,
      DsSortPill(
        columns: const <DsGridColumn>[
          DsGridColumn(
            key: 'x',
            title: 'A remarkably long column title that cannot fit',
          ),
        ],
        sorts: const <DsGridSort>[DsGridSort(columnKey: 'x')],
        onChanged: (_) {},
      ),
      surfaceSize: const Size(320, 480),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark and under a skin', (tester) async {
    for (final ThemeData theme in <ThemeData>[
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
    ]) {
      await pumpDs(
        tester,
        DsSortPill(
          columns: _columns,
          sorts: const <DsGridSort>[DsGridSort(columnKey: 'city')],
          onChanged: (_) {},
        ),
        theme: theme,
      );
      expect(find.text('Sorted by City'), findsOneWidget);
    }
  });
}
