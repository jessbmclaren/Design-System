// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Layout → Navigation rail.
final PatternPage navRailPage = PatternPage(
  id: 'nav-rail',
  group: DocGroup.layout,
  navTitle: 'Navigation rail',
  title: 'Navigation rail',
  description:
      'A navigation rail is the vertical side navigation for app chrome: '
      'icon-only by default, a labelled sidebar when extended. Both forms of '
      '`DsNavRail` share one treatment: the selected destination sits on the '
      'theme\'s brand-tinted fill with the brand ink, hovering shows a soft '
      'fill and keyboard focus draws a distinct accent ring. Selection is '
      'controlled, so the rail marks the destination you pass and reports '
      'taps through `onNavigate` without owning any routing itself. The app '
      'shell composes the rail for you and switches between its forms by '
      'width; reach for the rail directly when building custom chrome.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'Destinations are plain data: a `DsNavItem` binds a label and a '
      '`DsIcons` glyph to the stable route string reported back on tap. '
      'Icon-only items carry their label as a tooltip and announce it to '
      'assistive technology, so the compact form loses no meaning. The rail '
      'scrolls when the window is short, an optional `header` tops the '
      'extended form (a workspace switcher, say) and a `trailing` slot pins '
      'content beneath the items in both forms.',
    ),
  ],
  dos: const [
    'Keep destinations to a handful of top-level places; deep trees belong in the content.',
    'Give every item a distinct glyph from the `DsIcons` vocabulary.',
    'Pass the current route so the selected treatment always matches the screen.',
    'Let the shell drive `extended` from width rather than toggling it by hand.',
  ],
  donts: const [
    'Don\'t mix actions into the rail; it navigates, it does not submit or delete.',
    'Don\'t hide the selected state; the tinted fill is how users stay oriented.',
    'Don\'t hardcode the rail\'s colours; every treatment reads from the theme tokens.',
  ],
  code: '''
DsNavRail(
  items: const [
    DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
    DsNavItem(label: 'Wallet', icon: DsIcons.wallet, route: 'wallet'),
  ],
  selectedRoute: 'home',
  extended: false,
  onNavigate: (route) => goTo(route),
);
''',
  related: const ['app-shell', 'menu-sheet', 'breakpoints'],
);
