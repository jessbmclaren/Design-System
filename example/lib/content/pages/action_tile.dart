// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Actions → Action tiles.
final PatternPage actionTilePage = PatternPage(
  id: 'action-tile',
  group: DocGroup.actions,
  navTitle: 'Action tiles',
  title: 'Action tiles',
  description:
      'An action tile is the shortcut a home screen puts its common jobs on: a '
      'glyph above a title and a supporting line. Where a stat tile states a '
      'number, `DsActionTile` names a job and says where it leads.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'The glyph does the recognising, so a thumb finds the tile before the '
      'label is read. It is decorative to assistive technology, because the '
      'title already names the job and a screen reader would otherwise hear '
      'it twice. The tile announces its title and subtitle as one thing.',
    ),
    ProseBlock(
      'The card carries a shadow rather than an outline, so a grid of tiles '
      'reads as objects lifted off the page. Keyboard focus is the one time it '
      'draws a ring, since a shadow cannot show focus, and the ring holds its '
      'space when unfocused so gaining focus never shifts the grid.',
    ),
    ProseBlock(
      'Lay tiles out as `Expanded` children of a row so they share the width '
      'evenly, and wrap them below a comfortable width so each keeps a '
      'readable measure. A tile with no `onTap` is a plain card and leaves the '
      'focus order.',
    ),
  ],
  dos: const [
    'Give the tone a job: a distinct tone per tile helps a thumb aim.',
    'Keep the title to the job itself, and the subtitle to where it leads.',
    'Wrap tiles below a comfortable width so each keeps a readable measure.',
  ],
  donts: const [
    'Don\'t repeat the title in the subtitle; both lines ellipsize on one line.',
    'Don\'t use a tile for a destructive action; that belongs on a button.',
    'Don\'t rely on the glyph alone to say what the tile does.',
  ],
  code: '''
Row(
  children: [
    Expanded(
      child: DsActionTile(
        icon: DsIcons.fuel,
        title: 'I want to fuel',
        subtitle: 'Find a station',
        tone: DsIconBadgeTone.danger,
        onTap: openStations,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: DsActionTile(
        icon: DsIcons.reward,
        title: 'Rewards',
        subtitle: 'Points & streaks',
        tone: DsIconBadgeTone.warning,
        onTap: openRewards,
      ),
    ),
  ],
);
''',
  related: const ['stat-tile', 'icon-badge', 'bottom-nav'],
);
