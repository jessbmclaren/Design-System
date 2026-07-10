// Pure Dart — NO Flutter imports.
import '../pattern_page_content.dart';

/// Foundations → Iconography.
final PatternPage iconographyPage = PatternPage(
  id: 'iconography',
  group: DocGroup.foundations,
  navTitle: 'Iconography',
  title: 'Iconography',
  description:
      'Icons are referenced by the role they play, not the glyph they happen '
      'to be. `DsIcons` is the system\'s icon vocabulary: a component asks for '
      '`DsIcons.close` or `DsIcons.success`, and the registry decides which '
      'drawing that is. Centralising it is what turns a pile of glyphs into a '
      'system — the family policy lives in one place, the set stays coherent, '
      'and re-branding the iconography (or swapping in a real Lucide font '
      'later) is a single file\'s edit rather than a hunt through every call '
      'site.',
  blocks: const [
    ProseBlock(
      'The set is drawn to read like Lucide — thin, even, open line work with a '
      'consistent stroke. A short family policy keeps it honest: **outlined '
      'line glyphs** are the default for actions, affordances and status; '
      '**bare strokes** carry pure directional marks (chevrons, arrows, add, '
      'close) that have no shape to outline; **filled is reserved for '
      'true-state** glyphs where the fill itself is the meaning, like a selected '
      'rating star; and the **rounded family is banned** — it reads as '
      'consumer-playful, the wrong register for a dense professional product, '
      'so any rounded Material glyph is mapped to its sharp or outlined '
      'equivalent here.',
    ),
    ProseBlock(
      'Because every component reaches through the registry, iconography is part '
      'of the white-label story without being theme-aware: a brand that wants '
      'different icons forks this one file and remaps the roles to its own '
      'glyphs, and the whole system follows. Name new entries for their role '
      '(`upload`, `warning`, `externalLink`), never their appearance, so the '
      'name survives a glyph change.',
    ),
  ],
  dos: const [
    'Reference icons by role through `DsIcons` — never reach for `Icons.*` '
        'directly in a component or a screen.',
    'Add a new glyph by adding a semantic entry to the registry, so the family '
        'policy and the single swap-site stay intact.',
    'Keep to the outlined line family; reserve a filled glyph for a genuine '
        'true-state (a selected star), never for emphasis.',
    'Pair an icon-only control with a semantic label so the meaning never rests '
        'on the glyph alone.',
  ],
  donts: const [
    "Don't scatter raw `Icons.*` through the codebase; that is the audit the "
        'registry exists to prevent.',
    "Don't introduce a rounded glyph — it breaks the register; map it to the "
        'sharp or outlined equivalent instead.',
    "Don't name an entry for how it looks (`filledBell`); name it for what it "
        'means (`notifications`) so a later redraw keeps the name true.',
    "Don't lean on colour or fill alone to carry meaning; the line work and an "
        'accessible label do the work.',
  ],
  code: '''
// Components and screens reference the role, not the glyph.
DsIcon(icon: DsIcons.success, semanticLabel: 'Saved');

DsButton(
  label: 'Export',
  icon: DsIcons.upload,
  onPressed: _export,
);

// Re-branding is one file: fork ds_icons.dart and remap the role.
//   static const IconData close = MyBrandIcons.dismiss;
''',
  shots: const [
    Shot(pageId: 'iconography', size: ShotSize.desktop),
    Shot(pageId: 'iconography', size: ShotSize.phone),
  ],
  hasLiveDemo: true,
  related: ['design-tokens', 'motion'],
);
