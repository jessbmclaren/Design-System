import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_typography.dart';
import '../atoms/ds_icon.dart';

/// A single selectable row within a [DsMenuSheet].
///
/// An item pairs a required [label] with an optional leading [icon] and an
/// [onSelected] callback that fires after the sheet closes. Mark the current
/// choice with [selected] so it renders on the brand-tinted fill, and mark an
/// irreversible action with [destructive] so it renders in the danger colour.
@immutable
class DsMenuSheetItem {
  /// Creates a sheet item.
  const DsMenuSheetItem({
    required this.label,
    this.icon,
    this.onSelected,
    this.selected = false,
    this.destructive = false,
    this.enabled = true,
  });

  /// The visible text for the row.
  final String label;

  /// An optional leading glyph rendered at [DsIconSize.md].
  final IconData? icon;

  /// Called after the sheet closes when the row is chosen.
  final VoidCallback? onSelected;

  /// Whether this row is the current choice. A selected row renders on
  /// [DsTokens.brandTintColor] with the brand ink and announces its state to
  /// assistive technology.
  final bool selected;

  /// Whether this item represents a destructive action, rendered in
  /// [DsTokens.colorDanger].
  final bool destructive;

  /// Whether the item can be chosen. A disabled item is dimmed and ignores
  /// taps.
  final bool enabled;
}

/// A menu presented as a modal bottom sheet, for narrow, touch-first widths.
///
/// [DsMenuSheet] is the thumb-zone counterpart to [DsMenu]: where the menu
/// anchors a popover beneath its trigger, the sheet slides the same choices up
/// from the bottom edge, where they are easiest to reach one-handed. Use it
/// when the window is compact, for example for the navigation menu behind
/// `DsAppShell`'s hamburger trigger.
///
/// Present it with [DsMenuSheet.show], which resolves the sheet's fill, corner
/// radius and barrier from [DsTokens] and returns once the sheet closes.
/// Choosing a row closes the sheet first and then runs the row's
/// [DsMenuSheetItem.onSelected], so a navigation that rebuilds the tree never
/// races the closing sheet.
///
/// ```dart
/// DsMenuSheet.show(
///   context,
///   items: [
///     for (final item in navItems)
///       DsMenuSheetItem(
///         label: item.label,
///         icon: item.icon,
///         selected: item.route == selectedRoute,
///         onSelected: () => onNavigate(item.route),
///       ),
///   ],
/// );
/// ```
///
/// Each row is at least 48dp tall, keyboard-focusable and announced as a
/// button with its selected state. A grab handle at the top signals the sheet
/// drags to dismiss; the barrier also dismisses on tap or Escape.
class DsMenuSheet extends StatelessWidget {
  /// Creates the sheet's content. Prefer presenting it with [show].
  const DsMenuSheet({super.key, required this.items});

  /// The rows shown in the sheet, in display order.
  final List<DsMenuSheetItem> items;

  /// Presents the sheet above [context]'s navigator and returns once it has
  /// closed. A chosen row's [DsMenuSheetItem.onSelected] runs after the sheet
  /// has popped.
  static Future<void> show(
    BuildContext context, {
    required List<DsMenuSheetItem> items,
  }) {
    final DsTokens tokens = DsTokens.of(context);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.formBackgroundColor,
      barrierColor: tokens.overlayBackdropColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.overlayBorderRadius),
        ),
      ),
      isScrollControlled: false,
      builder: (BuildContext context) => DsMenuSheet(items: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // The grab handle signalling drag-to-dismiss; decorative only.
          ExcludeSemantics(
            child: Center(
              child: Container(
                width: unit * 4,
                height: unit / 2,
                margin: EdgeInsets.only(top: unit, bottom: unit),
                decoration: BoxDecoration(
                  color: tokens.colorBorderSubtle,
                  borderRadius: BorderRadius.circular(unit / 4),
                ),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: unit),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final DsMenuSheetItem item in items)
                    _DsMenuSheetRow(tokens: tokens, item: item),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single sheet row: leading glyph, label and the selected treatment.
class _DsMenuSheetRow extends StatelessWidget {
  const _DsMenuSheetRow({required this.tokens, required this.item});

  final DsTokens tokens;
  final DsMenuSheetItem item;

  @override
  Widget build(BuildContext context) {
    final double unit = tokens.spacingUnit;
    final Color ink = item.destructive
        ? tokens.colorDanger
        : item.selected
            ? tokens.actionPrimaryColorText
            : tokens.colorText;
    final Color iconColor = item.destructive
        ? tokens.colorDanger
        : item.selected
            ? tokens.actionPrimaryColorText
            : tokens.formPlaceholderTextColor;
    final bool enabled = item.enabled;
    final double disabledOpacity = tokens.stateDisabledOpacity;

    final DsTypeToken type = item.selected ? tokens.labelMd : tokens.bodyMd;
    final TextStyle labelStyle = type
        .toTextStyle(color: enabled ? ink : ink.withValues(alpha: disabledOpacity))
        .copyWith(fontSize: tokens.bodyMd.fontSize);

    void choose() {
      Navigator.of(context).pop();
      item.onSelected?.call();
    }

    // The visual content is excluded and the row's name carried on the
    // wrapping semantics, so the merged node reads as one labelled button
    // with the InkWell's tap and focus actions.
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: item.selected,
        label: item.label,
        child: Material(
          color: item.selected ? tokens.brandTintColor : Colors.transparent,
          child: InkWell(
            onTap: enabled ? choose : null,
            child: ExcludeSemantics(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: tokens.minTapTarget),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: unit * 2.5),
                  child: Row(
                    children: <Widget>[
                      if (item.icon != null) ...<Widget>[
                        DsIcon(
                          icon: item.icon!,
                          size: DsIconSize.md,
                          color: enabled
                              ? iconColor
                              : iconColor.withValues(alpha: disabledOpacity),
                        ),
                        SizedBox(width: unit * 1.5),
                      ],
                      Expanded(
                        child: Text(
                          item.label,
                          style: labelStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
