/// The Design System icon size scale, in logical pixels.
///
/// Prefer these steps over ad-hoc icon sizes so glyphs stay visually aligned
/// with the type ramp and controls across the system.
abstract final class DsIconSize {
  /// 12dp — tiny marker glyphs.
  static const double xxs = 12;

  /// 14dp — inline with small text.
  static const double xs = 14;

  /// 16dp — the default control icon (buttons, inputs, chips).
  static const double sm = 16;

  /// 18dp — list rows and toolbars.
  static const double md = 18;

  /// 20dp — prominent actions and status icons.
  static const double lg = 20;

  /// 24dp — headers and empty-state glyphs.
  static const double xl = 24;
}
