// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Layout → Auth gradient.
final PatternPage authGradientPage = PatternPage(
  id: 'auth-gradient',
  group: DocGroup.layout,
  navTitle: 'Auth gradient',
  title: 'Auth gradient',
  description:
      'The auth gradient is the full-bleed wash behind sign-in, sign-up and '
      'waiting screens. `DsAuthGradient` paints the theme\'s '
      '`authWashGradient` stops from top to bottom and lays an optional child '
      'over them, so every entry screen shares one backdrop without '
      'per-screen colour work. The default stops drift from the form '
      'background into the secondary button fill, a barely-there neutral '
      'that keeps the white-label look quiet.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'The wash is decoration: it is excluded from semantics and carries no '
      'meaning of its own. Because the stops are tokens, a skin restyles the '
      'backdrop across the product in one place. The widget fills whatever '
      'bounds its parent provides, so give it a `Positioned.fill`, an '
      'expanded stack slot or an explicit size.',
    ),
  ],
  dos: const [
    'Use it behind full-page auth and waiting surfaces, not inside cards.',
    'Layer a `DsBrandBloom` over the wash when the page should carry the '
        'brand glow.',
    'Restyle the backdrop through the `authWashGradient` token, not with a '
        'bespoke gradient per screen.',
  ],
  donts: const [
    'Don\'t place body text straight onto the deepest stop without checking '
        'contrast; keep copy on a card or the paler end of the wash.',
    'Don\'t hardcode wash colours in a screen; skins can no longer restyle '
        'them.',
    'Don\'t use it as a section divider inside a page; it is a page '
        'backdrop.',
  ],
  code: '''
Scaffold(
  body: DsAuthGradient(
    child: Center(child: signInCard),
  ),
);
''',
  related: ['brand-bloom', 'waiting-screens', 'sign-in'],
);
