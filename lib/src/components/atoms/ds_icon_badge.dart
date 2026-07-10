import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// The colour pairing of a [DsIconBadge].
///
/// Each tone maps onto an existing token pair, so the mark re-skins with the
/// active theme:
///
/// * [primary]: the solid primary action pair, for the flow's own marks such
///   as a completed step tick.
/// * [success]: the tinted success badge pair, for a positive outcome.
/// * [warning]: the tinted warning badge pair, for something needing
///   attention.
/// * [danger]: the tinted danger badge pair, for a failure.
/// * [neutral]: the tinted neutral badge pair, for a mark with no strong
///   connotation.
enum DsIconBadgeTone { primary, success, warning, danger, neutral }

/// A circular mark holding a single icon on a token-tinted background.
///
/// [DsIconBadge] is the shared circle-plus-glyph mark used for step ticks,
/// task states and list decorations: a completed step's check, a warning dot
/// beside a pending task, a lock ahead of a security row. The circle and the
/// glyph take their colours from the token pair named by [tone], so the mark
/// follows the active theme without any hardcoded colour.
///
/// The badge is decorative by default and hidden from assistive technology,
/// on the expectation that the neighbouring label carries the meaning. When
/// the mark stands alone, pass a [semanticLabel] so it is announced.
///
/// It is static and deterministic: no timers, no animation, safe in goldens.
///
/// ```dart
/// const DsIconBadge(
///   icon: DsIcons.check,
///   tone: DsIconBadgeTone.success,
/// )
/// ```
class DsIconBadge extends StatelessWidget {
  /// Creates a circular icon mark.
  const DsIconBadge({
    super.key,
    required this.icon,
    this.tone = DsIconBadgeTone.primary,
    this.size = 28,
    this.iconSize,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticLabel,
  });

  /// The glyph shown at the centre of the circle.
  final IconData icon;

  /// The token pair colouring the circle and the glyph.
  ///
  /// Defaults to [DsIconBadgeTone.primary].
  final DsIconBadgeTone tone;

  /// The circle's diameter in logical pixels. Defaults to 28.
  final double size;

  /// The glyph size in logical pixels.
  ///
  /// Defaults to just over half the diameter, the proportion the progress
  /// stepper's step circles use.
  final double? iconSize;

  /// Overrides the tone's background colour.
  ///
  /// Prefer a [tone]; use this only when a consumer needs a pairing the tones
  /// do not cover.
  final Color? backgroundColor;

  /// Overrides the tone's glyph colour.
  final Color? foregroundColor;

  /// An optional label announced by assistive technology.
  ///
  /// When null (the default) the badge is treated as decorative and excluded
  /// from semantics, so the neighbouring text is not doubled up.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final (Color background, Color foreground) = switch (tone) {
      DsIconBadgeTone.primary => (
          tokens.buttonPrimaryColorBackground,
          tokens.buttonPrimaryColorText,
        ),
      DsIconBadgeTone.success => (
          tokens.badgeSuccessColorBackground,
          tokens.badgeSuccessColorText,
        ),
      DsIconBadgeTone.warning => (
          tokens.badgeWarningColorBackground,
          tokens.badgeWarningColorText,
        ),
      DsIconBadgeTone.danger => (
          tokens.badgeDangerColorBackground,
          tokens.badgeDangerColorText,
        ),
      DsIconBadgeTone.neutral => (
          tokens.badgeNeutralColorBackground,
          tokens.badgeNeutralColorText,
        ),
    };

    final mark = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? background,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        // 4/7 of the diameter: a 28dp circle carries a 16dp glyph, matching
        // the marks the stepper and setup guide draw today.
        size: iconSize ?? size * 4 / 7,
        color: foregroundColor ?? foreground,
      ),
    );

    if (semanticLabel == null) {
      return ExcludeSemantics(child: mark);
    }
    return Semantics(container: true, label: semanticLabel, child: mark);
  }
}
