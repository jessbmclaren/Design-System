// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Layout → Filter controls.
final PatternPage filterControlsPage = PatternPage(
  id: 'filter-controls',
  group: DocGroup.inputs,
  navTitle: 'Filter controls',
  title: 'Filter controls',
  description:
      'Filter controls let people narrow a table or list to the records they '
      'care about. Each `DsFilterChip` has two states driven entirely by its '
      'value: a suggested chip shows the filter name and opens a menu of '
      'options when tapped, and an active chip shows the chosen value with a '
      'clear affordance. Arrange chips horizontally above the data so the set '
      'of active filters is always visible, and filter the rows in Dart before '
      'they reach the table so totals, counts and pagination stay honest.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'The chip is generic over its value type, so it can carry an enum, an id '
      'or any domain value without stringly-typed lookups. When more than one '
      'filter is active, offer a single "Clear filters" link beside the chips '
      'so people can reset the view in one step. If a combination of filters '
      'leaves no matching records, replace the table with an empty state that '
      'explains why and offers a way back.',
    ),
  ],
  dos: const [
    'Filter the data in Dart before passing it to the table so row counts, '
        'totals and pagination reflect what is shown.',
    'Match each chip label to the column it filters, such as Status or Plan.',
    'Arrange chips horizontally in a Wrap above the table so they reflow '
        'cleanly from phone to desktop.',
    'Show a "Clear filters" link only while at least one filter is active.',
    'Render an empty state when the active filters match no records.',
  ],
  donts: const [
    'Do not reopen the options menu when someone clears an active chip; '
        'clearing should only remove the filter.',
    'Do not use chips for complex multi-field filtering; use a focused '
        'filter panel instead.',
    'Do not leave a filtered-empty table blank with no explanation or reset.',
    'Do not hide the active filters below the fold where their effect on the '
        'data is invisible.',
  ],
  code: '''
// Keep the selected filters in state and narrow the rows in Dart
// before building the table, so counts stay correct.
DsStatus? status = DsStatus.active;

final visible = people
    .where((p) => status == null || p.status == status)
    .toList();

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Wrap(
      spacing: 8,
      children: [
        DsFilterChip<DsStatus>(
          label: 'Status',
          value: status,
          onChanged: (v) => setState(() => status = v),
          options: const [
            DsFilterOption(value: DsStatus.active, label: 'Active'),
            DsFilterOption(value: DsStatus.invited, label: 'Invited'),
            DsFilterOption(value: DsStatus.paused, label: 'Paused'),
          ],
        ),
        if (status != null)
          TextButton(
            onPressed: () => setState(() => status = null),
            child: const Text('Clear filters'),
          ),
      ],
    ),
    DsDataTable(
      columns: const [
        DsColumn(label: 'Name'),
        DsColumn(label: 'Status'),
        DsColumn(label: 'Amount', numeric: true),
      ],
      rows: [
        for (final p in visible)
          DsDataRow(cells: [p.name, p.statusLabel, p.amount]),
      ],
    ),
  ],
)
''',
  shots: const [
    Shot(pageId: 'filter-controls', size: ShotSize.desktop),
    Shot(pageId: 'filter-controls', size: ShotSize.phone),
  ],
  related: ['lists', 'empty-state', 'full-page-layouts'],
);
