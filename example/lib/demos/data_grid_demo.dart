import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Data grid page: a realistic fleet register showing the
/// frozen first column, typed cells (status, user, currency, date, progress,
/// rating, checkbox, link), row selection and sortable headers. Screenshot
/// safe: it starts no timers and holds its own selection state.
class DataGridDemo extends StatefulWidget {
  const DataGridDemo({super.key});

  @override
  State<DataGridDemo> createState() => _DataGridDemoState();
}

class _DataGridDemoState extends State<DataGridDemo> {
  static final _columns = <DsGridColumn>[
    const DsGridColumn(
      key: 'vehicle',
      title: 'Vehicle',
      frozen: true,
      width: 180,
      icon: DsIcons.vehicle,
    ),
    const DsGridColumn(key: 'status', title: 'Status', type: DsCellType.status, width: 128),
    const DsGridColumn(key: 'driver', title: 'Driver', type: DsCellType.user, width: 180),
    const DsGridColumn(key: 'plate', title: 'Plate', width: 120),
    const DsGridColumn(
      key: 'monthly',
      title: 'Monthly cost',
      type: DsCellType.currency,
      currencySymbol: r'$',
      width: 140,
    ),
    const DsGridColumn(key: 'serviceDue', title: 'Service due', type: DsCellType.date, width: 132),
    const DsGridColumn(key: 'utilisation', title: 'Utilisation', type: DsCellType.progress, width: 140),
    const DsGridColumn(key: 'rating', title: 'Condition', type: DsCellType.rating, width: 120),
    const DsGridColumn(key: 'insured', title: 'Insured', type: DsCellType.checkbox, width: 88),
    const DsGridColumn(key: 'record', title: 'Record', type: DsCellType.link, width: 120),
  ];

  static final _rows = <DsGridRow>[
    DsGridRow(id: 'v1', cells: {
      'vehicle': 'Ford Transit', 'status': 'Active', 'driver': 'Ada Lovelace',
      'plate': 'CX-1180', 'monthly': 640, 'serviceDue': DateTime(2026, 8, 12),
      'utilisation': 0.82, 'rating': 4, 'insured': true, 'record': 'Open',
    }),
    DsGridRow(id: 'v2', cells: {
      'vehicle': 'Toyota HiAce', 'status': 'In service', 'driver': 'Grace Hopper',
      'plate': 'BR-4420', 'monthly': 510, 'serviceDue': DateTime(2026, 7, 28),
      'utilisation': 0.64, 'rating': 5, 'insured': true, 'record': 'Open',
    }),
    DsGridRow(id: 'v3', cells: {
      'vehicle': 'Mercedes Sprinter', 'status': 'Grounded', 'driver': 'Alan Turing',
      'plate': 'AK-9037', 'monthly': 720, 'serviceDue': DateTime(2026, 7, 15),
      'utilisation': 0.18, 'rating': 2, 'insured': false, 'record': 'Open',
    }),
    DsGridRow(id: 'v4', cells: {
      'vehicle': 'Nissan NV200', 'status': 'Active', 'driver': 'Katherine Johnson',
      'plate': 'ZP-2261', 'monthly': 430, 'serviceDue': DateTime(2026, 9, 3),
      'utilisation': 0.71, 'rating': 4, 'insured': true, 'record': 'Open',
    }),
    DsGridRow(id: 'v5', cells: {
      'vehicle': 'Renault Master', 'status': 'Pending', 'driver': 'Dorothy Vaughan',
      'plate': 'LM-5573', 'monthly': 590, 'serviceDue': DateTime(2026, 8, 22),
      'utilisation': 0.0, 'rating': 3, 'insured': true, 'record': 'Open',
    }),
  ];

  final Set<String> _selected = {'v1'};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: DsDataGrid(
        columns: _columns,
        rows: _rows,
        selectable: true,
        selectedRowIds: _selected,
        onSelectionChanged: (s) => setState(() {
          _selected
            ..clear()
            ..addAll(s);
        }),
        caption: 'Fleet register',
      ),
    );
  }
}
