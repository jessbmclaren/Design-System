import 'package:flutter/widgets.dart';

/// How a typography token transforms the strings it renders.
///
/// Flutter has no CSS-style `text-transform`, so Design System components apply the
/// transform to the string itself before painting.
enum DsTextTransform {
  /// Render the string as authored.
  none,

  /// Render the string in upper case.
  uppercase,

  /// Render the string in lower case.
  lowercase,

  /// Capitalize the first letter of the string.
  capitalize;

  /// Applies this transform to [input].
  String apply(String input) {
    return switch (this) {
      DsTextTransform.none => input,
      DsTextTransform.uppercase => input.toUpperCase(),
      DsTextTransform.lowercase => input.toLowerCase(),
      DsTextTransform.capitalize => input.isEmpty
          ? input
          : input[0].toUpperCase() + input.substring(1),
    };
  }
}

/// A single Design System typography token: size, weight and an optional text
/// transform.
@immutable
class DsTypeToken {
  const DsTypeToken({
    required this.fontSize,
    required this.fontWeight,
    this.height,
    this.textTransform = DsTextTransform.none,
  });

  /// The font size in logical pixels.
  final double fontSize;

  /// The font weight.
  final FontWeight fontWeight;

  /// The line height multiplier.
  final double? height;

  /// The text transform applied by Design System components when rendering strings
  /// with this token. Defaults to [DsTextTransform.none].
  final DsTextTransform textTransform;

  /// Materializes this token as a [TextStyle].
  ///
  /// The font family is intentionally omitted: it is applied once at the theme
  /// level from `DsTokens.fontFamily` (see [DsTheme]), so overriding that one
  /// token re-fonts every component. Passing [fontFamily] here overrides it for
  /// a single style.
  TextStyle toTextStyle({
    Color? color,
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    );
  }

  /// Returns a copy of this token with the given fields replaced.
  DsTypeToken copyWith({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    DsTextTransform? textTransform,
  }) {
    return DsTypeToken(
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      height: height ?? this.height,
      textTransform: textTransform ?? this.textTransform,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DsTypeToken &&
          runtimeType == other.runtimeType &&
          fontSize == other.fontSize &&
          fontWeight == other.fontWeight &&
          height == other.height &&
          textTransform == other.textTransform;

  @override
  int get hashCode => Object.hash(fontSize, fontWeight, height, textTransform);
}

/// Design System typography tokens.
///
/// The scale is intentionally small: five heading levels, two body sizes,
/// two label sizes, plus dedicated button and badge label tokens.
abstract final class DsTypography {
  /// The Design System brand font family, bundled with the package.
  static const String fontFamily = 'Inter';

  /// The font family as resolved from consuming apps
  /// (`packages/design_system/Inter`).
  static const String packagedFontFamily = 'packages/design_system/Inter';

  // Headings — weight 700.

  /// Extra large heading. 28px / 700.
  static const DsTypeToken headingXl =
      DsTypeToken(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25);

  /// Large heading. 24px / 700.
  static const DsTypeToken headingLg =
      DsTypeToken(fontSize: 24, fontWeight: FontWeight.w700, height: 1.25);

  /// Medium heading. 20px / 700.
  static const DsTypeToken headingMd =
      DsTypeToken(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3);

  /// Small heading. 16px / 700.
  static const DsTypeToken headingSm =
      DsTypeToken(fontSize: 16, fontWeight: FontWeight.w700, height: 1.35);

  /// Extra small heading. 12px / 700.
  static const DsTypeToken headingXs =
      DsTypeToken(fontSize: 12, fontWeight: FontWeight.w700, height: 1.35);

  // Body — weight 400.

  /// Medium body text. 16px / 400.
  static const DsTypeToken bodyMd =
      DsTypeToken(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);

  /// Small body text. 14px / 400.
  static const DsTypeToken bodySm =
      DsTypeToken(fontSize: 14, fontWeight: FontWeight.w400, height: 1.45);

  // Labels — weight 400.

  /// Medium label. 14px / 400.
  static const DsTypeToken labelMd =
      DsTypeToken(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4);

  /// Small label. 12px / 400.
  static const DsTypeToken labelSm =
      DsTypeToken(fontSize: 12, fontWeight: FontWeight.w400, height: 1.35);

  // Component labels.

  /// Button label. 16px / 400.
  static const DsTypeToken buttonLabel =
      DsTypeToken(fontSize: 16, fontWeight: FontWeight.w400, height: 1.2);

  /// Badge label. 14px / 400.
  static const DsTypeToken badgeLabel =
      DsTypeToken(fontSize: 14, fontWeight: FontWeight.w400, height: 1.2);
}
