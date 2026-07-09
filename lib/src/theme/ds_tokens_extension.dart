import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../tokens/ds_colors.dart';
import '../tokens/ds_radii.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

/// How the system presents an overlay such as a [DsFocusView].
enum DsOverlayStyle {
  /// A centered dialog (modal).
  dialog,

  /// A drawer that slides in from the edge — often better on small screens.
  drawer,
}

/// The Design System appearance variables, exposed as a [ThemeExtension].
///
/// Field names mirror the published Design System appearance variables one-to-one
/// (`buttonPrimaryColorBackground`, `badgeSuccessColorText`,
/// `headingXlFontSize`, …) so that a value in the documentation always has
/// an identically named counterpart in code.
///
/// Read the tokens for the active theme with:
///
/// ```dart
/// final tokens = DsTokens.of(context);
/// ```
@immutable
class DsTokens extends ThemeExtension<DsTokens> {
  const DsTokens({
    // Global — the high-level knobs the rest of the system derives from.
    required this.fontFamily,
    required this.fontSizeBase,
    required this.spacingUnit,
    required this.borderRadius,
    required this.colorPrimary,
    required this.colorBackground,
    required this.colorDanger,
    // Typography ramp
    required this.headingXl,
    required this.headingLg,
    required this.headingMd,
    required this.headingSm,
    required this.headingXs,
    required this.bodyMd,
    required this.bodySm,
    required this.labelMd,
    required this.labelSm,
    // Text
    required this.colorText,
    required this.colorSecondaryText,
    required this.colorBorder,
    // Actions
    required this.actionPrimaryColorText,
    required this.actionPrimaryTextDecorationLine,
    required this.actionPrimaryTextDecorationColor,
    required this.actionPrimaryTextDecorationStyle,
    required this.actionPrimaryTextDecorationThickness,
    required this.actionPrimaryTextTransform,
    required this.actionSecondaryColorText,
    required this.actionSecondaryTextDecorationLine,
    required this.actionSecondaryTextDecorationColor,
    required this.actionSecondaryTextDecorationStyle,
    required this.actionSecondaryTextDecorationThickness,
    required this.actionSecondaryTextTransform,
    // Buttons
    required this.buttonPrimaryColorBackground,
    required this.buttonPrimaryColorBorder,
    required this.buttonPrimaryColorText,
    required this.buttonSecondaryColorBackground,
    required this.buttonSecondaryColorBorder,
    required this.buttonSecondaryColorText,
    required this.buttonDangerColorBackground,
    required this.buttonDangerColorBorder,
    required this.buttonDangerColorText,
    required this.buttonPaddingX,
    required this.buttonPaddingY,
    required this.buttonBorderRadius,
    required this.buttonLabelFontSize,
    required this.buttonLabelFontWeight,
    required this.buttonLabelTextTransform,
    // Badges
    required this.badgeNeutralColorBackground,
    required this.badgeNeutralColorText,
    required this.badgeNeutralColorBorder,
    required this.badgeSuccessColorBackground,
    required this.badgeSuccessColorText,
    required this.badgeSuccessColorBorder,
    required this.badgeWarningColorBackground,
    required this.badgeWarningColorText,
    required this.badgeWarningColorBorder,
    required this.badgeDangerColorBackground,
    required this.badgeDangerColorText,
    required this.badgeDangerColorBorder,
    required this.badgePaddingX,
    required this.badgePaddingY,
    required this.badgeBorderRadius,
    required this.badgeLabelFontSize,
    required this.badgeLabelFontWeight,
    required this.badgeLabelTextTransform,
    // Forms & surfaces
    required this.offsetBackgroundColor,
    required this.formBackgroundColor,
    required this.formHighlightColorBorder,
    required this.formAccentColor,
    required this.formPlaceholderTextColor,
    required this.formBorderRadius,
    required this.inputFieldPaddingX,
    required this.inputFieldPaddingY,
    // Table
    required this.tableRowPaddingY,
    // Overlays
    required this.overlayBorderRadius,
    required this.overlayBackdropColor,
    required this.overlays,
  });

