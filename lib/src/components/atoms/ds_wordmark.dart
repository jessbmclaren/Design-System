import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// A two-tone product wordmark.
///
/// [DsWordmark] sets a product name as text, with an optional [accent] suffix
/// in a heavier weight so the mark reads with a subtle two-tone emphasis (for
/// example "acme" followed by "id"). The family and colour come from the
/// active theme and the type metrics from the wordmark tokens
/// ([DsTokens.wordmarkFontSize], [DsTokens.wordmarkLetterSpacing] and
/// [DsTokens.wordmarkHeight]), so the mark re-skins with the rest of the
/// system; the two weights are fixed.
///
/// The name itself is content rather than a token, so the caller passes it in.
/// A brand that keeps its name in its own theme can build the wordmark there
/// and pass the parts down, so a re-brand still updates every mark at once.
class DsWordmark extends StatelessWidget {
  /// Creates a product wordmark.
  const DsWordmark({
    super.key,
    required this.primary,
    this.accent,
    this.fontSize,
    this.color,
  });

  /// The main part of the name, shown in the lighter of the two weights.
  final String primary;

  /// An optional suffix shown in the heavier weight for a two-tone emphasis.
  final String? accent;

  /// The wordmark size, in logical pixels. Defaults to
  /// [DsTokens.wordmarkFontSize].
  final double? fontSize;

  /// The wordmark colour. Defaults to [DsTokens.colorText].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    // No explicit fontFamily: the style inherits the theme's resolved family,
    // which already maps the default token onto the bundled package-prefixed
    // font and carries any brand override. Naming the raw token here would
    // bypass that mapping and miss the bundled font entirely.
    // The tight tracking and glyph-height line come from the wordmark
    // tokens, so a skin can retune the mark's set without a new widget.
    final base = TextStyle(
      fontSize: fontSize ?? tokens.wordmarkFontSize,
      color: color ?? tokens.colorText,
      height: tokens.wordmarkHeight,
      letterSpacing: tokens.wordmarkLetterSpacing,
    );
    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: primary,
            style: base.copyWith(fontWeight: tokens.wordmarkPrimaryFontWeight),
          ),
          if (accent != null)
            TextSpan(
              text: accent,
              style: base.copyWith(fontWeight: tokens.wordmarkAccentFontWeight),
            ),
        ],
      ),
      // The whole mark reads as one thing to assistive technology: the name.
      semanticsLabel: '$primary${accent ?? ''}',
    );
  }
}
