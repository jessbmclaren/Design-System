/// Design System spacing tokens.
///
/// The base scale is a 4dp grid ([xxs] through [xxl]); the component
/// paddings below it mirror the published Design System appearance variables.
abstract final class DsSpacing {
  // Base 4dp scale.

  /// 2dp.
  static const double xxs = 2;

  /// 4dp.
  static const double xs = 4;

  /// 8dp.
  static const double sm = 8;

  /// 12dp.
  static const double md = 12;

  /// 16dp.
  static const double lg = 16;

  /// 24dp.
  static const double xl = 24;

  /// 32dp.
  static const double xxl = 32;

  // Component paddings.

  /// The horizontal padding for buttons.
  ///
  /// No longer read by the token layer: the button paints the full inset
  /// held in [DsTokens.buttonPaddingX], so this value is stale.
  @Deprecated('Set DsTokens.buttonPaddingX instead')
  static const double buttonPaddingX = 4;

  /// The vertical padding for buttons.
  ///
  /// No longer read by the token layer: the button paints the full inset
  /// held in [DsTokens.buttonPaddingY], so this value is stale.
  @Deprecated('Set DsTokens.buttonPaddingY instead')
  static const double buttonPaddingY = 4;

  /// The horizontal padding for input fields in forms.
  static const double inputFieldPaddingX = 8;

  /// The vertical padding for input fields in forms.
  static const double inputFieldPaddingY = 4;

  /// The horizontal padding for badges.
  static const double badgePaddingX = 6;

  /// The vertical padding for badges.
  static const double badgePaddingY = 2;

  /// The vertical padding for table rows.
  static const double tableRowPaddingY = 8;
}
