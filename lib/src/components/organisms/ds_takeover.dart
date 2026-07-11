import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// A foreground card hosted over a blurred, non-interactive background.
///
/// [DsTakeover] presents [child] as the only live surface while [background]
/// (usually the page the user came from) stays visible behind a light blur
/// and a scrim, so the takeover reads as a focused step rather than a context
/// switch. The background is wrapped in [IgnorePointer], [ExcludeSemantics]
/// and a focus scope that can never hold focus, so it cannot be tapped, read
/// by assistive technology or reached by keyboard while the takeover is up.
/// A background field that was focused when the takeover mounts is unfocused
/// on the first frame, which also closes its input connection, so typing can
/// never leak behind the card.
///
/// The foreground is centred inside a [SafeArea] and a scroll view, so a card
/// taller than the viewport scrolls instead of overflowing. Set
/// [barrierDismissible] with an [onDismiss] to let a tap outside the card
/// close the takeover; by default the card itself owns the way out. While
/// dismissible, the card claims every tap inside its own footprint, including
/// taps on transparent gaps between its surfaces, so only genuine barrier
/// taps dismiss.
///
/// The takeover holds no route of its own; the caller shows and removes it,
/// typically by swapping the page body.
///
/// Takeovers nest through [background] only: pass an existing takeover as the
/// [background] of a new one to stack a second card over the first. Hosting a
/// takeover inside another's [child] is not supported; the card slot is a
/// scroll view, so the inner takeover's expanding stack would receive
/// unbounded height and fail layout.
///
/// ```dart
/// DsTakeover(
///   background: dashboard,
///   child: verifyEmailCard,
/// )
/// ```
class DsTakeover extends StatefulWidget {
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
  State<DsTakeover> createState() => _DsTakeoverState();
}

class _DsTakeoverState extends State<DsTakeover> {
  /// Owns the background's focus subtree. The scope can never request focus,
  /// so focus cannot move into the background while the takeover is up, and
  /// it gives the state a handle for releasing focus that was already inside
  /// the background when the takeover mounted.
  final FocusScopeNode _backgroundFocus = FocusScopeNode(
    debugLabel: 'DsTakeover background',
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void initState() {
    super.initState();
    // Focus exclusion only blocks NEW focus requests: a field focused before
    // the takeover mounts keeps primary focus and its open input connection.
    // The scope attaches during the first build, so resolve any focus caught
    // inside the background once that frame is out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final primary = FocusManager.instance.primaryFocus;
      if (primary != null && primary.ancestors.contains(_backgroundFocus)) {
        primary.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _backgroundFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final dismissible = widget.barrierDismissible && widget.onDismiss != null;
    final blurSigma = widget.blurSigma;
    final background = widget.background;

    return Stack(
      fit: StackFit.expand,
      children: [
        // The background stays visible but inert: no taps, no semantics, no
        // focus. ImageFiltered blurs the subtree itself, which renders
        // deterministically in tests where a backdrop layer would not.
        FocusScope(
          node: _backgroundFocus,
          canRequestFocus: false,
          skipTraversal: true,
          child: ExcludeFocus(
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
        ),
        Positioned.fill(
          child: ColoredBox(
            color: widget.scrimColor ?? tokens.overlayBackdropColor,
          ),
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
                        // The inner detector claims every tap on the card's
                        // footprint, opaquely, so transparent gaps inside the
                        // card never fall through to the dismiss handler
                        // below. Controls inside the card still win their own
                        // gestures.
                        child: dismissible
                            ? GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {},
                                child: widget.child,
                              )
                            : widget.child,
                      ),
                    ),
                  ),
                );
                if (!dismissible) return content;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onDismiss,
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
