// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Layout → Box.
final PatternPage boxPage = PatternPage(
  id: 'box',
  group: DocGroup.layout,
  navTitle: 'Box',
  title: 'Box',
  description:
      'A box is the design system\'s primitive for wrapping a subtree in '
      'tokened spacing, a background, a border, a corner radius and elevation: '
      'everything you would otherwise hand-write on a raw `Container` and '
      '`BoxDecoration`. `DsBox` is deliberately colour-neutral: every colour '
      'defaults to `null`, so an undecorated box is as cheap as a `Padding`, '
      'and you opt into surface treatment by passing theme tokens read from '
      '`DsTokens.of(context)` (`colorBackground`, `colorBorder` and '
      '`borderRadius`) rather than literal hex. Use it to build cards, '
      'panels, callouts and inset regions whose padding and radius track the '
      'theme, so a single token change re-skins every surface at once.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Feed `DsBox` values from the theme rather than raw colours: pass '
      '`tokens.colorBackground` for the fill, `tokens.colorBorder` for the '
      'stroke, `tokens.borderRadius` for the corners and a shadow token '
      '(`tokens.shadowLow`, `tokens.shadowMedium` or `tokens.shadowHigh`) for '
      'the elevation, so a skin that retints its shadows lifts every box with '
      'it. A box with no explicit `width` or `height` sizes to its child; '
      'supplying an `alignment` makes it expand to fill the available space, '
      'as `Container` does.',
    ),
  ],
  dos: const [
    'Read colours from `DsTokens.of(context)` (background, border and radius) instead of hard-coding hex values.',
    'Derive `padding` and `margin` from `tokens.spacingUnit` so insets follow the theme\'s spacing scale.',
    'Pass a shadow token (`shadowLow`, `shadowMedium` or `shadowHigh`) to `shadow` to lift a surface off the page.',
    'Let the box size to its child; add `width`/`height` only when a fixed footprint is required.',
    'Set `borderWidth` alongside `borderColor` when you need a heavier stroke than the 1px default.',
    'Use `DsBox` to build cards, panels and callouts instead of a raw `Container` + `BoxDecoration`.',
  ],
  donts: const [
    'Don\'t hard-code hex colours; a box should re-skin when the theme tokens change.',
    'Don\'t nest many decorated boxes to fake elevation; pass one of the theme\'s shadow tokens instead.',
    'Don\'t rely on the box to clip an overflowing child unless you set a non-zero `borderRadius`.',
    'Don\'t set `borderWidth` without a `borderColor`; the width is ignored when no border is drawn.',
  ],
  code: '''
final tokens = DsTokens.of(context);

DsBox(
  padding: EdgeInsets.all(tokens.spacingUnit * 2),
  background: tokens.colorBackground,
  borderColor: tokens.colorBorder,
  borderRadius: tokens.borderRadius,
  shadow: tokens.shadowLow,
  child: const Text('Monthly volume'),
);
''',
  shots: const [
    Shot(pageId: 'box', size: ShotSize.desktop),
    Shot(pageId: 'box', size: ShotSize.phone),
  ],
  related: const ['divider', 'form-field-group'],
);
