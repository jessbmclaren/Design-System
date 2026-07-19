import 'package:flutter/widgets.dart';

/// The design system's motion foundation.
///
/// Motion here is **physical**: things enter by decelerating into place, leave
/// by accelerating away and settle with a subtle spring-like overshoot rather
/// than snapping. Choreography (staggering a group of elements a beat apart)
/// gives a sequence a sense of cause and effect. Every animation obeys one
/// law: it collapses to a still frame when the user has asked for reduced
/// motion.
///
/// Use the **duration scale** ([fast]/[base]/[slow]/[expressive]) and the
/// **curves** ([standard]/[emphasized]/[decelerate]/[accelerate]/[settle])
/// rather than hand-picking millisecond values, and resolve them through
/// [durationOf] / [curveOf] so a single call site both animates normally and
/// settles instantly under the reduce-motion setting.
///
/// ```dart
/// AnimatedContainer(
///   duration: DsMotion.durationOf(context, DsMotion.base),
///   curve: DsMotion.curveOf(context, DsMotion.emphasized),
///   ...
/// );
/// ```
abstract final class DsMotion {
  // --- Duration scale -------------------------------------------------------

  /// No motion: an immediate change.
  static const Duration instant = Duration.zero;

  /// Micro-interactions: hover, press, a toggle flipping. Quick enough to feel
  /// instantaneous but still eased.
  static const Duration fast = Duration(milliseconds: 120);

  /// The standard transition for most state changes (selection, reveal, colour
  /// and position shifts).
  static const Duration base = Duration(milliseconds: 200);

  /// Deliberate transitions for larger surfaces (sheets, dialogs, an
  /// accordion expanding) where the extra time reads as weight.
  static const Duration slow = Duration(milliseconds: 320);

  /// Choreographed, hero moments: an onboarding reveal, a celebratory
  /// confirmation. Use sparingly; expressive motion is a spotlight.
  static const Duration expressive = Duration(milliseconds: 500);

  /// The scene scale, for narrated beats (a guided tour's dwell on a frame)
  /// rather than widget transitions: the short beat.
  static const Duration sceneShort = Duration(milliseconds: 900);

  /// The scene scale's standard beat.
  static const Duration scene = Duration(milliseconds: 1400);

  /// The scene scale's long beat, for a closing or emphasised frame.
  static const Duration sceneLong = Duration(milliseconds: 1900);

  // --- Curves ---------------------------------------------------------------

  /// The everyday curve: a gentle decelerate into place.
  static const Curve standard = Curves.easeOutCubic;

  /// A strong decelerate for entrances: fast off the mark, softly landing.
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Pure decelerate, for elements arriving from off-screen.
  static const Curve decelerate = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Accelerate, for elements leaving the screen entirely (they should not
  /// linger on the way out).
  static const Curve accelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  /// A physical settle with a subtle overshoot, for a value snapping into place
  /// (a switch, a card lifting, a sheet catching). Restrained on purpose: it
  /// settles, it does not bounce.
  static const Curve settle = Cubic(0.175, 0.885, 0.32, 1.08);

  // --- Physics --------------------------------------------------------------

  /// A spring for physics-driven motion (a dragged card snapping back, a
  /// pull-to-refresh). Tuned to settle quickly with only a hint of overshoot.
  static const SpringDescription spring = SpringDescription(
    mass: 1,
    stiffness: 180,
    damping: 22,
  );

  /// A springier, under-damped spring for a tactile, playful *bounce*: a
  /// button releasing, a chip toggling. It visibly overshoots and settles with
  /// a couple of diminishing rebounds (damping ratio ≈ 0.37), where [spring] is
  /// nearly critically damped. Use it where the motion should feel satisfying,
  /// not merely correct.
  static const SpringDescription bounce = SpringDescription(
    mass: 1,
    stiffness: 180,
    damping: 10,
  );

  // --- Choreography ---------------------------------------------------------

  /// The delay before the item at [index] in a staggered sequence begins, so a
  /// group reveals a beat apart instead of all at once. [step] is the gap
  /// between successive items; the total is clamped by [max] so a long list
  /// never crawls. Returns [Duration.zero] under reduced motion.
  static Duration stagger(
    BuildContext context,
    int index, {
    Duration step = const Duration(milliseconds: 60),
    Duration max = const Duration(milliseconds: 300),
  }) {
    if (reduced(context) || index <= 0) return Duration.zero;
    final total = step * index;
    return total > max ? max : total;
  }

  // --- Reduced-motion resolvers ---------------------------------------------

  /// Whether the user has requested reduced motion (or platform animations are
  /// disabled). Motion is a law: honour this everywhere.
  ///
  /// Registers a dependency on the `disableAnimations` aspect alone, so a
  /// caller rebuilds when that setting changes and not on every media query
  /// change (keyboard insets, window resizes and so on).
  static bool reduced(BuildContext context) {
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  /// [full] when motion is allowed, otherwise [Duration.zero].
  static Duration durationOf(BuildContext context, Duration full) {
    return reduced(context) ? Duration.zero : full;
  }

  /// [full] when motion is allowed, otherwise [Curves.linear] (there is no
  /// easing to perceive across a zero-length animation).
  static Curve curveOf(BuildContext context, Curve full) {
    return reduced(context) ? Curves.linear : full;
  }
}
