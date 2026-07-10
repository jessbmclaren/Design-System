import 'package:flutter/widgets.dart';

/// The Design System elevation scale.
///
/// A single soft, low-contrast drop that deepens with elevation, with no
/// stacked grey layers. Three steps cover the whole system:
///
///  * [low]: resting raised surfaces (chips, hovers, list cards).
///  * [medium]: floating surfaces (menus, popovers, toasts).
///  * [high]: modal surfaces (dialogs, drawers, takeovers).
///
/// The default scale is a neutral navy ink. Call [tinted] to derive a
/// brand-tinted scale from a colour (e.g. `DsElevation.tinted(tokens.colorPrimary)`),
/// which lets a skin lift its surfaces with its own hue.
abstract final class DsElevation {
  /// No shadow.
  static const List<BoxShadow> none = <BoxShadow>[];

  /// Resting / small raised surfaces.
  static const List<BoxShadow> low = <BoxShadow>[
    BoxShadow(color: Color(0x14101828), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x0F101828), offset: Offset(0, 2), blurRadius: 6),
  ];

  /// Floating surfaces: menus, popovers, toasts.
  static const List<BoxShadow> medium = <BoxShadow>[
    BoxShadow(color: Color(0x1A101828), offset: Offset(0, 6), blurRadius: 16),
  ];

  /// Modal surfaces: dialogs, drawers, takeovers.
  static const List<BoxShadow> high = <BoxShadow>[
    BoxShadow(color: Color(0x24101828), offset: Offset(0, 16), blurRadius: 40),
  ];

  /// A brand-tinted scale derived from [color]. The three steps use the same
  /// geometry as the defaults with the colour applied at increasing opacity.
  static List<BoxShadow> tinted(Color color, {double intensity = 1}) {
    List<BoxShadow> step(double alpha, Offset offset, double blur) => [
          BoxShadow(
            color: color.withValues(alpha: alpha * intensity),
            offset: offset,
            blurRadius: blur,
          ),
        ];
    return [
      ...step(0.10, const Offset(0, 6), 16),
    ];
  }

  /// The shadow list for a semantic [DsElevationLevel].
  static List<BoxShadow> forLevel(DsElevationLevel level) {
    return switch (level) {
      DsElevationLevel.none => none,
      DsElevationLevel.low => low,
      DsElevationLevel.medium => medium,
      DsElevationLevel.high => high,
    };
  }
}

/// A semantic elevation step.
enum DsElevationLevel {
  /// Flush with the surface.
  none,

  /// Resting raised surfaces.
  low,

  /// Floating surfaces.
  medium,

  /// Modal surfaces.
  high,
}
