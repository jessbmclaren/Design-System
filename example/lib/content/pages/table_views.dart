// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Data → Table views.
final PatternPage tableViewsPage = PatternPage(
  id: 'table-views',
  group: DocGroup.data,
  navTitle: 'Table views',
  title: 'Table views',
  description:
      'A table view is a saved way of looking at the same records: which '
      'columns show, in what order, under what labels, sorted how, with '
      'which column-bottom calculations. `DsGridView` captures that '
      'configuration as plain data the caller owns. Pass one to '
      '`DsDataGrid.view` and the grid renders it; add `onViewChanged` and '
      'the grid grows its management surface, so users shape the view '
      'directly in the table and every change comes back to you as a new '
      'value to store.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'With `onViewChanged` set, each header gains a column menu (sort '
      'ascending or descending, move, edit label, hide), headers reorder by '
      'long-press drag with the menu\'s move actions covering keyboard and '
      'assistive users, a trailing add-column affordance restores hidden '
      'columns and a footer band holds the calculations: count for any '
      'column, sum, average, min and max for numeric ones. Relabelling is '
      'display-only; the underlying column and its data key never change.',
    ),
    ProseBlock(
      'The grid never stores a view itself. Persisting views, naming them '
      'and switching between them belongs to the application: hold a list '
      'of `DsGridView` values, show the active one, and compose a switcher '
      'from `DsTabs` or `DsMenu`. Passing a view without `onViewChanged` '
      'renders it read-only, which is how a shared or locked view ships.',
    ),
  ],
  dos: const [
    'Store the emitted view and pass it straight back; the grid renders only what you give it.',
    'Give saved views meaningful names in your switcher, such as `Overdue accounts`.',
    'Use display relabels for context, such as shortening `Organisation legal name` to `Organisation`.',
    'Ship locked or shared views by passing the view without `onViewChanged`.',
  ],
  donts: const [
    'Don\'t mutate a view in place; emit and store new values so equality and undo stay trivial.',
    'Don\'t hide every column; the grid refuses to hide the last one.',
    'Don\'t use relabels to change meaning; they restyle the header, not the data.',
  ],
  code: '''
DsDataGrid(
  columns: columns,
  rows: rows,
  view: activeView,
  onViewChanged: (next) => setState(() => activeView = next),
);

// A saved view is plain data:
const overdue = DsGridView(
  visibleColumns: ['driver', 'amount', 'status'],
  columnLabels: {'driver': 'Account holder'},
  sort: DsGridSort(columnKey: 'amount', ascending: false),
  calculations: {'amount': DsAggregation.sum},
);
''',
  related: const ['data-grid', 'cell-types', 'grouping', 'filtering-sorting'],
);
