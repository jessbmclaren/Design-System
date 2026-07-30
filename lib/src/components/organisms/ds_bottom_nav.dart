import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../util/ds_motion.dart';
import 'ds_nav_rail.dart' show DsNavItem;

/// A bottom navigation bar: the phone's top-level destinations, side by side.
///
/// [DsBottomNav] is the touch counterpart to [DsNavRail]. A rail runs down the
/// side of a desktop window where there is width to spare; a bar sits along the
/// bottom edge of a phone, where the thumb already rests. Both take the same
/// [DsNavItem] vocabulary and both are controlled, so a product can swap one
/// for the other on a window-class change without restating its navigation.
///
/// The selected destination carries a brand-tinted pill behind its glyph and
/// the brand ink on both glyph and label, so the current place reads without
/// relying on colour alone. Labels stay visible rather than appearing on
/// selection, because a label that comes and goes moves the row it sits in.
///
/// Nested [DsNavItem.children] and [DsNavItem.section] headings are ignored:
/// a bottom bar is a flat set of top-level places, and anything deeper belongs
/// on the destination itself.
///
/// ```dart
/// DsBottomNav(
///   items: const [
///     DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
///     DsNavItem(label: 'Fuel', icon: DsIcons.fuel, route: 'fuel'),
///     DsNavItem(label: 'History', icon: DsIcons.history, route: 'history'),
///     DsNavItem(label: 'Account', icon: DsIcons.account, route: 'account'),
///   ],
///   selectedRoute: 'home',
///   onNavigate: (String route) => setState(() => _route = route),
/// )
/// ```
class DsBottomNav extends StatefulWidget {
  /// Creates a bottom navigation bar.
  const DsBottomNav({
    super.key,
    required this.items,
    required this.selectedRoute,
    required this.onNavigate,
  });

  /// The top-level destinations, in the order they are shown.
  ///
  /// Three to five reads comfortably on a phone; beyond that the labels crush
  /// and the last destinations belong behind one of the others.
  final List<DsNavItem> items;

  /// The route currently shown, matched against [DsNavItem.route].
  final String selectedRoute;

  /// Called with the chosen destination's route. A null callback disables the
  /// whole bar and drops it from the focus order.
  final ValueChanged<String>? onNavigate;

  @override
  State<DsBottomNav> createState() => _DsBottomNavState();
}

class _DsBottomNavState extends State<DsBottomNav> {
  /// The route whose destination currently holds keyboard focus, if any.
  String? _focusedRoute;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        // A hairline rather than a shadow: the bar is anchored to the edge, so
        // it reads as part of the frame, not as a card floating over content.
        border: Border(
          top: BorderSide(
            color: tokens.colorBorderSubtle,
            width: tokens.boxBorderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: Row(
            children: <Widget>[
              for (final DsNavItem item in widget.items)
                Expanded(child: _destination(context, tokens, unit, item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _destination(
    BuildContext context,
    DsTokens tokens,
    double unit,
    DsNavItem item,
  ) {
    final bool enabled = widget.onNavigate != null;
    final bool selected = item.route == widget.selectedRoute;
    final bool focused = _focusedRoute == item.route;

    final Color ink = !enabled
        ? tokens.colorTextDisabled
        : selected
            ? tokens.actionPrimaryColorText
            : tokens.colorSecondaryText;

    final Widget pill = AnimatedContainer(
      duration: DsMotion.durationOf(context, DsMotion.fast),
      curve: DsMotion.curveOf(context, DsMotion.standard),
      padding: EdgeInsets.symmetric(horizontal: unit * 2, vertical: unit / 2),
      decoration: BoxDecoration(
        color: selected && enabled ? tokens.brandTintColor : Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.radiusFull),
        // Focus draws a ring on the pill. A transparent ring holds the same
        // space when unfocused, so gaining focus never shifts the row.
        border: Border.all(
          color: focused ? tokens.focusRingColor : Colors.transparent,
          width: tokens.focusRingWidth,
        ),
      ),
      child: Icon(item.icon, size: tokens.iconSizeMd, color: ink),
    );

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        pill,
        SizedBox(height: unit / 4),
        Text(
          item.label,
          style: tokens.labelSm.toTextStyle(color: ink),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: item.label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: enabled ? () => widget.onNavigate!(item.route) : null,
          onFocusChange: (bool value) =>
              setState(() => _focusedRoute = value ? item.route : null),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: tokens.surfaceHoverColor,
          focusColor: Colors.transparent,
          child: ConstrainedBox(
            // The whole column is the target, held to the accessible minimum
            // even where a short label leaves the content smaller.
            constraints: BoxConstraints(minHeight: tokens.minTapTarget),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: unit / 2),
              child: ExcludeSemantics(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
