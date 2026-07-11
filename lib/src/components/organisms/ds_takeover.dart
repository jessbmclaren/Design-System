import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// A foreground card hosted over a blurred, non-interactive background.
///
/// [DsTakeover] presents [child] as the only live surface while [background]
/// (usually the page the user came from) stays visible behind a light blur
/// and a scrim, so the takeover reads as a focused step rather than a context
/// switch. The background is wrapped in [IgnorePointer], [ExcludeSemantics]
/// and [ExcludeFocus], so it cannot be tapped, read by assistive technology
/// or reached by keyboard while the takeover is up.
///
/// The foreground is centred inside a [SafeArea] and a scroll view, so a card
/// taller than the viewport scrolls instead of overflowing. Set
/// [barrierDismissible] with an [onDismiss] to let a tap outside the card
/// close the takeover; by default the card itself owns the way out.
///
/// The takeover is stateless and holds no route of its own; the caller shows
/// and removes it, typically by swapping the page body.
///
/// ```dart
/// DsTakeover(
///   background: dashboard,
///   child: verifyEmailCard,
/// )
/// ```
class DsTakeover extends StatelessWidget {
  /// Creates a takeover of [background] by [child].
  const DsTakeover({
    super.key,
    required this.background,
    required this.child,
    this.blurSigma = 3,
    this.scrimColor,
    this.barrierDismissible = false,
    this.onDismiss,
  }) : assert(blurSigma >= 0, 'blurSigma must not be negative');

  /// The page behind the takeover. It keeps its layout but is blurred,
  /// scrimmed and removed from pointer, semantics and focus handling.
  final Widget background;

  /// The foreground surface, centred over the scrim in a scroll view.
  final Widget child;

  /// The blur applied to [background], in logical pixels. Defaults to 3, a
  /// light blur that keeps the page recognisable; 0 skips the blur.
  final double blurSigma;

  /// The scrim painted between the background and [child]. Defaults to the
  /// theme's `overlayBackdropColor`.
  final Color? scrimColor;

  /// Whether a tap outside [child] calls [onDismiss]. Defaults to false: a
  /// takeover usually gates a step the user must finish or close explicitly.
  final bool barrierDismissible;

  /// Called when the barrier is tapped while [barrierDismissible] is true.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final dismissible = barrierDismissible && onDismiss != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        // The background stays visible but inert: no taps, no semantics, no
        // focus. ImageFiltered blurs the subtree itself, which renders
        // deterministically in tests where a backdrop layer would not.
        ExcludeFocus(
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: blurSigma > 0
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blurSigma,
                        sigmaY: blurSigma,
                      ),
                      child: background,
                    )
                  : background,
            ),
          ),
        ),
        Positioned.fill(
          child: ColoredBox(color: scrimColor ?? tokens.overlayBackdropColor),
        ),
        Positioned.fill(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final content = SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.spacingUnit * 2,
                          vertical: tokens.spacingUnit * 3,
                        ),
                        // The inner detector claims taps on the card, so
                        // only genuine barrier taps reach the dismiss
                        // handler below. Controls inside the card still win
                        // their own gestures.
                        child: dismissible
                            ? GestureDetector(onTap: () {}, child: child)
                            : child,
                      ),
                    ),
                  ),
                );
                if (!dismissible) return content;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDismiss,
                  child: content,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
