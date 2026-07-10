// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// User actions → Action buttons.
final PatternPage actionButtonsPage = PatternPage(
  id: 'action-buttons',
  group: DocGroup.actions,
  navTitle: 'Action buttons',
  title: 'Action buttons',
  description:
      'Anchor a record\'s main actions in its `DsPageHeader` so they stay '
      'reachable while the content below scrolls. Give each view a single '
      'primary `DsButton` for the one action you most want people to take, and '
      'render the supporting choices as `secondary` buttons beside it. '
      'Placement is consistent and responsive: the header measures its own '
      'width, keeps actions on the trailing edge beside the title from the '
      '600dp medium breakpoint and stacks them beneath the title when '
      'narrower, so it adapts inside a split pane as well as a full window. '
      'People always know where to look to act, and the emphasis in the '
      'button styling tells them which action is the expected next step.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Emphasis comes from the `variant`, not the position. Reserve the '
      '`danger` variant for destructive, hard-to-undo actions such as deleting '
      'a record or voiding a document, and pair it with a confirmation step. '
      'Ordinary actions (even important ones like saving) should never borrow '
      'the danger style, or the colour stops signalling real risk.',
    ),
    ProseBlock(
      'Feedback is felt, not flashy. On press a `DsButton` gives a subtle, '
      'physical response: it scales down a touch and springs back through the '
      '`DsMotion.spring` token, settling with a single small overshoot and no '
      'bounce, with the ink ripple removed so the motion itself is the '
      'acknowledgement. It is deliberately restrained: the same calm press on '
      'every button reads as considered, where an exaggerated bounce would read '
      'as a toy. Under reduced motion it holds perfectly still. Because it '
      'lives in the atom, every button in the product feels identical; you '
      'never add your own scale or bounce on top.',
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
    'Don\'t add a custom scale or bounce to a button; the atom\'s subtle, '
        'token-driven press is the single consistent feedback.',
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
