import 'package:flutter/material.dart';

import '../tokens/ds_typography.dart';
import 'ds_tokens_extension.dart';

/// Optional, ready-made brand skins.
///
/// These presets **do not change the default appearance** and have no effect
/// on white-labelling: the core `DsTokens.light()` / `DsTokens.dark()` remain
/// the neutral defaults. A skin is a `DsTokens` value you opt into:
///
/// ```dart
/// MaterialApp(
///   theme: DsTheme.light(tokens: DsSkins.engenLight()),
///   darkTheme: DsTheme.dark(tokens: DsSkins.engenDark()),
/// );
/// ```
///
/// Because a skin is just data (a `DsTokens` built with `copyWith`), you can
/// define your own the same way. [engenLight] / [engenDark] are a full,
/// pixel-accurate re-brand (the Engen fleet identity: deep indigo over
/// navy-tinted slates), carried down to the type tracking and the card shadow.
abstract final class DsSkins {
  // Engen indigo palette (navy-tinted neutrals).
  static const Color _indigo = Color(0xFF15259B); // brand
  static const Color _navyInk = Color(0xFF0B1B45); // body ink
  static const Color _slate = Color(0xFF5B6478); // secondary text
  static const Color _border = Color(0xFFD8DCE5); // border
  static const Color _hairline = Color(0xFFE5E8F0); // badge / divider hairline
  static const Color _fill = Color(0xFFEEF0F5); // muted fill / offset surface
  static const Color _page = Color(0xFFFAFBFD); // page background
  // Placeholder text: the slate ramp step that clears AA contrast (4.5:1) on
  // the white field fill while staying lighter than the secondary slate.
  static const Color _placeholder = Color(0xFF6E7686);
  static const Color _danger = Color(0xFFDF1B41);

  /// The brand-tinted elevation scale: one soft indigo drop that deepens with
  /// height (indigo at 8 to 12%), no grey ink or stacked layers.
  static const List<BoxShadow> _shadowLow = <BoxShadow>[
    BoxShadow(color: Color(0x1415259B), offset: Offset(0, 4), blurRadius: 12),
  ];
  static const List<BoxShadow> _shadowMedium = <BoxShadow>[
    BoxShadow(color: Color(0x1F15259B), offset: Offset(0, 20), blurRadius: 48),
  ];
  static const List<BoxShadow> _shadowHigh = <BoxShadow>[
    BoxShadow(color: Color(0x1F15259B), offset: Offset(0, 26), blurRadius: 56),
  ];

