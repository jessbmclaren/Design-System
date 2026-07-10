import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

final _columns = <DsGridColumn>[
  const DsGridColumn(key: 'name', title: 'Name'),
  const DsGridColumn(key: 'amount', title: 'Amount', type: DsCellType.number),
  const DsGridColumn(
    key: 'status',
    title: 'Status',
    type: DsCellType.status,
    options: [
      DsGridOption(value: 'active', label: 'Active'),
      DsGridOption(value: 'pending', label: 'Pending'),
      DsGridOption(value: 'failed', label: 'Failed'),
    ],
  ),
  const DsGridColumn(key: 'due', title: 'Due', type: DsCellType.date),
  const DsGridColumn(key: 'active', title: 'Active', type: DsCellType.checkbox),
  const DsGridColumn(
    key: 'tags',
    title: 'Tags',
    type: DsCellType.multiSelect,
    options: [
      DsGridOption(value: 'red', label: 'Red'),
      DsGridOption(value: 'blue', label: 'Blue'),
    ],
  ),
];

DsGridRow _row(Map<String, Object?> cells) => DsGridRow(id: 'r', cells: cells);

/// A controlled host that feeds edits back into [DsFilterBar], as a real caller
/// would, and reports every emitted filter through [onChanged].
class _FilterHarness extends StatefulWidget {
  const _FilterHarness({
    required this.initial,
    this.initiallyOpen = false,
    this.onChanged,
  });

  final DsFilter initial;
  final bool initiallyOpen;
  final ValueChanged<DsFilter>? onChanged;

  @override
  State<_FilterHarness> createState() => _FilterHarnessState();
}

class _FilterHarnessState extends State<_FilterHarness> {
  late DsFilter _filter = widget.initial;

  @override
  Widget build(BuildContext context) {
    return DsFilterBar(
      columns: _columns,
      value: _filter,
      initiallyOpen: widget.initiallyOpen,
      onChanged: (filter) {
        setState(() => _filter = filter);
        widget.onChanged?.call(filter);
      },
    );
  }
}

