// Pure Dart — NO Flutter imports.
import '../pattern_page_content.dart';

/// Data → Grouping & aggregation.
final PatternPage groupingPage = PatternPage(
  id: 'grouping',
  group: DocGroup.data,
  navTitle: 'Grouping',
  title: 'Grouping & aggregation',
  description:
      'Grouping turns a flat grid into an outline. Pass `DsDataGrid` a `groupBy` '
      'list of column keys and it partitions the rows under collapsible group '
      'headers — one key gives flat groups, several give nested subgroups '
      '(depot → status → …), each indented under its parent. Every header shows '
      'the group value and its record count, and an `aggregations` map rolls up '
      'a chosen column per group — a summed monthly cost, an averaged '
      'utilisation, a count — rendered aligned under its column so the summary '
      'reads like part of the table. Collapse a group to fold its rows (and '
      'subgroups) away and scan the shape of the data.',
  blocks: const [
    ProseBlock(
      'Grouping is a view over the same rows, applied after the grid\'s own '
      'sort, so it composes with everything else: frozen columns stay pinned, '
      'the header band and its aggregations scroll horizontally in step with '
      'the columns, and below the compact breakpoint each group becomes a '
      'labelled, collapsible section above its stacked cards. Group labels '
      'resolve select and status values through the column\'s `options`, format '
      'dates and currency like their cells, and read a missing value as '
      '"Ungrouped". Collapse state is the grid\'s own; `initiallyExpanded` sets '
      'the starting posture.',
    ),
    ProseBlock(
      'Reach for grouping when the question is "how do these records cluster, '
      'and what do the clusters total?" — vehicles by depot and status, drivers '
      'by team, costs by category. For moving records between clusters by hand, '
      'reach for the board view; for slicing which records are in scope at all, '
      'reach for filtering.',
    ),
  ],
  dos: const [
    'Group by the attribute people compare across — a status, a depot, an '
        'owner — and add a second key only when the nesting genuinely helps.',
    'Aggregate the columns whose totals matter (sum a cost, average a rate) and '
        'leave the rest; a header crowded with roll-ups stops being scannable.',
    'Give select and status group columns their `options` so headers show clean '
        'labels and colours instead of raw stored values.',
    'Start groups expanded for small sets and collapsed for large ones via '
        '`initiallyExpanded`, so the first screen is legible.',
  ],
  donts: const [
    "Don't nest more than two or three levels deep — past that the indentation "
        'costs more than the structure gives back.',
    "Don't group by a near-unique column (an id, a free-text note); you get one "
        'record per group and lose the outline entirely.',
    "Don't sum a column whose values aren't additive (a rate, a ratio) — average "
        'or count it instead, or leave it un-aggregated.',
    "Don't rely on grouping to hide records that shouldn't be there — filter "
        'them out first, then group what remains.',
  ],
  code: '''
DsDataGrid(
  caption: 'Fleet grouped by depot, then status',
  columns: _columns,
  rows: _rows,
  // Outermost key first: depot → status subgroups.
  groupBy: const ['depot', 'status'],
  // Roll up a total and an average per group, aligned under their columns.
  aggregations: const {
    'monthly': DsAggregation.sum,
    'utilisation': DsAggregation.average,
  },
  initiallyExpanded: true,
);
''',
  shots: const [
    Shot(pageId: 'grouping', size: ShotSize.desktop),
    Shot(pageId: 'grouping', size: ShotSize.phone),
  ],
  hasLiveDemo: true,
  related: ['data-grid', 'board-view', 'filtering-sorting'],
);
