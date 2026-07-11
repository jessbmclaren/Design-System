import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// The full-bleed wash behind an auth or waiting page.
///
/// [DsAuthGradient] paints the theme's `authWashGradient` stops from the top
/// of its bounds to the bottom, giving sign-in, sign-up and waiting screens a
/// shared backdrop without per-screen colour work. The default tokens keep
/// the wash a barely-there neutral drift from the page background; a skin
/// supplies branded stops through `DsTokens.authWashGradient`.
///
/// The wash is pure decoration, so it is excluded from semantics. Layer a
/// [DsBrandBloom] between the wash and the content when the page should also
/// carry the brand glow.
///
/// The widget fills whatever bounds its parent provides; give it a
/// `Positioned.fill`, an expanded [Stack] slot or an explicit [SizedBox].
///
/// ```dart
/// DsAuthGradient(
///   child: Center(child: signInCard),
/// )
/// ```
class DsAuthGradient extends StatelessWidget {
  /// Creates the auth wash backdrop.
  const DsAuthGradient({super.key, this.child});

  /// The content placed over the wash, filling the same bounds. Null paints
  /// the wash alone, for callers composing their own stack.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final stops = tokens.authWashGradient;
    // A gradient needs two stops; fewer degrades to a solid fill rather
    // than throwing at paint time.
    final wash = ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: stops.length < 2
              ? (stops.isEmpty ? tokens.colorBackground : stops.first)
              : null,
          gradient: stops.length < 2
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: stops,
                ),
        ),
      ),
    );
    if (child == null) return wash;
    return Stack(
      fit: StackFit.expand,
      children: [wash, child!],
    );
  }
}