void main() {
  group('DsFilterBar rendering', () {
    testWidgets('the filter button shows the active count', (tester) async {
      await pumpDs(
        tester,
        DsFilterBar(
          columns: _columns,
          value: const DsFilter(conditions: [
            DsFilterCondition(
              columnKey: 'name',
              operator: DsFilterOperator.contains,
              value: 'ac',
            ),
            DsFilterCondition(
              columnKey: 'amount',
              operator: DsFilterOperator.greaterThan,
              value: 100,
            ),
          ]),
          onChanged: (_) {},
        ),
        surfaceSize: const Size(900, 700),
      );
      await tester.pump();
      expect(find.text('Filter (2)'), findsOneWidget);
    });

    testWidgets('opening an empty filter reads "No filters"', (tester) async {
      await pumpDs(
        tester,
        DsFilterBar(
          columns: _columns,
          value: const DsFilter(),
          onChanged: (_) {},
        ),
        surfaceSize: const Size(900, 700),
      );
      await tester.pump();
      expect(find.text('Filter'), findsOneWidget);
      await tester.tap(find.text('Filter'));
      await tester.pump();
      expect(find.text('No filters'), findsOneWidget);
      expect(find.text('Add condition'), findsOneWidget);
    });

    testWidgets('a condition on an unknown column opens without crashing',
        (tester) async {
      // Regression: a persisted filter may reference a column no longer present
      // (DsFilter.matches tolerates it); the editor must not assert on the
      // unmatched dropdown value.
      await pumpDs(
        tester,
        DsFilterBar(
          columns: _columns,
          value: const DsFilter(conditions: [
            DsFilterCondition(
              columnKey: 'legacy_removed_column',
              operator: DsFilterOperator.contains,
              value: 'x',
            ),
          ]),
          onChanged: (_) {},
        ),
        surfaceSize: const Size(900, 700),
      );
      await tester.pump();
      await tester.tap(find.textContaining('Filter'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('DsFilterBar editing', () {
    testWidgets('adding a condition emits one default condition',
        (tester) async {
      DsFilter? last;
      await pumpDs(
        tester,
        _FilterHarness(
          initial: const DsFilter(),
          initiallyOpen: true,
          onChanged: (f) => last = f,
        ),
        surfaceSize: const Size(900, 700),
      );
      await tester.pump();
      await tester.tap(find.text('Add condition'));
      await tester.pump();
      expect(last, isNotNull);
      expect(last!.conditions, hasLength(1));
      expect(last!.conditions.first.columnKey, 'name');
      expect(last!.conditions.first.operator, DsFilterOperator.is_);
    });

    testWidgets('removing a condition emits an empty filter', (tester) async {
      DsFilter? last;
      await pumpDs(
        tester,
        _FilterHarness(
          initial: const DsFilter(conditions: [
            DsFilterCondition(
              columnKey: 'name',
              operator: DsFilterOperator.contains,
              value: 'ac',
            ),
          ]),
          initiallyOpen: true,
          onChanged: (f) => last = f,
        ),
        surfaceSize: const Size(900, 700),
      );
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Remove filter condition'));
      await tester.pump();
      expect(last, isNotNull);
      expect(last!.conditions, isEmpty);
    });

    testWidgets('editing the value input emits the typed text', (tester) async {
      DsFilter? last;
      await pumpDs(
        tester,
        _FilterHarness(
          initial: const DsFilter(conditions: [
            DsFilterCondition(
              columnKey: 'name',
              operator: DsFilterOperator.contains,
            ),
          ]),
          initiallyOpen: true,
          onChanged: (f) => last = f,
        ),
        surfaceSize: const Size(900, 700),
      );
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'acme');
      await tester.pump();
      expect(last, isNotNull);
      expect(last!.conditions.single.value, 'acme');
    });

    testWidgets('the conjunction toggle switches to OR', (tester) async {
      DsFilter? last;
      await pumpDs(
        tester,
        _FilterHarness(
          initial: const DsFilter(conditions: [
            DsFilterCondition(
              columnKey: 'name',
              operator: DsFilterOperator.contains,
              value: 'a',
            ),
            DsFilterCondition(
              columnKey: 'amount',
              operator: DsFilterOperator.greaterThan,
              value: 10,
            ),
          ]),
          initiallyOpen: true,
          onChanged: (f) => last = f,
        ),
        surfaceSize: const Size(1000, 700),
      );
      await tester.pump();
      await tester.tap(find.text('Or'));
      await tester.pump();
      expect(last, isNotNull);
      expect(last!.conjunction, DsFilterConjunction.or);
    });
  });

  group('DsFilter.matches', () {
    test('text contains is case-insensitive', () {
      const filter = DsFilter(conditions: [
        DsFilterCondition(
          columnKey: 'name',
          operator: DsFilterOperator.contains,
          value: 'ac',
        ),
      ]);
      expect(filter.matches(_row({'name': 'Acme'}), _columns), isTrue);
      expect(filter.matches(_row({'name': 'Northwind'}), _columns), isFalse);
    });

    test('number greaterThan compares numerically', () {
      const filter = DsFilter(conditions: [
        DsFilterCondition(
          columnKey: 'amount',
          operator: DsFilterOperator.greaterThan,
          value: 1000,
        ),
      ]);
      expect(filter.matches(_row({'amount': 1240}), _columns), isTrue);
      expect(filter.matches(_row({'amount': 320}), _columns), isFalse);
    });

    test('select isAnyOf matches membership by value', () {
      const filter = DsFilter(conditions: [
        DsFilterCondition(
          columnKey: 'status',
          operator: DsFilterOperator.isAnyOf,
          value: ['active', 'failed'],
        ),
      ]);
      expect(filter.matches(_row({'status': 'active'}), _columns), isTrue);
      expect(filter.matches(_row({'status': 'pending'}), _columns), isFalse);
    });

    test('date before compares by day', () {
      final filter = DsFilter(conditions: [
        DsFilterCondition(
          columnKey: 'due',
          operator: DsFilterOperator.before,
          value: DateTime(2026, 7, 1),
        ),
      ]);
      expect(
        filter.matches(_row({'due': DateTime(2026, 6, 20)}), _columns),
        isTrue,
      );
      expect(
        filter.matches(_row({'due': DateTime(2026, 8, 1)}), _columns),
        isFalse,
      );
    });

    test('checkbox is compares the boolean', () {
      const filter = DsFilter(conditions: [
        DsFilterCondition(
          columnKey: 'active',
          operator: DsFilterOperator.is_,
          value: true,
        ),
      ]);
      expect(filter.matches(_row({'active': true}), _columns), isTrue);
      expect(filter.matches(_row({'active': false}), _columns), isFalse);
    });

    test('an empty filter matches every row', () {
      const filter = DsFilter();
      expect(filter.matches(_row({'name': 'Anything'}), _columns), isTrue);
    });

    test('AND requires all, OR requires any', () {
      const conditions = [
        DsFilterCondition(
          columnKey: 'name',
          operator: DsFilterOperator.contains,
          value: 'ac',
        ),
        DsFilterCondition(
          columnKey: 'amount',
          operator: DsFilterOperator.greaterThan,
          value: 5000,
        ),
      ];
      final row = _row({'name': 'Acme', 'amount': 1240});
      expect(
        const DsFilter(conditions: conditions).matches(row, _columns),
        isFalse,
      );
      expect(
        const DsFilter(
          conjunction: DsFilterConjunction.or,
          conditions: conditions,
        ).matches(row, _columns),
        isTrue,
      );
    });

    test('an incomplete condition is ignored, not treated as a mismatch', () {
      const filter = DsFilter(conditions: [
        DsFilterCondition(
          columnKey: 'name',
          operator: DsFilterOperator.contains,
          // No value: the condition is incomplete and must not hide rows.
        ),
      ]);
      expect(filter.matches(_row({'name': 'Acme'}), _columns), isTrue);
    });

    test('dsOperatorsForType returns type-appropriate operators', () {
      expect(dsOperatorsForType(DsCellType.checkbox), [DsFilterOperator.is_]);
      expect(
        dsOperatorsForType(DsCellType.multiSelect),
        contains(DsFilterOperator.contains),
      );
      expect(
        dsOperatorsForType(DsCellType.date),
        contains(DsFilterOperator.onOrBefore),
      );
      expect(DsFilterOperator.doesNotContain.label, 'does not contain');
    });
  });

  testWidgets('no overflow across device widths', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1.0;
    for (final width in <double>[320, 768, 1440]) {
      tester.view.physicalSize = Size(width, 1200);
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DsFilterBar(
                columns: _columns,
                initiallyOpen: true,
                value: const DsFilter(conditions: [
                  DsFilterCondition(
                    columnKey: 'name',
                    operator: DsFilterOperator.contains,
                    value: 'ac',
                  ),
                  DsFilterCondition(
                    columnKey: 'status',
                    operator: DsFilterOperator.isAnyOf,
                    value: ['active'],
                  ),
                ]),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'overflow at ${width}dp');
    }
  });
}
