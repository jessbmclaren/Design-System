// Pure Dart — NO Flutter imports.
import '../pattern_page_content.dart';

/// Data → Board view.
final PatternPage boardViewPage = PatternPage(
  id: 'board-view',
  group: DocGroup.data,
  navTitle: 'Board view',
  title: 'Board view',
  description:
      '`DsBoardView` is the same records the grid shows, laid out as a kanban '
      'board: one lane per option of a status or single-select column, plus a '
      'trailing "Ungrouped" lane, each holding a stack of record cards. It is '
      'the view for working a pipeline by hand — moving a vehicle from In '
      'service to Active, a task from To do to Done — where the column a record '
      'sits in *is* its state. Drag a card between lanes, or use the accessible '
      '"Move to…" menu on each card, and the board reports the move through '
      '`onRowMoved(rowId, toGroup)`; like the grid it is controlled and never '
      'mutates your rows.',
  blocks: const [
    ProseBlock(
      'Lanes are drawn from the group column\'s `options`, in their declared '
      'order, so the board reads left-to-right the way your workflow does; the '
      'lane header shows the option as its coloured badge and a live count. Each '
      'card leads with the record\'s primary text and shows a few secondary '
      'fields — a status badge, an owner\'s avatar, a cost — and you can replace '
      'it with your own `cardBuilder`. On a wide screen the lanes sit '
      'side-by-side in a horizontal scroll; on a phone they stack full-width and '
      'collapse, so the same board works from 320dp up.',
    ),
    ProseBlock(
      'Reach for the board when moving records between states is the job. When '
      'the job is instead scanning many attributes at once, use the grid; when '
      'it is totalling clusters, use grouping. All three read the same '
      '`DsGridColumn` / `DsGridRow` model, so a view switch is a change of '
      'presentation, not of data.',
    ),
  ],
  dos: const [
    'Lane by a column whose options are genuine states of a workflow — a status, '
        'a stage — so moving a card means something.',
    'Keep cards scannable: a strong primary line and two or three secondary '
        'fields, not a transcription of every column.',
    'Rely on the built-in "Move to…" menu for keyboard and screen-reader users; '
        'drag is an enhancement, not the only way to move a card.',
    'Treat the board as controlled — apply `onRowMoved` to your state so the '
        'grid, board and any totals stay in agreement.',
  ],
  donts: const [
    "Don't lane by a column with dozens of options; a board is legible at a "
        'handful of lanes, not a wall of them.',
    "Don't hide records with no group value — the Ungrouped lane is where they "
        'belong until someone triages them.',
    "Don't put actions that lose data behind a drag alone; confirm destructive "
        'moves the same way you would elsewhere.',
    "Don't use a board when order within a lane carries no meaning and the real "
        "task is comparison — that is the grid's job.",
  ],
  code: '''
DsBoardView(
  columns: columns,
  rows: rows,
  // Lane by a status / single-select column; lanes follow its options.
  groupByKey: 'status',
  onRowMoved: (move) {
    setState(() => _apply(move.rowId, status: move.toGroup));
  },
  onCardTap: (row) => _openRecord(row),
);
''',
  shots: const [
    Shot(pageId: 'board-view', size: ShotSize.desktop),
    Shot(pageId: 'board-view', size: ShotSize.phone),
  ],
  hasLiveDemo: true,
  related: ['data-grid', 'grouping', 'filtering-sorting'],
);
