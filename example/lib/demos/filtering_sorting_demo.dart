import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Filtering & sorting page: a `DsFilterBar` and
/// `DsSortBuilder` sitting above a `DsDataGrid`, both driving the rows the grid
/// shows. Starts with one filter and one sort applied so the screenshot is
/// representative; fully interactive at runtime. Screenshot safe.
class FilteringSortingDemo extends StatefulWidget {
  const FilteringSortingDemo({super.key});

  @override
  State<FilteringSortingDemo> createState() => _FilteringSortingDemoState();
}

class _FilteringSortingDemoState extends State<FilteringSortingDemo> {
  static const _statusOptions = [
    DsGridOption(value: 'active', label: 'Active', variant: DsBadgeVariant.success),
    DsGridOption(value: 'grounded', label: 'Grounded', variant: DsBadgeVariant.danger),
    DsGridOption(value: 'pending', label: 'Pending', variant: DsBadgeVariant.warning),
  ];

  static final _columns = <DsGridColumn>[
    const DsGridColumn(key: 'vehicle', title: 'Vehicle', frozen: true, width: 170),
    const DsGridColumn(key: 'status', title: 'Status', type: DsCellType.status, width: 128, options: _statusOptions),
    const DsGridColumn(key: 'driver', title: 'Driver', type: DsCellType.user, width: 160),
    const DsGridColumn(key: 'monthly', title: 'Monthly cost', type: DsCellType.currency, currencySymbol: r'$', width: 140),
    const DsGridColumn(key: 'utilisation', title: 'Utilisation', type: DsCellType.progress, width: 140),
  ];

  static final _all = <DsGridRow>[
    DsGridRow(id: 'v1', cells: {'vehicle': 'Ford Transit', 'status': 'active', 'driver': 'Ada Lovelace', 'monthly': 640, 'utilisation': 0.82}),
    DsGridRow(id: 'v2', cells: {'vehicle': 'Toyota HiAce', 'status': 'active', 'driver': 'Grace Hopper', 'monthly': 510, 'utilisation': 0.64}),
    DsGridRow(id: 'v3', cells: {'vehicle': 'Mercedes Sprinter', 'status': 'grounded', 'driver': 'Alan Turing', 'monthly': 720, 'utilisation': 0.18}),
    DsGridRow(id: 'v4', cells: {'vehicle': 'Nissan NV200', 'status': 'active', 'driver': 'Katherine Johnson', 'monthly': 430, 'utilisation': 0.71}),
    DsGridRow(id: 'v5', cells: {'vehicle': 'Renault Master', 'status': 'pending', 'driver': 'Dorothy Vaughan', 'monthly': 590, 'utilisation': 0.44}),
  ];

  DsFilter _filter = const DsFilter(
    conditions: [
      DsFilterCondition(columnKey: 'status', operator: DsFilterOperator.is_, value: 'active'),
    ],
  );

  List<DsGridSort> _sorts = const [DsGridSort(columnKey: 'monthly', ascending: false)];

  List<DsGridRow> get _visible {
    final rows = _all.where((r) => _filter.matches(r, _columns)).toList();
    rows.sort(_compare);
    return rows;
  }

  int _compare(DsGridRow a, DsGridRow b) {
    for (final sort in _sorts) {
      final av = a.cells[sort.columnKey];
      final bv = b.cells[sort.columnKey];
      final c = _compareValues(av, bv);
      if (c != 0) return sort.ascending ? c : -c;
    }
    return 0;
  }

  int _compareValues(Object? a, Object? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is num && b is num) return a.compareTo(b);
    if (a is DateTime && b is DateTime) return a.compareTo(b);
    if (a is bool && b is bool) return a == b ? 0 : (a ? 1 : -1);
    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            DsFilterBar(
              columns: _columns,
              value: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            DsSortBuilder(
              columns: _columns,
              value: _sorts,
              onChanged: (s) => setState(() => _sorts = s),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: DsDataGrid(
            columns: _columns,
            rows: _visible,
            caption: '${_visible.length} of ${_all.length} vehicles',
          ),
        ),
      ],
    );
  }
}