  /// The default Design System light appearance.
  factory DsTokens.light() {
    return const DsTokens(
      fontFamily: DsTypography.fontFamily,
      fontSizeBase: 16,
      spacingUnit: DsSpacing.sm,
      borderRadius: DsRadii.form,
      colorPrimary: DsColors.actionPrimary,
      colorBackground: DsColors.formBackground,
      colorDanger: DsColors.buttonDangerBackground,
      headingXl: DsTypography.headingXl,
      headingLg: DsTypography.headingLg,
      headingMd: DsTypography.headingMd,
      headingSm: DsTypography.headingSm,
      headingXs: DsTypography.headingXs,
      bodyMd: DsTypography.bodyMd,
      bodySm: DsTypography.bodySm,
      labelMd: DsTypography.labelMd,
      labelSm: DsTypography.labelSm,
      colorText: DsColors.textPrimary,
      colorSecondaryText: DsColors.textSecondary,
      colorBorder: DsColors.border,
      actionPrimaryColorText: DsColors.actionPrimary,
      actionPrimaryTextDecorationLine: TextDecoration.underline,
      actionPrimaryTextDecorationColor: DsColors.actionTextDecoration,
      actionPrimaryTextDecorationStyle: TextDecorationStyle.solid,
      actionPrimaryTextDecorationThickness: 1,
      actionPrimaryTextTransform: DsTextTransform.none,
      actionSecondaryColorText: DsColors.actionSecondary,
      actionSecondaryTextDecorationLine: TextDecoration.underline,
      actionSecondaryTextDecorationColor: DsColors.actionTextDecoration,
      actionSecondaryTextDecorationStyle: TextDecorationStyle.solid,
      actionSecondaryTextDecorationThickness: 1,
      actionSecondaryTextTransform: DsTextTransform.none,
      buttonPrimaryColorBackground: DsColors.buttonPrimaryBackground,
      buttonPrimaryColorBorder: DsColors.buttonPrimaryBorder,
      buttonPrimaryColorText: DsColors.buttonPrimaryText,
      buttonSecondaryColorBackground: DsColors.buttonSecondaryBackground,
      buttonSecondaryColorBorder: DsColors.buttonSecondaryBorder,
      buttonSecondaryColorText: DsColors.buttonSecondaryText,
      buttonDangerColorBackground: DsColors.buttonDangerBackground,
      buttonDangerColorBorder: DsColors.buttonDangerBorder,
      buttonDangerColorText: DsColors.buttonDangerText,
      buttonPaddingX: DsSpacing.buttonPaddingX,
      buttonPaddingY: DsSpacing.buttonPaddingY,
      buttonBorderRadius: DsRadii.button,
      buttonLabelFontSize: 16,
      buttonLabelFontWeight: FontWeight.w400,
      buttonLabelTextTransform: DsTextTransform.none,
      badgeNeutralColorBackground: DsColors.badgeNeutralBackground,
      badgeNeutralColorText: DsColors.badgeNeutralText,
      badgeNeutralColorBorder: DsColors.badgeNeutralBorder,
      badgeSuccessColorBackground: DsColors.badgeSuccessBackground,
      badgeSuccessColorText: DsColors.badgeSuccessText,
      badgeSuccessColorBorder: DsColors.badgeSuccessBorder,
      badgeWarningColorBackground: DsColors.badgeWarningBackground,
      badgeWarningColorText: DsColors.badgeWarningText,
      badgeWarningColorBorder: DsColors.badgeWarningBorder,
      badgeDangerColorBackground: DsColors.badgeDangerBackground,
      badgeDangerColorText: DsColors.badgeDangerText,
      badgeDangerColorBorder: DsColors.badgeDangerBorder,
      badgePaddingX: DsSpacing.badgePaddingX,
      badgePaddingY: DsSpacing.badgePaddingY,
      badgeBorderRadius: DsRadii.badge,
      badgeLabelFontSize: 14,
      badgeLabelFontWeight: FontWeight.w400,
      badgeLabelTextTransform: DsTextTransform.none,
      offsetBackgroundColor: DsColors.offsetBackground,
      formBackgroundColor: DsColors.formBackground,
      formHighlightColorBorder: DsColors.formHighlightBorder,
      formAccentColor: DsColors.formAccent,
      formPlaceholderTextColor: DsColors.formPlaceholderText,
      formBorderRadius: DsRadii.form,
      inputFieldPaddingX: DsSpacing.inputFieldPaddingX,
      inputFieldPaddingY: DsSpacing.inputFieldPaddingY,
      tableRowPaddingY: DsSpacing.tableRowPaddingY,
      overlayBorderRadius: DsRadii.overlay,
      overlayBackdropColor: DsColors.overlayBackdrop,
      overlays: DsOverlayStyle.dialog,
    );
  }

  /// The Design System dark appearance, derived from the light tokens.
  factory DsTokens.dark() {
    return DsTokens.light().copyWith(
      colorPrimary: const Color(0xFF2388DB),
      colorBackground: const Color(0xFF121317),
      colorText: const Color(0xFFF3F4F6),
      colorSecondaryText: const Color(0xFF9CA3AF),
      colorBorder: const Color(0xFF3F4147),
      actionPrimaryColorText: const Color(0xFF58A6F0),
      actionPrimaryTextDecorationColor: const Color(0xFF58A6F0),
      actionSecondaryColorText: const Color(0xFFC9CDD3),
      actionSecondaryTextDecorationColor: const Color(0xFF58A6F0),
      // AA-safe with white label text (contrast ~5:1); the lighter #2388DB
      // is kept for scheme accents/links only.
      buttonPrimaryColorBackground: const Color(0xFF0B6BC7),
      buttonPrimaryColorBorder: const Color(0xFF0B6BC7),
      buttonSecondaryColorBackground: const Color(0xFF2A2C33),
      buttonSecondaryColorBorder: const Color(0xFF2A2C33),
      buttonSecondaryColorText: const Color(0xFFE5E7EB),
      badgeNeutralColorBackground: const Color(0xFF2C3234),
      badgeNeutralColorText: const Color(0xFFB4BCC8),
      badgeNeutralColorBorder: const Color(0xFF454E50),
      badgeSuccessColorBackground: const Color(0xFF15330A),
      badgeSuccessColorText: const Color(0xFF7FD860),
      badgeSuccessColorBorder: const Color(0xFF285317),
      badgeWarningColorBackground: const Color(0xFF3A2E07),
      badgeWarningColorText: const Color(0xFFF0B429),
      badgeWarningColorBorder: const Color(0xFF5C4A10),
      badgeDangerColorBackground: const Color(0xFF3B0F22),
      badgeDangerColorText: const Color(0xFFF06A9B),
      badgeDangerColorBorder: const Color(0xFF5C1A37),
      offsetBackgroundColor: const Color(0xFF1E2025),
      formBackgroundColor: const Color(0xFF17181C),
      formHighlightColorBorder: const Color(0xFF4B4E56),
      formAccentColor: const Color(0xFF2388DB),
      formPlaceholderTextColor: const Color(0xFF6B7280),
      overlayBackdropColor: const Color(0x99000000),
    );
  }

