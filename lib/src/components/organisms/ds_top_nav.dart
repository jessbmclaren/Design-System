import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_icon_button.dart';
import '../atoms/ds_nav_link.dart';
import '../molecules/ds_dialog.dart';
import '../molecules/ds_floating_bar.dart';

/// One destination in a [DsTopNav].
@immutable
class DsTopNavLink {
  /// Creates a top-nav destination.
  const DsTopNavLink({
    required this.label,
    this.dropdown = false,
    this.onTap,
  });

  /// The destination's name.
  final String label;

  /// Whether choosing it opens a menu rather than navigating.
  final bool dropdown;

  /// Called when the destination is chosen.
  final VoidCallback? onTap;
}

/// The bar across the top of a marketing or public site.
///
/// [DsTopNav] lays a [brand] on the leading edge, the [links] beside it and
/// the [secondaryActions] and [primaryAction] on the trailing edge. Where the
/// app shell frames a signed-in product, this frames the pages around it: a
/// landing page, pricing, documentation.
///
/// As the width tightens the bar discloses progressively rather than
/// dropping anything: the links move into a menu sheet behind a trailing
/// menu button, then the secondary actions follow them, and the primary
/// action is the last to go. The brand is the only element allowed to shrink,
/// so the row holds together down to the smallest phone.
///
/// ```dart
/// DsTopNav(
///   brand: const DsWordmark(),
///   links: [
///     DsTopNavLink(label: 'Product', dropdown: true, onTap: openProduct),
///     DsTopNavLink(label: 'Pricing', onTap: () => go('/pricing')),
///   ],
///   secondaryActions: [DsButton(label: 'Log in', variant: DsButtonVariant.tertiary, onPressed: logIn)],
///   primaryAction: DsButton(label: 'Get started', onPressed: signUp),
///   floating: scrolled,
/// )
/// ```
class DsTopNav extends StatelessWidget {
  /// Creates a site top bar.
  const DsTopNav({
    super.key,
    required this.brand,
    this.links = const <DsTopNavLink>[],
    this.secondaryActions = const <Widget>[],
    this.primaryAction,
    this.floating = false,
    this.menuSemanticLabel = 'Open menu',
  });

  /// The mark on the leading edge, typically a `DsWordmark`.
  final Widget brand;

  /// The destinations, in display order.
  final List<DsTopNavLink> links;

  /// Quiet actions beside the primary one, such as a sign-in link.
  final List<Widget> secondaryActions;

  /// The bar's leading action, kept visible longest as the width tightens.
  final Widget? primaryAction;

  /// Whether content has scrolled beneath the bar, which lifts it.
  final bool floating;

  /// The name assistive technology announces for the disclosure trigger.
  final String menuSemanticLabel;

  /// The bar height, in logical pixels.
  static const double height = 72;

  /// The width the links need before they fold into the menu.
  static const double _linksBreakpoint = 900;

  /// The width the trailing actions need before they follow.
  static const double _actionsBreakpoint = 600;

  /// Presents whatever has folded away: the links always, and the actions
  /// too when they have left the bar. Nothing is ever dropped, only moved.
  void _openMenu(BuildContext context, {required bool includeActions}) {
    DsModalSheet.show<void>(
      context,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final DsTopNavLink link in links)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DsNavLink(
                label: link.label,
                dropdown: link.dropdown,
                onTap: link.onTap == null
                    ? null
                    : () {
                        // Close first, then act, so a navigation never races
                        // the closing sheet.
                        Navigator.of(context).pop();
                        link.onTap!();
                      },
              ),
            ),
          if (includeActions) ...<Widget>[
            for (final Widget action in secondaryActions)
              Padding(
                padding: EdgeInsets.only(top: DsTokens.of(context).spacingUnit),
                child: action,
              ),
            if (primaryAction != null)
              Padding(
                padding:
                    EdgeInsets.only(top: DsTokens.of(context).spacingUnit),
                child: primaryAction,
              ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;

    return DsFloatingBar(
      floating: floating,
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final bool showLinks =
                links.isNotEmpty && width >= _linksBreakpoint;
            final bool showActions = width >= _actionsBreakpoint;
            // Anything not shown inline is reachable from the menu, so the
            // trigger appears whenever something has folded away.
            final bool showMenu =
                (links.isNotEmpty && !showLinks) || (!showActions);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: unit * 2),
              child: Row(
                children: <Widget>[
                  // The brand is the one element allowed to scale down, so a
                  // long wordmark can never break the row.
                  Flexible(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: brand,
                      ),
                    ),
                  ),
                  if (showLinks) ...<Widget>[
                    SizedBox(width: unit * 3),
                    for (final DsTopNavLink link in links)
                      DsNavLink(
                        label: link.label,
                        dropdown: link.dropdown,
                        onTap: link.onTap,
                      ),
                  ],
                  const Spacer(),
                  if (showActions) ...<Widget>[
                    for (final Widget action in secondaryActions) ...<Widget>[
                      action,
                      SizedBox(width: unit),
                    ],
                    ?primaryAction,
                  ],
                  if (showMenu) ...<Widget>[
                    SizedBox(width: unit),
                    Builder(
                      builder: (BuildContext context) => DsIconButton(
                        icon: DsIcons.menu,
                        iconSize: DsIconSize.md,
                        semanticLabel: menuSemanticLabel,
                        onPressed: () =>
                            _openMenu(context, includeActions: !showActions),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
