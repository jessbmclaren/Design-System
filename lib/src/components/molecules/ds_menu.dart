import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../atoms/ds_icon.dart';

/// A single selectable row within a [DsMenu].
///
/// An item pairs a required [label] with an optional leading [icon] and an
/// [onSelected] callback that fires when the row is chosen. Mark irreversible
/// or dangerous choices (delete, revoke, …) with [destructive] so they render
/// in the theme's danger colour, and set [enabled] to `false` to show (but
/// dim and disable) a choice that is temporarily unavailable.
@immutable
class DsMenuItem {
  /// Creates a menu item.
  ///
  /// Only [label] is required. A null [onSelected] leaves the row tappable but
  /// inert; pass [enabled] `false` instead to visibly disable it.
  const DsMenuItem({
    required this.label,
    this.icon,
    this.onSelected,
    this.destructive = false,
    this.enabled = true,
  });

  /// The visible text for the row.
  final String label;

  /// An optional leading glyph rendered at [DsIconSize.sm].
  final IconData? icon;

  /// Called when the row is chosen. The menu closes automatically first.
  final VoidCallback? onSelected;

  /// Whether this item represents a destructive action.
  ///
  /// Destructive items render their label and icon in [DsTokens.colorDanger].
  final bool destructive;

  /// Whether the item can be chosen. A disabled item is dimmed and ignores
  /// taps.
  final bool enabled;
}

/// An action menu anchored beneath a trigger.
///
/// [DsMenu] wraps any [trigger] widget in a [MenuAnchor]. Tapping the trigger
/// opens a themed surface listing [items]; choosing a row runs its
/// [DsMenuItem.onSelected] and closes the menu. The surface reads its fill
/// ([DsTokens.formBackgroundColor]), corner radius
/// ([DsTokens.overlayBorderRadius]), 1px border ([DsTokens.colorBorder]) and
/// [DsTokens.shadowMedium] drop shadow from the active theme, so a white-label
/// skin restyles it without touching this widget.
///
/// ```dart
/// DsMenu(
///   trigger: const DsIcon(icon: DsIcons.moreHorizontal, semanticLabel: 'More'),
///   items: [
///     DsMenuItem(label: 'Edit', icon: DsIcons.edit, onSelected: _edit),
///     DsMenuItem(
///       label: 'Delete',
///       icon: DsIcons.delete,
///       destructive: true,
///       onSelected: _delete,
///     ),
///   ],
/// )
/// ```
///
/// ## Responsiveness
///
/// The menu sizes to its content between a 200dp minimum and a 320dp maximum,
/// so it never overflows a 320dp phone; longer labels ellipsize to a single
/// line. [MenuAnchor] keeps the surface within the screen and repositions it
/// near edges, so the same widget works from a small phone up to a large
/// desktop.
///
/// ## Accessibility
///
/// The trigger is exposed to assistive technology as a button that reports its
/// expanded state, and each row is a focusable, keyboard-navigable button at
/// least 48dp tall. Provide a label or tooltip on an icon-only [trigger] (for
/// example via [DsIcon.semanticLabel]) so its purpose is announced.
///
/// ## Screenshot safety
///
/// The menu is closed on first build and starts no timers or animations, so it
/// renders deterministically in a static demo.
class DsMenu extends StatelessWidget {
  /// Creates an action menu.
  const DsMenu({
    super.key,
    required this.trigger,
    required this.items,
  });

  /// The widget the user taps to open the menu.
  final Widget trigger;

  /// The rows shown when the menu is open, in display order.
  final List<DsMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    return MenuAnchor(
      // The custom surface below draws its own fill, border and shadow, so the
      // anchor's built-in Material panel is made transparent and un-clipped to
      // avoid double-painting or clipping the drop shadow.
      clipBehavior: Clip.none,
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll<Color>(
          Color(0x00000000),
        ),
        surfaceTintColor: const WidgetStatePropertyAll<Color>(
          Color(0x00000000),
        ),
        shadowColor: const WidgetStatePropertyAll<Color>(Color(0x00000000)),
        elevation: const WidgetStatePropertyAll<double>(0),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.zero,
        ),
      ),
      menuChildren: <Widget>[_DsMenuSurface(tokens: tokens, items: items)],
      builder: (BuildContext context, MenuController controller, Widget? child) {
        void toggle() {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        }

        return Semantics(
          button: true,
          expanded: controller.isOpen,
          onTap: toggle,
          // FocusableActionDetector makes the trigger reachable by Tab and
          // activatable by Enter/Space (via the ambient ActivateIntent), so the
          // menu is fully keyboard-operable, not pointer-only.
          child: FocusableActionDetector(
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  toggle();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: toggle,
              child: child,
            ),
          ),
        );
      },
      child: trigger,
    );
  }
}

/// The themed surface that hosts the menu rows.
class _DsMenuSurface extends StatelessWidget {
  const _DsMenuSurface({required this.tokens, required this.items});

  final DsTokens tokens;
  final List<DsMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(tokens.overlayBorderRadius);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.formBackgroundColor,
          borderRadius: radius,
          border: Border.all(color: tokens.colorBorder),
          boxShadow: tokens.shadowMedium,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.spacingUnit / 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final DsMenuItem item in items)
                  _DsMenuRow(tokens: tokens, item: item),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A single row rendered as a [MenuItemButton] so it inherits focus, keyboard
/// navigation and automatic close-on-select from the enclosing [MenuAnchor].
class _DsMenuRow extends StatelessWidget {
  const _DsMenuRow({required this.tokens, required this.item});

  final DsTokens tokens;
  final DsMenuItem item;

  @override
  Widget build(BuildContext context) {
    final Color base =
        item.destructive ? tokens.colorDanger : tokens.colorText;
    final Color disabledColor = base.withValues(alpha: 0.38);
    final bool isEnabled = item.enabled;

    final ButtonStyle style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(Size(112, 48)),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: tokens.spacingUnit * 1.5),
      ),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle>(tokens.bodyMd.toTextStyle()),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) return disabledColor;
        return base;
      }),
      iconColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) return disabledColor;
        return base;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return base.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return base.withValues(alpha: 0.08);
        }
        return const Color(0x00000000);
      }),
    );

    return MenuItemButton(
      onPressed: isEnabled ? (item.onSelected ?? () {}) : null,
      style: style,
      leadingIcon: item.icon == null
          ? null
          : DsIcon(
              icon: item.icon!,
              size: DsIconSize.sm,
              color: isEnabled ? base : disabledColor,
            ),
      child: Text(
        item.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
