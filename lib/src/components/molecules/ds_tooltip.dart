import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_elevation.dart';

/// A small text label that surfaces contextual help for its [child].
///
/// [DsTooltip] wraps the child in a themed Material [Tooltip] that appears on
/// hover (pointer devices such as desktop) and on long-press (touch devices),
/// and reads its appearance entirely from [DsTokens] so it matches the active
/// skin in both light and dark themes.
///
/// The bubble uses a dark, inverted surface ([DsTokens.colorText]) with text in
/// [DsTokens.formBackgroundColor] for high contrast, `bodySm` typography, a
/// [DsTokens.overlayBorderRadius] radius and a [DsElevation.medium] shadow so it
/// floats above surrounding content.
///
/// The bubble is constrained so long messages wrap rather than overflow, which
/// keeps it safe from a 320dp phone up to a large desktop.
///
/// ```dart
/// DsTooltip(
///   message: 'Copy to clipboard',
///   child: IconButton(icon: const Icon(DsIcons.copy), onPressed: () {}),
/// )
/// ```
class DsTooltip extends StatelessWidget {
  /// Creates a themed tooltip that decorates [child] with a hint [message].
  const DsTooltip({
    super.key,
    required this.message,
    required this.child,
    this.preferBelow = true,
  });

  /// The text shown inside the tooltip bubble.
  ///
  /// Also surfaced to assistive technology as the semantic label of the
  /// underlying [Tooltip].
  final String message;

  /// The widget the tooltip is attached to and describes.
  final Widget child;

  /// Whether the bubble prefers to appear below [child].
  ///
  /// When there is not enough room on the preferred side, the tooltip flips to
  /// the opposite side automatically. Defaults to `true`.
  final bool preferBelow;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    // Inverted surface: dark bubble on light themes, light bubble on dark
    // themes, always the maximum-contrast pairing of text/background tokens.
    final Color surface = tokens.colorText;
    final Color foreground = tokens.formBackgroundColor;

    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      waitDuration: const Duration(milliseconds: 500),
      // Cap the width so long copy wraps onto multiple lines instead of
      // overflowing on narrow (320dp) screens.
      constraints: const BoxConstraints(maxWidth: 280),
      textStyle: tokens.bodySm.toTextStyle(color: foreground),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
        boxShadow: DsElevation.medium,
      ),
      child: child,
    );
  }
}
