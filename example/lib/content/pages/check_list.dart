// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Content → Check list.
final PatternPage checkListPage = PatternPage(
  id: 'check-list',
  group: DocGroup.inputs,
  navTitle: 'Check list',
  title: 'Check list',
  description:
      'A `DsCheckList` is the body shared by every "pick several from a set" '
      'surface in the system: a scrollable column of `DsCheckbox` rows with an '
      'optional action row pinned beneath them. The `DsCheckMenu` column '
      'picker renders one, and so does the data grid\'s multi-select cell '
      'editor — which is the point. Two checklists in the same product are the '
      'same checklist, with the same row height, the same checkbox and the '
      'same padding, because they are literally the same widget.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'It draws no surface of its own. A popover, a side panel and an inline '
      'block frame their content differently, so the host supplies the fill, '
      'border, radius and shadow and the list supplies only the rows. Give it '
      'bounded width — a popover\'s constraints, a panel\'s column — rather '
      'than an unbounded one.',
    ),
    ProseBlock(
      'The list is controlled: every toggle reports the whole next selection '
      'through `onChanged` and the caller passes the result back in '
      '`selected`, so the list holds no state. Lock an option with '
      '`enabled: false` and it keeps whatever state it is in and ignores taps '
      '— the way a caller guarantees a selection can never empty. Rows scroll '
      'once they pass `maxHeight` while the action row stays put, so a long '
      'list never pushes its own action off the bottom.',
    ),
    ProseBlock(
      'Reach for the list directly when the choices belong on the surface — '
      'inline in a settings panel or a filter sheet. Wrap it in a '
      '`DsCheckMenu` when they should stay behind a trigger until asked for. '
      'When exactly one choice applies, use a `DsSelect` instead.',
    ),
  ],
  dos: const [
    'Frame it yourself: the list is the rows, the host is the surface.',
    'Lock the options that must always stay selected with `enabled: false`.',
    'Give it a bounded width, and a `maxHeight` that leaves the action row on '
        'screen.',
    'Keep labels to one line; longer ones ellipsize.',
  ],
  donts: const [
    'Don\'t nest it in another scroll view of the same axis — it already '
        'scrolls past `maxHeight`.',
    'Don\'t hold the selection inside the list; it is controlled, so the '
        'screen owns it.',
    'Don\'t use it for a single mutually exclusive choice; use a select.',
    'Don\'t hand-build a second checklist somewhere else in the product.',
  ],
  code: '''
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

DsCheckList(
  options: const [
    // Locked, so the selection can never empty.
    DsCheckOption(value: 'name', label: 'Application', enabled: false),
    DsCheckOption(value: 'owner', label: 'Owner'),
    DsCheckOption(value: 'spend', label: 'Spend'),
  ],
  selected: const {'name', 'owner'},
  onChanged: (next) {},
  actionLabel: 'Select all',
  onAction: () {},
)
''',
  shots: const [
    Shot(pageId: 'check-list', size: ShotSize.desktop),
    Shot(pageId: 'check-list', size: ShotSize.phone),
  ],
  related: const ['check-menu', 'selection-controls', 'select-dropdown'],
);
