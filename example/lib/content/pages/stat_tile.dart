// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Data → Stat tiles.
final PatternPage statTilePage = PatternPage(
  id: 'stat-tile',
  group: DocGroup.data,
  navTitle: 'Stat tiles',
  title: 'Stat tiles',
  description:
      'A stat tile states one number plainly: a label above a figure, with '
      'an optional line of context beneath. Give `DsStatTile` an `onTap` and '
      'it becomes a choice, which is how a row of tiles doubles as the '
      'segments above a table: the whole set, the open ones, the archived '
      'ones.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'A selected tile carries the brand accent on its label and figure, a '
      'brand-tinted fill and a heavier border, and announces itself as '
      'selected, so the state reads without relying on colour alone. A tile '
      'with no `onTap` is a plain card that still announces its label and '
      'figure as one thing.',
    ),
    ProseBlock(
      'Lay tiles out as `Expanded` children of a row so they share the width '
      'evenly, and wrap them below a comfortable width so each keeps a '
      'readable measure. The figure is the caller\'s to format: the tile '
      'never rounds or abbreviates a number behind your back.',
    ),
  ],
  dos: const [
    'Format the figure yourself, including its thousands separators or currency.',
    'Use the caption for a comparison, such as a change since last month.',
    'Give every tile in a set the same shape, so the row reads as one control.',
  ],
  donts: const [
    'Don\'t use tiles for more than a handful of segments; a select handles more.',
    'Don\'t mark a tile selected when it is not a choice; that needs an `onTap`.',
    'Don\'t bury a long label; it ellipsizes rather than wrapping.',
  ],
  code: '''
Row(
  children: [
    Expanded(
      child: DsStatTile(label: 'Total', value: '1,284', onTap: showAll),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: DsStatTile(
        label: 'Open',
        value: '96',
        caption: 'up 12 this week',
        selected: true,
        onTap: showOpen,
      ),
    ),
  ],
);
''',
  related: const ['data-grid', 'table-views', 'meter-chart'],
);
