import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../../util/ds_motion.dart';
import '../atoms/ds_icon.dart';

/// A single destination in a [DsNavRail] (and in `DsAppShell`'s navigation).
///
/// An item binds the visible [label] and [icon] to the stable [route] the
/// shell reports through its `onNavigate` callback when the item is chosen.
@immutable
class DsNavItem {
  /// Creates a navigation destination.
  const DsNavItem({
    required this.label,
    required this.icon,
    required this.route,
    this.section,
    this.children = const <DsNavItem>[],
  });

  /// The destination's name, shown as the row label when the rail is
  /// [DsNavRail.extended] and as the tooltip when it is icon-only.
  final String label;

  /// The destination's glyph, from the `DsIcons` vocabulary.
  final IconData icon;

  /// The stable identifier reported when the item is chosen and matched
  /// against the current selection.
  final String route;

  /// The heading this item sits under in the extended sidebar. Consecutive
  /// items sharing a section are grouped beneath one quiet heading; a null
  /// section leaves the item in the unheaded run at the top. Headings are
  /// dropped in the icon-only rail, which has no room for them.
  final String? section;

  /// The destinations nested under this one. A parent with children becomes
  /// a disclosure in the extended sidebar: choosing it expands the group
  /// rather than navigating, and the children indent beneath it. Ignored in
  /// the icon-only rail, where nesting has nowhere to go.
  final List<DsNavItem> children;
}

/// A vertical navigation rail: icon-only by default, a labelled sidebar when
/// [extended].
///
/// [DsNavRail] is the side navigation for app chrome. In its compact form it
/// is a narrow column of icon tiles, each with a tooltip; extended, it widens
/// into a sidebar of labelled rows. Both forms share the same treatments: the
/// selected item sits on the theme's brand-tinted fill with the brand ink,
/// hovering shows a soft fill, and keyboard focus draws a distinct accent
/// ring. Selection is controlled: the caller passes [selectedRoute] and
/// applies [onNavigate] itself.
///
/// The rail scrolls when the window is short, so every destination stays
/// reachable, and an optional [header] (extended only) and [trailing] slot
/// bookend the items.
///
/// ```dart
/// DsNavRail(
///   items: const [
///     DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
///     DsNavItem(label: 'Wallet', icon: DsIcons.wallet, route: 'wallet'),
///   ],
///   selectedRoute: 'home',
///   onNavigate: (route) => _go(route),
/// )
/// ```
class DsNavRail extends StatefulWidget {
  /// Creates a navigation rail.
  const DsNavRail({
    super.key,
    required this.items,
    required this.selectedRoute,
    required this.onNavigate,
    this.extended = false,
    this.header,
    this.trailing,
    this.width,
    this.semanticLabel = 'Navigation',
  });

  /// The destinations, in display order.
  final List<DsNavItem> items;

  /// The route of the currently selected destination. An unmatched value
  /// leaves every item unselected.
  final String selectedRoute;

  /// Called with the chosen item's route. A null callback disables every
  /// item and drops the rail from the focus order.
  final ValueChanged<String>? onNavigate;

  /// Whether the rail renders as a labelled sidebar instead of icon tiles.
  final bool extended;

  /// Content pinned above the items when [extended], such as a workspace
  /// switcher. Ignored in the icon-only form.
  final Widget? header;

  /// Content pinned beneath the items, after any scrolling space.
  final Widget? trailing;

  /// Overrides the rail width. Defaults to 7 spacing units icon-only and to
  /// [extendedWidth] when [extended].
  final double? width;

  /// The name assistive technology announces for the navigation region.
  final String semanticLabel;

  /// The default width of the extended sidebar, in logical pixels.
  static const double extendedWidth = 236;

  @override
  State<DsNavRail> createState() => _DsNavRailState();
}

class _DsNavRailState extends State<DsNavRail> {
  /// Which groups the user has opened or closed, keyed by the parent's route.
  /// A group absent from the map follows whether it holds the selection.
  final Map<String, bool> _openGroups = <String, bool>{};

  bool _isOpen(DsNavItem parent) =>
      _openGroups[parent.route] ??
      parent.children.any((DsNavItem c) => c.route == widget.selectedRoute);

