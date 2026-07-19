import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const List<DsGridColumn> _columns = <DsGridColumn>[
  DsGridColumn(key: 'name', title: 'Name'),
  DsGridColumn(key: 'amount', title: 'Amount', type: DsCellType.number),
  DsGridColumn(key: 'status', title: 'Status', type: DsCellType.status),
];

final List<DsGridRow> _rows = <DsGridRow>[
  const DsGridRow(id: 'a', cells: <String, Object?>{
    'name': 'Alpha',
    'amount': 10,
    'status': 'Active',
  }),
  const DsGridRow(id: 'b', cells: <String, Object?>{
    'name': 'Beta',
    'amount': 30,
    'status': 'Pending',
  }),
  const DsGridRow(id: 'c', cells: <String, Object?>{
    'name': 'Gamma',
    'amount': 20,
    'status': 'Active',
  }),
];

Widget _grid({
  required DsGridView view,
  ValueChanged<DsGridView>? onViewChanged,
}) {
  return SizedBox(
    width: 700,
    height: 400,
    child: DsDataGrid(
      columns: _columns,
      rows: _rows,
      view: view,
      onViewChanged: onViewChanged,
    ),
  );
}

void main() {
  testWidgets('the view controls which columns show and in what order', (
    tester,
  ) async {
    await pumpDs(
      tester,
      _grid(
        view: const DsGridView(visibleColumns: <String>['amount', 'name']),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('AMOUNT'), findsOneWidget);
    expect(find.text('NAME'), findsOneWidget);
    expect(find.text('STATUS'), findsNothing);
    // Order: amount's header sits left of name's.
    final double amountX = tester.getTopLeft(find.text('AMOUNT')).dx;
    final double nameX = tester.getTopLeft(find.text('NAME')).dx;
    expect(amountX, lessThan(nameX));
  });

  testWidgets('a display relabel changes the header, not the data', (
    tester,
  ) async {
    await pumpDs(
      tester,
      _grid(
        view: const DsGridView(
          columnLabels: <String, String>{'name': 'Driver'},
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('DRIVER'), findsOneWidget);
    expect(find.text('NAME'), findsNothing);
    expect(find.text('Alpha'), findsOneWidget);
  });

  testWidgets('the view sort orders the rows and header taps report a new '
      'view', (tester) async {
    DsGridView? emitted;
    await pumpDs(
      tester,
      _grid(
        view: const DsGridView(
          sort: DsGridSort(columnKey: 'amount', ascending: false),
        ),
        onViewChanged: (DsGridView next) => emitted = next,
      ),
      surfaceSize: const Size(800, 600),
    );

    // Descending by amount: Beta (30) renders above Gamma (20) above Alpha.
    expect(
      tester.getTopLeft(find.text('Beta')).dy,
      lessThan(tester.getTopLeft(find.text('Gamma')).dy),
    );

    await tester.tap(find.text('NAME'));
    await tester.pump();
    expect(emitted, isNotNull);
    expect(emitted!.sort!.columnKey, 'name');
    expect(emitted!.sort!.ascending, isTrue);
  });

  testWidgets('the header menu hides a column through onViewChanged', (
    tester,
  ) async {
    DsGridView? emitted;
    await pumpDs(
      tester,
      _grid(
        view: const DsGridView(),
        onViewChanged: (DsGridView next) => emitted = next,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.bySemanticsLabel('Column options for Status'));
    await tester.pump();
    await tester.tap(find.text('Hide column'));
    await tester.pump();

    expect(emitted, isNotNull);
    expect(emitted!.visibleColumns, <String>['name', 'amount']);
  });

  testWidgets('the header menu moves a column', (tester) async {
    DsGridView? emitted;
    await pumpDs(
      tester,
      _grid(
        view: const DsGridView(),
        onViewChanged: (DsGridView next) => emitted = next,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.bySemanticsLabel('Column options for Amount'));
    await tester.pump();
    await tester.tap(find.text('Move left'));
    await tester.pump();

    expect(emitted!.visibleColumns, <String>['amount', 'name', 'status']);
  });

  testWidgets('editing a header label relabels or clears through the view', (
    tester,
  ) async {
    DsGridView? emitted;
    await pumpDs(
      tester,
      _grid(
        view: const DsGridView(),
        onViewChanged: (DsGridView next) => emitted = next,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.bySemanticsLabel('Column options for Name'));
    await tester.pump();
    await tester.tap(find.text('Edit label'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Driver');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(emitted!.columnLabels, <String, String>{'name': 'Driver'});
  });

  testWidgets('a hidden column comes back through the add-column affordance', (
    tester,
  ) async {
    DsGridView? emitted;
    await pumpDs(
      tester,
      _grid(
        view: const DsGridView(visibleColumns: <String>['name', 'amount']),
        onViewChanged: (DsGridView next) => emitted = next,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.bySemanticsLabel('Add column'));
    await tester.pump();
    await tester.tap(find.text('Status'));
    await tester.pump();

    expect(emitted!.visibleColumns, <String>['name', 'amount', 'status']);
  });

  testWidgets('the last visible column cannot be hidden', (tester) async {
    DsGridView? emitted;
    await pumpDs(
      tester,
      _grid(
        view: const DsGridView(visibleColumns: <String>['name']),
        onViewChanged: (DsGridView next) => emitted = next,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.bySemanticsLabel('Column options for Name'));
    await tester.pump();
    await tester.tap(find.text('Hide column'), warnIfMissed: false);
    await tester.pump();
    expect(emitted, isNull);
  });

  testWidgets('calculations render in the footer and read to assistive '
      'technology', (tester) async {
    await pumpDs(
      tester,
      _grid(
        view: const DsGridView(
          calculations: <String, DsAggregation>{
            'amount': DsAggregation.sum,
          },
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('SUM'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.bySemanticsLabel('Sum of Amount: 60'), findsOneWidget);
  });

  testWidgets('a managed footer slot opens the picker and reports the choice', (
    tester,
  ) async {
    DsGridView? emitted;
    await pumpDs(
      tester,
      _grid(
        view: const DsGridView(),
        onViewChanged: (DsGridView next) => emitted = next,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.bySemanticsLabel('Add calculation for Amount'));
    await tester.pump();
    await tester.tap(find.text('Average'));
    await tester.pump();

    expect(emitted!.calculations, <String, DsAggregation>{
      'amount': DsAggregation.average,
    });
  });

  testWidgets('a text column offers count but not the numeric aggregations', (
    tester,
  ) async {
    await pumpDs(
      tester,
      _grid(view: const DsGridView(), onViewChanged: (_) {}),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.bySemanticsLabel('Add calculation for Name'));
    await tester.pump();
    expect(find.text('Count'), findsOneWidget);
    expect(find.text('Sum'), findsNothing);
  });

  testWidgets('a read-only view renders its configuration without any '
      'management chrome', (tester) async {
    await pumpDs(
      tester,
      _grid(
        view: const DsGridView(
          visibleColumns: <String>['name', 'amount'],
          sort: DsGridSort(columnKey: 'amount'),
          calculations: <String, DsAggregation>{'amount': DsAggregation.max},
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.bySemanticsLabel('Column options for Name'), findsNothing);
    expect(find.bySemanticsLabel('Add column'), findsNothing);
    expect(find.text('MAX'), findsOneWidget);
    expect(find.text('30'), findsAtLeastNWidgets(1));
  });

  testWidgets('the compact layout honours the view and summarises '
      'calculations', (tester) async {
    await pumpDs(
      tester,
      SizedBox(
        width: 320,
        height: 500,
        child: DsDataGrid(
          columns: _columns,
          rows: _rows,
          view: const DsGridView(
            visibleColumns: <String>['name', 'amount'],
            columnLabels: <String, String>{'name': 'Driver'},
            calculations: <String, DsAggregation>{
              'amount': DsAggregation.sum,
            },
          ),
        ),
      ),
      surfaceSize: const Size(320, 600),
    );

    expect(find.text('Driver'), findsAtLeastNWidgets(1));
    expect(find.text('Status'), findsNothing);
    expect(find.text('Sum 60'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the grid never mutates the view it is passed', (tester) async {
    const DsGridView view = DsGridView(
      visibleColumns: <String>['name', 'amount', 'status'],
    );
    final List<DsGridView> emissions = <DsGridView>[];
    await pumpDs(
      tester,
      _grid(view: view, onViewChanged: emissions.add),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.bySemanticsLabel('Column options for Status'));
    await tester.pump();
    await tester.tap(find.text('Hide column'));
    await tester.pump();

    // The original value is untouched; the change arrived as a new value.
    expect(view.visibleColumns, <String>['name', 'amount', 'status']);
    expect(emissions.single.visibleColumns, <String>['name', 'amount']);
    // Status still renders because the caller has not applied the change.
    expect(find.text('STATUS'), findsOneWidget);
  });

  testWidgets('view equality is by value', (tester) async {
    const DsGridView a = DsGridView(
      visibleColumns: <String>['name'],
      columnLabels: <String, String>{'name': 'Driver'},
      sort: DsGridSort(columnKey: 'name'),
      calculations: <String, DsAggregation>{'name': DsAggregation.count},
    );
    const DsGridView b = DsGridView(
      visibleColumns: <String>['name'],
      columnLabels: <String, String>{'name': 'Driver'},
      sort: DsGridSort(columnKey: 'name'),
      calculations: <String, DsAggregation>{'name': DsAggregation.count},
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a.copyWith(sort: null).sort, isNull);
    expect(a.copyWith().sort, isNotNull);
  });
}
