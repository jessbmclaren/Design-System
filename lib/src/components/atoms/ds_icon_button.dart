import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';

/// A flat, circular icon button.
///
/// [DsIconButton] is the Design System's compact, chromeless control for a
/// single icon action: a close button on a dialog, an overflow trigger in a
/// toolbar, a clear affordance in a field. It stays flat at rest and shows a
/// soft themed fill on hover, focus and press, so it reads as part of the
/// surface rather than a raised button.
///
/// It is built on [IconButton], so it is keyboard-focusable, activates on Enter
/// and Space, exposes a button role to assistive technology and surfaces
/// [semanticLabel] as both the accessible name and a tooltip. Always provide a
/// meaningful [semanticLabel]: an icon alone carries no text for a screen
/// reader.
///
/// The diameter and glyph default to the medium control size. Pass [size] and
/// [iconSize] to fit a denser or more prominent slot.
class DsIconButton extends StatelessWidget {
  /// Creates a flat, circular icon button.
  const DsIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 40,
    this.iconSize = DsIconSize.md,
  });

  /// The glyph shown in the centre of the button.
  final IconData icon;

  /// Called when the button is activated. A null callback disables it and
  /// removes it from the focus order.
  final VoidCallback? onPressed;

  /// The accessible name, announced by screen readers and shown as a tooltip.
  final String semanticLabel;

  /// The control diameter, in logical pixels.
  final double size;

  /// The glyph size, in logical pixels.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final Color foreground = tokens.colorText;

    // A flat control with a soft fill that only appears on interaction, tinted
    // from the text colour so it reads on any surface in light or dark.
    final WidgetStateProperty<Color?> fill =
        WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return foreground.withValues(alpha: 0.10);
      }
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused)) {
        return foreground.withValues(alpha: 0.06);
      }
      return null;
    });

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize),
      tooltip: semanticLabel,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: size, height: size),
      style: IconButton.styleFrom(
        foregroundColor: foreground,
        disabledForegroundColor: foreground.withValues(alpha: 0.38),
        shape: const CircleBorder(),
      ).copyWith(backgroundColor: fill),
    );
  }
}
