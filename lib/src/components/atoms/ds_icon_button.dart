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
/// and Space and exposes a button role to assistive technology. [semanticLabel]
/// becomes the button's tooltip, the stock Material pattern: screen readers
/// announce the tooltip as the control's name, though the semantics label
/// itself stays empty. Always provide a meaningful [semanticLabel]: an icon
/// alone carries no text for a screen reader.
///
/// Keyboard focus draws a ring around the circle in the theme's
/// [DsTokens.formAccentColor] at [DsTokens.focusRingWidth], so focus reads
/// differently from hover. The hover, press and disabled treatments come from
/// the state tokens ([DsTokens.stateHoverOpacity],
/// [DsTokens.statePressedOpacity] and [DsTokens.stateDisabledIconOpacity]),
/// so a skin can retune them alongside the rest of the system. The tap
/// target is padded to at least 48dp on every platform while the visible
/// circle keeps its [size], so the control stays accessible to touch without
/// growing visually.
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

  /// The name screen readers announce, carried on the button's tooltip (the
  /// stock Material pattern) rather than on the semantics label, and shown as
  /// a tooltip on hover and long press.
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
        return foreground.withValues(alpha: tokens.statePressedOpacity);
      }
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused)) {
        return foreground.withValues(alpha: tokens.stateHoverOpacity);
      }
      return null;
    });

    // The soft fill alone reads the same as hover, so keyboard focus adds an
    // accent ring on the circle's edge as a distinct indicator.
    final WidgetStateProperty<OutlinedBorder> shape =
        WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return CircleBorder(
          side: BorderSide(
            color: tokens.formAccentColor,
            width: tokens.focusRingWidth,
          ),
        );
      }
      return const CircleBorder();
    });

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize),
      tooltip: semanticLabel,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: size, height: size),
      style: IconButton.styleFrom(
        foregroundColor: foreground,
        disabledForegroundColor:
            foreground.withValues(alpha: tokens.stateDisabledIconOpacity),
        // Pad the hit area out to the 48dp accessible minimum on every
        // platform. The visible circle stays at [size]; the padding is
        // transparent and still routes taps to the button.
        tapTargetSize: MaterialTapTargetSize.padded,
      ).copyWith(backgroundColor: fill, shape: shape),
    );
  }
}
