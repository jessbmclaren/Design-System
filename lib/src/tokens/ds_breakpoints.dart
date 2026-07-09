import 'package:flutter/widgets.dart';

/// Design System window size classes, following the Material 3 breakpoint system.
enum DsWindowSize {
  /// Width < 600dp — phones in portrait.
  compact,

  /// 600dp ≤ width < 840dp — tablets in portrait, large phones in landscape.
  medium,

  /// Width ≥ 840dp — tablets in landscape, desktops.
  expanded;

  /// Whether this size is at least [other].
  bool operator >=(DsWindowSize other) => index >= other.index;
}

/// Design System responsive breakpoints.
///
/// Design System layouts adapt across three window size classes rather than targeting
/// devices: [DsWindowSize.compact], [DsWindowSize.medium] and
/// [DsWindowSize.expanded].
abstract final class DsBreakpoints {
  /// Lower bound of the medium window class.
  static const double medium = 600;

  /// Lower bound of the expanded window class.
  static const double expanded = 840;

  /// Resolves the window size class for [width].
  static DsWindowSize windowSizeFor(double width) {
    if (width >= expanded) return DsWindowSize.expanded;
    if (width >= medium) return DsWindowSize.medium;
    return DsWindowSize.compact;
  }

  /// Resolves the window size class for the current [MediaQuery] width.
  static DsWindowSize of(BuildContext context) {
    return windowSizeFor(MediaQuery.sizeOf(context).width);
  }
}
