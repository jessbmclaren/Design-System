import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';

/// A themed icon that reads its default colour from the active Design System
/// theme.
///
/// [DsIcon] is a thin, token-aware wrapper around Flutter's [Icon]. Prefer it
/// over a raw [Icon] so that glyphs stay on the shared [DsIconSize] scale and
/// pick up the correct foreground colour ([DsTokens.colorText]) for the active
/// theme, including in white-label builds where that colour is themed.
///
/// ```dart
/// const DsIcon(icon: DsIcons.success)
///
/// DsIcon(
///   icon: DsIcons.warning,
///   size: DsIconSize.lg,
///   color: DsTokens.of(context).colorDanger,
///   semanticLabel: 'Warning',
/// )
/// ```
///
/// ## Sizing & responsiveness
///
/// The icon renders at a fixed [size] and never grows or overflows, so it is
/// safe from a 320dp phone up to a large desktop. Choose a step from
/// [DsIconSize] rather than an ad-hoc value so the glyph aligns with the type
/// ramp and surrounding controls.
///
/// ## Accessibility
///
/// A decorative icon (one that merely accompanies visible text) should leave
/// [semanticLabel] null so assistive technology skips it. A meaning-bearing or
/// icon-only glyph should pass a concise [semanticLabel] describing its intent.
/// Interactive affordances (tap targets, tooltips, the >=48dp touch area) are
/// the responsibility of the enclosing control; [DsIcon] renders the glyph
/// only.
class DsIcon extends StatelessWidget {
  /// Creates a themed icon.
  ///
  /// [icon] is required. [size] defaults to [DsIconSize.md]; [color] defaults
  /// to [DsTokens.colorText] resolved from the active theme.
  const DsIcon({
    required this.icon,
    this.size = DsIconSize.md,
    this.color,
    this.semanticLabel,
    super.key,
  });

  /// The glyph to render, e.g. `DsIcons.check`.
  final IconData icon;

  /// The rendered size in logical pixels. Prefer a [DsIconSize] step.
  final double size;

  /// The glyph colour. When null, resolves to [DsTokens.colorText].
  final Color? color;

  /// A description announced by assistive technology.
  ///
  /// Leave null for purely decorative icons so they are not announced twice
  /// alongside adjacent visible text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    return Icon(
      icon,
      size: size,
      color: color ?? tokens.colorText,
      semanticLabel: semanticLabel,
    );
  }
}
