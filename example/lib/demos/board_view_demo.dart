import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Board view page: fleet records laned by status, moved by
/// drag or the accessible "Move to…" menu on each card. Controlled — the demo
/// applies each move to its own state. Screenshot safe.
class BoardViewDemo extends StatefulWidget {
  const BoardViewDemo({super.key});

  @override
  State<BoardViewDemo> createState() => _BoardViewDemoState();
}

class _BoardViewDemoState extends State<BoardViewDemo> {
  static const _statusOptions = [
    DsGridOption(value: 'active', label: 'Active', variant: DsBadgeVariant.success),
    DsGridOption(value: 'in_service', label: 'In service', variant: DsBadgeVariant.neutral),
    DsGridOption(value: 'grounded', label: 'Grounded', variant: DsBadgeVariant.danger),
  ];

  static final _columns = <DsGridColumn>[
    const DsGridColumn(key: 'vehicle', title: 'Vehicle', width: 170),
    const DsGridColumn(key: 'status', title: 'Status', type: DsCellType.status, options: _statusOptions),
    const DsGridColumn(key: 'driver', title: 'Driver', type: DsCellType.user),
    const DsGridColumn(key: 'monthly', title: 'Monthly cost', type: DsCellType.currency, currencySymbol: r'$'),
  ];

  late List<DsGridRow> _rows = [
    DsGridRow(id: 'v1', cells: {'vehicle': 'Ford Transit', 'status': 'active', 'driver': 'Ada Lovelace', 'monthly': 640}),
    DsGridRow(id: 'v2', cells: {'vehicle': 'Toyota HiAce', 'status': 'in_service', 'driver': 'Grace Hopper', 'monthly': 510}),
    DsGridRow(id: 'v3', cells: {'vehicle': 'Mercedes Sprinter', 'status': 'grounded', 'driver': 'Alan Turing', 'monthly': 720}),
    DsGridRow(id: 'v4', cells: {'vehicle': 'Nissan NV200', 'status': 'active', 'driver': 'Katherine Johnson', 'monthly': 430}),
    DsGridRow(id: 'v5', cells: {'vehicle': 'Renault Master', 'status': 'in_service', 'driver': 'Dorothy Vaughan', 'monthly': 590}),
  ];

  void _move(({String rowId, String? toGroup}) move) {
    final index = _rows.indexWhere((r) => r.id == move.rowId);
    if (index == -1) return;
    // A null destination is the Ungrouped lane; store an empty status for it.
    final next = Map<String, Object?>.from(_rows[index].cells)
      ..['status'] = move.toGroup ?? '';
    setState(() {
      _rows = [..._rows]..[index] = DsGridRow(id: move.rowId, cells: next);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: DsBoardView(
        columns: _columns,
        rows: _rows,
        groupByKey: 'status',
        onRowMoved: _move,
      ),
    );
  }
}