  /// The [DsTokens] of the closest [Theme] ancestor.
  static DsTokens of(BuildContext context) {
    final tokens = Theme.of(context).extension<DsTokens>();
    assert(
      tokens != null,
      'DsTokens is missing from the theme. Build your ThemeData with '
      'DsTheme.light() or DsTheme.dark().',
    );
    return tokens!;
  }

  // Global ---------------------------------------------------------------
  //
  // The high-level knobs most brands change first. They seed the theme and
  // provide sensible defaults the rest of the system derives from.

  /// The font family used across every component.
  final String fontFamily;

  /// The base font size, in logical pixels, that body text derives from.
  final double fontSizeBase;

  /// The base spacing unit, in logical pixels, that layout spacing derives
  /// from.
  final double spacingUnit;

  /// The general border radius used as the default for components.
  final double borderRadius;

  /// The primary brand colour used for primary actions and accents.
  final Color colorPrimary;

  /// The background colour for components, including overlays and surfaces.
  final Color colorBackground;

  /// The colour used to indicate errors or destructive actions.
  final Color colorDanger;

  // Typography ramp ------------------------------------------------------
  //
  // Each level is a [DsTypeToken] bundling its font size, weight, line
  // height and text transform. Override a whole level to re-scale the
  // system's typography for your brand; the theme's [TextTheme] is built
  // from these tokens.

  /// Extra large heading typography.
  final DsTypeToken headingXl;

  /// Large heading typography.
  final DsTypeToken headingLg;

  /// Medium heading typography.
  final DsTypeToken headingMd;

  /// Small heading typography.
  final DsTypeToken headingSm;

  /// Extra small heading typography.
  final DsTypeToken headingXs;

  /// Medium body typography.
  final DsTypeToken bodyMd;

  /// Small body typography.
  final DsTypeToken bodySm;

  /// Medium label typography.
  final DsTypeToken labelMd;

  /// Small label typography.
  final DsTypeToken labelSm;

  // Text ----------------------------------------------------------------

  /// The colour used for primary text.
  final Color colorText;

  /// The colour used for secondary text.
  final Color colorSecondaryText;

  /// The colour used for borders throughout components.
  final Color colorBorder;

  // Actions -------------------------------------------------------------

  /// The colour used for primary actions and links.
  final Color actionPrimaryColorText;

  /// The line type used for text decoration of primary actions and links.
  final TextDecoration actionPrimaryTextDecorationLine;

  /// The colour used for text decoration of primary actions and links.
  final Color actionPrimaryTextDecorationColor;

  /// The style of text decoration of primary actions and links.
  final TextDecorationStyle actionPrimaryTextDecorationStyle;

  /// The thickness of text decoration of primary actions and links.
  final double actionPrimaryTextDecorationThickness;

  /// The text transform for primary actions and links.
  final DsTextTransform actionPrimaryTextTransform;

  /// The colour used for secondary actions and links.
  final Color actionSecondaryColorText;

  /// The line type used for text decoration of secondary actions and links.
  final TextDecoration actionSecondaryTextDecorationLine;

  /// The colour used for text decoration of secondary actions and links.
  final Color actionSecondaryTextDecorationColor;

  /// The style of text decoration of secondary actions and links.
  final TextDecorationStyle actionSecondaryTextDecorationStyle;

  /// The thickness of text decoration of secondary actions and links.
  final double actionSecondaryTextDecorationThickness;

  /// The text transform for secondary actions and links.
  final DsTextTransform actionSecondaryTextTransform;

  // Buttons -------------------------------------------------------------

  /// The colour used as a background for primary buttons.
  final Color buttonPrimaryColorBackground;

  /// The border colour used for primary buttons.
  final Color buttonPrimaryColorBorder;

  /// The text colour used for primary buttons.
  final Color buttonPrimaryColorText;

  /// The colour used as a background for secondary buttons.
  final Color buttonSecondaryColorBackground;

  /// The colour used as a border for secondary buttons.
  final Color buttonSecondaryColorBorder;

  /// The text colour used for secondary buttons.
  final Color buttonSecondaryColorText;

  /// The background colour for danger buttons that indicate destructive
  /// actions.
  final Color buttonDangerColorBackground;

  /// The border colour for danger buttons that indicate destructive actions.
  final Color buttonDangerColorBorder;

  /// The text colour for danger buttons that indicate destructive actions.
  final Color buttonDangerColorText;

  /// The horizontal padding for buttons.
  final double buttonPaddingX;

  /// The vertical padding for buttons.
  final double buttonPaddingY;

  /// The border radius used for buttons.
  final double buttonBorderRadius;

  /// The font size for button label typography.
  final double buttonLabelFontSize;

  /// The font weight for button label typography.
  final FontWeight buttonLabelFontWeight;

  /// The text transform for button label typography.
  final DsTextTransform buttonLabelTextTransform;

  // Badges --------------------------------------------------------------

  /// The background colour used to represent neutral state in status badges.
  final Color badgeNeutralColorBackground;

  /// The text colour used to represent neutral state in status badges.
  final Color badgeNeutralColorText;

  /// The border colour used to represent neutral state in status badges.
  final Color badgeNeutralColorBorder;

  /// The background colour used to reinforce a successful outcome in status
  /// badges.
  final Color badgeSuccessColorBackground;

  /// The text colour used to reinforce a successful outcome in status badges.
  final Color badgeSuccessColorText;

