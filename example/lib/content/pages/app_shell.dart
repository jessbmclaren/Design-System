// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Layout → App shell.
final PatternPage appShellPage = PatternPage(
  id: 'app-shell',
  group: DocGroup.layout,
  navTitle: 'App shell',
  title: 'App shell',
  description:
      'The app shell is the frame every routed screen sits in: a light top '
      'bar over a side navigation and the page content. `DsAppShell` '
      'arranges the chrome an app shares across screens without owning any '
      'of the content. The top bar carries the brand, an optional search '
      'slot and the trailing widgets (an account switcher, notifications, '
      'an avatar); a hairline separates it from the content. Selection is '
      'controlled: pass the current route and apply `onNavigate` yourself.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'The navigation adapts to the shell\'s own width. At or above the '
      'large breakpoint (1200dp by default) an extended, labelled sidebar '
      'stays permanently open; between the medium breakpoint and that '
      'threshold it collapses to an icon-only rail with tooltips; below the '
      'medium breakpoint the side navigation is dropped and a menu trigger '
      'in the top bar opens the destinations as a menu sheet in the thumb '
      'zone. Both thresholds are constructor parameters when a product '
      'needs different ones.',
    ),
    ProseBlock(
      'The shell never scrolls or pads the body: page composition (headers, '
      'banners, filters) belongs to the page, so the same shell frames a '
      'dashboard, a data table and a settings form. An optional status bar '
      'closes the frame along the bottom edge.',
    ),
  ],
  dos: const [
    'Give every screen the same shell instance shape so chrome never jumps between routes.',
    'Put the brand switcher or account menu in the `trailing` slot.',
    'Cap and pad the page content inside the body; the shell stays out of layout.',
    'Pass a `DsSearchField` to the `search` slot for a global lookup.',
  ],
  donts: const [
    'Don\'t scroll the shell; scrolling belongs to the page body.',
    'Don\'t bake a brand colour into the bar; the chrome reads from the theme tokens.',
    'Don\'t duplicate the navigation in the page when the rail already carries it.',
  ],
  code: '''
DsAppShell(
  navItems: const [
    DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
    DsNavItem(label: 'Statements', icon: DsIcons.fileText, route: 'statements'),
  ],
  selectedRoute: 'home',
  onNavigate: (route) => goTo(route),
  brand: const DsWordmark(primary: 'acme'),
  trailing: [accountMenu],
  statusBar: const DsStatusBar(label: 'Developers', icon: DsIcons.terminal),
  body: const HomeScreen(),
);
''',
  related: const ['nav-rail', 'menu-sheet', 'status-bar', 'auth-shell', 'breakpoints'],
);
