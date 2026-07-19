import 'package:flutter/widgets.dart';

/// Design System window size classes, following the Material 3 breakpoint system.
enum DsWindowSize {
  /// Width < 600dp: phones in portrait.
  compact,

  /// 600dp ≤ width < 840dp: tablets in portrait, large phones in landscape.
  medium,

  /// 840dp ≤ width < 1200dp: tablets in landscape, small desktops.
  expanded,

  /// Width ≥ 1200dp: large desktops, where app chrome such as a navigation
  /// sidebar can stay permanently expanded.
  large;

  /// Whether this size is at least [other].
  bool operator >=(DsWindowSize other) => index >= other.index;
}

/// Design System responsive breakpoints.
///
/// Design System layouts adapt across four window size classes rather than
/// targeting devices: [DsWindowSize.compact], [DsWindowSize.medium],
/// [DsWindowSize.expanded] and [DsWindowSize.large].
abstract final class DsBreakpoints {
  /// Lower bound of the medium window class.
  static const double medium = 600;

  /// Lower bound of the expanded window class.
  static const double expanded = 840;

  /// Lower bound of the large window class.
  static const double large = 1200;

  /// The maximum width of a page's main content area on wide screens, in
  /// logical pixels. Constrain content to this and centre the surplus so a
  /// layout does not sprawl across a large desktop. `DsPageScaffold` caps its
  /// body at this by default.
  static const double contentMaxWidth = 960;

  /// Resolves the window size class for [width].
  static DsWindowSize windowSizeFor(double width) {
    if (width >= large) return DsWindowSize.large;
    if (width >= expanded) return DsWindowSize.expanded;
    if (width >= medium) return DsWindowSize.medium;
    return DsWindowSize.compact;
  }

  /// Resolves the window size class for the current [MediaQuery] width.
  static DsWindowSize of(BuildContext context) {
    return windowSizeFor(MediaQuery.sizeOf(context).width);
  }
}
