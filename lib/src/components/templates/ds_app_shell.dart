import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_icon_button.dart';
import '../molecules/ds_menu_sheet.dart';
import '../organisms/ds_nav_rail.dart';

/// The application frame every routed screen sits in: a light top bar over a
/// side navigation and the page content.
///
/// [DsAppShell] arranges the chrome an app shares across its screens without
/// owning any of the content. The top bar carries the [brand] on its leading
/// edge, an optional [search] slot beside it and the [trailing] widgets (an
/// account switcher, notifications, an avatar) on the other; a hairline
/// separates it from the content below. The navigation adapts to the shell's
/// own width:
///
/// * at or above [sidebarBreakpoint] (1200dp by default) an extended,
///   labelled sidebar stays permanently open;
/// * between [railBreakpoint] and the sidebar threshold the navigation
///   collapses to an icon-only rail with tooltips;
/// * below [railBreakpoint] (600dp by default) the side navigation is dropped
///   and a menu trigger in the top bar opens the destinations as a
///   [DsMenuSheet] in the thumb zone.
///
/// Selection is controlled: pass the current [selectedRoute] and apply
/// [onNavigate] yourself. The shell never scrolls or pads [body]; page
/// composition (headers, banners, filters) belongs to the page. An optional
/// [statusBar] closes the frame along the bottom edge.
///
/// ```dart
/// DsAppShell(
///   navItems: const [
///     DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
///     DsNavItem(label: 'Statements', icon: DsIcons.fileText, route: 'statements'),
///   ],
///   selectedRoute: 'home',
///   onNavigate: (route) => _go(route),
///   brand: const DsWordmark(primary: 'acme'),
///   trailing: [themeToggle],
///   body: const HomeScreen(),
/// )
/// ```
class DsAppShell extends StatelessWidget {
  /// Creates the app chrome frame.
  const DsAppShell({
    super.key,
    required this.navItems,
    required this.selectedRoute,
    required this.onNavigate,
    this.brand,
    this.search,
    this.trailing = const <Widget>[],
    this.navHeader,
    this.navTrailing,
    this.notice,
    this.statusBar,
    this.railBreakpoint = DsBreakpoints.medium,
    this.sidebarBreakpoint = DsBreakpoints.large,
    this.menuSemanticLabel = 'Open navigation',
    required this.body,
  });

  /// The navigation destinations, in display order.
  final List<DsNavItem> navItems;

  /// The route of the current destination, matched against
  /// [DsNavItem.route].
  final String selectedRoute;

  /// Called with the chosen destination's route. A null callback disables
  /// the navigation.
  final ValueChanged<String>? onNavigate;

  /// The top bar's leading content, typically a `DsWordmark`. Null leaves the
  /// leading edge empty.
  final Widget? brand;

  /// An optional search slot rendered beside the brand, typically a
  /// `DsSearchField`. It flexes with the bar and is capped at a readable
  /// width.
  final Widget? search;

  /// Widgets pinned to the top bar's trailing edge, in display order.
  final List<Widget> trailing;

  /// Content pinned above the sidebar items while the sidebar is extended,
  /// such as a workspace switcher.
  final Widget? navHeader;

  /// Content pinned beneath the navigation items in the rail and sidebar.
  final Widget? navTrailing;

  /// An optional full-bleed strip above the top bar, for a state that
  /// applies to the whole session rather than the page: a test environment,
  /// an impersonation notice, a service interruption. It spans the shell,
  /// above both the bar and the navigation, because it qualifies everything
  /// beneath it.
  final Widget? notice;

  /// An optional strip closing the frame along the bottom edge, typically a
  /// `DsStatusBar`.
  final Widget? statusBar;

  /// The shell width, in logical pixels, below which the side navigation is
  /// replaced by the top bar's menu trigger and a [DsMenuSheet].
  final double railBreakpoint;

  /// The shell width, in logical pixels, at which the icon rail becomes a
  /// permanently extended sidebar.
  final double sidebarBreakpoint;

  /// The name assistive technology announces for the menu trigger shown
  /// below [railBreakpoint].
  final String menuSemanticLabel;

