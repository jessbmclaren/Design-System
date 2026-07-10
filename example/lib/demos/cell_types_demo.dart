import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Cell types page: an editable grid that exercises every
/// `DsCellType`. Tapping a cell opens the editor appropriate to its type
/// (text field, date picker, option menu, star row, checkbox toggle). Held in
/// local state so committed edits apply immediately. Screenshot safe.
class CellTypesDemo extends StatefulWidget {
  const CellTypesDemo({super.key});

  @override
  State<CellTypesDemo> createState() => _CellTypesDemoState();
}

class _CellTypesDemoState extends State<CellTypesDemo> {
  static const _statusOptions = [
    DsGridOption(value: 'active', label: 'Active', variant: DsBadgeVariant.success),
    DsGridOption(value: 'in_service', label: 'In service', variant: DsBadgeVariant.neutral),
    DsGridOption(value: 'grounded', label: 'Grounded', variant: DsBadgeVariant.danger),
    DsGridOption(value: 'pending', label: 'Pending', variant: DsBadgeVariant.warning),
  ];

  static const _typeOptions = [
    DsGridOption(value: 'van', label: 'Van'),
    DsGridOption(value: 'truck', label: 'Truck'),
    DsGridOption(value: 'car', label: 'Car'),
  ];

  static const _tagOptions = [
    DsGridOption(value: 'refrigerated', label: 'Refrigerated'),
    DsGridOption(value: 'long_haul', label: 'Long haul'),
    DsGridOption(value: 'city', label: 'City'),
    DsGridOption(value: 'hazmat', label: 'Hazmat'),
  ];

  late final List<DsGridColumn> _columns = [
    const DsGridColumn(key: 'vehicle', title: 'Vehicle', frozen: true, width: 170, editable: true),
    const DsGridColumn(
      key: 'status',
      title: 'Status',
      type: DsCellType.status,
      width: 130,
      editable: true,
      options: _statusOptions,
    ),
    const DsGridColumn(
      key: 'type',
      title: 'Type',
      type: DsCellType.singleSelect,
      width: 120,
      editable: true,
      options: _typeOptions,
    ),
    const DsGridColumn(
      key: 'tags',
      title: 'Tags',
      type: DsCellType.multiSelect,
      width: 200,
      editable: true,
      options: _tagOptions,
    ),
    const DsGridColumn(key: 'driver', title: 'Driver', type: DsCellType.user, width: 170, editable: true),
    const DsGridColumn(
      key: 'monthly',
      title: 'Monthly',
      type: DsCellType.currency,
      currencySymbol: r'$',
      width: 120,
      editable: true,
    ),
    const DsGridColumn(key: 'serviceDue', title: 'Service due', type: DsCellType.date, width: 132, editable: true),
    const DsGridColumn(key: 'condition', title: 'Condition', type: DsCellType.rating, width: 128, editable: true),
    const DsGridColumn(key: 'utilisation', title: 'Utilisation', type: DsCellType.progress, width: 130),
    const DsGridColumn(key: 'insured', title: 'Insured', type: DsCellType.checkbox, width: 84, editable: true),
    const DsGridColumn(key: 'record', title: 'Record', type: DsCellType.link, width: 110),
  ];

  late final List<DsGridRow> _rows = [
    DsGridRow(id: 'v1', cells: {
      'vehicle': 'Ford Transit', 'status': 'active', 'type': 'van',
      'tags': ['city', 'refrigerated'], 'driver': 'Ada Lovelace',
      'monthly': 640, 'serviceDue': DateTime(2026, 8, 12), 'condition': 4,
      'utilisation': 0.82, 'insured': true, 'record': 'Open',
    }),
    DsGridRow(id: 'v2', cells: {
      'vehicle': 'Toyota HiAce', 'status': 'in_service', 'type': 'van',
      'tags': ['long_haul'], 'driver': 'Grace Hopper',
      'monthly': 510, 'serviceDue': DateTime(2026, 7, 28), 'condition': 5,
      'utilisation': 0.64, 'insured': true, 'record': 'Open',
    }),
    DsGridRow(id: 'v3', cells: {
      'vehicle': 'Mercedes Sprinter', 'status': 'grounded', 'type': 'truck',
      'tags': ['hazmat', 'long_haul'], 'driver': 'Alan Turing',
      'monthly': 720, 'serviceDue': DateTime(2026, 7, 15), 'condition': 2,
      'utilisation': 0.18, 'insured': false, 'record': 'Open',
    }),
    DsGridRow(id: 'v4', cells: {
      'vehicle': 'Nissan NV200', 'status': 'pending', 'type': 'car',
      'tags': ['city'], 'driver': 'Katherine Johnson',
      'monthly': 430, 'serviceDue': DateTime(2026, 9, 3), 'condition': 3,
      'utilisation': 0.0, 'insured': true, 'record': 'Open',
    }),
  ];

  void _apply(String rowId, String key, Object? value) {
    final index = _rows.indexWhere((r) => r.id == rowId);
    if (index == -1) return;
    final next = Map<String, Object?>.from(_rows[index].cells)..[key] = value;
    setState(() {
      _rows[index] = DsGridRow(id: rowId, cells: next, onTap: _rows[index].onTap);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: DsDataGrid(
        columns: _columns,
        rows: _rows,
        editable: true,
        onCellChanged: _apply,
        caption: 'Editable fleet register',
      ),
    );
  }
}
