import 'dart:ui';

/// The Design System data-visualization palette.
///
/// The categorical order is **fixed** — assign hues by series identity in this
/// order and never cycle them; a 9th series folds into "Other". Both the light
/// and dark ramps were validated for CVD separation, chroma, lightness band and
/// contrast against their surface (do not hand-edit without re-validating).
///
/// Charts also draw magnitude from [sequential] (one hue, light→dark) and
/// polarity from [diverging] (two poles + a neutral midpoint). Status/state is
/// carried by the theme's badge tokens, never by a categorical hue.
abstract final class DsChartPalette {
  /// Fixed categorical order for the light surface.
  static const List<Color> categoricalLight = [
    Color(0xFF2A7DE1), // blue (brand)
    Color(0xFFD1660F), // orange
    Color(0xFF12967E), // teal
    Color(0xFF8250DE), // purple
    Color(0xFFC61F70), // magenta
    Color(0xFF6E8B1E), // olive
  ];

  /// Fixed categorical order for the dark surface (its own steps, not a flip).
  static const List<Color> categoricalDark = [
    Color(0xFF3E8EE8),
    Color(0xFFC56F1E),
    Color(0xFF12876E),
    Color(0xFF8A5FE0),
    Color(0xFFC63C7C),
    Color(0xFF6E8A26),
  ];

  /// The neutral "Other" bucket for series beyond the categorical order.
  static const Color otherLight = Color(0xFF8A94A6);
  static const Color otherDark = Color(0xFF6B7480);

  /// Sequential ramp (magnitude) — a single blue hue, light → dark.
  static const List<Color> sequential = [
    Color(0xFFDCEBFB),
    Color(0xFFAFD1F5),
    Color(0xFF77B0EC),
    Color(0xFF3E8EE8),
    Color(0xFF1D6FD0),
    Color(0xFF0D4E9C),
  ];

  /// Diverging pair (polarity): warm pole, neutral midpoint, cool pole.
  static const Color divergingNegative = Color(0xFFC2255C); // magenta pole
  static const Color divergingNeutral = Color(0xFFECEEF2); // neutral midpoint
  static const Color divergingPositive = Color(0xFF12967E); // teal pole

  /// The categorical list for a [brightness].
  static List<Color> categorical(Brightness brightness) =>
      brightness == Brightness.dark ? categoricalDark : categoricalLight;

  /// The categorical colour for series [index], folding overflow into "Other".
  static Color colorAt(int index, Brightness brightness) {
    final list = categorical(brightness);
    if (index >= 0 && index < list.length) return list[index];
    return brightness == Brightness.dark ? otherDark : otherLight;
  }
}