  /// The page content. The shell neither scrolls nor pads it.
  final Widget body;

  /// The top bar height, in logical pixels.
  static const double topBarHeight = 60;

  /// The widest the [search] slot grows inside the top bar.
  static const double searchMaxWidth = 440;

  /// The narrowest slot the [search] widget is given. When the bar cannot
  /// spare this much beside the brand and trailing widgets the slot hides,
  /// so a squeezed field never breaks the bar; surface search in the page
  /// on such widths instead.
  static const double searchMinWidth = 160;

  void _openMenuSheet(BuildContext context) {
    DsMenuSheet.show(
      context,
      items: <DsMenuSheetItem>[
        for (final DsNavItem item in navItems)
          DsMenuSheetItem(
            label: item.label,
            icon: item.icon,
            selected: item.route == selectedRoute,
            onSelected:
                onNavigate == null ? null : () => onNavigate!(item.route),
            enabled: onNavigate != null,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final bool showSheet = width < railBreakpoint;
        final bool showSidebar = width >= sidebarBreakpoint;

        final Widget topBar = _DsAppShellTopBar(
          tokens: tokens,
          brand: brand,
          search: search,
          trailing: trailing,
          menuTrigger: showSheet
              ? DsIconButton(
                  icon: DsIcons.menu,
                  iconSize: DsIconSize.md,
                  semanticLabel: menuSemanticLabel,
                  onPressed: () => _openMenuSheet(context),
                )
              : null,
        );

        // The shell is a page-level frame, so like [Scaffold] it provides the
        // Material its descendants (fields, ink, menus) require, rather than
        // assuming the caller wrapped it in one.
        return Material(
          color: tokens.colorBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ?notice,
              topBar,
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (!showSheet)
                      DsNavRail(
                        items: navItems,
                        selectedRoute: selectedRoute,
                        onNavigate: onNavigate,
                        extended: showSidebar,
                        header: navHeader,
                        trailing: navTrailing,
                      ),
                    Expanded(child: body),
                  ],
                ),
              ),
              ?statusBar,
            ],
          ),
        );
      },
    );
  }
}

/// The shell's top bar: menu trigger, brand, search slot and trailing run.
class _DsAppShellTopBar extends StatelessWidget {
  const _DsAppShellTopBar({
    required this.tokens,
    required this.brand,
    required this.search,
    required this.trailing,
    required this.menuTrigger,
  });

  final DsTokens tokens;
  final Widget? brand;
  final Widget? search;
  final List<Widget> trailing;
  final Widget? menuTrigger;

  @override
  Widget build(BuildContext context) {
    final double unit = tokens.spacingUnit;

    return Container(
      // The design height is a minimum: the bar grows with the user's text
      // scale (a scaled search field needs the room) instead of clipping.
      constraints: const BoxConstraints(minHeight: DsAppShell.topBarHeight),
      padding: EdgeInsets.symmetric(horizontal: unit * 2),
      decoration: BoxDecoration(
        color: tokens.colorBackground,
        border: Border(
          bottom: BorderSide(color: tokens.colorBorderSubtle),
        ),
      ),
      // The slots inherit the chrome foreground, so arbitrary trailing
      // widgets stay legible on the bar in any theme.
      child: IconTheme.merge(
        data: IconThemeData(color: tokens.colorSecondaryText),
        child: DefaultTextStyle.merge(
          style: tokens.bodyMd.toTextStyle(color: tokens.colorText),
          child: Row(
            children: <Widget>[
              if (menuTrigger != null) ...<Widget>[
                menuTrigger!,
                SizedBox(width: unit),
              ],
              ?brand,
              if (search != null)
                Flexible(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints slot) {
                      // Hide the slot rather than hand the field a sliver it
                      // cannot lay out in; see [DsAppShell.searchMinWidth].
                      if (slot.maxWidth <
                          DsAppShell.searchMinWidth + unit * 3) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsetsDirectional.only(start: unit * 3),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: DsAppShell.searchMaxWidth,
                            ),
                            child: search!,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                const Spacer(),
              for (final Widget widget in trailing) ...<Widget>[
                SizedBox(width: unit),
                widget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