  /// The border colour used to reinforce a successful outcome in status
  /// badges.
  final Color badgeSuccessColorBorder;

  /// The background colour used in status badges that highlight things that
  /// might require action.
  final Color badgeWarningColorBackground;

  /// The text colour used in status badges that highlight things that might
  /// require action.
  final Color badgeWarningColorText;

  /// The border colour used in status badges that highlight things that
  /// might require action.
  final Color badgeWarningColorBorder;

  /// The background colour used in status badges for critical situations and
  /// failed outcomes.
  final Color badgeDangerColorBackground;

  /// The text colour used in status badges for critical situations and
  /// failed outcomes.
  final Color badgeDangerColorText;

  /// The border colour used in status badges for critical situations and
  /// failed outcomes.
  final Color badgeDangerColorBorder;

  /// The horizontal padding for badges.
  final double badgePaddingX;

  /// The vertical padding for badges.
  final double badgePaddingY;

  /// The border radius used for badges.
  final double badgeBorderRadius;

  /// The font size for badge label typography.
  final double badgeLabelFontSize;

  /// The font weight for badge label typography.
  final FontWeight badgeLabelFontWeight;

  /// The text transform for badge label typography.
  final DsTextTransform badgeLabelTextTransform;

  // Forms & surfaces ------------------------------------------------------

  /// The background colour used when highlighting information, like the
  /// selected row on a table.
  final Color offsetBackgroundColor;

  /// The background colour used for form items.
  final Color formBackgroundColor;

  /// The colour used to highlight form items when focused.
  final Color formHighlightColorBorder;

  /// The colour used to fill form items such as tickboxes, radio buttons and
  /// switches.
  final Color formAccentColor;

  /// The colour for placeholder text in form items.
  final Color formPlaceholderTextColor;

  /// The border radius used for form elements.
  final double formBorderRadius;

  /// The horizontal padding for input fields in forms.
  final double inputFieldPaddingX;

  /// The vertical padding for input fields in forms.
  final double inputFieldPaddingY;

  // Table ---------------------------------------------------------------

  /// The vertical padding for table rows.
  final double tableRowPaddingY;

  // Overlays ------------------------------------------------------------

  /// The border radius used for overlays.
  final double overlayBorderRadius;

  /// The backdrop colour shown behind an open overlay.
  final Color overlayBackdropColor;

  /// Whether overlays such as [DsFocusView] present as a dialog or a drawer.
  final DsOverlayStyle overlays;

