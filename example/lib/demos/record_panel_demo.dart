import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Record panel page: a single vehicle record opened for
/// editing, its fields grouped into sections. Controlled — edits update the
/// local values map. Screenshot safe.
class RecordPanelDemo extends StatefulWidget {
  const RecordPanelDemo({super.key});

  @override
  State<RecordPanelDemo> createState() => _RecordPanelDemoState();
}

class _RecordPanelDemoState extends State<RecordPanelDemo> {
  static const _statusOptions = [
    DsGridOption(value: 'active', label: 'Active', variant: DsBadgeVariant.success),
    DsGridOption(value: 'in_service', label: 'In service', variant: DsBadgeVariant.neutral),
    DsGridOption(value: 'grounded', label: 'Grounded', variant: DsBadgeVariant.danger),
  ];

  static final _columns = <DsGridColumn>[
    const DsGridColumn(key: 'id', title: 'Vehicle ID'),
    const DsGridColumn(key: 'vehicle', title: 'Name'),
    const DsGridColumn(key: 'plate', title: 'Plate'),
    const DsGridColumn(key: 'status', title: 'Status', type: DsCellType.status, options: _statusOptions),
    const DsGridColumn(key: 'condition', title: 'Condition', type: DsCellType.rating),
    const DsGridColumn(key: 'insured', title: 'Insured', type: DsCellType.checkbox),
    const DsGridColumn(key: 'driver', title: 'Assigned driver', type: DsCellType.user),
    const DsGridColumn(key: 'monthly', title: 'Monthly cost', type: DsCellType.currency, currencySymbol: r'$'),
    const DsGridColumn(key: 'serviceDue', title: 'Service due', type: DsCellType.date),
  ];

  static const _groups = [
    DsRecordFieldGroup(title: 'Identity', columnKeys: ['id', 'vehicle', 'plate']),
    DsRecordFieldGroup(title: 'Status', columnKeys: ['status', 'condition', 'insured']),
    DsRecordFieldGroup(title: 'Assignment & cost', columnKeys: ['driver', 'monthly', 'serviceDue']),
  ];

  Map<String, Object?> _values = {
    'id': 'VH-1180',
    'vehicle': 'Ford Transit',
    'plate': 'CX-1180',
    'status': 'active',
    'condition': 4,
    'insured': true,
    'driver': 'Ada Lovelace',
    'monthly': 640,
    'serviceDue': DateTime(2026, 8, 12),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 560,
      child: DsRecordPanel(
        title: 'Ford Transit',
        subtitle: 'Vehicle · North depot',
        columns: _columns,
        values: _values,
        readOnlyKeys: const {'id'},
        groups: _groups,
        onChanged: (v) => setState(() => _values = v),
        onSave: () {},
        onClose: () {},
      ),
    );
  }
}
