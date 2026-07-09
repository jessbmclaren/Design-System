import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The account status used by the Status filter chip.
enum _Status { active, invited, paused }

/// The plan tier used by the Plan filter chip.
enum _Plan { starter, growth, enterprise }

/// A single record shown in the demo table.
class _Member {
  const _Member(this.name, this.status, this.plan, this.amount);

  final String name;
  final _Status status;
  final _Plan plan;
  final String amount;

  String get statusLabel => switch (status) {
    _Status.active => 'Active',
    _Status.invited => 'Invited',
    _Status.paused => 'Paused',
  };
}

const _members = <_Member>[
  _Member('Amara Okafor', _Status.active, _Plan.growth, '\$1,240'),
  _Member('Ben Whitfield', _Status.invited, _Plan.starter, '\$0'),
  _Member('Chandra Rao', _Status.active, _Plan.enterprise, '\$8,900'),
  _Member('Dana Levine', _Status.paused, _Plan.growth, '\$1,240'),
  _Member('Elias Brandt', _Status.active, _Plan.starter, '\$320'),
  _Member('Farah Nasser', _Status.invited, _Plan.enterprise, '\$8,900'),
];

/// Live demo for the Filter controls page: two filter chips above a data
/// table, with the rows narrowed in Dart before they reach the table.
class FilterControlsDemo extends StatefulWidget {
  const FilterControlsDemo({super.key});

  @override
  State<FilterControlsDemo> createState() => _FilterControlsDemoState();
}

class _FilterControlsDemoState extends State<FilterControlsDemo> {
  // Initialise with one active filter so a single captured frame is meaningful.
  _Status? _status = _Status.active;
  _Plan? _plan;

  bool get _hasFilters => _status != null || _plan != null;

  @override
  Widget build(BuildContext context) {
    final visible = _members
        .where((m) => _status == null || m.status == _status)
        .where((m) => _plan == null || m.plan == _plan)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DsFilterChip<_Status>(
              label: 'Status',
              value: _status,
              onChanged: (v) => setState(() => _status = v),
              options: const [
                DsFilterOption(value: _Status.active, label: 'Active'),
                DsFilterOption(value: _Status.invited, label: 'Invited'),
                DsFilterOption(value: _Status.paused, label: 'Paused'),
              ],
            ),
            DsFilterChip<_Plan>(
              label: 'Plan',
              value: _plan,
              onChanged: (v) => setState(() => _plan = v),
              options: const [
                DsFilterOption(value: _Plan.starter, label: 'Starter'),
                DsFilterOption(value: _Plan.growth, label: 'Growth'),
                DsFilterOption(value: _Plan.enterprise, label: 'Enterprise'),
              ],
            ),
            if (_hasFilters)
              TextButton(
                onPressed: () => setState(() {
                  _status = null;
                  _plan = null;
                }),
                child: const Text('Clear filters'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          DsEmptyState(
            icon: Icons.filter_alt_off_outlined,
            title: 'No matching records',
            message: 'No members match the current filters. Try clearing them '
                'to see everyone.',
            action: DsEmptyStateAction(
              label: 'Clear filters',
              onPressed: () => setState(() {
                _status = null;
                _plan = null;
              }),
            ),
          )
        else
          DsDataTable(
            columns: const [
              DsColumn(label: 'Name'),
              DsColumn(label: 'Status'),
              DsColumn(label: 'Amount', numeric: true),
            ],
            rows: [
              for (final m in visible)
                DsDataRow(cells: [m.name, m.statusLabel, m.amount]),
            ],
          ),
      ],
    );
  }
}
