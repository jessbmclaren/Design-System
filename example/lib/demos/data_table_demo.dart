import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Data table page: a small block of already-formatted rows,
/// the job this component exists for. Rows are tappable and one is selected,
/// so both states are visible. Deterministic — fixed data, no timers.
class DataTableDemo extends StatefulWidget {
  const DataTableDemo({super.key});

  @override
  State<DataTableDemo> createState() => _DataTableDemoState();
}

class _DataTableDemoState extends State<DataTableDemo> {
  static const _rows = <List<String>>[
    <String>['INV-0042', '12 Jun 2026', 'R1,240.50', 'Paid'],
    <String>['INV-0043', '19 Jun 2026', 'R860.00', 'Overdue'],
    <String>['INV-0044', '26 Jun 2026', 'R2,015.75', 'Paid'],
    <String>['INV-0045', '03 Jul 2026', 'R430.00', 'Draft'],
  ];

  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    return DsDataTable(
      columns: const <DsColumn>[
        DsColumn(label: 'Invoice'),
        DsColumn(label: 'Issued'),
        // Numeric columns align to the trailing edge by convention.
        DsColumn(label: 'Amount', numeric: true),
        DsColumn(label: 'Status'),
      ],
      rows: <DsDataRow>[
        for (var i = 0; i < _rows.length; i++)
          DsDataRow(
            cells: _rows[i],
            selected: i == _selected,
            onTap: () => setState(() => _selected = i),
          ),
      ],
    );
  }
}
