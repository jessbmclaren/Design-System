// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Content → Check menu.
final PatternPage checkMenuPage = PatternPage(
  id: 'check-menu',
  group: DocGroup.overlays,
  navTitle: 'Check menu',
  title: 'Check menu',
  description:
      'A `DsCheckMenu` is the picker for choosing *several* things at once. '
      'Where a `DsMenu` runs one command and closes, a check menu stays open '
      'while the user ticks options on and off, which is the shape a column '
      'picker, a tag picker or a filter value list needs. It is controlled: '
      'every toggle reports the whole next selection through `onChanged` and '
      'the caller passes the result back in `selected`, so the menu holds no '
      'state of its own and the screen stays the single source of truth. The '
      'surface takes the same fill, radius, border and shadow tokens as '
      '`DsMenu`, so the two read as one system under any white-label skin, and '
      'the rows themselves are a `DsCheckList` — the same body the data '
      'grid\'s multi-select cell editor renders.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'A trailing row selects every enabled option, and once they are all '
      'ticked it flips to clearing them again. Lock an option with '
      '`enabled: false` and it keeps whatever state it is in, ignores taps '
      'and is skipped by that row — which is how a caller guarantees the '
      'selection can never be emptied. A column picker locks the one or two '
      'columns that identify the record, so a table can never be left with '
      'nothing to identify its rows by. Pass `showSelectAll: false` when the '
      'set is short enough that the row is only noise.',
    ),
    ProseBlock(
      'Reach for a check menu when the choices are additive and the user will '
      'usually change more than one before moving on. When exactly one choice '
      'applies, use a `DsSelect`, which shows the current value and reads as '
      'a form control. When the choices are actions rather than state, use a '
      '`DsMenu`, which closes on the choice being made. When there are only '
      'two or three options and the space allows, put `DsCheckbox`es inline '
      'instead of hiding them behind a trigger.',
    ),
  ],
  dos: const [
    'Give an icon-only trigger a semantic label so its purpose is announced.',
    'Lock the options that must always stay selected with `enabled: false`, so '
        'the selection can never empty.',
    'Rebuild the caller\'s list in its own canonical order, so re-ticking an '
        'option restores it where it belongs rather than at the end.',
    'Keep labels short enough to read on one line; long ones ellipsize.',
    'Use `showSelectAll: false` for a short list where the row adds nothing.',
  ],
  donts: const [
    'Don\'t use a check menu for a single mutually exclusive choice; use a '
        'select instead.',
    'Don\'t use it for actions — a menu that stays open after running a '
        'command reads as broken.',
    'Don\'t hide the only way to recover a hidden column behind an unlabelled '
        'icon.',
    'Don\'t hold the selection inside the menu; it is controlled, so the '
        'screen owns it.',
  ],
  code: '''
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

DsCheckMenu(
  trigger: const DsIcon(icon: DsIcons.tune, semanticLabel: 'Columns'),
  options: const [
    // Locked, so the table always keeps something to identify rows by.
    DsCheckOption(value: 'status', label: 'Status', enabled: false),
    DsCheckOption(value: 'name', label: 'Application', enabled: false),
    DsCheckOption(value: 'owner', label: 'Owner'),
    DsCheckOption(value: 'spend', label: 'Spend'),
    DsCheckOption(value: 'requests', label: 'Requests'),
  ],
  selected: const {'status', 'name', 'owner', 'spend'},
  onChanged: (next) {},
)
''',
  shots: const [
    Shot(pageId: 'check-menu', size: ShotSize.desktop),
    Shot(pageId: 'check-menu', size: ShotSize.phone),
  ],
  related: const ['check-list', 'menu', 'select-dropdown', 'table-workbench'],
);