  @override
  DsTokens copyWith({
    String? fontFamily,
    double? fontSizeBase,
    double? spacingUnit,
    double? borderRadius,
    Color? colorPrimary,
    Color? colorBackground,
    Color? colorDanger,
    DsTypeToken? headingXl,
    DsTypeToken? headingLg,
    DsTypeToken? headingMd,
    DsTypeToken? headingSm,
    DsTypeToken? headingXs,
    DsTypeToken? bodyMd,
    DsTypeToken? bodySm,
    DsTypeToken? labelMd,
    DsTypeToken? labelSm,
    Color? colorText,
    Color? colorSecondaryText,
    Color? colorBorder,
    Color? actionPrimaryColorText,
    TextDecoration? actionPrimaryTextDecorationLine,
    Color? actionPrimaryTextDecorationColor,
    TextDecorationStyle? actionPrimaryTextDecorationStyle,
    double? actionPrimaryTextDecorationThickness,
    DsTextTransform? actionPrimaryTextTransform,
    Color? actionSecondaryColorText,
    TextDecoration? actionSecondaryTextDecorationLine,
    Color? actionSecondaryTextDecorationColor,
    TextDecorationStyle? actionSecondaryTextDecorationStyle,
    double? actionSecondaryTextDecorationThickness,
    DsTextTransform? actionSecondaryTextTransform,
    Color? buttonPrimaryColorBackground,
    Color? buttonPrimaryColorBorder,
    Color? buttonPrimaryColorText,
    Color? buttonSecondaryColorBackground,
    Color? buttonSecondaryColorBorder,
    Color? buttonSecondaryColorText,
    Color? buttonDangerColorBackground,
    Color? buttonDangerColorBorder,
    Color? buttonDangerColorText,
    double? buttonPaddingX,
    double? buttonPaddingY,
    double? buttonBorderRadius,
    double? buttonLabelFontSize,
    FontWeight? buttonLabelFontWeight,
    DsTextTransform? buttonLabelTextTransform,
    Color? badgeNeutralColorBackground,
    Color? badgeNeutralColorText,
    Color? badgeNeutralColorBorder,
    Color? badgeSuccessColorBackground,
    Color? badgeSuccessColorText,
    Color? badgeSuccessColorBorder,
    Color? badgeWarningColorBackground,
    Color? badgeWarningColorText,
    Color? badgeWarningColorBorder,
    Color? badgeDangerColorBackground,
    Color? badgeDangerColorText,
    Color? badgeDangerColorBorder,
    double? badgePaddingX,
    double? badgePaddingY,
    double? badgeBorderRadius,
    double? badgeLabelFontSize,
    FontWeight? badgeLabelFontWeight,
    DsTextTransform? badgeLabelTextTransform,
    Color? offsetBackgroundColor,
    Color? formBackgroundColor,
    Color? formHighlightColorBorder,
    Color? formAccentColor,
    Color? formPlaceholderTextColor,
    double? formBorderRadius,
    double? inputFieldPaddingX,
    double? inputFieldPaddingY,
    double? tableRowPaddingY,
    double? overlayBorderRadius,
    Color? overlayBackdropColor,
    DsOverlayStyle? overlays,
  }) {
    return DsTokens(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSizeBase: fontSizeBase ?? this.fontSizeBase,
      spacingUnit: spacingUnit ?? this.spacingUnit,
      borderRadius: borderRadius ?? this.borderRadius,
      colorPrimary: colorPrimary ?? this.colorPrimary,
      colorBackground: colorBackground ?? this.colorBackground,
      colorDanger: colorDanger ?? this.colorDanger,
      headingXl: headingXl ?? this.headingXl,
      headingLg: headingLg ?? this.headingLg,
      headingMd: headingMd ?? this.headingMd,
      headingSm: headingSm ?? this.headingSm,
      headingXs: headingXs ?? this.headingXs,
      bodyMd: bodyMd ?? this.bodyMd,
      bodySm: bodySm ?? this.bodySm,
      labelMd: labelMd ?? this.labelMd,
      labelSm: labelSm ?? this.labelSm,
      colorText: colorText ?? this.colorText,
      colorSecondaryText: colorSecondaryText ?? this.colorSecondaryText,
      colorBorder: colorBorder ?? this.colorBorder,
      actionPrimaryColorText:
          actionPrimaryColorText ?? this.actionPrimaryColorText,
      actionPrimaryTextDecorationLine: actionPrimaryTextDecorationLine ??
          this.actionPrimaryTextDecorationLine,
      actionPrimaryTextDecorationColor: actionPrimaryTextDecorationColor ??
          this.actionPrimaryTextDecorationColor,
      actionPrimaryTextDecorationStyle: actionPrimaryTextDecorationStyle ??
          this.actionPrimaryTextDecorationStyle,
      actionPrimaryTextDecorationThickness:
          actionPrimaryTextDecorationThickness ??
              this.actionPrimaryTextDecorationThickness,
      actionPrimaryTextTransform:
          actionPrimaryTextTransform ?? this.actionPrimaryTextTransform,
      actionSecondaryColorText:
          actionSecondaryColorText ?? this.actionSecondaryColorText,
      actionSecondaryTextDecorationLine: actionSecondaryTextDecorationLine ??
          this.actionSecondaryTextDecorationLine,
      actionSecondaryTextDecorationColor: actionSecondaryTextDecorationColor ??
          this.actionSecondaryTextDecorationColor,
      actionSecondaryTextDecorationStyle: actionSecondaryTextDecorationStyle ??
          this.actionSecondaryTextDecorationStyle,
      actionSecondaryTextDecorationThickness:
          actionSecondaryTextDecorationThickness ??
              this.actionSecondaryTextDecorationThickness,
      actionSecondaryTextTransform:
          actionSecondaryTextTransform ?? this.actionSecondaryTextTransform,
      buttonPrimaryColorBackground:
          buttonPrimaryColorBackground ?? this.buttonPrimaryColorBackground,
      buttonPrimaryColorBorder:
          buttonPrimaryColorBorder ?? this.buttonPrimaryColorBorder,
      buttonPrimaryColorText:
          buttonPrimaryColorText ?? this.buttonPrimaryColorText,
      buttonSecondaryColorBackground: buttonSecondaryColorBackground ??
          this.buttonSecondaryColorBackground,
      buttonSecondaryColorBorder:
          buttonSecondaryColorBorder ?? this.buttonSecondaryColorBorder,
      buttonSecondaryColorText:
          buttonSecondaryColorText ?? this.buttonSecondaryColorText,
      buttonDangerColorBackground:
          buttonDangerColorBackground ?? this.buttonDangerColorBackground,
      buttonDangerColorBorder:
          buttonDangerColorBorder ?? this.buttonDangerColorBorder,
      buttonDangerColorText:
          buttonDangerColorText ?? this.buttonDangerColorText,
      buttonPaddingX: buttonPaddingX ?? this.buttonPaddingX,
      buttonPaddingY: buttonPaddingY ?? this.buttonPaddingY,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonLabelFontSize: buttonLabelFontSize ?? this.buttonLabelFontSize,
      buttonLabelFontWeight:
          buttonLabelFontWeight ?? this.buttonLabelFontWeight,
      buttonLabelTextTransform:
          buttonLabelTextTransform ?? this.buttonLabelTextTransform,
      badgeNeutralColorBackground:
          badgeNeutralColorBackground ?? this.badgeNeutralColorBackground,
      badgeNeutralColorText:
          badgeNeutralColorText ?? this.badgeNeutralColorText,
      badgeNeutralColorBorder:
          badgeNeutralColorBorder ?? this.badgeNeutralColorBorder,
      badgeSuccessColorBackground:
          badgeSuccessColorBackground ?? this.badgeSuccessColorBackground,
      badgeSuccessColorText:
          badgeSuccessColorText ?? this.badgeSuccessColorText,
      badgeSuccessColorBorder:
          badgeSuccessColorBorder ?? this.badgeSuccessColorBorder,
      badgeWarningColorBackground:
          badgeWarningColorBackground ?? this.badgeWarningColorBackground,
      badgeWarningColorText:
          badgeWarningColorText ?? this.badgeWarningColorText,
      badgeWarningColorBorder:
          badgeWarningColorBorder ?? this.badgeWarningColorBorder,
      badgeDangerColorBackground:
          badgeDangerColorBackground ?? this.badgeDangerColorBackground,
      badgeDangerColorText: badgeDangerColorText ?? this.badgeDangerColorText,
      badgeDangerColorBorder:
          badgeDangerColorBorder ?? this.badgeDangerColorBorder,
      badgePaddingX: badgePaddingX ?? this.badgePaddingX,
      badgePaddingY: badgePaddingY ?? this.badgePaddingY,
      badgeBorderRadius: badgeBorderRadius ?? this.badgeBorderRadius,
      badgeLabelFontSize: badgeLabelFontSize ?? this.badgeLabelFontSize,
      badgeLabelFontWeight: badgeLabelFontWeight ?? this.badgeLabelFontWeight,
      badgeLabelTextTransform:
          badgeLabelTextTransform ?? this.badgeLabelTextTransform,
      offsetBackgroundColor:
          offsetBackgroundColor ?? this.offsetBackgroundColor,
      formBackgroundColor: formBackgroundColor ?? this.formBackgroundColor,
      formHighlightColorBorder:
          formHighlightColorBorder ?? this.formHighlightColorBorder,
      formAccentColor: formAccentColor ?? this.formAccentColor,
      formPlaceholderTextColor:
          formPlaceholderTextColor ?? this.formPlaceholderTextColor,
      formBorderRadius: formBorderRadius ?? this.formBorderRadius,
      inputFieldPaddingX: inputFieldPaddingX ?? this.inputFieldPaddingX,
      inputFieldPaddingY: inputFieldPaddingY ?? this.inputFieldPaddingY,
      tableRowPaddingY: tableRowPaddingY ?? this.tableRowPaddingY,
      overlayBorderRadius: overlayBorderRadius ?? this.overlayBorderRadius,
      overlayBackdropColor: overlayBackdropColor ?? this.overlayBackdropColor,
      overlays: overlays ?? this.overlays,
    );
  }

