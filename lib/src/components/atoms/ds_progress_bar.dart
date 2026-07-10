import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../util/ds_motion.dart';

/// A thin, rounded, determinate progress bar.
///
/// [DsProgressBar] shows how much of a bounded task is complete. The track is
/// tinted with [DsTokens.colorBorder] and the fill with
/// [DsTokens.buttonPrimaryColorBackground], so the bar re-skins with the
/// active theme. It stretches to the width its parent provides and never
/// overflows, from a 320dp phone up to a wide desktop.
///
/// Set [animate] to ease the fill towards a new [value] through [DsMotion];
/// when the user has asked for reduced motion the fill lands on the final
/// frame instantly. The default is a static bar, which keeps it safe for
/// screenshots and golden tests.
///
/// For an unbounded wait with no measurable progress use `DsSpinner` instead.
///
/// ## Accessibility
///
/// Assistive technology announces the bar as a percentage. Pass a
/// [semanticLabel] to name what is progressing ("Setup progress"). When the
/// same information is already conveyed by adjacent text (a "3 of 6" count,
/// say), set [excludeSemantics] so the value is not announced twice.
///
/// ```dart
/// const DsProgressBar(
///   value: 0.6,
///   semanticLabel: 'Setup progress',
/// )
/// ```
class DsProgressBar extends StatelessWidget {
  /// Creates a determinate progress bar.
  ///
  /// [value] is clamped into the range 0 to 1.
  const DsProgressBar({
    super.key,
    required this.value,
    this.minHeight = 4,
    this.animate = false,
    this.semanticLabel,
    this.excludeSemantics = false,
  });

  /// The completed fraction of the task, from 0 (nothing) to 1 (done).
  ///
  /// Values outside that range are clamped.
  final double value;

  /// The thickness of the bar in logical pixels. Defaults to 4.
  final double minHeight;

  /// Whether the fill eases towards a changed [value].
  ///
  /// When `true` the fill animates through [DsMotion] and settles on a still
  /// frame under reduced motion. Defaults to `false`, a static bar.
  final bool animate;

  /// A short name for what is progressing, announced by assistive technology
  /// alongside the percentage.
  final String? semanticLabel;

  /// Whether to drop the bar from the semantics tree entirely.
  ///
  /// Set this when the bar is decorative and the progress is already conveyed
  /// by neighbouring text, so it is not announced twice.
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final clamped = value.clamp(0.0, 1.0).toDouble();

    Widget buildBar(double fill) {
      return ClipRRect(
        // A radius far larger than any sensible minHeight, so the ends are
        // always fully rounded.
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: fill,
          minHeight: minHeight,
          backgroundColor: tokens.colorBorder,
          valueColor: AlwaysStoppedAnimation<Color>(
            tokens.buttonPrimaryColorBackground,
          ),
          semanticsLabel: semanticLabel,
        ),
      );
    }

    final Widget bar = animate
        ? TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: clamped),
            duration: DsMotion.durationOf(context, DsMotion.expressive),
            curve: DsMotion.curveOf(context, DsMotion.standard),
            builder: (context, fill, _) => buildBar(fill),
          )
        : buildBar(clamped);

    if (excludeSemantics) return ExcludeSemantics(child: bar);
    return bar;
  }
}
