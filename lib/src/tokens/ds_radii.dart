import 'package:flutter/widgets.dart';

/// Design System border radius tokens.
abstract final class DsRadii {
  /// The border radius used for buttons.
  static const double button = 4;

  /// The border radius used for form elements.
  static const double form = 6;

  /// The border radius used for badges.
  static const double badge = 4;

  /// The border radius used for overlays.
  static const double overlay = 8;

  /// [button] as a [BorderRadius].
  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(button));

  /// [form] as a [BorderRadius].
  static const BorderRadius formRadius =
      BorderRadius.all(Radius.circular(form));

  /// [badge] as a [BorderRadius].
  static const BorderRadius badgeRadius =
      BorderRadius.all(Radius.circular(badge));

  /// [overlay] as a [BorderRadius].
  static const BorderRadius overlayRadius =
      BorderRadius.all(Radius.circular(overlay));
}
