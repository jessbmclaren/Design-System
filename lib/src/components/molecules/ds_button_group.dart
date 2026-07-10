import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../atoms/ds_button.dart';

/// Lays out a set of related actions in a single row and collapses the ones
/// that do not fit into an overflow menu.
///
/// A [DsButtonGroup] is the toolbar primitive of the Design System: pass a list
/// of actions (typically [DsButton]s) as [children] and the group keeps them
/// on one line so they never overflow. When the available width (or [maxVisible])
/// cannot accommodate every action, the leading ones stay inline and the rest
/// move into a "More" menu opened from a trailing icon button.
///
/// The number of inline actions is resolved responsively from the constraints
/// handed down by the parent, so the same group shows one or two actions plus a
/// menu on a 320dp phone and every action inline on a wide desktop, without any
/// configuration.
///
/// ```dart
/// DsButtonGroup(
///   children: [
///     DsButton(label: 'Save', onPressed: _save),
///     DsButton(
///       label: 'Duplicate',
///       variant: DsButtonVariant.secondary,
///       onPressed: _duplicate,
///     ),
///     DsButton(
///       label: 'Delete',
///       variant: DsButtonVariant.danger,
///       onPressed: _delete,
///     ),
///   ],
/// )
/// ```
///
/// When a child is a [DsButton], its label, icon and callback are reused for the
/// matching overflow menu entry so the action behaves identically whether it is
/// shown inline or in the menu. Other widget types still overflow gracefully but
/// appear under a generic label.
class DsButtonGroup extends StatelessWidget {
  /// Creates a button group.
  const DsButtonGroup({
    super.key,
    required this.children,
    this.spacing = 8,
    this.maxVisible,
  }) : assert(spacing >= 0, 'spacing must not be negative'),
       assert(
         maxVisible == null || maxVisible > 0,
         'maxVisible must be greater than zero',
       );

  /// The actions to lay out, in priority order. Leading children stay inline
  /// the longest; trailing children are the first to move into the overflow
  /// menu. These are typically [DsButton]s.
  final List<Widget> children;

  /// The horizontal gap between adjacent actions, in logical pixels.
  final double spacing;

  /// An optional hard cap on the number of inline actions. Any actions beyond
  /// this count always collapse into the overflow menu, even when there is room
  /// for more. When null, only the available width limits how many show inline.
  final int? maxVisible;

  /// The conservative minimum width reserved for an inline action when deciding
  /// how many fit. Inline actions are laid out flexibly, so a slight
  /// over-estimate only hides an action rather than ever overflowing.
  static const double _minItemWidth = 96;

  /// The width reserved for the trailing "More" button (a 48dp touch target).
  static const double _moreButtonWidth = 48;

  /// How many actions of [_minItemWidth] fit in [width] with [spacing] gaps.
  int _fitCount(double width) {
    if (width <= 0) return 0;
    return ((width + spacing) / (_minItemWidth + spacing)).floor();
  }

  @override
  Widget build(BuildContext context) {
    final total = children.length;
    if (total == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final cap = maxVisible == null
            ? total
            : maxVisible!.clamp(1, total);
        final fitsAll = _fitCount(available);

        int visible;
        if (cap >= total && fitsAll >= total) {
          // Everything is allowed and everything fits, so show it all inline.
          visible = total;
        } else {
          // At least one action must collapse; reserve room for the More button.
          final fitWithMore = _fitCount(available - _moreButtonWidth - spacing);
          visible = math.min(cap, fitWithMore);
          if (visible < 1) visible = 1;
          if (visible >= total) visible = total - 1;
        }

        final hasOverflow = visible < total;
        final tokens = DsTokens.of(context);

        final row = <Widget>[];
        for (var i = 0; i < visible; i++) {
          if (i > 0) row.add(SizedBox(width: spacing));
          // Flexible/loose keeps a long action from ever overflowing the row:
          // it is constrained to its share and a [DsButton] then ellipsizes.
          row.add(Flexible(child: children[i]));
        }
        if (hasOverflow) {
          if (row.isNotEmpty) row.add(SizedBox(width: spacing));
          row.add(
            _DsOverflowMenu(
              items: children.sublist(visible),
              tokens: tokens,
            ),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: row,
        );
      },
    );
  }
}

/// The trailing "More" affordance and its menu of collapsed actions.
class _DsOverflowMenu extends StatelessWidget {
  const _DsOverflowMenu({required this.items, required this.tokens});

  /// The actions that did not fit inline.
  final List<Widget> items;

  final DsTokens tokens;

  /// The label used for an overflow entry that is not a [DsButton].
  String _labelFor(Widget item, int index) {
    if (item is DsButton) return item.label;
    return 'Action ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final menuChildren = <Widget>[
      for (var i = 0; i < items.length; i++)
        _buildMenuItem(items[i], i),
    ];

    return MenuAnchor(
      menuChildren: menuChildren,
      builder: (context, controller, child) {
        return Tooltip(
          message: 'More actions',
          child: Semantics(
            button: true,
            label: 'More actions',
            expanded: controller.isOpen,
            child: InkResponse(
              radius: DsButtonGroup._moreButtonWidth / 2,
              onTap: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              child: SizedBox(
                width: DsButtonGroup._moreButtonWidth,
                height: DsButtonGroup._moreButtonWidth,
                child: Center(
                  child: Icon(
                    DsIcons.moreHorizontal,
                    size: DsIconSize.lg,
                    color: tokens.colorText,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(Widget item, int index) {
    final label = _labelFor(item, index);
    IconData? icon;
    VoidCallback? onPressed;
    var enabled = true;

    if (item is DsButton) {
      icon = item.icon;
      onPressed = item.onPressed;
      enabled = item.onPressed != null;
    }

    return MenuItemButton(
      onPressed: enabled ? onPressed : null,
      leadingIcon: icon == null
          ? null
          : Icon(
              icon,
              size: DsIconSize.sm,
              color: enabled
                  ? tokens.colorText
                  : tokens.colorSecondaryText,
            ),
      child: Text(
        label,
        style: tokens.bodyMd.toTextStyle(
          color: enabled ? tokens.colorText : tokens.colorSecondaryText,
        ),
      ),
    );
  }
}
