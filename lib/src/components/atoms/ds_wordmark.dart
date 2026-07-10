import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_typography.dart';

/// A two-tone product wordmark.
///
/// [DsWordmark] sets a product name as text, with an optional [accent] suffix
/// in a heavier weight so the mark reads with a subtle two-tone emphasis (for
/// example "acme" followed by "id"). The family, weights and colour come from
/// the active theme, so the mark re-skins with the rest of the system.
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
    this.fontSize = 22,
    this.color,
  });

  /// The main part of the name, shown in the lighter of the two weights.
  final String primary;

  /// An optional suffix shown in the heavier weight for a two-tone emphasis.
  final String? accent;

  /// The wordmark size, in logical pixels.
  final double fontSize;

  /// The wordmark colour. Defaults to [DsTokens.colorText].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final base = TextStyle(
      fontFamily: tokens.fontFamily,
      fontSize: fontSize,
      color: color ?? tokens.colorText,
      height: 1,
      letterSpacing: -0.2,
    );
    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: primary,
            style: base.copyWith(fontWeight: DsTypography.semiBold),
          ),
          if (accent != null)
            TextSpan(
              text: accent,
              style: base.copyWith(fontWeight: DsTypography.bold),
            ),
        ],
      ),
      // The whole mark reads as one thing to assistive technology: the name.
      semanticsLabel: '$primary${accent ?? ''}',
    );
  }
}