  /// Flattens the items into the rows to render: section headings, parents
  /// and, for an open group, its indented children. The icon-only rail has
  /// no room for headings or nesting, so it renders parents alone.
  List<Widget> _rows(DsTokens tokens) {
    final double unit = tokens.spacingUnit;
    final bool extended = widget.extended;
    final List<Widget> rows = <Widget>[];
    String? currentSection;

    Widget pad(Widget child, {double indent = 0}) => Padding(
          padding: EdgeInsets.only(
            left: indent,
            bottom: extended ? unit / 4 : unit,
          ),
          child: child,
        );

    for (final DsNavItem item in widget.items) {
      if (extended && item.section != null && item.section != currentSection) {
        currentSection = item.section;
        rows.add(
          Padding(
            padding: EdgeInsets.fromLTRB(unit * 1.25, unit * 1.5, 0, unit / 2),
            child: Semantics(
              header: true,
              child: Text(
                item.section!,
                style: tokens.labelSm
                    .toTextStyle(color: tokens.colorSecondaryText),
              ),
            ),
          ),
        );
      } else if (item.section == null) {
        currentSection = null;
      }

      final bool isGroup = extended && item.children.isNotEmpty;
      final bool open = isGroup && _isOpen(item);

      rows.add(
        pad(
          _DsNavRailItem(
            tokens: tokens,
            item: item,
            selected: item.route == widget.selectedRoute,
            extended: extended,
            expanded: isGroup ? open : null,
            onTap: widget.onNavigate == null
                ? null
                : isGroup
                    // A parent is a disclosure, not a destination.
                    ? () => setState(() => _openGroups[item.route] = !open)
                    : () => widget.onNavigate!(item.route),
          ),
        ),
      );

      if (open) {
        for (final DsNavItem child in item.children) {
          rows.add(
            pad(
              _DsNavRailItem(
                tokens: tokens,
                item: child,
                selected: child.route == widget.selectedRoute,
                extended: extended,
                onTap: widget.onNavigate == null
                    ? null
                    : () => widget.onNavigate!(child.route),
              ),
              indent: unit * 2.5,
            ),
          );
        }
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;
    final bool extended = widget.extended;
    final Widget? header = widget.header;
    final Widget? trailing = widget.trailing;
    final double railWidth =
        widget.width ?? (extended ? DsNavRail.extendedWidth : unit * 7);

    final Widget list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _rows(tokens),
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: Container(
        width: railWidth,
        decoration: BoxDecoration(
          color:
              extended ? tokens.formBackgroundColor : tokens.colorBackground,
          border: Border(
            right: BorderSide(color: tokens.colorBorderSubtle),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (extended && header != null) header,
            Expanded(
              child: SingleChildScrollView(
                padding: extended
                    ? EdgeInsets.symmetric(
                        horizontal: unit * 1.5, vertical: unit)
                    : EdgeInsets.symmetric(vertical: unit * 2),
                child: list,
              ),
            ),
            if (trailing != null)
              Padding(
                padding: EdgeInsets.all(extended ? unit * 1.5 : unit),
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }
}

/// One destination: an icon tile when compact, a labelled row when extended.
class _DsNavRailItem extends StatefulWidget {
  const _DsNavRailItem({
    required this.tokens,
    required this.item,
    required this.selected,
    required this.extended,
    required this.onTap,
    this.expanded,
  });

  final DsTokens tokens;
  final DsNavItem item;
  final bool selected;
  final bool extended;
  final VoidCallback? onTap;

  /// Whether this row is an open group, a closed group, or not a group at
  /// all (null), which decides the trailing chevron and the announced state.
  final bool? expanded;

  @override
  State<_DsNavRailItem> createState() => _DsNavRailItemState();
}

class _DsNavRailItemState extends State<_DsNavRailItem> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = widget.tokens;
    final double unit = tokens.spacingUnit;
    final bool enabled = widget.onTap != null;

    final Color fill = widget.selected
        ? tokens.brandTintColor
        : _hovered && enabled
            ? tokens.colorText.withValues(alpha: tokens.stateHoverOpacity)
            : Colors.transparent;
    // Idle glyphs use the secondary text colour in both forms: it clears the
    // 3:1 graphic bar in every theme, which the placeholder grey does not.
    final Color iconColor = widget.selected
        ? tokens.actionPrimaryColorText
        : tokens.colorSecondaryText;
    final Color labelColor =
        widget.selected ? tokens.actionPrimaryColorText : tokens.colorText;

    // The focus ring is a border so it never shifts layout: an invisible
    // border of the same width is reserved while unfocused.
    final Border border = Border.fromBorderSide(
      BorderSide(
        color: _focused ? tokens.formAccentColor : Colors.transparent,
        width: tokens.focusRingWidth,
      ),
    );
    final double radius =
        widget.extended ? tokens.badgeBorderRadius : tokens.borderRadius;

    final Widget content;
    if (widget.extended) {
      content = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: unit * 1.25,
          vertical: unit,
        ),
        child: Row(
          children: <Widget>[
            DsIcon(
              icon: widget.item.icon,
              size: tokens.iconSizeMd,
              color: iconColor,
            ),
            SizedBox(width: unit * 1.5),
            Expanded(
              child: Text(
                widget.item.label,
                style: (widget.selected ? tokens.labelMd : tokens.bodySm)
                    .toTextStyle(color: labelColor)
                    .copyWith(fontSize: tokens.bodySm.fontSize),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // A group parent carries the disclosure chevron its state.
            if (widget.expanded != null)
              DsIcon(
                icon: widget.expanded!
                    ? DsIcons.expandLess
                    : DsIcons.expandMore,
                size: tokens.iconSizeSm,
                color: tokens.colorSecondaryText,
              ),
          ],
        ),
      );
    } else {
      content = Center(
        child: DsIcon(
          icon: widget.item.icon,
          size: tokens.iconSizeLg,
          color: iconColor,
        ),
      );
    }

    Widget tile = AnimatedContainer(
      duration: DsMotion.durationOf(context, DsMotion.fast),
      curve: DsMotion.curveOf(context, DsMotion.standard),
      constraints: BoxConstraints(
        minHeight: tokens.minTapTarget,
        minWidth: widget.extended ? 0 : tokens.minTapTarget,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: border,
      ),
      child: content,
    );

    if (!widget.extended) {
      tile = Center(
        child: SizedBox(
          width: tokens.minTapTarget,
          height: tokens.minTapTarget,
          child: tile,
        ),
      );
    }

    // The visual content is excluded and the row's name carried on the
    // wrapping semantics instead, so the merged node reads as one labelled
    // button with the InkWell's tap and focus actions.
    final Widget interactive = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        onHover: (bool value) => setState(() => _hovered = value),
        onFocusChange: (bool value) => setState(() => _focused = value),
        child: ExcludeSemantics(child: tile),
      ),
    );

    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: widget.expanded == null ? widget.selected : null,
        expanded: widget.expanded,
        label: widget.item.label,
        child: widget.extended
            ? interactive
            : Tooltip(message: widget.item.label, child: interactive),
      ),
    );
  }
}
