import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Data import page: a four-step import wizard (upload → map
/// → preview → commit) pre-loaded with a small parsed source so the flow can be
/// walked without real file IO. Screenshot safe.
class DataImportDemo extends StatefulWidget {
  const DataImportDemo({super.key});

  @override
  State<DataImportDemo> createState() => _DataImportDemoState();
}

class _DataImportDemoState extends State<DataImportDemo> {
  static const _statusOptions = [
    DsGridOption(value: 'active', label: 'Active', variant: DsBadgeVariant.success),
    DsGridOption(value: 'grounded', label: 'Grounded', variant: DsBadgeVariant.danger),
  ];

  static final _destination = <DsGridColumn>[
    const DsGridColumn(key: 'vehicle', title: 'Vehicle'),
    const DsGridColumn(key: 'status', title: 'Status', type: DsCellType.status, options: _statusOptions),
    const DsGridColumn(key: 'plate', title: 'Plate'),
    const DsGridColumn(key: 'monthly', title: 'Monthly cost', type: DsCellType.currency, currencySymbol: r'$'),
    const DsGridColumn(key: 'serviceDue', title: 'Service due', type: DsCellType.date),
  ];

  // A small parsed spreadsheet the app would hand the wizard after a file pick.
  static const _source = ImportSource(
    headers: ['Vehicle', 'Status', 'Plate', 'Monthly cost', 'Service due'],
    rows: [
      ['Ford Transit', 'active', 'CX-1180', '640', '2026-08-12'],
      ['Toyota HiAce', 'active', 'BR-4420', '510', '2026-07-28'],
      ['Mercedes Sprinter', 'grounded', 'AK-9037', '720', '2026-07-15'],
    ],
  );

  ImportSource? _loaded = _source;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 520,
      child: DsImportWizard(
        destinationColumns: _destination,
        source: _loaded,
        onBrowse: () => setState(() => _loaded = _source),
        onCancel: () {},
        onCommit: (rows) {},
      ),
    );
  }
}
