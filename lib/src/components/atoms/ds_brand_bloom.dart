import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// The soft radial brand glow behind auth and marketing surfaces.
///
/// [DsBrandBloom] paints a single elliptical pool of the theme's `bloomColor`
/// that fades to transparent, anchored by [alignment] and sized by [radius].
/// Layered over a [DsAuthGradient] it lifts the backdrop from a flat wash to
/// a branded one; the default token keeps the glow a quiet neutral, so the
/// white-label look barely changes until a skin supplies a brand tint.
///
/// The bloom is pure decoration and static, so it is excluded from semantics
/// and needs no reduce-motion handling.
///
/// The widget fills whatever bounds its parent provides; give it a
/// `Positioned.fill`, an expanded [Stack] slot or an explicit [SizedBox].
///
/// ```dart
/// Stack(fit: StackFit.expand, children: [
///   const DsAuthGradient(),
///   const DsBrandBloom(alignment: Alignment.bottomRight),
///   content,
/// ])
/// ```
class DsBrandBloom extends StatelessWidget {
  /// Creates the brand glow.
  const DsBrandBloom({
    super.key,
    this.alignment = Alignment.bottomCenter,
    this.radius = 1.2,
    this.opacity = 0.6,
  })  : assert(radius > 0, 'radius must be positive'),
        assert(
          opacity >= 0 && opacity <= 1,
          'opacity must be between 0 and 1',
        );

  /// Where the glow's centre sits within the bounds. Defaults to the bottom
  /// centre, a pool rising from the lower edge.
  final AlignmentGeometry alignment;

  /// The glow's reach as a multiple of the shorter side of the bounds, per
  /// [RadialGradient.radius]. Defaults to 1.2, wide enough to read as a soft
  /// pool rather than a spotlight.
  final double radius;

  /// The peak opacity applied to the theme's bloom colour, fading to fully
  /// transparent at the rim. Defaults to 0.6.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final peak =
        tokens.bloomColor.withValues(alpha: tokens.bloomColor.a * opacity);
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: alignment,
            radius: radius,
            colors: [peak, peak.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
