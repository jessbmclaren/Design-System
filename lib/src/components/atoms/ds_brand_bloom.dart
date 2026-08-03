import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
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
/// A marketing backdrop that pools more than one of the brand's hues passes
/// [color] per instance, so a second glow can carry the brand's other colour
/// without the theme having to choose between them.
///
/// For a richer, multi-hue wash rising from the bottom edge — the spotlight
/// glow behind a [DsSpotlight] nudge — use [DsBrandBloom.pools], which paints a
/// sweep of soft pools from the theme's `bloomStops`. On the neutral base,
/// where `bloomStops` is empty, it falls back to a soft spread of `bloomColor`,
/// so the white-label glow stays a single quiet hue until a skin supplies its
/// stops.
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
  /// Creates the single-pool brand glow.
  const DsBrandBloom({
    super.key,
    this.alignment = Alignment.bottomCenter,
    this.radius = 1.2,
    this.opacity = 0.6,
    this.color,
  })  : _pools = false,
        assert(radius > 0, 'radius must be positive'),
        assert(
          opacity >= 0 && opacity <= 1,
          'opacity must be between 0 and 1',
        );

  /// Creates the multi-pool spotlight bloom: a sweep of soft elliptical pools
  /// anchored along the bottom edge, coloured by the theme's `bloomStops`.
  ///
  /// Each pool carries its own baked geometry and peak alpha; [opacity] scales
  /// every pool at once, so the whole bloom can be dimmed without disturbing
  /// its balance. When the theme sets no `bloomStops` (the neutral base) the
  /// sweep falls back to a soft spread of the single `bloomColor`.
  const DsBrandBloom.pools({
    super.key,
    this.opacity = 1,
  })  : _pools = true,
        alignment = Alignment.bottomCenter,
        radius = 1.2,
        color = null,
        assert(
          opacity >= 0 && opacity <= 1,
          'opacity must be between 0 and 1',
        );

  /// Whether to paint the multi-pool sweep rather than the single pool.
  final bool _pools;

  /// Where the single pool's centre sits within the bounds. Defaults to the
  /// bottom centre, a pool rising from the lower edge. Unused by
  /// [DsBrandBloom.pools], whose pool geometry is fixed.
  final AlignmentGeometry alignment;

  /// The single pool's reach as a multiple of the shorter side of the bounds,
  /// per [RadialGradient.radius]. Defaults to 1.2, wide enough to read as a
  /// soft pool rather than a spotlight. Unused by [DsBrandBloom.pools].
  final double radius;

  /// The peak opacity applied to the bloom, fading to fully transparent at the
  /// rim. Defaults to 0.6 for the single pool and 1.0 for [DsBrandBloom.pools]
  /// (whose pools carry their own peak alphas that this simply scales).
  final double opacity;

  /// The pool's hue, overriding the theme's `bloomColor`.
  ///
  /// Leave it null and the glow takes the theme's own bloom, which is what a
  /// single backdrop glow should do. Pass another *token* — a brand tint, the
  /// second brand colour's wash — when a backdrop pools more than one hue and
  /// the theme can only name one of them. Unused by [DsBrandBloom.pools],
  /// whose hues come from `bloomStops`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    if (_pools) {
      // The branded stops, or a soft spread of the single bloom colour so the
      // neutral base still reads as one cohesive glow.
      final stops = tokens.bloomStops.isNotEmpty
          ? tokens.bloomStops
          : List<Color>.filled(_kPools.length, tokens.bloomColor);
      return ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _BloomPainter(stops: stops, opacity: opacity),
          ),
        ),
      );
    }

    final bloom = color ?? tokens.bloomColor;
    final peak = bloom.withValues(alpha: bloom.a * opacity);
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

/// One radial pool in the multi-pool bloom: geometry and peak alpha for a
/// colour that fades to transparent, shaped as an ellipse anchored near the
/// bottom edge. All measurements are fractions of the paint box.
@immutable
class _Pool {
  const _Pool({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
    required this.fade,
    required this.alpha,
  });

  /// Centre x as a fraction of width (1.0 = right edge).
  final double cx;

  /// Centre y as a fraction of height (1.0 = bottom edge).
  final double cy;

  /// Ellipse x-radius as a fraction of width.
  final double rx;

  /// Ellipse y-radius as a fraction of height.
  final double ry;

  /// Fraction of the radius where the colour reaches transparent.
  final double fade;

  /// Peak opacity of this pool.
  final double alpha;
}

/// Per-pool geometry, in the same order as the theme's `bloomStops`. Painted
/// first-to-last so the last stop (a deep corner anchor in the Engen sweep)
/// lands on top.
const List<_Pool> _kPools = <_Pool>[
  _Pool(cx: 0.27, cy: 1.24, rx: 0.58, ry: 0.54, fade: 0.52, alpha: 0.46),
  _Pool(cx: 0.48, cy: 1.16, rx: 0.70, ry: 0.60, fade: 0.55, alpha: 0.58),
  _Pool(cx: 0.66, cy: 1.12, rx: 0.72, ry: 0.64, fade: 0.56, alpha: 0.50),
  _Pool(cx: 0.84, cy: 1.08, rx: 0.80, ry: 0.70, fade: 0.56, alpha: 0.62),
  _Pool(cx: 1.04, cy: 1.16, rx: 0.85, ry: 0.70, fade: 0.52, alpha: 0.78),
];

/// Paints the multi-pool bloom: each stop as a soft elliptical radial pool
/// rising from the bottom edge, at its pool's peak alpha scaled by [opacity].
class _BloomPainter extends CustomPainter {
  const _BloomPainter({required this.stops, required this.opacity});

  final List<Color> stops;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _kPools.length && i < stops.length; i++) {
      final p = _kPools[i];
      final color = stops[i].withValues(alpha: p.alpha * opacity);
      final cx = p.cx * size.width;
      final cy = p.cy * size.height;
      final rx = p.rx * size.width;
      final ry = p.ry * size.height;
      if (rx <= 0 || ry <= 0) continue;
      final k = ry / rx;

      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy),
          rx,
          [color, color.withValues(alpha: 0)],
          [0.0, p.fade],
        );

      // Squash the canvas vertically about the pool's centre, turning the
      // circular gradient (radius rx) into a wide, shallow ellipse (rx x ry).
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(1.0, k);
      canvas.translate(-cx, -cy);
      canvas.drawRect(
        Rect.fromLTRB(0, cy - cy / k, size.width, cy + (size.height - cy) / k),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BloomPainter oldDelegate) =>
      oldDelegate.opacity != opacity || !listEquals(oldDelegate.stops, stops);
}
