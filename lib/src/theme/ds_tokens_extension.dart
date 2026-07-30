import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../tokens/ds_chart_palette.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_elevation.dart';
import '../tokens/ds_icon_size.dart';
import '../tokens/ds_radii.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

/// How the system presents an overlay such as a [DsFocusView].
enum DsOverlayStyle {
  /// A centred dialog (modal).
  dialog,

  /// A drawer that slides in from the edge, often better on small screens.
  drawer,
}

/// The Design System appearance variables, exposed as a [ThemeExtension].
///
/// Field names mirror the published Design System appearance variables one-to-one
/// (`buttonPrimaryColorBackground`, `badgeSuccessColorText`,
/// `spacingUnit`, …) so that a value in the documentation always has
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
    // Global: the high-level knobs the rest of the system derives from.
    required this.fontFamily,
    required this.fontSizeBase,
    required this.spacingUnit,
    required this.borderRadius,
    required this.colorPrimary,
    required this.colorBackground,
    required this.colorDanger,
    required this.colorSuccess,
    required this.colorWarning,
    required this.colorOnPrimary,
    required this.colorOnSignal,
    required this.colorAttention,
    required this.radiusXxs,
    required this.radiusControl,
    required this.radiusLg,
    required this.radiusFull,
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
    required this.bodyLg,
    required this.stepTitle,
    required this.display,
    required this.strongLabelFontWeight,
    required this.mediumLabelFontWeight,
    // Icon scale
    required this.iconSizeXxs,
    required this.iconSizeXs,
    required this.iconSizeSm,
    required this.iconSizeMd,
    required this.iconSizeLg,
    required this.iconSizeXl,
    // Text
    required this.colorText,
    required this.colorSecondaryText,
    required this.colorBorder,
    required this.colorBorderSubtle,
    required this.colorIconMuted,
    required this.colorTextDisabled,
    required this.colorInverseSurface,
    required this.colorOnInverse,
    required this.colorDangerOnInverse,
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
    // Interaction states
    required this.stateHoverOpacity,
    required this.statePressedOpacity,
    required this.stateDisabledOpacity,
    required this.stateDisabledTextOpacity,
    required this.stateDisabledIconOpacity,
    required this.focusRingWidth,
    required this.focusRingColor,
    required this.focusRingGap,
    required this.minTapTarget,
    required this.statePressedTintColor,
    required this.stateInkColor,
    required this.surfaceHoverColor,
    // Buttons
    required this.buttonPrimaryColorBackground,
    required this.buttonPrimaryColorBorder,
    required this.buttonPrimaryColorText,
    required this.buttonPrimaryDisabledColorBackground,
    required this.buttonPrimaryDisabledColorText,
    required this.buttonSecondaryColorBackground,
    required this.buttonSecondaryColorBorder,
    required this.buttonSecondaryColorText,
    required this.buttonDangerColorBackground,
    required this.buttonDangerColorBorder,
    required this.buttonDangerColorText,
    required this.buttonNeutralColorBackground,
    required this.buttonNeutralColorBorder,
    required this.buttonNeutralColorText,
    required this.buttonTertiaryColorBackground,
    required this.buttonTertiaryColorBorder,
    required this.buttonTertiaryColorText,
    required this.buttonPaddingX,
    required this.buttonPaddingY,
    required this.buttonBorderRadius,
    required this.buttonMinHeight,
    required this.buttonIconSize,
    required this.buttonRestBorderWidth,
    required this.buttonLabelFontSize,
    required this.buttonLabelFontWeight,
    required this.buttonLabelTextTransform,
    required this.buttonLgLabelFontSize,
    required this.buttonLgPaddingX,
    required this.buttonLgPaddingY,
    required this.buttonLgIconSize,
    required this.buttonCompactPaddingX,
    required this.buttonCompactPaddingY,
    required this.buttonIconGap,
    required this.buttonMinWidth,
    required this.buttonPressedScale,
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
    required this.badgeInfoColorBackground,
    required this.badgeInfoColorText,
    required this.badgeInfoColorBorder,
    // Forms & surfaces
    required this.offsetBackgroundColor,
    required this.colorSurfaceMuted,
    required this.formBackgroundColor,
    required this.formHighlightColorBorder,
    required this.formAccentColor,
    required this.formPlaceholderTextColor,
    required this.formBorderRadius,
    required this.inputFieldPaddingX,
    required this.inputFieldPaddingY,
    required this.textFieldPaddingY,
    required this.inputBorderWidth,
    required this.inputFocusBorderWidth,
    required this.fieldLabelGap,
    required this.boxBorderWidth,
    required this.controlTrackColor,
    required this.controlDiameterSm,
    required this.controlDiameterMd,
    required this.markerDiameter,
    required this.markerBorderWidth,
    required this.cardPadding,
    // Table
    required this.tableRowPaddingY,
    // Overlays
    required this.overlayBorderRadius,
    required this.overlayBackdropColor,
    required this.overlays,
    required this.shadowLow,
    required this.shadowMedium,
    required this.shadowHigh,
    required this.overlayBackdropSubtleColor,
    required this.tooltipBorderRadius,
    required this.dialogMaxWidthSm,
    required this.dialogMaxWidthMd,
    required this.dialogMaxWidthLg,
    required this.dialogMinHeight,
    // Charts
    required this.chartCategorical,
    required this.chartOther,
    required this.chartSequential,
    required this.chartDiverging,
    // Chrome
    required this.authWashGradient,
    required this.authWashStops,
    required this.authWashBegin,
    required this.authWashEnd,
    required this.headlineGradient,
    required this.bloomColor,
    required this.bloomStops,
    required this.brandTintColor,
    // Wordmark
    required this.wordmarkFontSize,
    required this.wordmarkLetterSpacing,
    required this.wordmarkHeight,
    required this.wordmarkPrimaryFontWeight,
    required this.wordmarkAccentFontWeight,
    required this.wordmarkPrimaryText,
    required this.wordmarkAccentText,
  });

  /// The default Design System light appearance.
  ///
  /// Not const because the disabled button defaults derive from the primary
  /// button colours at build time; [DsTokens] equality stays structural.
  factory DsTokens.light() {
    return DsTokens(
      fontFamily: DsTypography.fontFamily,
      fontSizeBase: 16,
      spacingUnit: DsSpacing.sm,
      borderRadius: DsRadii.form,
      colorPrimary: DsColors.actionPrimary,
      colorBackground: DsColors.formBackground,
      colorDanger: DsColors.buttonDangerBackground,
      colorSuccess: DsColors.success,
      colorWarning: DsColors.warning,
      colorOnPrimary: const Color(0xFFFFFFFF),
      colorOnSignal: const Color(0xFFFFFFFF),
      colorAttention: const Color(0xFFFFA800),
      radiusXxs: 2,
      radiusControl: 6,
      radiusLg: 12,
      radiusFull: 1000,
      headingXl: DsTypography.headingXl,
      headingLg: DsTypography.headingLg,
      headingMd: DsTypography.headingMd,
      headingSm: DsTypography.headingSm,
      headingXs: DsTypography.headingXs,
      bodyMd: DsTypography.bodyMd,
      bodySm: DsTypography.bodySm,
      labelMd: DsTypography.labelMd,
      labelSm: DsTypography.labelSm,
      bodyLg: const DsTypeToken(
          fontSize: 17, fontWeight: DsTypography.regular, height: 1.45),
      stepTitle: const DsTypeToken(
          fontSize: 28,
          fontWeight: DsTypography.bold,
          height: 1.2,
          letterSpacing: -0.4),
      display: const DsTypeToken(
          fontSize: 60,
          fontWeight: DsTypography.extraBold,
          height: 1.05,
          letterSpacing: -1.8),
      strongLabelFontWeight: DsTypography.semiBold,
      mediumLabelFontWeight: DsTypography.medium,
      iconSizeXxs: DsIconSize.xxs,
      iconSizeXs: DsIconSize.xs,
      iconSizeSm: DsIconSize.sm,
      iconSizeMd: DsIconSize.md,
      iconSizeLg: DsIconSize.lg,
      iconSizeXl: DsIconSize.xl,
      colorText: DsColors.textPrimary,
      colorSecondaryText: DsColors.textSecondary,
      colorBorder: DsColors.border,
      colorBorderSubtle: DsColors.borderSubtle,
      colorIconMuted: const Color(0xFF717171),
      colorTextDisabled: const Color(0xFFBCBCBC),
      colorInverseSurface: const Color(0xFF101828),
      colorOnInverse: const Color(0xFFFFFFFF),
      colorDangerOnInverse: const Color(0xFFFF8A80),
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
      stateHoverOpacity: 0.06,
      statePressedOpacity: 0.10,
      stateDisabledOpacity: 0.5,
      stateDisabledTextOpacity: 0.9,
      stateDisabledIconOpacity: 0.38,
      focusRingWidth: 2,
      // The accent the tickbox and switch already ring themselves with,
      // named so every control can agree on it.
      focusRingColor: DsColors.formAccent,
      focusRingGap: 1,
      minTapTarget: kMinInteractiveDimension,
      // The primary flattened onto white, a solid press tint.
      statePressedTintColor: const Color(0xFFB3D5F2),
      stateInkColor: const Color(0xFF000000),
      // The state ink at roughly the hover alpha, ready mixed.
      surfaceHoverColor: const Color(0x0F000000),
      buttonPrimaryColorBackground: DsColors.buttonPrimaryBackground,
      buttonPrimaryColorBorder: DsColors.buttonPrimaryBorder,
      buttonPrimaryColorText: DsColors.buttonPrimaryText,
      buttonPrimaryDisabledColorBackground:
          DsColors.buttonPrimaryDisabledBackground,
      buttonPrimaryDisabledColorText: DsColors.buttonPrimaryDisabledText,
      buttonSecondaryColorBackground: DsColors.buttonSecondaryBackground,
      buttonSecondaryColorBorder: DsColors.buttonSecondaryBorder,
      buttonSecondaryColorText: DsColors.buttonSecondaryText,
      buttonDangerColorBackground: DsColors.buttonDangerBackground,
      buttonDangerColorBorder: DsColors.buttonDangerBorder,
      buttonDangerColorText: DsColors.buttonDangerText,
      buttonNeutralColorBackground: DsColors.buttonNeutralBackground,
      buttonNeutralColorBorder: DsColors.buttonNeutralBorder,
      buttonNeutralColorText: DsColors.buttonNeutralText,
      buttonTertiaryColorBackground: Colors.transparent,
      buttonTertiaryColorBorder: Colors.transparent,
      buttonTertiaryColorText: DsColors.actionPrimary,
      // The full insets the button paints, so a skin sets its metrics
      // directly.
      buttonPaddingX: 16,
      buttonPaddingY: 10,
      buttonBorderRadius: DsRadii.button,
      buttonMinHeight: 40,
      // The glyph rides 2 above the 16dp label, the maths the button used at
      // build time; keep the pair in step when re-sizing the label.
      buttonIconSize: 18,
      buttonRestBorderWidth: 1,
      buttonLabelFontSize: 16,
      buttonLabelFontWeight: FontWeight.w400,
      buttonLabelTextTransform: DsTextTransform.none,
      buttonLgLabelFontSize: 18,
      buttonLgPaddingX: 28,
      buttonLgPaddingY: 18,
      buttonLgIconSize: 20,
      buttonCompactPaddingX: 12,
      buttonCompactPaddingY: 8,
      buttonIconGap: 8,
      buttonMinWidth: 64,
      buttonPressedScale: 0.96,
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
      // The info badge shares the neutral container on the base, with the
      // primary as its ink, so it stays quiet until a skin tints it.
      badgeInfoColorBackground: DsColors.badgeNeutralBackground,
      // A deepened brand blue: the action primary sits below AA on the pale
      // container, so the info ink runs one step darker.
      badgeInfoColorText: const Color(0xFF005FB8),
      badgeInfoColorBorder: DsColors.badgeNeutralBackground,
      offsetBackgroundColor: DsColors.offsetBackground,
      colorSurfaceMuted: DsColors.surfaceMuted,
      formBackgroundColor: DsColors.formBackground,
      formHighlightColorBorder: DsColors.formHighlightBorder,
      formAccentColor: DsColors.formAccent,
      formPlaceholderTextColor: DsColors.formPlaceholderText,
      formBorderRadius: DsRadii.form,
      inputFieldPaddingX: DsSpacing.inputFieldPaddingX,
      inputFieldPaddingY: DsSpacing.inputFieldPaddingY,
      // The full vertical padding the text field paints: the raw DsSpacing
      // value plus the 12 the field used to add at build time.
      textFieldPaddingY: DsSpacing.inputFieldPaddingY + 12,
      inputBorderWidth: 1,
      inputFocusBorderWidth: 1.6,
      fieldLabelGap: 6,
      boxBorderWidth: 1,
      controlTrackColor: const Color(0xFFD6D6D6),
      controlDiameterSm: 32,
      controlDiameterMd: 36,
      markerDiameter: 18,
      markerBorderWidth: 1.5,
      cardPadding: 24,
      tableRowPaddingY: DsSpacing.tableRowPaddingY,
      overlayBorderRadius: DsRadii.overlay,
      overlayBackdropColor: DsColors.overlayBackdrop,
      overlays: DsOverlayStyle.dialog,
      shadowLow: DsElevation.low,
      shadowMedium: DsElevation.medium,
      shadowHigh: DsElevation.high,
      overlayBackdropSubtleColor: const Color(0x59EFF1F6),
      tooltipBorderRadius: 8,
      dialogMaxWidthSm: 460,
      dialogMaxWidthMd: 560,
      dialogMaxWidthLg: 620,
      dialogMinHeight: 240,
      chartCategorical: DsChartPalette.categoricalLight,
      chartOther: DsChartPalette.otherLight,
      chartSequential: DsChartPalette.sequential,
      chartDiverging: const <Color>[
        DsChartPalette.divergingNegative,
        DsChartPalette.divergingNeutral,
        DsChartPalette.divergingPositive,
      ],
      authWashGradient: DsColors.authWash,
      // Null spaces the wash colours evenly, the spread the gradient has
      // always painted.
      authWashStops: null,
      authWashBegin: Alignment.topCenter,
      authWashEnd: Alignment.bottomCenter,
      // Empty keeps headline text on its plain ink until a skin supplies
      // gradient stops.
      headlineGradient: const <Color>[],
      bloomColor: DsColors.bloom,
      // No branded pools on the neutral base: the multi-pool bloom falls back
      // to a soft spread of [bloomColor], so white-label output is unchanged
      // until a skin supplies its stops.
      bloomStops: const <Color>[],
      // A soft wash of the primary, so a brand-soft mark is legible on the
      // base; a skin supplies its own tint.
      brandTintColor: const Color(0xFFE6F5F2),
      wordmarkFontSize: 22,
      wordmarkLetterSpacing: -0.2,
      wordmarkHeight: 1,
      wordmarkPrimaryFontWeight: DsTypography.semiBold,
      wordmarkAccentFontWeight: DsTypography.bold,
      wordmarkPrimaryText: '',
      wordmarkAccentText: null,
    );
  }

  /// The Design System dark appearance, derived from the light tokens.
  factory DsTokens.dark() {
    return DsTokens.light().copyWith(
      colorPrimary: DsColors.brandPrimaryDark,
      colorBackground: const Color(0xFF121317),
      colorText: const Color(0xFFF3F4F6),
      colorSecondaryText: const Color(0xFF9CA3AF),
      colorBorder: const Color(0xFF3F4147),
      colorBorderSubtle: const Color(0xFF3F4147),
      // One step dimmer than the dark secondary text.
      colorIconMuted: const Color(0xFF8A93A6),
      colorTextDisabled: const Color(0xFF5A6170),
      // The inverse pair flips against the dark theme.
      colorInverseSurface: const Color(0xFFF5F6F8),
      colorOnInverse: const Color(0xFF17181C),
      colorDangerOnInverse: const Color(0xFFB3261E),
      // The primary lifted onto the dark page, a solid press tint.
      statePressedTintColor: const Color(0xFF1E3A57),
      surfaceHoverColor: const Color(0x14FFFFFF),
      controlTrackColor: const Color(0xFF3A3D45),
      badgeInfoColorBackground: const Color(0xFF1E2530),
      badgeInfoColorText: DsColors.brandLinkDark,
      badgeInfoColorBorder: const Color(0xFF1E2530),
      overlayBackdropSubtleColor: const Color(0x59101828),
      colorSuccess: const Color(0xFF7FD860),
      colorWarning: const Color(0xFFF0B429),
      actionPrimaryColorText: DsColors.brandLinkDark,
      actionPrimaryTextDecorationColor: DsColors.brandLinkDark,
      actionSecondaryColorText: const Color(0xFFC9CDD3),
      actionSecondaryTextDecorationColor: DsColors.brandLinkDark,
      // The tertiary label follows the dark link colour, the value the
      // button used to read from actionPrimaryColorText.
      buttonTertiaryColorText: DsColors.brandLinkDark,
      // The button fill is a deeper teal, AA-safe with white label text
      // (contrast ~5.5:1); the lighter brandPrimaryDark is kept for scheme
      // accents/links only.
      buttonPrimaryColorBackground: DsColors.brandButtonDark,
      buttonPrimaryColorBorder: DsColors.brandButtonDark,
      // Re-derived from the dark primary pair so the disabled fade matches
      // the dark fill, exactly as the button used to compute it.
      buttonPrimaryDisabledColorBackground:
          DsColors.brandButtonDark.withValues(alpha: 0.5),
      buttonPrimaryDisabledColorText:
          const Color(0xFFFFFFFF).withValues(alpha: 0.9),
      buttonSecondaryColorBackground: const Color(0xFF2A2C33),
      buttonSecondaryColorBorder: const Color(0xFF2A2C33),
      buttonSecondaryColorText: const Color(0xFFE5E7EB),
      buttonNeutralColorBackground: const Color(0xFF2A2C33),
      buttonNeutralColorBorder: const Color(0xFF2A2C33),
      buttonNeutralColorText: const Color(0xFFE5E7EB),
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
      // The muted tier shares the offset surface on dark; both sit one step
      // above the page.
      colorSurfaceMuted: const Color(0xFF1E2025),
      formBackgroundColor: const Color(0xFF17181C),
      formHighlightColorBorder: const Color(0xFF4B4E56),
      formAccentColor: DsColors.brandPrimaryDark,
      // Follows the dark accent, so the ring keeps matching the control
      // it surrounds.
      focusRingColor: DsColors.brandPrimaryDark,
      // The dark surface has its own validated ramp, not a flip of the
      // light one.
      chartCategorical: DsChartPalette.categoricalDark,
      chartOther: DsChartPalette.otherDark,
      // Clears AA contrast (4.5:1) on the dark field fill while staying
      // clearly dimmer than the value ink.
      formPlaceholderTextColor: const Color(0xFF8A93A6),
      overlayBackdropColor: const Color(0x99000000),
      // The same quiet drift as light, rebuilt from the dark surfaces: the
      // page background into the offset surface, with the secondary button
      // fill as the bloom peak.
      authWashGradient: const [Color(0xFF121317), Color(0xFF1E2025)],
      bloomColor: const Color(0xFF2A2C33),
      // A dark wash toward the primary, one step above the page.
      brandTintColor: const Color(0xFF123330),
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

  /// The categorical chart colour for the series at [index].
  ///
  /// The order is fixed and assigned by series identity, never cycled: a
  /// series past the end of [chartCategorical] folds into the neutral
  /// [chartOther] bucket rather than repeating a hue that already means
  /// something else on the same chart.
  Color chartColorAt(int index) {
    if (index >= 0 && index < chartCategorical.length) {
      return chartCategorical[index];
    }
    return chartOther;
  }

  /// Sentinel marking a nullable [copyWith] parameter as not supplied, so
  /// a caller can set such a field to null explicitly.
  static const Object _unset = Object();

  // Global ---------------------------------------------------------------
  //
  // The high-level knobs most brands change first. They seed the theme and
  // provide sensible defaults the rest of the system derives from.

  /// The font family used across every component. Null uses the platform
  /// system font.
  final String? fontFamily;

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

  /// The bright signal colour for positive live status, such as a password
  /// meter's good tier or a healthy status readout. Defaults to the success
  /// badge text colour so existing readouts keep their colour.
  final Color colorSuccess;

  /// The bright signal colour for cautionary live status, such as a password
  /// meter's fair tier. Defaults to the warning badge text colour so existing
  /// readouts keep their colour.
  final Color colorWarning;

  /// The ink painted on top of [colorPrimary] fills, such as a filled
  /// brand surface or a primary marker.
  final Color colorOnPrimary;

  /// The ink painted on top of the bright signal colours [colorSuccess],
  /// [colorWarning] and [colorAttention] when they fill a surface.
  final Color colorOnSignal;

  /// The bright attention colour for highlights that ask for the eye
  /// without signalling success or danger, such as a ratings star or a
  /// pending marker.
  final Color colorAttention;

  /// The smallest corner radius, for fine details such as a scrollbar
  /// thumb or a tiny indicator.
  final double radiusXxs;

  /// The corner radius for small controls such as tickboxes and compact
  /// inputs.
  final double radiusControl;

  /// The corner radius for card-sized surfaces: a board lane, a panel, a
  /// raised tile. The step above [DsTokens.overlayBorderRadius], for
  /// containers large enough that a tighter corner reads as sharp.
  ///
  /// Nested surfaces derive from this rather than declaring their own: an
  /// inner card inset by *n* from its container takes `radiusLg - n`, so
  /// the two curves stay concentric when a skin retunes the outer one.
  final double radiusLg;

  /// The stadium radius: large enough that any control it is applied to
  /// renders fully rounded ends.
  final double radiusFull;

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

  /// Large body typography, one step up from [bodyMd] for lead
  /// paragraphs.
  final DsTypeToken bodyLg;

  /// The title of a step or section within a flow, sitting between
  /// [headingXl] and [display].
  final DsTypeToken stepTitle;

  /// Display typography for hero surfaces, the largest style in the ramp.
  final DsTypeToken display;

  /// The font weight for strong labels: group legends, table headers and
  /// other short emphasised runs. Defaults to [DsTypography.semiBold].
  final FontWeight strongLabelFontWeight;

  /// The font weight for medium-emphasis text: a field label, a picker value,
  /// a selected row. One step below [strongLabelFontWeight]. Defaults to
  /// [DsTypography.medium].
  final FontWeight mediumLabelFontWeight;

  // Icon scale -----------------------------------------------------------
  //
  // The glyph sizes components draw at, defaulting to [DsIconSize]. They sit
  // in the token layer for the same reason the type ramp does: a brand that
  // re-scales its text without re-scaling the glyphs beside it ends up with
  // icons that no longer sit on the line.

  /// Tiny marker glyphs. Defaults to [DsIconSize.xxs].
  final double iconSizeXxs;

  /// Glyphs set inline with small text. Defaults to [DsIconSize.xs].
  final double iconSizeXs;

  /// The default control glyph, for buttons, inputs and chips. Defaults to
  /// [DsIconSize.sm].
  final double iconSizeSm;

  /// Glyphs in list rows and toolbars. Defaults to [DsIconSize.md].
  final double iconSizeMd;

  /// Glyphs on prominent actions and status readouts. Defaults to
  /// [DsIconSize.lg].
  final double iconSizeLg;

  /// Header and empty-state glyphs, the largest step. Defaults to
  /// [DsIconSize.xl].
  final double iconSizeXl;

  // Text ----------------------------------------------------------------

  /// The colour used for primary text.
  final Color colorText;

  /// The colour used for secondary text.
  final Color colorSecondaryText;

  /// The colour used for borders throughout components.
  final Color colorBorder;

  /// The hairline tier beneath [colorBorder]: the quietest rule the system
  /// draws, used by [DsDivider] and decorative hairlines. Defaults to
  /// [colorBorder]'s value so nothing shifts until a skin supplies a lighter
  /// hairline.
  final Color colorBorderSubtle;

  /// The colour for muted, non-interactive icons such as a field's
  /// leading glyph. One step dimmer than [colorSecondaryText].
  final Color colorIconMuted;

  /// The colour for disabled text, dimmer than [colorSecondaryText] while
  /// staying legible against [colorBackground].
  final Color colorTextDisabled;

  /// The inverse surface: a high-contrast panel that flips against the
  /// theme, such as a tooltip or a snack bar.
  final Color colorInverseSurface;

  /// The ink painted on top of [colorInverseSurface].
  final Color colorOnInverse;

  /// The danger ink that stays legible on [colorInverseSurface], for a
  /// destructive action inside an inverse panel.
  final Color colorDangerOnInverse;

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

  // Interaction states ----------------------------------------------------
  //
  // The alpha and stroke vocabulary for hover, press, focus and disabled
  // treatments. Each default equals the value components used to hardcode,
  // so nothing shifts until a skin retunes it.

  /// The state-layer alpha painted over a flat control on hover and
  /// keyboard focus.
  final double stateHoverOpacity;

  /// The state-layer alpha painted over a flat control while pressed.
  final double statePressedOpacity;

  /// The fade shared by the disabled treatments that dim a whole surface: a
  /// disabled button's fill, a disabled tertiary button's label and a
  /// disabled input's border.
  final double stateDisabledOpacity;

  /// The fade for a disabled filled button's label. Gentler than
  /// [stateDisabledOpacity], so the label stays readable on the dimmed
  /// fill.
  final double stateDisabledTextOpacity;

  /// The fade for a disabled icon-only control's glyph.
  final double stateDisabledIconOpacity;

  /// The stroke width of the keyboard focus ring on buttons and icon
  /// buttons.
  final double focusRingWidth;

  /// The colour of the keyboard focus ring. Defaults to [formAccentColor],
  /// the accent the tickbox and switch already ring themselves with.
  ///
  /// A control whose own foreground carries the focus state instead (a
  /// filled button rings itself in its label colour, so the ring stays
  /// legible on any variant fill) is the deliberate exception.
  final Color focusRingColor;

  /// The gap held between a control's edge and its focus ring, so the ring
  /// stays visible against a filled control rather than merging with it.
  final double focusRingGap;

  /// The minimum size of an interactive control's tap target, in logical
  /// pixels. Defaults to `kMinInteractiveDimension` (48), the accessible floor;
  /// a brand that wants a denser or roomier touch surface retunes it here, and
  /// every control reads it rather than hardcoding the value.
  final double minTapTarget;

  /// The solid tint a tonal control shows while pressed, an alternative
  /// to the alpha overlay of [statePressedOpacity].
  final Color statePressedTintColor;

  /// The ink the hover and pressed state layers are cut from before
  /// their opacity is applied.
  final Color stateInkColor;

  /// The ready-mixed hover fill for flat surfaces such as list rows and
  /// table rows, an alternative to deriving it from [stateInkColor] and
  /// [stateHoverOpacity].
  final Color surfaceHoverColor;

  // Buttons -------------------------------------------------------------

  /// The colour used as a background for primary buttons.
  final Color buttonPrimaryColorBackground;

  /// The border colour used for primary buttons.
  final Color buttonPrimaryColorBorder;

  /// The text colour used for primary buttons.
  final Color buttonPrimaryColorText;

  /// The background colour for disabled primary buttons.
  ///
  /// Defaults to [buttonPrimaryColorBackground] at 50% opacity, the fade the
  /// button used to derive at build time, so the default treatment is
  /// unchanged. A skin can supply a solid tint that reads identically on any
  /// backdrop.
  final Color buttonPrimaryDisabledColorBackground;

  /// The text colour for disabled primary buttons.
  ///
  /// Defaults to [buttonPrimaryColorText] at 90% opacity, the fade the button
  /// used to derive at build time.
  final Color buttonPrimaryDisabledColorText;

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

  /// The colour used as a background for neutral buttons.
  ///
  /// Neutral buttons carry third-party or utility actions (such as federated
  /// sign-in) that must not compete with the brand pair. The defaults match
  /// the secondary button so existing surfaces keep their appearance.
  final Color buttonNeutralColorBackground;

  /// The border colour used for neutral buttons.
  final Color buttonNeutralColorBorder;

  /// The text colour used for neutral buttons.
  final Color buttonNeutralColorText;

  /// The background colour for tertiary (text) buttons. Transparent by
  /// default, so the label alone carries the action.
  final Color buttonTertiaryColorBackground;

  /// The border colour for tertiary (text) buttons. Transparent by default.
  final Color buttonTertiaryColorBorder;

  /// The text colour for tertiary (text) buttons. Defaults to the primary
  /// action colour, the value the button used to read from
  /// [actionPrimaryColorText].
  final Color buttonTertiaryColorText;

  /// The horizontal padding for buttons. This is the full inset the button
  /// paints, so a skin can set its metrics directly.
  final double buttonPaddingX;

  /// The vertical padding for buttons. This is the full inset the button
  /// paints, so a skin can set its metrics directly.
  final double buttonPaddingY;

  /// The border radius used for buttons.
  final double buttonBorderRadius;

  /// The minimum height for buttons, in logical pixels.
  final double buttonMinHeight;

  /// The size of a glyph inside a button, in logical pixels. Defaults to
  /// [buttonLabelFontSize] plus 2, the derivation the button used at build
  /// time; keep the pair in step when a skin re-sizes the label.
  final double buttonIconSize;

  /// The border stroke width for buttons at rest.
  final double buttonRestBorderWidth;

  /// The font size for button label typography.
  final double buttonLabelFontSize;

  /// The font weight for button label typography.
  final FontWeight buttonLabelFontWeight;

  /// The text transform for button label typography.
  final DsTextTransform buttonLabelTextTransform;

  /// The label font size for the large button tier.
  final double buttonLgLabelFontSize;

  /// The horizontal padding for the large button tier.
  final double buttonLgPaddingX;

  /// The vertical padding for the large button tier.
  final double buttonLgPaddingY;

  /// The glyph size inside a large button.
  final double buttonLgIconSize;

  /// The horizontal padding for the compact button tier.
  final double buttonCompactPaddingX;

  /// The vertical padding for the compact button tier.
  final double buttonCompactPaddingY;

  /// The gap between a button's glyph and its label.
  final double buttonIconGap;

  /// The minimum width of a button, so a short label still renders a
  /// balanced control.
  final double buttonMinWidth;

  /// How far a button shrinks while pressed, as a scale factor. Just under
  /// 1, so the press reads as the surface giving under the finger rather
  /// than as the control changing size.
  final double buttonPressedScale;

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

  /// The background colour used in status badges that carry neutral
  /// informational state in the brand hue.
  final Color badgeInfoColorBackground;

  /// The text colour used in status badges that carry neutral
  /// informational state in the brand hue.
  final Color badgeInfoColorText;

  /// The border colour used in status badges that carry neutral
  /// informational state in the brand hue. Matches
  /// [badgeInfoColorBackground] by default, so the badge reads as a flat
  /// container.
  final Color badgeInfoColorBorder;

  // Forms & surfaces ------------------------------------------------------

  /// The background colour used when highlighting information, like the
  /// selected row on a table.
  final Color offsetBackgroundColor;

  /// The muted surface tier: the quiet grey behind code wells, table
  /// headers and other recessed panels. Exposed to the Material scheme as
  /// `surfaceContainerHighest`.
  final Color colorSurfaceMuted;

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

  /// The full vertical padding a bordered text input paints, used by
  /// [DsTextField]. Defaults to [inputFieldPaddingY] plus the 12 the field
  /// used to add at build time, so the rendered field is unchanged; a skin
  /// can lower it directly for denser inputs.
  final double textFieldPaddingY;

  /// The border stroke width for input fields at rest.
  final double inputBorderWidth;

  /// The border stroke width for a focused input field. The error border
  /// carries the same emphasis.
  final double inputFocusBorderWidth;

  /// The gap between a field's label and its input.
  final double fieldLabelGap;

  /// The border stroke width a [DsBox] draws when given a border colour
  /// without an explicit width.
  final double boxBorderWidth;

  /// The colour of a switch or slider track at rest, before the accent
  /// fills it.
  final Color controlTrackColor;

  /// The diameter of a small round control such as a stepper button.
  final double controlDiameterSm;

  /// The diameter of a medium round control such as an icon button's
  /// fill.
  final double controlDiameterMd;

  /// The diameter of a small round marker such as a step indicator's
  /// dot.
  final double markerDiameter;

  /// The border stroke width of a round marker.
  final double markerBorderWidth;

  /// The inner padding of a card surface.
  final double cardPadding;

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

  /// The resting drop shadow for lightly raised surfaces (chips, hover cards).
  /// Defaults to [DsElevation.low]; a skin can supply a brand-tinted shadow.
  final List<BoxShadow> shadowLow;

  /// The drop shadow for floating surfaces such as cards, menus and overlays.
  /// Defaults to [DsElevation.medium]; a skin can supply a brand-tinted shadow.
  final List<BoxShadow> shadowMedium;

  /// The drop shadow for modal surfaces (dialogs, drawers, takeovers). Defaults
  /// to [DsElevation.high]; a skin can supply a brand-tinted shadow.
  final List<BoxShadow> shadowHigh;

  /// A quieter backdrop than [overlayBackdropColor], for overlays that
  /// dim the page only slightly, such as a popover scrim.
  final Color overlayBackdropSubtleColor;

  /// The corner radius of a tooltip.
  final double tooltipBorderRadius;

  /// The maximum width of a small dialog.
  final double dialogMaxWidthSm;

  /// The maximum width of a medium dialog.
  final double dialogMaxWidthMd;

  /// The maximum width of a large dialog.
  final double dialogMaxWidthLg;

  /// The minimum height of a dialog, so a sparse dialog still reads as a
  /// settled surface.
  final double dialogMinHeight;

  // Charts ---------------------------------------------------------------
  //
  // The data-visualisation ramps, defaulting to [DsChartPalette]. A chart is
  // the one surface where colour carries data rather than decoration, so the
  // defaults are validated for colour-vision separation, chroma and contrast
  // against their surface. A skin that replaces them owes the same check.

  /// The fixed categorical order, assigned by series identity and never
  /// cycled. Defaults to the [DsChartPalette] ramp for the active surface.
  final List<Color> chartCategorical;

  /// The neutral bucket for series past the end of [chartCategorical].
  final Color chartOther;

  /// The sequential ramp carrying magnitude: a single hue, light to dark.
  final List<Color> chartSequential;

  /// The diverging ramp carrying polarity, as negative pole, neutral
  /// midpoint and positive pole.
  final List<Color> chartDiverging;

  // Chrome ----------------------------------------------------------------

  /// The colour stops of the auth wash, painted top to bottom by
  /// [DsAuthGradient] behind sign-in, sign-up and waiting screens. The
  /// default drifts from the form background into the secondary button fill,
  /// a barely-there neutral, so the white-label backdrop stays quiet; a skin
  /// supplies branded stops. Give it at least two colours.
  final List<Color> authWashGradient;

  /// The fractional positions of the [authWashGradient] colours along
  /// the wash, from 0 to 1. Null spaces the colours evenly, the spread
  /// the wash has always painted.
  final List<double>? authWashStops;

  /// Where the auth wash starts. Defaults to the top of the bounds, the
  /// axis [DsAuthGradient] has always painted.
  final AlignmentGeometry authWashBegin;

  /// Where the auth wash ends. Defaults to the bottom of the bounds.
  final AlignmentGeometry authWashEnd;

  /// The colour stops of a brand headline gradient, painted across hero
  /// display text. Empty by default, so headline text keeps its plain
  /// ink until a skin supplies stops.
  final List<Color> headlineGradient;

  /// The peak colour of the soft radial brand glow painted by [DsBrandBloom].
  /// The default is a neutral one step deeper than the wash, so the glow is
  /// present without carrying a hue; a skin supplies its brand tint.
  final Color bloomColor;

  /// The colour pools of the multi-pool brand bloom painted by
  /// [DsBrandBloom.pools], read bottom edge outward. Empty by default, so the
  /// multi-pool bloom falls back to a soft spread of [bloomColor] and the
  /// white-label glow stays neutral; a skin supplies its own ordered stops
  /// (for example a corner-to-corner sweep of brand hues).
  final List<Color> bloomStops;

  /// A soft brand-tinted surface: the quiet wash behind a brand-soft badge or
  /// a selected brand row, distinct from the neutral [offsetBackgroundColor].
  /// Defaults to a soft wash of the primary, so a brand-soft mark stays legible
  /// on the base; a skin supplies its own tint. Pair it with
  /// [actionPrimaryColorText] as the ink on top.
  final Color brandTintColor;

  // Wordmark ---------------------------------------------------------------

  /// The default wordmark size, in logical pixels.
  final double wordmarkFontSize;

  /// The wordmark's letter spacing. Slightly negative by default, so the
  /// mark sets a little tighter than body text.
  final double wordmarkLetterSpacing;

  /// The wordmark's line height multiplier. 1 by default, so the mark
  /// occupies exactly its glyph height in chrome and headers.
  final double wordmarkHeight;

  /// The font weight of the wordmark's primary part. Defaults to
  /// [DsTypography.semiBold]; a skin retunes the mark's weight here.
  final FontWeight wordmarkPrimaryFontWeight;

  /// The font weight of the wordmark's optional accent part. Defaults to
  /// [DsTypography.bold], one step heavier than the primary.
  final FontWeight wordmarkAccentFontWeight;

  /// The wordmark's primary text, such as a brand name. Empty by
  /// default, so the white-label chrome shows no mark until a skin
  /// supplies one.
  final String wordmarkPrimaryText;

  /// The wordmark's optional accent text, rendered after
  /// [wordmarkPrimaryText] at [wordmarkAccentFontWeight]. Null renders
  /// no accent.
  final String? wordmarkAccentText;

  @override
  DsTokens copyWith({
    Object? fontFamily = _unset,
    double? fontSizeBase,
    double? spacingUnit,
    double? borderRadius,
    Color? colorPrimary,
    Color? colorBackground,
    Color? colorDanger,
    Color? colorSuccess,
    Color? colorWarning,
    Color? colorOnPrimary,
    Color? colorOnSignal,
    Color? colorAttention,
    double? radiusXxs,
    double? radiusControl,
    double? radiusLg,
    double? radiusFull,
    DsTypeToken? headingXl,
    DsTypeToken? headingLg,
    DsTypeToken? headingMd,
    DsTypeToken? headingSm,
    DsTypeToken? headingXs,
    DsTypeToken? bodyMd,
    DsTypeToken? bodySm,
    DsTypeToken? labelMd,
    DsTypeToken? labelSm,
    DsTypeToken? bodyLg,
    DsTypeToken? stepTitle,
    DsTypeToken? display,
    FontWeight? strongLabelFontWeight,
    FontWeight? mediumLabelFontWeight,
    double? iconSizeXxs,
    double? iconSizeXs,
    double? iconSizeSm,
    double? iconSizeMd,
    double? iconSizeLg,
    double? iconSizeXl,
    Color? colorText,
    Color? colorSecondaryText,
    Color? colorBorder,
    Color? colorBorderSubtle,
    Color? colorIconMuted,
    Color? colorTextDisabled,
    Color? colorInverseSurface,
    Color? colorOnInverse,
    Color? colorDangerOnInverse,
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
    double? stateHoverOpacity,
    double? statePressedOpacity,
    double? stateDisabledOpacity,
    double? stateDisabledTextOpacity,
    double? stateDisabledIconOpacity,
    double? focusRingWidth,
    Color? focusRingColor,
    double? focusRingGap,
    double? minTapTarget,
    Color? statePressedTintColor,
    Color? stateInkColor,
    Color? surfaceHoverColor,
    Color? buttonPrimaryColorBackground,
    Color? buttonPrimaryColorBorder,
    Color? buttonPrimaryColorText,
    Color? buttonPrimaryDisabledColorBackground,
    Color? buttonPrimaryDisabledColorText,
    Color? buttonSecondaryColorBackground,
    Color? buttonSecondaryColorBorder,
    Color? buttonSecondaryColorText,
    Color? buttonDangerColorBackground,
    Color? buttonDangerColorBorder,
    Color? buttonDangerColorText,
    Color? buttonNeutralColorBackground,
    Color? buttonNeutralColorBorder,
    Color? buttonNeutralColorText,
    Color? buttonTertiaryColorBackground,
    Color? buttonTertiaryColorBorder,
    Color? buttonTertiaryColorText,
    double? buttonPaddingX,
    double? buttonPaddingY,
    double? buttonBorderRadius,
    double? buttonMinHeight,
    double? buttonIconSize,
    double? buttonRestBorderWidth,
    double? buttonLabelFontSize,
    FontWeight? buttonLabelFontWeight,
    DsTextTransform? buttonLabelTextTransform,
    double? buttonLgLabelFontSize,
    double? buttonLgPaddingX,
    double? buttonLgPaddingY,
    double? buttonLgIconSize,
    double? buttonCompactPaddingX,
    double? buttonCompactPaddingY,
    double? buttonIconGap,
    double? buttonMinWidth,
    double? buttonPressedScale,
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
    Color? badgeInfoColorBackground,
    Color? badgeInfoColorText,
    Color? badgeInfoColorBorder,
    Color? offsetBackgroundColor,
    Color? colorSurfaceMuted,
    Color? formBackgroundColor,
    Color? formHighlightColorBorder,
    Color? formAccentColor,
    Color? formPlaceholderTextColor,
    double? formBorderRadius,
    double? inputFieldPaddingX,
    double? inputFieldPaddingY,
    double? textFieldPaddingY,
    double? inputBorderWidth,
    double? inputFocusBorderWidth,
    double? fieldLabelGap,
    double? boxBorderWidth,
    Color? controlTrackColor,
    double? controlDiameterSm,
    double? controlDiameterMd,
    double? markerDiameter,
    double? markerBorderWidth,
    double? cardPadding,
    double? tableRowPaddingY,
    double? overlayBorderRadius,
    Color? overlayBackdropColor,
    DsOverlayStyle? overlays,
    List<BoxShadow>? shadowLow,
    List<BoxShadow>? shadowMedium,
    List<BoxShadow>? shadowHigh,
    Color? overlayBackdropSubtleColor,
    double? tooltipBorderRadius,
    double? dialogMaxWidthSm,
    double? dialogMaxWidthMd,
    double? dialogMaxWidthLg,
    double? dialogMinHeight,
    List<Color>? chartCategorical,
    Color? chartOther,
    List<Color>? chartSequential,
    List<Color>? chartDiverging,
    List<Color>? authWashGradient,
    Object? authWashStops = _unset,
    AlignmentGeometry? authWashBegin,
    AlignmentGeometry? authWashEnd,
    List<Color>? headlineGradient,
    Color? bloomColor,
    List<Color>? bloomStops,
    Color? brandTintColor,
    double? wordmarkFontSize,
    double? wordmarkLetterSpacing,
    double? wordmarkHeight,
    FontWeight? wordmarkPrimaryFontWeight,
    FontWeight? wordmarkAccentFontWeight,
    String? wordmarkPrimaryText,
    Object? wordmarkAccentText = _unset,
  }) {
    return DsTokens(
      fontFamily: identical(fontFamily, _unset)
          ? this.fontFamily
          : fontFamily as String?,
      fontSizeBase: fontSizeBase ?? this.fontSizeBase,
      spacingUnit: spacingUnit ?? this.spacingUnit,
      borderRadius: borderRadius ?? this.borderRadius,
      colorPrimary: colorPrimary ?? this.colorPrimary,
      colorBackground: colorBackground ?? this.colorBackground,
      colorDanger: colorDanger ?? this.colorDanger,
      colorSuccess: colorSuccess ?? this.colorSuccess,
      colorWarning: colorWarning ?? this.colorWarning,
      colorOnPrimary: colorOnPrimary ?? this.colorOnPrimary,
      colorOnSignal: colorOnSignal ?? this.colorOnSignal,
      colorAttention: colorAttention ?? this.colorAttention,
      radiusXxs: radiusXxs ?? this.radiusXxs,
      radiusControl: radiusControl ?? this.radiusControl,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusFull: radiusFull ?? this.radiusFull,
      headingXl: headingXl ?? this.headingXl,
      headingLg: headingLg ?? this.headingLg,
      headingMd: headingMd ?? this.headingMd,
      headingSm: headingSm ?? this.headingSm,
      headingXs: headingXs ?? this.headingXs,
      bodyMd: bodyMd ?? this.bodyMd,
      bodySm: bodySm ?? this.bodySm,
      labelMd: labelMd ?? this.labelMd,
      labelSm: labelSm ?? this.labelSm,
      bodyLg: bodyLg ?? this.bodyLg,
      stepTitle: stepTitle ?? this.stepTitle,
      display: display ?? this.display,
      strongLabelFontWeight:
          strongLabelFontWeight ?? this.strongLabelFontWeight,
      mediumLabelFontWeight:
          mediumLabelFontWeight ?? this.mediumLabelFontWeight,
      iconSizeXxs: iconSizeXxs ?? this.iconSizeXxs,
      iconSizeXs: iconSizeXs ?? this.iconSizeXs,
      iconSizeSm: iconSizeSm ?? this.iconSizeSm,
      iconSizeMd: iconSizeMd ?? this.iconSizeMd,
      iconSizeLg: iconSizeLg ?? this.iconSizeLg,
      iconSizeXl: iconSizeXl ?? this.iconSizeXl,
      colorText: colorText ?? this.colorText,
      colorSecondaryText: colorSecondaryText ?? this.colorSecondaryText,
      colorBorder: colorBorder ?? this.colorBorder,
      colorBorderSubtle: colorBorderSubtle ?? this.colorBorderSubtle,
      colorIconMuted: colorIconMuted ?? this.colorIconMuted,
      colorTextDisabled: colorTextDisabled ?? this.colorTextDisabled,
      colorInverseSurface: colorInverseSurface ?? this.colorInverseSurface,
      colorOnInverse: colorOnInverse ?? this.colorOnInverse,
      colorDangerOnInverse:
          colorDangerOnInverse ?? this.colorDangerOnInverse,
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
      stateHoverOpacity: stateHoverOpacity ?? this.stateHoverOpacity,
      statePressedOpacity: statePressedOpacity ?? this.statePressedOpacity,
      stateDisabledOpacity: stateDisabledOpacity ?? this.stateDisabledOpacity,
      stateDisabledTextOpacity:
          stateDisabledTextOpacity ?? this.stateDisabledTextOpacity,
      stateDisabledIconOpacity:
          stateDisabledIconOpacity ?? this.stateDisabledIconOpacity,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      focusRingColor: focusRingColor ?? this.focusRingColor,
      focusRingGap: focusRingGap ?? this.focusRingGap,
      minTapTarget: minTapTarget ?? this.minTapTarget,
      statePressedTintColor:
          statePressedTintColor ?? this.statePressedTintColor,
      stateInkColor: stateInkColor ?? this.stateInkColor,
      surfaceHoverColor: surfaceHoverColor ?? this.surfaceHoverColor,
      buttonPrimaryColorBackground:
          buttonPrimaryColorBackground ?? this.buttonPrimaryColorBackground,
      buttonPrimaryColorBorder:
          buttonPrimaryColorBorder ?? this.buttonPrimaryColorBorder,
      buttonPrimaryColorText:
          buttonPrimaryColorText ?? this.buttonPrimaryColorText,
      buttonPrimaryDisabledColorBackground:
          buttonPrimaryDisabledColorBackground ??
              this.buttonPrimaryDisabledColorBackground,
      buttonPrimaryDisabledColorText: buttonPrimaryDisabledColorText ??
          this.buttonPrimaryDisabledColorText,
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
      buttonNeutralColorBackground:
          buttonNeutralColorBackground ?? this.buttonNeutralColorBackground,
      buttonNeutralColorBorder:
          buttonNeutralColorBorder ?? this.buttonNeutralColorBorder,
      buttonNeutralColorText:
          buttonNeutralColorText ?? this.buttonNeutralColorText,
      buttonTertiaryColorBackground:
          buttonTertiaryColorBackground ?? this.buttonTertiaryColorBackground,
      buttonTertiaryColorBorder:
          buttonTertiaryColorBorder ?? this.buttonTertiaryColorBorder,
      buttonTertiaryColorText:
          buttonTertiaryColorText ?? this.buttonTertiaryColorText,
      buttonPaddingX: buttonPaddingX ?? this.buttonPaddingX,
      buttonPaddingY: buttonPaddingY ?? this.buttonPaddingY,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonMinHeight: buttonMinHeight ?? this.buttonMinHeight,
      buttonIconSize: buttonIconSize ?? this.buttonIconSize,
      buttonRestBorderWidth:
          buttonRestBorderWidth ?? this.buttonRestBorderWidth,
      buttonLabelFontSize: buttonLabelFontSize ?? this.buttonLabelFontSize,
      buttonLabelFontWeight:
          buttonLabelFontWeight ?? this.buttonLabelFontWeight,
      buttonLabelTextTransform:
          buttonLabelTextTransform ?? this.buttonLabelTextTransform,
      buttonLgLabelFontSize:
          buttonLgLabelFontSize ?? this.buttonLgLabelFontSize,
      buttonLgPaddingX: buttonLgPaddingX ?? this.buttonLgPaddingX,
      buttonLgPaddingY: buttonLgPaddingY ?? this.buttonLgPaddingY,
      buttonLgIconSize: buttonLgIconSize ?? this.buttonLgIconSize,
      buttonCompactPaddingX:
          buttonCompactPaddingX ?? this.buttonCompactPaddingX,
      buttonCompactPaddingY:
          buttonCompactPaddingY ?? this.buttonCompactPaddingY,
      buttonIconGap: buttonIconGap ?? this.buttonIconGap,
      buttonMinWidth: buttonMinWidth ?? this.buttonMinWidth,
      buttonPressedScale: buttonPressedScale ?? this.buttonPressedScale,
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
      badgeInfoColorBackground:
          badgeInfoColorBackground ?? this.badgeInfoColorBackground,
      badgeInfoColorText: badgeInfoColorText ?? this.badgeInfoColorText,
      badgeInfoColorBorder:
          badgeInfoColorBorder ?? this.badgeInfoColorBorder,
      offsetBackgroundColor:
          offsetBackgroundColor ?? this.offsetBackgroundColor,
      colorSurfaceMuted: colorSurfaceMuted ?? this.colorSurfaceMuted,
      formBackgroundColor: formBackgroundColor ?? this.formBackgroundColor,
      formHighlightColorBorder:
          formHighlightColorBorder ?? this.formHighlightColorBorder,
      formAccentColor: formAccentColor ?? this.formAccentColor,
      formPlaceholderTextColor:
          formPlaceholderTextColor ?? this.formPlaceholderTextColor,
      formBorderRadius: formBorderRadius ?? this.formBorderRadius,
      inputFieldPaddingX: inputFieldPaddingX ?? this.inputFieldPaddingX,
      inputFieldPaddingY: inputFieldPaddingY ?? this.inputFieldPaddingY,
      textFieldPaddingY: textFieldPaddingY ?? this.textFieldPaddingY,
      inputBorderWidth: inputBorderWidth ?? this.inputBorderWidth,
      inputFocusBorderWidth:
          inputFocusBorderWidth ?? this.inputFocusBorderWidth,
      fieldLabelGap: fieldLabelGap ?? this.fieldLabelGap,
      boxBorderWidth: boxBorderWidth ?? this.boxBorderWidth,
      controlTrackColor: controlTrackColor ?? this.controlTrackColor,
      controlDiameterSm: controlDiameterSm ?? this.controlDiameterSm,
      controlDiameterMd: controlDiameterMd ?? this.controlDiameterMd,
      markerDiameter: markerDiameter ?? this.markerDiameter,
      markerBorderWidth: markerBorderWidth ?? this.markerBorderWidth,
      cardPadding: cardPadding ?? this.cardPadding,
      tableRowPaddingY: tableRowPaddingY ?? this.tableRowPaddingY,
      overlayBorderRadius: overlayBorderRadius ?? this.overlayBorderRadius,
      overlayBackdropColor: overlayBackdropColor ?? this.overlayBackdropColor,
      overlays: overlays ?? this.overlays,
      shadowLow: shadowLow ?? this.shadowLow,
      shadowMedium: shadowMedium ?? this.shadowMedium,
      shadowHigh: shadowHigh ?? this.shadowHigh,
      overlayBackdropSubtleColor:
          overlayBackdropSubtleColor ?? this.overlayBackdropSubtleColor,
      tooltipBorderRadius: tooltipBorderRadius ?? this.tooltipBorderRadius,
      dialogMaxWidthSm: dialogMaxWidthSm ?? this.dialogMaxWidthSm,
      dialogMaxWidthMd: dialogMaxWidthMd ?? this.dialogMaxWidthMd,
      dialogMaxWidthLg: dialogMaxWidthLg ?? this.dialogMaxWidthLg,
      dialogMinHeight: dialogMinHeight ?? this.dialogMinHeight,
      chartCategorical: chartCategorical ?? this.chartCategorical,
      chartOther: chartOther ?? this.chartOther,
      chartSequential: chartSequential ?? this.chartSequential,
      chartDiverging: chartDiverging ?? this.chartDiverging,
      authWashGradient: authWashGradient ?? this.authWashGradient,
      authWashStops: identical(authWashStops, _unset)
          ? this.authWashStops
          : authWashStops as List<double>?,
      authWashBegin: authWashBegin ?? this.authWashBegin,
      authWashEnd: authWashEnd ?? this.authWashEnd,
      headlineGradient: headlineGradient ?? this.headlineGradient,
      bloomColor: bloomColor ?? this.bloomColor,
      bloomStops: bloomStops ?? this.bloomStops,
      brandTintColor: brandTintColor ?? this.brandTintColor,
      wordmarkFontSize: wordmarkFontSize ?? this.wordmarkFontSize,
      wordmarkLetterSpacing:
          wordmarkLetterSpacing ?? this.wordmarkLetterSpacing,
      wordmarkHeight: wordmarkHeight ?? this.wordmarkHeight,
      wordmarkPrimaryFontWeight:
          wordmarkPrimaryFontWeight ?? this.wordmarkPrimaryFontWeight,
      wordmarkAccentFontWeight:
          wordmarkAccentFontWeight ?? this.wordmarkAccentFontWeight,
      wordmarkPrimaryText: wordmarkPrimaryText ?? this.wordmarkPrimaryText,
      wordmarkAccentText: identical(wordmarkAccentText, _unset)
          ? this.wordmarkAccentText
          : wordmarkAccentText as String?,
    );
  }

  @override
  DsTokens lerp(DsTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    double d(double a, double b) => lerpDouble(a, b, t)!;
    // Element-wise when the stop counts match; otherwise snap at the
    // midpoint, the same convention as the discrete tokens.
    List<Color> cs(List<Color> a, List<Color> b) => a.length == b.length
        ? List<Color>.generate(a.length, (i) => c(a[i], b[i]))
        : (t < 0.5 ? a : b);
    return DsTokens(
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      fontSizeBase: d(fontSizeBase, other.fontSizeBase),
      spacingUnit: d(spacingUnit, other.spacingUnit),
      borderRadius: d(borderRadius, other.borderRadius),
      colorPrimary: c(colorPrimary, other.colorPrimary),
      colorBackground: c(colorBackground, other.colorBackground),
      colorDanger: c(colorDanger, other.colorDanger),
      colorSuccess: c(colorSuccess, other.colorSuccess),
      colorWarning: c(colorWarning, other.colorWarning),
      colorOnPrimary: c(colorOnPrimary, other.colorOnPrimary),
      colorOnSignal: c(colorOnSignal, other.colorOnSignal),
      colorAttention: c(colorAttention, other.colorAttention),
      radiusXxs: d(radiusXxs, other.radiusXxs),
      radiusControl: d(radiusControl, other.radiusControl),
      radiusLg: d(radiusLg, other.radiusLg),
      radiusFull: d(radiusFull, other.radiusFull),
      headingXl: t < 0.5 ? headingXl : other.headingXl,
      headingLg: t < 0.5 ? headingLg : other.headingLg,
      headingMd: t < 0.5 ? headingMd : other.headingMd,
      headingSm: t < 0.5 ? headingSm : other.headingSm,
      headingXs: t < 0.5 ? headingXs : other.headingXs,
      bodyMd: t < 0.5 ? bodyMd : other.bodyMd,
      bodySm: t < 0.5 ? bodySm : other.bodySm,
      labelMd: t < 0.5 ? labelMd : other.labelMd,
      labelSm: t < 0.5 ? labelSm : other.labelSm,
      bodyLg: t < 0.5 ? bodyLg : other.bodyLg,
      stepTitle: t < 0.5 ? stepTitle : other.stepTitle,
      display: t < 0.5 ? display : other.display,
      strongLabelFontWeight: FontWeight.lerp(
          strongLabelFontWeight, other.strongLabelFontWeight, t)!,
      mediumLabelFontWeight: FontWeight.lerp(
          mediumLabelFontWeight, other.mediumLabelFontWeight, t)!,
      iconSizeXxs: d(iconSizeXxs, other.iconSizeXxs),
      iconSizeXs: d(iconSizeXs, other.iconSizeXs),
      iconSizeSm: d(iconSizeSm, other.iconSizeSm),
      iconSizeMd: d(iconSizeMd, other.iconSizeMd),
      iconSizeLg: d(iconSizeLg, other.iconSizeLg),
      iconSizeXl: d(iconSizeXl, other.iconSizeXl),
      colorText: c(colorText, other.colorText),
      colorSecondaryText: c(colorSecondaryText, other.colorSecondaryText),
      colorBorder: c(colorBorder, other.colorBorder),
      colorBorderSubtle: c(colorBorderSubtle, other.colorBorderSubtle),
      colorIconMuted: c(colorIconMuted, other.colorIconMuted),
      colorTextDisabled: c(colorTextDisabled, other.colorTextDisabled),
      colorInverseSurface: c(colorInverseSurface, other.colorInverseSurface),
      colorOnInverse: c(colorOnInverse, other.colorOnInverse),
      colorDangerOnInverse:
          c(colorDangerOnInverse, other.colorDangerOnInverse),
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
      stateHoverOpacity: d(stateHoverOpacity, other.stateHoverOpacity),
      statePressedOpacity: d(statePressedOpacity, other.statePressedOpacity),
      stateDisabledOpacity:
          d(stateDisabledOpacity, other.stateDisabledOpacity),
      stateDisabledTextOpacity:
          d(stateDisabledTextOpacity, other.stateDisabledTextOpacity),
      stateDisabledIconOpacity:
          d(stateDisabledIconOpacity, other.stateDisabledIconOpacity),
      focusRingWidth: d(focusRingWidth, other.focusRingWidth),
      focusRingColor: c(focusRingColor, other.focusRingColor),
      focusRingGap: d(focusRingGap, other.focusRingGap),
      minTapTarget: d(minTapTarget, other.minTapTarget),
      statePressedTintColor:
          c(statePressedTintColor, other.statePressedTintColor),
      stateInkColor: c(stateInkColor, other.stateInkColor),
      surfaceHoverColor: c(surfaceHoverColor, other.surfaceHoverColor),
      buttonPrimaryColorBackground:
          c(buttonPrimaryColorBackground, other.buttonPrimaryColorBackground),
      buttonPrimaryColorBorder:
          c(buttonPrimaryColorBorder, other.buttonPrimaryColorBorder),
      buttonPrimaryColorText:
          c(buttonPrimaryColorText, other.buttonPrimaryColorText),
      buttonPrimaryDisabledColorBackground: c(
          buttonPrimaryDisabledColorBackground,
          other.buttonPrimaryDisabledColorBackground),
      buttonPrimaryDisabledColorText: c(buttonPrimaryDisabledColorText,
          other.buttonPrimaryDisabledColorText),
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
      buttonNeutralColorBackground:
          c(buttonNeutralColorBackground, other.buttonNeutralColorBackground),
      buttonNeutralColorBorder:
          c(buttonNeutralColorBorder, other.buttonNeutralColorBorder),
      buttonNeutralColorText:
          c(buttonNeutralColorText, other.buttonNeutralColorText),
      buttonTertiaryColorBackground: c(
          buttonTertiaryColorBackground, other.buttonTertiaryColorBackground),
      buttonTertiaryColorBorder:
          c(buttonTertiaryColorBorder, other.buttonTertiaryColorBorder),
      buttonTertiaryColorText:
          c(buttonTertiaryColorText, other.buttonTertiaryColorText),
      buttonPaddingX: d(buttonPaddingX, other.buttonPaddingX),
      buttonPaddingY: d(buttonPaddingY, other.buttonPaddingY),
      buttonBorderRadius: d(buttonBorderRadius, other.buttonBorderRadius),
      buttonMinHeight: d(buttonMinHeight, other.buttonMinHeight),
      buttonIconSize: d(buttonIconSize, other.buttonIconSize),
      buttonRestBorderWidth:
          d(buttonRestBorderWidth, other.buttonRestBorderWidth),
      buttonLabelFontSize: d(buttonLabelFontSize, other.buttonLabelFontSize),
      buttonLabelFontWeight:
          FontWeight.lerp(buttonLabelFontWeight, other.buttonLabelFontWeight, t)!,
      buttonLabelTextTransform:
          t < 0.5 ? buttonLabelTextTransform : other.buttonLabelTextTransform,
      buttonLgLabelFontSize:
          d(buttonLgLabelFontSize, other.buttonLgLabelFontSize),
      buttonLgPaddingX: d(buttonLgPaddingX, other.buttonLgPaddingX),
      buttonLgPaddingY: d(buttonLgPaddingY, other.buttonLgPaddingY),
      buttonLgIconSize: d(buttonLgIconSize, other.buttonLgIconSize),
      buttonCompactPaddingX:
          d(buttonCompactPaddingX, other.buttonCompactPaddingX),
      buttonCompactPaddingY:
          d(buttonCompactPaddingY, other.buttonCompactPaddingY),
      buttonIconGap: d(buttonIconGap, other.buttonIconGap),
      buttonMinWidth: d(buttonMinWidth, other.buttonMinWidth),
      buttonPressedScale: d(buttonPressedScale, other.buttonPressedScale),
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
      badgeInfoColorBackground:
          c(badgeInfoColorBackground, other.badgeInfoColorBackground),
      badgeInfoColorText: c(badgeInfoColorText, other.badgeInfoColorText),
      badgeInfoColorBorder:
          c(badgeInfoColorBorder, other.badgeInfoColorBorder),
      offsetBackgroundColor:
          c(offsetBackgroundColor, other.offsetBackgroundColor),
      colorSurfaceMuted: c(colorSurfaceMuted, other.colorSurfaceMuted),
      formBackgroundColor: c(formBackgroundColor, other.formBackgroundColor),
      formHighlightColorBorder:
          c(formHighlightColorBorder, other.formHighlightColorBorder),
      formAccentColor: c(formAccentColor, other.formAccentColor),
      formPlaceholderTextColor:
          c(formPlaceholderTextColor, other.formPlaceholderTextColor),
      formBorderRadius: d(formBorderRadius, other.formBorderRadius),
      inputFieldPaddingX: d(inputFieldPaddingX, other.inputFieldPaddingX),
      inputFieldPaddingY: d(inputFieldPaddingY, other.inputFieldPaddingY),
      textFieldPaddingY: d(textFieldPaddingY, other.textFieldPaddingY),
      inputBorderWidth: d(inputBorderWidth, other.inputBorderWidth),
      inputFocusBorderWidth:
          d(inputFocusBorderWidth, other.inputFocusBorderWidth),
      fieldLabelGap: d(fieldLabelGap, other.fieldLabelGap),
      boxBorderWidth: d(boxBorderWidth, other.boxBorderWidth),
      controlTrackColor: c(controlTrackColor, other.controlTrackColor),
      controlDiameterSm: d(controlDiameterSm, other.controlDiameterSm),
      controlDiameterMd: d(controlDiameterMd, other.controlDiameterMd),
      markerDiameter: d(markerDiameter, other.markerDiameter),
      markerBorderWidth: d(markerBorderWidth, other.markerBorderWidth),
      cardPadding: d(cardPadding, other.cardPadding),
      tableRowPaddingY: d(tableRowPaddingY, other.tableRowPaddingY),
      overlayBorderRadius: d(overlayBorderRadius, other.overlayBorderRadius),
      overlayBackdropColor: c(overlayBackdropColor, other.overlayBackdropColor),
      overlays: t < 0.5 ? overlays : other.overlays,
      shadowLow: BoxShadow.lerpList(shadowLow, other.shadowLow, t) ?? shadowLow,
      shadowMedium:
          BoxShadow.lerpList(shadowMedium, other.shadowMedium, t) ??
              shadowMedium,
      shadowHigh:
          BoxShadow.lerpList(shadowHigh, other.shadowHigh, t) ?? shadowHigh,
      overlayBackdropSubtleColor:
          c(overlayBackdropSubtleColor, other.overlayBackdropSubtleColor),
      tooltipBorderRadius: d(tooltipBorderRadius, other.tooltipBorderRadius),
      dialogMaxWidthSm: d(dialogMaxWidthSm, other.dialogMaxWidthSm),
      dialogMaxWidthMd: d(dialogMaxWidthMd, other.dialogMaxWidthMd),
      dialogMaxWidthLg: d(dialogMaxWidthLg, other.dialogMaxWidthLg),
      dialogMinHeight: d(dialogMinHeight, other.dialogMinHeight),
      chartCategorical: cs(chartCategorical, other.chartCategorical),
      chartOther: c(chartOther, other.chartOther),
      chartSequential: cs(chartSequential, other.chartSequential),
      chartDiverging: cs(chartDiverging, other.chartDiverging),
      authWashGradient: cs(authWashGradient, other.authWashGradient),
      authWashStops: t < 0.5 ? authWashStops : other.authWashStops,
      authWashBegin: t < 0.5 ? authWashBegin : other.authWashBegin,
      authWashEnd: t < 0.5 ? authWashEnd : other.authWashEnd,
      headlineGradient: cs(headlineGradient, other.headlineGradient),
      bloomColor: c(bloomColor, other.bloomColor),
      bloomStops: cs(bloomStops, other.bloomStops),
      brandTintColor: c(brandTintColor, other.brandTintColor),
      wordmarkFontSize: d(wordmarkFontSize, other.wordmarkFontSize),
      wordmarkLetterSpacing:
          d(wordmarkLetterSpacing, other.wordmarkLetterSpacing),
      wordmarkHeight: d(wordmarkHeight, other.wordmarkHeight),
      wordmarkPrimaryFontWeight: FontWeight.lerp(
          wordmarkPrimaryFontWeight, other.wordmarkPrimaryFontWeight, t)!,
      wordmarkAccentFontWeight: FontWeight.lerp(
          wordmarkAccentFontWeight, other.wordmarkAccentFontWeight, t)!,
      wordmarkPrimaryText:
          t < 0.5 ? wordmarkPrimaryText : other.wordmarkPrimaryText,
      wordmarkAccentText:
          t < 0.5 ? wordmarkAccentText : other.wordmarkAccentText,
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
          colorSuccess == other.colorSuccess &&
          colorWarning == other.colorWarning &&
          colorOnPrimary == other.colorOnPrimary &&
          colorOnSignal == other.colorOnSignal &&
          colorAttention == other.colorAttention &&
          radiusXxs == other.radiusXxs &&
          radiusControl == other.radiusControl &&
          radiusLg == other.radiusLg &&
          radiusFull == other.radiusFull &&
          headingXl == other.headingXl &&
          headingLg == other.headingLg &&
          headingMd == other.headingMd &&
          headingSm == other.headingSm &&
          headingXs == other.headingXs &&
          bodyMd == other.bodyMd &&
          bodySm == other.bodySm &&
          labelMd == other.labelMd &&
          labelSm == other.labelSm &&
          bodyLg == other.bodyLg &&
          stepTitle == other.stepTitle &&
          display == other.display &&
          strongLabelFontWeight == other.strongLabelFontWeight &&
          mediumLabelFontWeight == other.mediumLabelFontWeight &&
          iconSizeXxs == other.iconSizeXxs &&
          iconSizeXs == other.iconSizeXs &&
          iconSizeSm == other.iconSizeSm &&
          iconSizeMd == other.iconSizeMd &&
          iconSizeLg == other.iconSizeLg &&
          iconSizeXl == other.iconSizeXl &&
          colorText == other.colorText &&
          colorSecondaryText == other.colorSecondaryText &&
          colorBorder == other.colorBorder &&
          colorBorderSubtle == other.colorBorderSubtle &&
          colorIconMuted == other.colorIconMuted &&
          colorTextDisabled == other.colorTextDisabled &&
          colorInverseSurface == other.colorInverseSurface &&
          colorOnInverse == other.colorOnInverse &&
          colorDangerOnInverse == other.colorDangerOnInverse &&
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
          stateHoverOpacity == other.stateHoverOpacity &&
          statePressedOpacity == other.statePressedOpacity &&
          stateDisabledOpacity == other.stateDisabledOpacity &&
          stateDisabledTextOpacity == other.stateDisabledTextOpacity &&
          stateDisabledIconOpacity == other.stateDisabledIconOpacity &&
          focusRingWidth == other.focusRingWidth &&
          focusRingColor == other.focusRingColor &&
          focusRingGap == other.focusRingGap &&
          minTapTarget == other.minTapTarget &&
          statePressedTintColor == other.statePressedTintColor &&
          stateInkColor == other.stateInkColor &&
          surfaceHoverColor == other.surfaceHoverColor &&
          buttonPrimaryColorBackground == other.buttonPrimaryColorBackground &&
          buttonPrimaryColorBorder == other.buttonPrimaryColorBorder &&
          buttonPrimaryColorText == other.buttonPrimaryColorText &&
          buttonPrimaryDisabledColorBackground ==
              other.buttonPrimaryDisabledColorBackground &&
          buttonPrimaryDisabledColorText ==
              other.buttonPrimaryDisabledColorText &&
          buttonSecondaryColorBackground == other.buttonSecondaryColorBackground &&
          buttonSecondaryColorBorder == other.buttonSecondaryColorBorder &&
          buttonSecondaryColorText == other.buttonSecondaryColorText &&
          buttonDangerColorBackground == other.buttonDangerColorBackground &&
          buttonDangerColorBorder == other.buttonDangerColorBorder &&
          buttonDangerColorText == other.buttonDangerColorText &&
          buttonNeutralColorBackground == other.buttonNeutralColorBackground &&
          buttonNeutralColorBorder == other.buttonNeutralColorBorder &&
          buttonNeutralColorText == other.buttonNeutralColorText &&
          buttonTertiaryColorBackground ==
              other.buttonTertiaryColorBackground &&
          buttonTertiaryColorBorder == other.buttonTertiaryColorBorder &&
          buttonTertiaryColorText == other.buttonTertiaryColorText &&
          buttonPaddingX == other.buttonPaddingX &&
          buttonPaddingY == other.buttonPaddingY &&
          buttonBorderRadius == other.buttonBorderRadius &&
          buttonMinHeight == other.buttonMinHeight &&
          buttonIconSize == other.buttonIconSize &&
          buttonRestBorderWidth == other.buttonRestBorderWidth &&
          buttonLabelFontSize == other.buttonLabelFontSize &&
          buttonLabelFontWeight == other.buttonLabelFontWeight &&
          buttonLabelTextTransform == other.buttonLabelTextTransform &&
          buttonLgLabelFontSize == other.buttonLgLabelFontSize &&
          buttonLgPaddingX == other.buttonLgPaddingX &&
          buttonLgPaddingY == other.buttonLgPaddingY &&
          buttonLgIconSize == other.buttonLgIconSize &&
          buttonCompactPaddingX == other.buttonCompactPaddingX &&
          buttonCompactPaddingY == other.buttonCompactPaddingY &&
          buttonIconGap == other.buttonIconGap &&
          buttonMinWidth == other.buttonMinWidth &&
          buttonPressedScale == other.buttonPressedScale &&
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
          badgeInfoColorBackground == other.badgeInfoColorBackground &&
          badgeInfoColorText == other.badgeInfoColorText &&
          badgeInfoColorBorder == other.badgeInfoColorBorder &&
          offsetBackgroundColor == other.offsetBackgroundColor &&
          colorSurfaceMuted == other.colorSurfaceMuted &&
          formBackgroundColor == other.formBackgroundColor &&
          formHighlightColorBorder == other.formHighlightColorBorder &&
          formAccentColor == other.formAccentColor &&
          formPlaceholderTextColor == other.formPlaceholderTextColor &&
          formBorderRadius == other.formBorderRadius &&
          inputFieldPaddingX == other.inputFieldPaddingX &&
          inputFieldPaddingY == other.inputFieldPaddingY &&
          textFieldPaddingY == other.textFieldPaddingY &&
          inputBorderWidth == other.inputBorderWidth &&
          inputFocusBorderWidth == other.inputFocusBorderWidth &&
          fieldLabelGap == other.fieldLabelGap &&
          boxBorderWidth == other.boxBorderWidth &&
          controlTrackColor == other.controlTrackColor &&
          controlDiameterSm == other.controlDiameterSm &&
          controlDiameterMd == other.controlDiameterMd &&
          markerDiameter == other.markerDiameter &&
          markerBorderWidth == other.markerBorderWidth &&
          cardPadding == other.cardPadding &&
          tableRowPaddingY == other.tableRowPaddingY &&
          overlayBorderRadius == other.overlayBorderRadius &&
          overlayBackdropColor == other.overlayBackdropColor &&
          overlays == other.overlays &&
          listEquals(shadowLow, other.shadowLow) &&
          listEquals(shadowMedium, other.shadowMedium) &&
          listEquals(shadowHigh, other.shadowHigh) &&
          overlayBackdropSubtleColor == other.overlayBackdropSubtleColor &&
          tooltipBorderRadius == other.tooltipBorderRadius &&
          dialogMaxWidthSm == other.dialogMaxWidthSm &&
          dialogMaxWidthMd == other.dialogMaxWidthMd &&
          dialogMaxWidthLg == other.dialogMaxWidthLg &&
          dialogMinHeight == other.dialogMinHeight &&
          listEquals(chartCategorical, other.chartCategorical) &&
          chartOther == other.chartOther &&
          listEquals(chartSequential, other.chartSequential) &&
          listEquals(chartDiverging, other.chartDiverging) &&
          listEquals(authWashGradient, other.authWashGradient) &&
          listEquals(authWashStops, other.authWashStops) &&
          authWashBegin == other.authWashBegin &&
          authWashEnd == other.authWashEnd &&
          listEquals(headlineGradient, other.headlineGradient) &&
          bloomColor == other.bloomColor &&
          listEquals(bloomStops, other.bloomStops) &&
          brandTintColor == other.brandTintColor &&
          wordmarkFontSize == other.wordmarkFontSize &&
          wordmarkLetterSpacing == other.wordmarkLetterSpacing &&
          wordmarkHeight == other.wordmarkHeight &&
          wordmarkPrimaryFontWeight == other.wordmarkPrimaryFontWeight &&
          wordmarkAccentFontWeight == other.wordmarkAccentFontWeight &&
          wordmarkPrimaryText == other.wordmarkPrimaryText &&
          wordmarkAccentText == other.wordmarkAccentText;
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
        colorSuccess,
        colorWarning,
        colorOnPrimary,
        colorOnSignal,
        colorAttention,
        radiusXxs,
        radiusControl,
        radiusLg,
        radiusFull,
        headingXl,
        headingLg,
        headingMd,
        headingSm,
        headingXs,
        bodyMd,
        bodySm,
        labelMd,
        labelSm,
        bodyLg,
        stepTitle,
        display,
        strongLabelFontWeight,
        mediumLabelFontWeight,
        iconSizeXxs,
        iconSizeXs,
        iconSizeSm,
        iconSizeMd,
        iconSizeLg,
        iconSizeXl,
        colorText,
        colorSecondaryText,
        colorBorder,
        colorBorderSubtle,
        colorIconMuted,
        colorTextDisabled,
        colorInverseSurface,
        colorOnInverse,
        colorDangerOnInverse,
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
        stateHoverOpacity,
        statePressedOpacity,
        stateDisabledOpacity,
        stateDisabledTextOpacity,
        stateDisabledIconOpacity,
        focusRingWidth,
        focusRingColor,
        focusRingGap,
        minTapTarget,
        statePressedTintColor,
        stateInkColor,
        surfaceHoverColor,
        buttonPrimaryColorBackground,
        buttonPrimaryColorBorder,
        buttonPrimaryColorText,
        buttonPrimaryDisabledColorBackground,
        buttonPrimaryDisabledColorText,
        buttonSecondaryColorBackground,
        buttonSecondaryColorBorder,
        buttonSecondaryColorText,
        buttonDangerColorBackground,
        buttonDangerColorBorder,
        buttonDangerColorText,
        buttonNeutralColorBackground,
        buttonNeutralColorBorder,
        buttonNeutralColorText,
        buttonTertiaryColorBackground,
        buttonTertiaryColorBorder,
        buttonTertiaryColorText,
        buttonPaddingX,
        buttonPaddingY,
        buttonBorderRadius,
        buttonMinHeight,
        buttonIconSize,
        buttonRestBorderWidth,
        buttonLabelFontSize,
        buttonLabelFontWeight,
        buttonLabelTextTransform,
        buttonLgLabelFontSize,
        buttonLgPaddingX,
        buttonLgPaddingY,
        buttonLgIconSize,
        buttonCompactPaddingX,
        buttonCompactPaddingY,
        buttonIconGap,
        buttonMinWidth,
        buttonPressedScale,
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
        badgeInfoColorBackground,
        badgeInfoColorText,
        badgeInfoColorBorder,
        offsetBackgroundColor,
        colorSurfaceMuted,
        formBackgroundColor,
        formHighlightColorBorder,
        formAccentColor,
        formPlaceholderTextColor,
        formBorderRadius,
        inputFieldPaddingX,
        inputFieldPaddingY,
        textFieldPaddingY,
        inputBorderWidth,
        inputFocusBorderWidth,
        fieldLabelGap,
        boxBorderWidth,
        controlTrackColor,
        controlDiameterSm,
        controlDiameterMd,
        markerDiameter,
        markerBorderWidth,
        cardPadding,
        tableRowPaddingY,
        overlayBorderRadius,
        overlayBackdropColor,
        overlays,
        Object.hashAll(shadowLow),
        Object.hashAll(shadowMedium),
        Object.hashAll(shadowHigh),
        overlayBackdropSubtleColor,
        tooltipBorderRadius,
        dialogMaxWidthSm,
        dialogMaxWidthMd,
        dialogMaxWidthLg,
        dialogMinHeight,
        Object.hashAll(chartCategorical),
        chartOther,
        Object.hashAll(chartSequential),
        Object.hashAll(chartDiverging),
        Object.hashAll(authWashGradient),
        authWashStops == null ? null : Object.hashAll(authWashStops!),
        authWashBegin,
        authWashEnd,
        Object.hashAll(headlineGradient),
        bloomColor,
        Object.hashAll(bloomStops),
        brandTintColor,
        wordmarkFontSize,
        wordmarkLetterSpacing,
        wordmarkHeight,
        wordmarkPrimaryFontWeight,
        wordmarkAccentFontWeight,
        wordmarkPrimaryText,
        wordmarkAccentText,
      ]);
}