  @override
  DsTokens lerp(DsTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    double d(double a, double b) => lerpDouble(a, b, t)!;
    return DsTokens(
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      fontSizeBase: d(fontSizeBase, other.fontSizeBase),
      spacingUnit: d(spacingUnit, other.spacingUnit),
      borderRadius: d(borderRadius, other.borderRadius),
      colorPrimary: c(colorPrimary, other.colorPrimary),
      colorBackground: c(colorBackground, other.colorBackground),
      colorDanger: c(colorDanger, other.colorDanger),
      headingXl: t < 0.5 ? headingXl : other.headingXl,
      headingLg: t < 0.5 ? headingLg : other.headingLg,
      headingMd: t < 0.5 ? headingMd : other.headingMd,
      headingSm: t < 0.5 ? headingSm : other.headingSm,
      headingXs: t < 0.5 ? headingXs : other.headingXs,
      bodyMd: t < 0.5 ? bodyMd : other.bodyMd,
      bodySm: t < 0.5 ? bodySm : other.bodySm,
      labelMd: t < 0.5 ? labelMd : other.labelMd,
      labelSm: t < 0.5 ? labelSm : other.labelSm,
      colorText: c(colorText, other.colorText),
      colorSecondaryText: c(colorSecondaryText, other.colorSecondaryText),
      colorBorder: c(colorBorder, other.colorBorder),
      actionPrimaryColorText:
          c(actionPrimaryColorText, other.actionPrimaryColorText),
      actionPrimaryTextDecorationLine: t < 0.5
          ? actionPrimaryTextDecorationLine
          : other.actionPrimaryTextDecorationLine,
      actionPrimaryTextDecorationColor: c(actionPrimaryTextDecorationColor,
          other.actionPrimaryTextDecorationColor),
      actionPrimaryTextDecorationStyle: t < 0.5
          ? actionPrimaryTextDecorationStyle
          : other.actionPrimaryTextDecorationStyle,
      actionPrimaryTextDecorationThickness: d(
          actionPrimaryTextDecorationThickness,
          other.actionPrimaryTextDecorationThickness),
      actionPrimaryTextTransform: t < 0.5
          ? actionPrimaryTextTransform
          : other.actionPrimaryTextTransform,
      actionSecondaryColorText:
          c(actionSecondaryColorText, other.actionSecondaryColorText),
      actionSecondaryTextDecorationLine: t < 0.5
          ? actionSecondaryTextDecorationLine
          : other.actionSecondaryTextDecorationLine,
      actionSecondaryTextDecorationColor: c(actionSecondaryTextDecorationColor,
          other.actionSecondaryTextDecorationColor),
      actionSecondaryTextDecorationStyle: t < 0.5
          ? actionSecondaryTextDecorationStyle
          : other.actionSecondaryTextDecorationStyle,
      actionSecondaryTextDecorationThickness: d(
          actionSecondaryTextDecorationThickness,
          other.actionSecondaryTextDecorationThickness),
      actionSecondaryTextTransform: t < 0.5
          ? actionSecondaryTextTransform
          : other.actionSecondaryTextTransform,
      buttonPrimaryColorBackground:
          c(buttonPrimaryColorBackground, other.buttonPrimaryColorBackground),
      buttonPrimaryColorBorder:
          c(buttonPrimaryColorBorder, other.buttonPrimaryColorBorder),
      buttonPrimaryColorText:
          c(buttonPrimaryColorText, other.buttonPrimaryColorText),
      buttonSecondaryColorBackground: c(buttonSecondaryColorBackground,
          other.buttonSecondaryColorBackground),
      buttonSecondaryColorBorder:
          c(buttonSecondaryColorBorder, other.buttonSecondaryColorBorder),
      buttonSecondaryColorText:
          c(buttonSecondaryColorText, other.buttonSecondaryColorText),
      buttonDangerColorBackground:
          c(buttonDangerColorBackground, other.buttonDangerColorBackground),
      buttonDangerColorBorder:
          c(buttonDangerColorBorder, other.buttonDangerColorBorder),
      buttonDangerColorText:
          c(buttonDangerColorText, other.buttonDangerColorText),
      buttonPaddingX: d(buttonPaddingX, other.buttonPaddingX),
      buttonPaddingY: d(buttonPaddingY, other.buttonPaddingY),
      buttonBorderRadius: d(buttonBorderRadius, other.buttonBorderRadius),
      buttonLabelFontSize: d(buttonLabelFontSize, other.buttonLabelFontSize),
      buttonLabelFontWeight:
          FontWeight.lerp(buttonLabelFontWeight, other.buttonLabelFontWeight, t)!,
      buttonLabelTextTransform:
          t < 0.5 ? buttonLabelTextTransform : other.buttonLabelTextTransform,
      badgeNeutralColorBackground:
          c(badgeNeutralColorBackground, other.badgeNeutralColorBackground),
      badgeNeutralColorText:
          c(badgeNeutralColorText, other.badgeNeutralColorText),
      badgeNeutralColorBorder:
          c(badgeNeutralColorBorder, other.badgeNeutralColorBorder),
      badgeSuccessColorBackground:
          c(badgeSuccessColorBackground, other.badgeSuccessColorBackground),
      badgeSuccessColorText:
          c(badgeSuccessColorText, other.badgeSuccessColorText),
      badgeSuccessColorBorder:
          c(badgeSuccessColorBorder, other.badgeSuccessColorBorder),
      badgeWarningColorBackground:
          c(badgeWarningColorBackground, other.badgeWarningColorBackground),
      badgeWarningColorText:
          c(badgeWarningColorText, other.badgeWarningColorText),
      badgeWarningColorBorder:
          c(badgeWarningColorBorder, other.badgeWarningColorBorder),
      badgeDangerColorBackground:
          c(badgeDangerColorBackground, other.badgeDangerColorBackground),
      badgeDangerColorText:
          c(badgeDangerColorText, other.badgeDangerColorText),
      badgeDangerColorBorder:
          c(badgeDangerColorBorder, other.badgeDangerColorBorder),
      badgePaddingX: d(badgePaddingX, other.badgePaddingX),
      badgePaddingY: d(badgePaddingY, other.badgePaddingY),
      badgeBorderRadius: d(badgeBorderRadius, other.badgeBorderRadius),
      badgeLabelFontSize: d(badgeLabelFontSize, other.badgeLabelFontSize),
      badgeLabelFontWeight:
          FontWeight.lerp(badgeLabelFontWeight, other.badgeLabelFontWeight, t)!,
      badgeLabelTextTransform:
          t < 0.5 ? badgeLabelTextTransform : other.badgeLabelTextTransform,
      offsetBackgroundColor:
          c(offsetBackgroundColor, other.offsetBackgroundColor),
      formBackgroundColor: c(formBackgroundColor, other.formBackgroundColor),
      formHighlightColorBorder:
          c(formHighlightColorBorder, other.formHighlightColorBorder),
      formAccentColor: c(formAccentColor, other.formAccentColor),
      formPlaceholderTextColor:
          c(formPlaceholderTextColor, other.formPlaceholderTextColor),
      formBorderRadius: d(formBorderRadius, other.formBorderRadius),
      inputFieldPaddingX: d(inputFieldPaddingX, other.inputFieldPaddingX),
      inputFieldPaddingY: d(inputFieldPaddingY, other.inputFieldPaddingY),
      tableRowPaddingY: d(tableRowPaddingY, other.tableRowPaddingY),
      overlayBorderRadius: d(overlayBorderRadius, other.overlayBorderRadius),
      overlayBackdropColor: c(overlayBackdropColor, other.overlayBackdropColor),
      overlays: t < 0.5 ? overlays : other.overlays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DsTokens &&
        runtimeType == other.runtimeType &&
          fontFamily == other.fontFamily &&
          fontSizeBase == other.fontSizeBase &&
          spacingUnit == other.spacingUnit &&
          borderRadius == other.borderRadius &&
          colorPrimary == other.colorPrimary &&
          colorBackground == other.colorBackground &&
          colorDanger == other.colorDanger &&
          headingXl == other.headingXl &&
          headingLg == other.headingLg &&
          headingMd == other.headingMd &&
          headingSm == other.headingSm &&
          headingXs == other.headingXs &&
          bodyMd == other.bodyMd &&
          bodySm == other.bodySm &&
          labelMd == other.labelMd &&
          labelSm == other.labelSm &&
          colorText == other.colorText &&
          colorSecondaryText == other.colorSecondaryText &&
          colorBorder == other.colorBorder &&
          actionPrimaryColorText == other.actionPrimaryColorText &&
          actionPrimaryTextDecorationLine == other.actionPrimaryTextDecorationLine &&
          actionPrimaryTextDecorationColor == other.actionPrimaryTextDecorationColor &&
          actionPrimaryTextDecorationStyle == other.actionPrimaryTextDecorationStyle &&
          actionPrimaryTextDecorationThickness == other.actionPrimaryTextDecorationThickness &&
          actionPrimaryTextTransform == other.actionPrimaryTextTransform &&
          actionSecondaryColorText == other.actionSecondaryColorText &&
          actionSecondaryTextDecorationLine == other.actionSecondaryTextDecorationLine &&
          actionSecondaryTextDecorationColor == other.actionSecondaryTextDecorationColor &&
          actionSecondaryTextDecorationStyle == other.actionSecondaryTextDecorationStyle &&
          actionSecondaryTextDecorationThickness == other.actionSecondaryTextDecorationThickness &&
          actionSecondaryTextTransform == other.actionSecondaryTextTransform &&
          buttonPrimaryColorBackground == other.buttonPrimaryColorBackground &&
          buttonPrimaryColorBorder == other.buttonPrimaryColorBorder &&
          buttonPrimaryColorText == other.buttonPrimaryColorText &&
          buttonSecondaryColorBackground == other.buttonSecondaryColorBackground &&
          buttonSecondaryColorBorder == other.buttonSecondaryColorBorder &&
          buttonSecondaryColorText == other.buttonSecondaryColorText &&
          buttonDangerColorBackground == other.buttonDangerColorBackground &&
          buttonDangerColorBorder == other.buttonDangerColorBorder &&
          buttonDangerColorText == other.buttonDangerColorText &&
          buttonPaddingX == other.buttonPaddingX &&
          buttonPaddingY == other.buttonPaddingY &&
          buttonBorderRadius == other.buttonBorderRadius &&
          buttonLabelFontSize == other.buttonLabelFontSize &&
          buttonLabelFontWeight == other.buttonLabelFontWeight &&
          buttonLabelTextTransform == other.buttonLabelTextTransform &&
          badgeNeutralColorBackground == other.badgeNeutralColorBackground &&
          badgeNeutralColorText == other.badgeNeutralColorText &&
          badgeNeutralColorBorder == other.badgeNeutralColorBorder &&
          badgeSuccessColorBackground == other.badgeSuccessColorBackground &&
          badgeSuccessColorText == other.badgeSuccessColorText &&
          badgeSuccessColorBorder == other.badgeSuccessColorBorder &&
          badgeWarningColorBackground == other.badgeWarningColorBackground &&
          badgeWarningColorText == other.badgeWarningColorText &&
          badgeWarningColorBorder == other.badgeWarningColorBorder &&
          badgeDangerColorBackground == other.badgeDangerColorBackground &&
          badgeDangerColorText == other.badgeDangerColorText &&
          badgeDangerColorBorder == other.badgeDangerColorBorder &&
          badgePaddingX == other.badgePaddingX &&
          badgePaddingY == other.badgePaddingY &&
          badgeBorderRadius == other.badgeBorderRadius &&
          badgeLabelFontSize == other.badgeLabelFontSize &&
          badgeLabelFontWeight == other.badgeLabelFontWeight &&
          badgeLabelTextTransform == other.badgeLabelTextTransform &&
          offsetBackgroundColor == other.offsetBackgroundColor &&
          formBackgroundColor == other.formBackgroundColor &&
          formHighlightColorBorder == other.formHighlightColorBorder &&
          formAccentColor == other.formAccentColor &&
          formPlaceholderTextColor == other.formPlaceholderTextColor &&
          formBorderRadius == other.formBorderRadius &&
          inputFieldPaddingX == other.inputFieldPaddingX &&
          inputFieldPaddingY == other.inputFieldPaddingY &&
          tableRowPaddingY == other.tableRowPaddingY &&
          overlayBorderRadius == other.overlayBorderRadius &&
          overlayBackdropColor == other.overlayBackdropColor &&
          overlays == other.overlays;
  }

  @override
  int get hashCode => Object.hashAll([

        fontFamily,
        fontSizeBase,
        spacingUnit,
        borderRadius,
        colorPrimary,
        colorBackground,
        colorDanger,
        headingXl,
        headingLg,
        headingMd,
        headingSm,
        headingXs,
        bodyMd,
        bodySm,
        labelMd,
        labelSm,
        colorText,
        colorSecondaryText,
        colorBorder,
        actionPrimaryColorText,
        actionPrimaryTextDecorationLine,
        actionPrimaryTextDecorationColor,
        actionPrimaryTextDecorationStyle,
        actionPrimaryTextDecorationThickness,
        actionPrimaryTextTransform,
        actionSecondaryColorText,
        actionSecondaryTextDecorationLine,
        actionSecondaryTextDecorationColor,
        actionSecondaryTextDecorationStyle,
        actionSecondaryTextDecorationThickness,
        actionSecondaryTextTransform,
        buttonPrimaryColorBackground,
        buttonPrimaryColorBorder,
        buttonPrimaryColorText,
        buttonSecondaryColorBackground,
        buttonSecondaryColorBorder,
        buttonSecondaryColorText,
        buttonDangerColorBackground,
        buttonDangerColorBorder,
        buttonDangerColorText,
        buttonPaddingX,
        buttonPaddingY,
        buttonBorderRadius,
        buttonLabelFontSize,
        buttonLabelFontWeight,
        buttonLabelTextTransform,
        badgeNeutralColorBackground,
        badgeNeutralColorText,
        badgeNeutralColorBorder,
        badgeSuccessColorBackground,
        badgeSuccessColorText,
        badgeSuccessColorBorder,
        badgeWarningColorBackground,
        badgeWarningColorText,
        badgeWarningColorBorder,
        badgeDangerColorBackground,
        badgeDangerColorText,
        badgeDangerColorBorder,
        badgePaddingX,
        badgePaddingY,
        badgeBorderRadius,
        badgeLabelFontSize,
        badgeLabelFontWeight,
        badgeLabelTextTransform,
        offsetBackgroundColor,
        formBackgroundColor,
        formHighlightColorBorder,
        formAccentColor,
        formPlaceholderTextColor,
        formBorderRadius,
        inputFieldPaddingX,
        inputFieldPaddingY,
        tableRowPaddingY,
        overlayBorderRadius,
        overlayBackdropColor,
        overlays,
      ]);
}
