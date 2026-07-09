import 'package:flutter/widgets.dart';

/// Motion helpers that honour the platform's reduce-motion preference.
///
/// The Design System treats reduced motion as a law: any animation must
/// collapse to a still frame when the user has asked for less motion. Read the
/// preference with [reduced] and resolve durations with [duration] so a single
/// call sites both animate normally and settle instantly under the setting.
///
/// ```dart
/// AnimatedContainer(
///   duration: DsMotion.duration(context, const Duration(milliseconds: 200)),
///   ...
/// );
/// ```
abstract final class DsMotion {
  /// Whether the user has requested reduced motion (or platform animations
  /// are disabled).
  static bool reduced(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return media?.disableAnimations ?? false;
  }

  /// [full] when motion is allowed, otherwise [Duration.zero].
  static Duration duration(BuildContext context, Duration full) {
    return reduced(context) ? Duration.zero : full;
  }

  /// [full] when motion is allowed, otherwise [Curves.linear] (no easing to
  /// perceive across a zero-length animation).
  static Curve curve(BuildContext context, Curve full) {
    return reduced(context) ? Curves.linear : full;
  }
}
