import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Grouping page: a fleet grid grouped by depot then status,
/// with a per-group record count, a summed monthly cost and an averaged
/// utilisation. Collapsible group headers; screenshot safe.
class GroupingDemo extends StatelessWidget {
  const GroupingDemo({super.key});

  static const _statusOptions = [
    DsGridOption(value: 'active', label: 'Active', variant: DsBadgeVariant.success),
    DsGridOption(value: 'grounded', label: 'Grounded', variant: DsBadgeVariant.danger),
    DsGridOption(value: 'pending', label: 'Pending', variant: DsBadgeVariant.warning),
  ];

  static const _depotOptions = [
    DsGridOption(value: 'north', label: 'North depot'),
    DsGridOption(value: 'south', label: 'South depot'),
  ];

  static final _columns = <DsGridColumn>[
    const DsGridColumn(key: 'vehicle', title: 'Vehicle', frozen: true, width: 170),
    const DsGridColumn(key: 'depot', title: 'Depot', type: DsCellType.singleSelect, width: 140, options: _depotOptions),
    const DsGridColumn(key: 'status', title: 'Status', type: DsCellType.status, width: 128, options: _statusOptions),
    const DsGridColumn(key: 'driver', title: 'Driver', type: DsCellType.user, width: 160),
    const DsGridColumn(
      key: 'monthly',
      title: 'Monthly cost',
      type: DsCellType.currency,
      currencySymbol: r'$',
      width: 140,
    ),
    const DsGridColumn(key: 'utilisation', title: 'Utilisation', type: DsCellType.progress, width: 140),
  ];

  static final _rows = <DsGridRow>[
    DsGridRow(id: 'v1', cells: {'vehicle': 'Ford Transit', 'depot': 'north', 'status': 'active', 'driver': 'Ada Lovelace', 'monthly': 640, 'utilisation': 0.82}),
    DsGridRow(id: 'v2', cells: {'vehicle': 'Toyota HiAce', 'depot': 'north', 'status': 'active', 'driver': 'Grace Hopper', 'monthly': 510, 'utilisation': 0.64}),
    DsGridRow(id: 'v3', cells: {'vehicle': 'Mercedes Sprinter', 'depot': 'north', 'status': 'grounded', 'driver': 'Alan Turing', 'monthly': 720, 'utilisation': 0.18}),
    DsGridRow(id: 'v4', cells: {'vehicle': 'Nissan NV200', 'depot': 'south', 'status': 'active', 'driver': 'Katherine Johnson', 'monthly': 430, 'utilisation': 0.71}),
    DsGridRow(id: 'v5', cells: {'vehicle': 'Renault Master', 'depot': 'south', 'status': 'pending', 'driver': 'Dorothy Vaughan', 'monthly': 590, 'utilisation': 0.44}),
    DsGridRow(id: 'v6', cells: {'vehicle': 'Iveco Daily', 'depot': 'south', 'status': 'grounded', 'driver': 'Mary Jackson', 'monthly': 680, 'utilisation': 0.12}),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: DsDataGrid(
        columns: _columns,
        rows: _rows,
        caption: 'Fleet grouped by depot, then status',
        groupBy: const ['depot', 'status'],
        aggregations: const {
          'monthly': DsAggregation.sum,
          'utilisation': DsAggregation.average,
        },
      ),
    );
  }
}
