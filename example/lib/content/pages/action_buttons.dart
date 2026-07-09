// Pure Dart — NO Flutter imports.
import '../pattern_page_content.dart';

/// User actions → Action buttons.
final PatternPage actionButtonsPage = PatternPage(
  id: 'action-buttons',
  group: DocGroup.userActions,
  navTitle: 'Action buttons',
  title: 'Action buttons',
  description:
      'Anchor a record\'s main actions in its `DsPageHeader` so they stay '
      'reachable while the content below scrolls. Give each view a single '
      'primary `DsButton` for the one action you most want people to take, and '
      'render the supporting choices as `secondary` buttons beside it. This '
      'consistent placement — aligned to the trailing edge beside the title on '
      'wide layouts, and stacked beneath it on narrow ones — means people '
      'always know where to look to act, and the emphasis in the button '
      'styling tells them which action is the expected next step.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Emphasis comes from the `variant`, not the position. Reserve the '
      '`danger` variant for destructive, hard-to-undo actions such as deleting '
      'a record or voiding a document, and pair it with a confirmation step. '
      'Ordinary actions — even important ones like saving — should never borrow '
      'the danger style, or the colour stops signalling real risk.',
    ),
  ],
  dos: const [
    'Put the main actions in the page header so they stay visible while content scrolls.',
    'Use exactly one primary button per view for the expected next step.',
    'Render supporting choices as secondary buttons beside the primary one.',
    'Keep action placement consistent across every page in the product.',
    'Reserve the danger variant for destructive, hard-to-undo actions.',
  ],
  donts: const [
    'Don\'t bury actions at the bottom of scrolling content.',
    'Don\'t present two primary buttons competing for attention.',
    'Don\'t use the danger style for ordinary actions.',
    'Don\'t change action order or placement from one page to the next.',
  ],
  code: '''
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

DsPageHeader(
  title: 'Invoice #1042',
  subtitle: 'Draft · Due 30 July 2026',
  actions: [
    DsButton(
      label: 'Edit',
      variant: DsButtonVariant.secondary,
      onPressed: () {},
    ),
    DsButton(label: 'Send', onPressed: () {}),
  ],
)
''',
  shots: const [
    Shot(pageId: 'action-buttons', size: ShotSize.desktop),
    Shot(pageId: 'action-buttons', size: ShotSize.phone),
  ],
  related: ['full-page-layouts', 'communicating-state'],
);