  /// The light Engen skin: deep indigo brand, navy ink, roomier corners, a
  /// tightly-tracked heading ramp and a soft indigo card shadow.
  static DsTokens engenLight() {
    return DsTokens.light().copyWith(
      // Font: the platform system font, per the brand spec.
      fontFamily: null,
      // Brand
      colorPrimary: _indigo,
      buttonPrimaryColorBackground: _indigo,
      buttonPrimaryColorBorder: _indigo,
      actionPrimaryColorText: _indigo,
      actionPrimaryTextDecorationColor: _indigo,
      actionSecondaryColorText: _slate,
      // Ink on brand fills: a soft off-white rather than pure white.
      colorOnPrimary: const Color(0xFFF4F6FC),
      // The tertiary label follows the brand link colour.
      buttonTertiaryColorText: _indigo,
      formAccentColor: _indigo,
      formHighlightColorBorder: _indigo,
      // Text & surfaces
      colorText: _navyInk,
      colorSecondaryText: _slate,
      colorBorder: _border,
      colorBorderSubtle: _hairline,
      colorBackground: _page,
      offsetBackgroundColor: _fill,
      colorSurfaceMuted: _fill,
      formPlaceholderTextColor: _placeholder,
      colorIconMuted: const Color(0xFF7A8295),
      colorTextDisabled: const Color(0xFFBCC2D0),
      // Inverse panel: the navy slate with white ink and a softened danger.
      colorInverseSurface: const Color(0xFF101828),
      colorOnInverse: const Color(0xFFFFFFFF),
      colorDangerOnInverse: const Color(0xFFFF8A80),
      // States and controls: an indigo press tint, a hairline hover fill and
      // a hairline track.
      statePressedTintColor: const Color(0xFFB3BDE0),
      surfaceHoverColor: _hairline,
      controlTrackColor: _hairline,
      colorDanger: _danger,
      // Bright signal tier for meters and live status (distinct from the
      // AA-safe badge container inks).
      colorSuccess: const Color(0xFF1F9D57),
      colorWarning: const Color(0xFFD9870B),
      buttonDangerColorBackground: _danger,
      buttonDangerColorBorder: _danger,
      // Disabled primary: a solid tint (brand flattened onto white) so the
      // treatment reads identically on any backdrop.
      buttonPrimaryDisabledColorBackground: const Color(0xFF9DA3D5),
      buttonPrimaryDisabledColorText: const Color(0xFFF5F6FB),
      // Secondary action: a neutral outline (white fill, hairline border).
      buttonSecondaryColorBackground: const Color(0xFFFFFFFF),
      buttonSecondaryColorBorder: _border,
      buttonSecondaryColorText: _navyInk,
      // Neutral action (federated sign-in): the same quiet outline as the
      // secondary action in this skin.
      buttonNeutralColorBackground: const Color(0xFFFFFFFF),
      buttonNeutralColorBorder: _border,
      buttonNeutralColorText: _navyInk,
      // Badges (Engen container tones). Status borders match their
      // backgrounds so each badge reads as a flat container without an
      // outline; only the neutral badge keeps its hairline.
      badgeNeutralColorBackground: _fill,
      badgeNeutralColorText: _slate,
      badgeNeutralColorBorder: _hairline,
      badgeSuccessColorBackground: const Color(0xFFE4F3EB),
      badgeSuccessColorText: const Color(0xFF116B3C),
      badgeSuccessColorBorder: const Color(0xFFE4F3EB),
      badgeWarningColorBackground: const Color(0xFFFCEEBA),
      badgeWarningColorText: const Color(0xFFA82C00),
      badgeWarningColorBorder: const Color(0xFFFCEEBA),
      badgeDangerColorBackground: const Color(0xFFFCE8EC),
      badgeDangerColorText: const Color(0xFFB01030),
      badgeDangerColorBorder: const Color(0xFFFCE8EC),
      badgeInfoColorBackground: const Color(0xFFEEF1F8),
      badgeInfoColorText: _indigo,
      badgeInfoColorBorder: const Color(0xFFEEF1F8),
      // Badge metrics per the brand spec.
      badgePaddingX: 10,
      badgePaddingY: 4,
      badgeLabelFontSize: 13,
      badgeLabelFontWeight: DsTypography.medium,
      // Shape: roomier corners.
      buttonBorderRadius: 10,
      formBorderRadius: 10,
      badgeBorderRadius: 8,
      overlayBorderRadius: 16,
      borderRadius: 16,
      // Overlays: a navy-tinted backdrop.
      overlayBackdropColor: const Color(0x66101828),
      // Surfaces: the roomier Engen card inset.
      cardPadding: 40,
      // Type: bold headings with the brand's tight tracking; semi-bold labels.
      headingXl: const DsTypeToken(
          fontSize: 32,
          fontWeight: DsTypography.bold,
          height: 1.15,
          letterSpacing: -0.6),
      headingLg: const DsTypeToken(
          fontSize: 24,
          fontWeight: DsTypography.bold,
          height: 1.2,
          letterSpacing: -0.3),
      headingMd: const DsTypeToken(
          fontSize: 20,
          fontWeight: DsTypography.bold,
          height: 1.2,
          letterSpacing: -0.3),
      headingSm: const DsTypeToken(
          fontSize: 16, fontWeight: DsTypography.bold, height: 1.3),
      bodyLg: const DsTypeToken(
          fontSize: 17, fontWeight: DsTypography.regular, height: 1.45),
      bodyMd: const DsTypeToken(
          fontSize: 16, fontWeight: DsTypography.regular, height: 1.4),
      bodySm: const DsTypeToken(
          fontSize: 14, fontWeight: DsTypography.regular, height: 1.4),
      labelMd: const DsTypeToken(
          fontSize: 14, fontWeight: DsTypography.semiBold, height: 1.3),
      labelSm: const DsTypeToken(
          fontSize: 12, fontWeight: DsTypography.medium, height: 1.35),
      // The step and display tiers carry the ramp defaults, stated here so
      // the skin pins them.
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
      mediumLabelFontWeight: DsTypography.semiBold,
      buttonLabelFontSize: 15,
      buttonLabelFontWeight: DsTypography.semiBold,
      // Button metrics per the brand spec: a 16dp glyph beside the 15dp
      // label.
      buttonPaddingX: 22,
      buttonPaddingY: 15,
      buttonIconSize: 16,
      // Inputs: a denser field inset.
      inputFieldPaddingX: 12,
      textFieldPaddingY: 10,
      // Elevation: the brand-tinted scale (low / medium / high).
      shadowLow: _shadowLow,
      shadowMedium: _shadowMedium,
      shadowHigh: _shadowHigh,
      // Auth chrome: white easing out to clear across the page, left to
      // right, so the wash lifts the card side and lets the bloom read on
      // the other.
      authWashGradient: const [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
      authWashStops: const [0.42, 0.74],
      authWashBegin: Alignment.centerLeft,
      authWashEnd: Alignment.centerRight,
      // The single-hue fallback to bloomStops.
      bloomColor: const Color(0xFF5AA8E0),
      // The five-pool spotlight bloom, read left to right along the bottom
      // edge: a coral lift, warm red, sky and light blue, into the deep navy
      // corner anchor.
      bloomStops: const [
        Color(0xFFF48A8A),
        Color(0xFFE85A62),
        Color(0xFF7DC3EB),
        Color(0xFF5AA8E0),
        Color(0xFF004D7A),
      ],
      // A pale indigo tint for brand-soft badges and washes (the "verifying"
      // receipt check), with the indigo action colour as the ink on top.
      brandTintColor: const Color(0xFFEEF1F8),
      // The brand headline sweep: coral through sky and cobalt into the deep
      // indigo.
      headlineGradient: const [
        Color(0xFFE2231A),
        Color(0xFF6BB4DE),
        Color(0xFF2F6FBF),
        Color(0xFF15259B),
      ],
      // Wordmark: EngenXT, bold with an extra-bold accent.
      wordmarkPrimaryText: 'Engen',
      wordmarkAccentText: 'XT',
      wordmarkPrimaryFontWeight: DsTypography.bold,
      wordmarkAccentFontWeight: DsTypography.extraBold,
    );
  }

  /// The dark Engen skin.
  static DsTokens engenDark() {
    return DsTokens.dark().copyWith(
      colorPrimary: const Color(0xFF5A6BE0),
      actionPrimaryColorText: const Color(0xFF9DA8F0),
      actionPrimaryTextDecorationColor: const Color(0xFF9DA8F0),
      // The tertiary label follows the skin's dark link colour.
      buttonTertiaryColorText: const Color(0xFF9DA8F0),
      formAccentColor: const Color(0xFF5A6BE0),
      buttonPrimaryColorBackground: const Color(0xFF3B49C4),
      buttonPrimaryColorBorder: const Color(0xFF3B49C4),
      // Disabled primary: the dark indigo flattened onto the dark page, a
      // solid tint mirroring the light skin's treatment.
      buttonPrimaryDisabledColorBackground: const Color(0xFF232A60),
      buttonPrimaryDisabledColorText: const Color(0xFFE9EAEF),
      buttonBorderRadius: 10,
      formBorderRadius: 10,
      badgeBorderRadius: 8,
      overlayBorderRadius: 16,
      borderRadius: 16,
      headingXl: const DsTypeToken(
          fontSize: 32,
          fontWeight: DsTypography.bold,
          height: 1.2,
          letterSpacing: -0.4),
      headingLg: const DsTypeToken(
          fontSize: 24,
          fontWeight: DsTypography.bold,
          height: 1.2,
          letterSpacing: -0.4),
      // The same mid-ramp overrides as the light skin, so the brand's
      // heading voice carries into dark.
      headingMd: const DsTypeToken(
          fontSize: 20,
          fontWeight: DsTypography.bold,
          height: 1.25,
          letterSpacing: -0.2),
      headingSm: const DsTypeToken(
          fontSize: 16, fontWeight: DsTypography.bold, height: 1.3),
      labelMd: const DsTypeToken(
          fontSize: 14, fontWeight: DsTypography.semiBold, height: 1.4),
      labelSm: const DsTypeToken(
          fontSize: 12, fontWeight: DsTypography.medium, height: 1.35),
      mediumLabelFontWeight: DsTypography.semiBold,
      buttonLabelFontSize: 15,
      buttonLabelFontWeight: DsTypography.semiBold,
      // Button metrics per the brand spec: a 16dp glyph beside the 15dp
      // label.
      buttonPaddingX: 22,
      buttonPaddingY: 15,
      buttonIconSize: 16,
      // Inputs: a denser field inset.
      inputFieldPaddingX: 12,
      textFieldPaddingY: 10,
      // Badge metrics carried into dark, with an indigo info container and
      // the dark link ink.
      badgePaddingX: 10,
      badgePaddingY: 4,
      badgeLabelFontSize: 13,
      badgeLabelFontWeight: DsTypography.medium,
      badgeInfoColorBackground: const Color(0xFF20264D),
      badgeInfoColorText: const Color(0xFF9DA8F0),
      badgeInfoColorBorder: const Color(0xFF20264D),
      // A dark indigo press tint.
      statePressedTintColor: const Color(0xFF2A3470),
      // Surfaces: the roomier Engen card inset.
      cardPadding: 40,
      // Deeper drops read on the dark surfaces.
      shadowLow: const <BoxShadow>[
        BoxShadow(
            color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 12),
      ],
      shadowMedium: const <BoxShadow>[
        BoxShadow(
            color: Color(0x66000000), offset: Offset(0, 20), blurRadius: 48),
      ],
      shadowHigh: const <BoxShadow>[
        BoxShadow(
            color: Color(0x73000000), offset: Offset(0, 26), blurRadius: 56),
      ],
      // Auth chrome: the dark page drifting into a deep navy wash, the bloom
      // dimmed to hold the same soft glow on dark surfaces.
      authWashGradient: const [Color(0xFF121317), Color(0xFF101B2E)],
      bloomColor: const Color(0xFF2B5E8F),
      // The same five-pool sweep, dimmed to a low-saturation navy-forward set
      // so the glow reads on the dark page without turning garish.
      bloomStops: const [
        Color(0xFF3E2C57),
        Color(0xFF4A2733),
        Color(0xFF1F4E6E),
        Color(0xFF2B5E8F),
        Color(0xFF0C2A46),
      ],
      // A dark indigo tint for brand-soft badges, with the dark link colour as
      // the ink on top.
      brandTintColor: const Color(0xFF20264D),
      // Wordmark: EngenXT, bold with an extra-bold accent.
      wordmarkPrimaryText: 'Engen',
      wordmarkAccentText: 'XT',
      wordmarkPrimaryFontWeight: DsTypography.bold,
      wordmarkAccentFontWeight: DsTypography.extraBold,
    );
  }
}
