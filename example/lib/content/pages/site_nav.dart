// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Layout → Site navigation.
final PatternPage siteNavPage = PatternPage(
  id: 'site-nav',
  group: DocGroup.layout,
  navTitle: 'Site navigation',
  title: 'Site navigation',
  description:
      'A site bar frames the pages around a product the way the app shell '
      'frames the product itself: a landing page, pricing, documentation. '
      '`DsTopNav` lays a brand on the leading edge with its links beside it '
      'and its actions on the other, resting on `DsNavLink` for the labels '
      'and `DsFloatingBar` for its lift.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'As the width tightens the bar discloses progressively rather than '
      'dropping anything. The links leave the bar first and the actions '
      'follow, both reachable from a sheet behind the menu trigger, and the '
      'brand is the one element allowed to scale down, so the row holds '
      'together on the smallest phone.',
    ),
    ProseBlock(
      '`DsFloatingBar` is treatment only: while content has scrolled beneath '
      'it, a hairline and a soft shadow fade in so the bar reads as a layer '
      'above the page. The caller owns that knowledge, because only the '
      'caller knows which scroll view matters.',
    ),
  ],
  dos: const [
    'Drive `floating` from the scroll view the bar actually covers.',
    'Keep the link set short; a site bar is not a sitemap.',
    'Mark a link that opens a menu as a dropdown so it announces as a button.',
  ],
  donts: const [
    'Don\'t use the site bar for a signed-in product; the app shell frames that.',
    'Don\'t drop links on narrow widths; the bar folds them into the sheet.',
    'Don\'t stack a second bar beneath it; one bar owns the top edge.',
  ],
  code: '''
DsTopNav(
  brand: const DsWordmark(),
  links: [
    DsTopNavLink(label: 'Product', dropdown: true, onTap: openProductMenu),
    DsTopNavLink(label: 'Pricing', onTap: goToPricing),
  ],
  secondaryActions: [
    DsButton(
      label: 'Log in',
      variant: DsButtonVariant.tertiary,
      onPressed: logIn,
    ),
  ],
  primaryAction: DsButton(label: 'Get started', onPressed: signUp),
  floating: hasScrolled,
);
''',
  related: const ['app-shell', 'nav-rail', 'menu-sheet'],
);
