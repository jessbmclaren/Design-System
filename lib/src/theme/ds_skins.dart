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

  // --- Editorial ------------------------------------------------------------

  // The editorial palette: ink on paper, with a single restrained accent.
  static const Color _ink = Color(0xFF0A0A0A); // near-black body ink
  static const Color _inkSoft = Color(0xFF5A5A5A); // secondary ink
  static const Color _rule = Color(0xFFDCDCDC); // hairline rule
  static const Color _ruleFaint = Color(0xFFEDEDED); // faint rule
  static const Color _paper = Color(0xFFFFFFFF); // page
  static const Color _paperTinted = Color(0xFFF4F2EF); // warm offset paper
  static const Color _accent = Color(0xFF8A1C1C); // deep editorial red

  /// A high-contrast editorial skin: ink on paper, sharp corners, letter-spaced
  /// upper-case labels and a single deep-red accent.
  ///
  /// The look borrows from print rather than from software. Contrast does the
  /// work colour usually does, so the palette is almost monochrome and the one
  /// accent is spent only where an action must be found. Corners are square,
  /// shadows are almost absent and rules are hairlines, because a page has no
  /// depth; emphasis comes from scale and weight instead. Labels are set in
  /// upper case with wide tracking, the way a masthead sets its furniture.
  ///
  /// It is a skin like any other: the neutral base is untouched, and a product
  /// opts in with `DsTheme.light(tokens: DsSkins.editorialLight())`.
  static DsTokens editorialLight() {
    return DsTokens.light().copyWith(
      // Ink and paper.
      colorText: _ink,
      colorSecondaryText: _inkSoft,
      colorBorder: _rule,
      colorBorderSubtle: _ruleFaint,
      colorBackground: _paper,
      offsetBackgroundColor: _paperTinted,
      colorSurfaceMuted: _paperTinted,
      formBackgroundColor: _paper,
      formPlaceholderTextColor: const Color(0xFF767676),
      colorIconMuted: _inkSoft,
      // The accent is spent sparingly: actions, links, focus.
      colorPrimary: _accent,
      buttonPrimaryColorBackground: _ink,
      buttonPrimaryColorBorder: _ink,
      buttonPrimaryColorText: _paper,
      colorOnPrimary: _paper,
      actionPrimaryColorText: _accent,
      actionPrimaryTextDecorationColor: _accent,
      buttonTertiaryColorText: _accent,
      formAccentColor: _ink,
      formHighlightColorBorder: _ink,
      brandTintColor: _paperTinted,
      // Secondary and neutral actions are outlines, as a rule on a page.
      buttonSecondaryColorBackground: _paper,
      buttonSecondaryColorBorder: _ink,
      buttonSecondaryColorText: _ink,
      buttonNeutralColorBackground: _paper,
      buttonNeutralColorBorder: _rule,
      buttonNeutralColorText: _ink,
      buttonPrimaryDisabledColorBackground: const Color(0xFFBDBDBD),
      buttonPrimaryDisabledColorText: _paper,
      // Badges are hairline-bordered marks rather than filled pills.
      badgeNeutralColorBackground: _paper,
      badgeNeutralColorText: _ink,
      badgeNeutralColorBorder: _rule,
      badgeInfoColorBackground: _paper,
      badgeInfoColorText: _ink,
      badgeInfoColorBorder: _ink,
      badgeSuccessColorBackground: _paper,
      badgeSuccessColorText: const Color(0xFF1F5130),
      badgeSuccessColorBorder: const Color(0xFF1F5130),
      badgeWarningColorBackground: _paper,
      badgeWarningColorText: const Color(0xFF7A4A00),
      badgeWarningColorBorder: const Color(0xFF7A4A00),
      badgeDangerColorBackground: _paper,
      badgeDangerColorText: _accent,
      badgeDangerColorBorder: _accent,
      // Shape: square, the way a column of type is square.
      borderRadius: 0,
      buttonBorderRadius: 0,
      formBorderRadius: 0,
      badgeBorderRadius: 0,
      overlayBorderRadius: 0,
      radiusControl: 0,
      tooltipBorderRadius: 0,
      // This skin has no pills: a chip is a rule-bordered mark like every
      // other, so even the fully-rounded step squares off.
      radiusFull: 0,
      // Depth: a page has none. The rules carry the structure instead.
      shadowLow: const <BoxShadow>[],
      shadowMedium: const <BoxShadow>[
        BoxShadow(color: Color(0x14000000), offset: Offset(0, 8), blurRadius: 24),
      ],
      shadowHigh: const <BoxShadow>[
        BoxShadow(color: Color(0x1F000000), offset: Offset(0, 16), blurRadius: 40),
      ],
      // Type: a wide scale, tight display tracking, generous body leading.
      display: const DsTypeToken(
          fontSize: 72,
          fontWeight: DsTypography.extraBold,
          height: 0.95,
          letterSpacing: -2.4),
      headingXl: const DsTypeToken(
          fontSize: 44,
          fontWeight: DsTypography.bold,
          height: 1.05,
          letterSpacing: -1.2),
      stepTitle: const DsTypeToken(
          fontSize: 34,
          fontWeight: DsTypography.bold,
          height: 1.1,
          letterSpacing: -0.8),
      headingLg: const DsTypeToken(
          fontSize: 30,
          fontWeight: DsTypography.bold,
          height: 1.1,
          letterSpacing: -0.6),
      headingMd: const DsTypeToken(
          fontSize: 22,
          fontWeight: DsTypography.bold,
          height: 1.2,
          letterSpacing: -0.3),
      headingSm: const DsTypeToken(
          fontSize: 17, fontWeight: DsTypography.semiBold, height: 1.3),
      // Section furniture is set small, upper case and widely tracked.
      headingXs: const DsTypeToken(
          fontSize: 11,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: 1.4),
      bodyLg: const DsTypeToken(
          fontSize: 18, fontWeight: DsTypography.regular, height: 1.6),
      bodyMd: const DsTypeToken(
          fontSize: 16, fontWeight: DsTypography.regular, height: 1.6),
      bodySm: const DsTypeToken(
          fontSize: 14, fontWeight: DsTypography.regular, height: 1.55),
      labelMd: const DsTypeToken(
          fontSize: 13,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: 0.4),
      labelSm: const DsTypeToken(
          fontSize: 11,
          fontWeight: DsTypography.medium,
          height: 1.3,
          letterSpacing: 0.8),
      // Labels read as masthead furniture: upper case, widely tracked.
      buttonLabelTextTransform: DsTextTransform.uppercase,
      badgeLabelTextTransform: DsTextTransform.uppercase,
      buttonLabelFontSize: 12,
      buttonLabelFontWeight: DsTypography.semiBold,
      buttonPaddingX: 28,
      buttonPaddingY: 18,
      buttonIconSize: 14,
      badgeLabelFontSize: 10,
      badgeLabelFontWeight: DsTypography.semiBold,
      badgePaddingX: 8,
      badgePaddingY: 4,
      // Room to breathe: a printed page is mostly margin.
      cardPadding: 40,
      // The auth wash is paper, warming towards the edge.
      authWashGradient: const <Color>[_paper, _paperTinted],
      bloomColor: const Color(0xFFE8DFD6),
      bloomStops: const <Color>[
        Color(0xFFF0E6DC),
        Color(0xFFE8DFD6),
        Color(0xFFDCD3CB),
        Color(0xFFE8DFD6),
        Color(0xFF8A1C1C),
      ],
      headlineGradient: const <Color>[_ink, _accent],
      wordmarkPrimaryFontWeight: DsTypography.extraBold,
      wordmarkAccentFontWeight: DsTypography.regular,
      wordmarkLetterSpacing: -1.2,
    );
  }

  /// The dark editorial skin: the same page, printed white on black.
  static DsTokens editorialDark() {
    return DsTokens.dark().copyWith(
      colorText: const Color(0xFFF5F3F0),
      colorSecondaryText: const Color(0xFFA8A29B),
      colorBorder: const Color(0xFF3A3A3A),
      colorBorderSubtle: const Color(0xFF242424),
      colorBackground: const Color(0xFF0A0A0A),
      offsetBackgroundColor: const Color(0xFF161513),
      colorPrimary: const Color(0xFFD98484),
      actionPrimaryColorText: const Color(0xFFD98484),
      actionPrimaryTextDecorationColor: const Color(0xFFD98484),
      buttonTertiaryColorText: const Color(0xFFD98484),
      buttonPrimaryColorBackground: const Color(0xFFF5F3F0),
      buttonPrimaryColorBorder: const Color(0xFFF5F3F0),
      buttonPrimaryColorText: const Color(0xFF0A0A0A),
      formAccentColor: const Color(0xFFF5F3F0),
      formHighlightColorBorder: const Color(0xFFF5F3F0),
      brandTintColor: const Color(0xFF221F1D),
      // Outlines, as on the light page: a rule carries the mark, not a fill.
      buttonSecondaryColorBackground: const Color(0x00000000),
      buttonSecondaryColorBorder: const Color(0xFFF5F3F0),
      buttonSecondaryColorText: const Color(0xFFF5F3F0),
      buttonNeutralColorBackground: const Color(0x00000000),
      buttonNeutralColorBorder: const Color(0xFF3A3A3A),
      buttonNeutralColorText: const Color(0xFFF5F3F0),
      badgeNeutralColorBackground: const Color(0x00000000),
      badgeNeutralColorText: const Color(0xFFF5F3F0),
      badgeNeutralColorBorder: const Color(0xFF3A3A3A),
      badgeInfoColorBackground: const Color(0x00000000),
      badgeInfoColorText: const Color(0xFFF5F3F0),
      badgeInfoColorBorder: const Color(0xFFF5F3F0),
      badgeSuccessColorBackground: const Color(0x00000000),
      badgeSuccessColorText: const Color(0xFF7FBF95),
      badgeSuccessColorBorder: const Color(0xFF7FBF95),
      badgeWarningColorBackground: const Color(0x00000000),
      badgeWarningColorText: const Color(0xFFE0B357),
      badgeWarningColorBorder: const Color(0xFFE0B357),
      badgeDangerColorBackground: const Color(0x00000000),
      badgeDangerColorText: const Color(0xFFD98484),
      badgeDangerColorBorder: const Color(0xFFD98484),
      borderRadius: 0,
      buttonBorderRadius: 0,
      formBorderRadius: 0,
      badgeBorderRadius: 0,
      overlayBorderRadius: 0,
      radiusControl: 0,
      tooltipBorderRadius: 0,
      radiusFull: 0,
      buttonLabelTextTransform: DsTextTransform.uppercase,
      badgeLabelTextTransform: DsTextTransform.uppercase,
      buttonLabelFontSize: 12,
      buttonLabelFontWeight: DsTypography.semiBold,
      buttonPaddingX: 28,
      buttonPaddingY: 18,
      badgeLabelFontSize: 10,
      badgePaddingX: 8,
      badgePaddingY: 4,
      cardPadding: 40,
      headingXl: const DsTypeToken(
          fontSize: 44,
          fontWeight: DsTypography.bold,
          height: 1.05,
          letterSpacing: -1.2),
      headingLg: const DsTypeToken(
          fontSize: 30,
          fontWeight: DsTypography.bold,
          height: 1.1,
          letterSpacing: -0.6),
      headingXs: const DsTypeToken(
          fontSize: 11,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: 1.4),
      bodyMd: const DsTypeToken(
          fontSize: 16, fontWeight: DsTypography.regular, height: 1.6),
      bodySm: const DsTypeToken(
          fontSize: 14, fontWeight: DsTypography.regular, height: 1.55),
      labelSm: const DsTypeToken(
          fontSize: 11,
          fontWeight: DsTypography.medium,
          height: 1.3,
          letterSpacing: 0.8),
    );
  }

  // --- Engen Mobile ---------------------------------------------------------

  // The Engen Mobile palette, taken from the EngenXT mobile design. These are
  // the design's values as drawn, not an interpretation of them, so the skin
  // and the design stay one artefact.
  //
  // Measured, for a retune to check against rather than guess:
  //
  // * the blue carries white label text at 7.31:1,
  // * the ink sets on white at 16.99:1 and the secondary ink at 5.44:1,
  // * the red carries white label text at 4.68:1.
  //
  // The skin holds the design's values as drawn, with exactly two exceptions,
  // both forced rather than chosen. `DsTheme` carries a debug-only contrast
  // guard that refuses to build a theme whose badge ink fails AA on its own
  // fill, and the design's bright orange reaches only 2.47:1 on the warning
  // wash and its red 4.15:1 on the red wash. So the badge *label* takes a
  // darkened ink, while `colorWarning` and `colorDanger` keep the design's
  // bright values for every fill and signal, which is where the design
  // actually uses them.
  //
  // The muted and disabled greys are not guarded and are kept exactly as
  // drawn, even though neither clears AA: measured, the muted ink is 1.92:1 on
  // white and the disabled grey 1.68:1. The design annotates them 3.66:1 and
  // 4.54:1, which does not hold. `test/a11y/contrast_test.dart` records the
  // muted ink as a named exception so the debt stays visible rather than
  // silently passing. Reserve it for decorative or large text.
  static const Color _azure = Color(0xFF1650B8); // brand
  static const Color _azureDeep = Color(0xFF0D3A8A); // brand, deep
  static const Color _azureSoft = Color(0xFFEEF3FF); // brand wash
  static const Color _mobileInk = Color(0xFF0D1E2A); // body ink
  static const Color _mobileInkSoft = Color(0xFF5A6A8A); // secondary text
  static const Color _mobileInkMuted = Color(0xFFB0BCD0); // muted text
  static const Color _mobileBorder = Color(0x14000000); // 8% black
  static const Color _mobileBorderStrong = Color(0x1F000000); // 12% black
  static const Color _mobileHairline = Color(0x0F000000); // 6% black
  static const Color _mobileFill = Color(0xFFF2F2F7); // muted / offset surface
  static const Color _mobilePlaceholder = Color(0xFF6B7488); // placeholder
  static const Color _mobileRed = Color(0xFFE2231A); // second brand mark
  static const Color _mobileRedSoft = Color(0xFFFDEEEE); // red wash
  static const Color _mobileRedInk = Color(0xFFC21A12); // badge ink, 5.40:1
  static const Color _mobileSuccess = Color(0xFF1A7A3A);
  static const Color _mobileSuccessSoft = Color(0xFFE8F5EE);
  static const Color _mobileWarning = Color(0xFFF57C00);
  static const Color _mobileWarningInk = Color(0xFFA85700); // badge ink, 4.75:1
  static const Color _mobileWarningSoft = Color(0xFFFFF3E0);

  /// A touch-first mobile skin taken from the EngenXT mobile design: blue on
  /// white, pill controls, the iOS reading ramp and edge-anchored overlays.
  ///
  /// This is a phone theme rather than a desktop theme shrunk down, and the
  /// differences are deliberate:
  ///
  /// * **Controls are thumb-sized.** Buttons stand 52dp tall with a stadium
  ///   corner, because a control the thumb has to aim at is a different object
  ///   from one the pointer lands on precisely.
  /// * **Cards hold less inset, not more.** A phone is narrow, so padding that
  ///   reads as generous on a desktop card eats the line length a paragraph
  ///   needs. The corners grow instead.
  /// * **Glyphs run one step up.** An icon legible at arm's length on a
  ///   monitor is not legible at a glance, one-handed, outdoors.
  /// * **Overlays present as drawers.** A sheet from the edge is the mobile
  ///   idiom; a centred dialog is not.
  /// * **The focus ring is a stroke thicker**, so it survives a bright screen.
  ///
  /// It is a skin like any other: the neutral base is untouched, and a product
  /// opts in with `DsTheme.light(tokens: DsSkins.engenMobileLight())`.
  static DsTokens engenMobileLight() {
    return DsTokens.light().copyWith(
      // Font: the platform system font, so the app sets in the face the
      // device already reads in.
      fontFamily: null,
      // Brand
      colorPrimary: _azure,
      buttonPrimaryColorBackground: _azure,
      buttonPrimaryColorBorder: _azure,
      actionPrimaryColorText: _azure,
      actionPrimaryTextDecorationColor: _azure,
      actionSecondaryColorText: _mobileInkSoft,
      buttonTertiaryColorText: _azure,
      formAccentColor: _azure,
      formHighlightColorBorder: _azure,
      focusRingColor: _azure,
      // The second brand mark: this brand runs a red alongside the blue, and
      // the red carries a brand-owned highlight as well as the danger signal.
      colorBrandSecondary: _mobileRed,
      colorBrandSecondaryTint: _mobileRedSoft,
      // Text and surfaces: ink on white, with the fill tier one step off it.
      // The borders are alpha black rather than a mixed grey, so a rule reads
      // the same over a card, a wash or a photograph.
      colorText: _mobileInk,
      colorSecondaryText: _mobileInkSoft,
      colorTextMuted: _mobileInkMuted,
      colorBorder: _mobileBorder,
      colorBorderSubtle: _mobileHairline,
      colorBackground: const Color(0xFFFFFFFF),
      offsetBackgroundColor: _mobileFill,
      colorSurfaceMuted: _mobileFill,
      formPlaceholderTextColor: _mobilePlaceholder,
      colorIconMuted: _mobileInkSoft,
      colorTextDisabled: const Color(0xFFC7C7CC),
      // Signals
      colorDanger: _mobileRed,
      colorSuccess: _mobileSuccess,
      colorWarning: _mobileWarning,
      buttonDangerColorBackground: _mobileRed,
      buttonDangerColorBorder: _mobileRed,
      // Disabled primary: a solid tint, so the treatment reads identically on
      // any backdrop rather than picking up whatever sits behind it.
      buttonPrimaryDisabledColorBackground: const Color(0xFF8BA8DC),
      buttonPrimaryDisabledColorText: const Color(0xFFF5F8FE),
      // Secondary and neutral actions: a quiet outline on white. The outline
      // takes the stronger black, since the hairline tier disappears on a
      // control the thumb is meant to find.
      buttonSecondaryColorBackground: const Color(0xFFFFFFFF),
      buttonSecondaryColorBorder: _mobileBorderStrong,
      buttonSecondaryColorText: _mobileInk,
      buttonNeutralColorBackground: const Color(0xFFFFFFFF),
      buttonNeutralColorBorder: _mobileBorderStrong,
      buttonNeutralColorText: _mobileInk,
      // States: a press tint mixed from the brand at a quarter strength, and a
      // hairline hover fill.
      statePressedTintColor: const Color(0xFFC5D3ED),
      surfaceHoverColor: _mobileHairline,
      controlTrackColor: _mobileBorderStrong,
      // Badges: pill containers in the design's washes, each label carrying the
      // design's own signal ink.
      badgeNeutralColorBackground: _mobileFill,
      badgeNeutralColorText: _mobileInkSoft,
      badgeNeutralColorBorder: _mobileHairline,
      // Each status badge carries a visible outline in its own hue at low
      // alpha, the way the design draws them, rather than a border matched to
      // the fill. The pill reads as an outlined chip, not a flat wash.
      badgeSuccessColorBackground: _mobileSuccessSoft,
      badgeSuccessColorText: _mobileSuccess,
      badgeSuccessColorBorder: const Color(0x591A7A3A),
      badgeWarningColorBackground: _mobileWarningSoft,
      badgeWarningColorText: _mobileWarningInk,
      badgeWarningColorBorder: const Color(0x40F57C00),
      badgeDangerColorBackground: _mobileRedSoft,
      badgeDangerColorText: _mobileRedInk,
      badgeDangerColorBorder: const Color(0x40E2231A),
      badgeInfoColorBackground: _azureSoft,
      badgeInfoColorText: _azureDeep,
      badgeInfoColorBorder: const Color(0x1F1650B8),
      badgeBorderRadius: 999,
      badgePaddingX: 10,
      badgePaddingY: 4,
      badgeLabelFontSize: 13,
      badgeLabelFontWeight: DsTypography.medium,
      // Shape, read off the design's radius scale: a pill for anything the
      // thumb presses, a 16dp card, a 10dp chip, a 28dp sheet. The pill is set
      // past any control height and Flutter clamps it to a stadium, so a
      // control stays a pill whatever its size.
      buttonBorderRadius: 999,
      formBorderRadius: 14,
      radiusXxs: 4,
      radiusControl: 10,
      radiusLg: 16,
      overlayBorderRadius: 28,
      borderRadius: 16,
      // Touch geometry: the design stands its calls to action at 56dp, and the
      // field follows so a form reads as one stack of equal controls.
      buttonMinHeight: 56,
      buttonPaddingX: 24,
      buttonPaddingY: 16,
      buttonIconSize: 20,
      buttonIconGap: 10,
      inputFieldPaddingX: 16,
      textFieldPaddingY: 16,
      fieldLabelGap: 8,
      // A thicker ring, so keyboard focus survives a bright screen outdoors.
      focusRingWidth: 3,
      // Cards hold a tighter inset than a desktop skin: the phone is narrow,
      // and the line length matters more than the margin.
      cardPadding: 20,
      // Glyphs run one step up the scale, for a screen read at arm's length
      // and often one-handed.
      iconSizeXxs: 14,
      iconSizeXs: 16,
      iconSizeSm: 18,
      iconSizeMd: 20,
      iconSizeLg: 24,
      iconSizeXl: 28,
      // Overlays present from the edge, the mobile idiom, rather than as a
      // centred dialog.
      overlays: DsOverlayStyle.drawer,
      overlayBackdropColor: const Color(0x800A1628),
      // Type: the design's iOS ramp, carrying its tracking. Running text sets
      // at 15 and the large tiers step 28, 34, 48 with the negative tracking
      // that keeps big type from looking loose.
      bodyLg: const DsTypeToken(
          fontSize: 17,
          fontWeight: DsTypography.regular,
          height: 1.5,
          letterSpacing: -0.2),
      bodyMd: const DsTypeToken(
          fontSize: 15,
          fontWeight: DsTypography.regular,
          height: 1.5,
          letterSpacing: -0.2),
      bodySm: const DsTypeToken(
          fontSize: 14,
          fontWeight: DsTypography.regular,
          height: 1.4,
          letterSpacing: -0.1),
      display: const DsTypeToken(
          fontSize: 48,
          fontWeight: DsTypography.extraBold,
          height: 1.05,
          letterSpacing: -2),
      stepTitle: const DsTypeToken(
          fontSize: 34,
          fontWeight: DsTypography.bold,
          height: 1.15,
          letterSpacing: -1),
      headingXl: const DsTypeToken(
          fontSize: 28,
          fontWeight: DsTypography.bold,
          height: 1.2,
          letterSpacing: -1),
      headingLg: const DsTypeToken(
          fontSize: 22,
          fontWeight: DsTypography.bold,
          height: 1.25,
          letterSpacing: -0.5),
      headingMd: const DsTypeToken(
          fontSize: 18,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: -0.3),
      headingSm: const DsTypeToken(
          fontSize: 17,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: -0.2),
      headingXs: const DsTypeToken(
          fontSize: 12,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: -0.1),
      labelMd: const DsTypeToken(
          fontSize: 15,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: -0.2),
      labelSm: const DsTypeToken(
          fontSize: 13,
          fontWeight: DsTypography.medium,
          height: 1.35,
          letterSpacing: -0.1),
      buttonLabelFontSize: 17,
      buttonLabelFontWeight: DsTypography.semiBold,
      // Elevation: the design's two-part drop, a tight neutral contact shadow
      // under a wider brand-tinted one, so a raised surface reads as lifting
      // off a blue-cast page rather than casting a grey box shadow.
      shadowLow: const <BoxShadow>[
        BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 2),
        BoxShadow(color: Color(0x0F1650B8), offset: Offset(0, 2), blurRadius: 8),
      ],
      shadowMedium: const <BoxShadow>[
        BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 3),
        BoxShadow(
            color: Color(0x1C1650B8), offset: Offset(0, 8), blurRadius: 28),
      ],
      shadowHigh: const <BoxShadow>[
        BoxShadow(color: Color(0x0F000000), offset: Offset(0, 2), blurRadius: 6),
        BoxShadow(
            color: Color(0x291650B8), offset: Offset(0, 12), blurRadius: 40),
      ],
      // The eyebrow above a heading is set in caps and tracked out, the
      // design's kicker treatment: 0.08em at 13, which is 1.04 logical pixels.
      labelEyebrow: const DsTypeToken(
          fontSize: 13,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: 1.04,
          textTransform: DsTextTransform.uppercase),
      // The brand's gradient, corner to corner: the blue deepening across a
      // promoted panel, and the same ramp under the primary button, which is
      // how the design fills its calls to action.
      brandGradient: const <Color>[_azure, _azureDeep],
      buttonPrimaryGradient: const <Color>[_azure, _azureDeep],
      // Auth chrome: the design's map-blue wash lifting off the top.
      authWashGradient: const [Color(0xFFE8F1FB), Color(0xFFFFFFFF)],
      authWashStops: const [0.0, 0.55],
      bloomColor: _azureSoft,
      brandTintColor: _azureSoft,
      wordmarkPrimaryText: 'Engen',
      wordmarkAccentText: 'XT',
      wordmarkPrimaryFontWeight: DsTypography.bold,
      // The mark's suffix is set in the second brand colour, not just a
      // heavier weight.
      wordmarkAccentColor: _mobileRed,
    );
  }

  /// The dark Engen Mobile skin: the same touch geometry on a deep navy page.
  static DsTokens engenMobileDark() {
    return DsTokens.dark().copyWith(
      // Font: the platform system font, as in light. The two modes are the
      // same object in different light, and a phone app that sets in the
      // bundled face in the dark and the device's own in the day is two
      // different apps.
      fontFamily: null,
      // Brand: the blue lifts on dark, and the button fill runs deeper so
      // white label text still clears AA (5.82:1).
      colorPrimary: const Color(0xFF5B9DFF),
      actionPrimaryColorText: const Color(0xFF8FBEFF),
      actionPrimaryTextDecorationColor: const Color(0xFF8FBEFF),
      buttonTertiaryColorText: const Color(0xFF8FBEFF),
      formAccentColor: const Color(0xFF5B9DFF),
      formHighlightColorBorder: const Color(0xFF5B9DFF),
      focusRingColor: const Color(0xFF5B9DFF),
      buttonPrimaryColorBackground: const Color(0xFF1F5FD0),
      buttonPrimaryColorBorder: const Color(0xFF1F5FD0),
      buttonPrimaryDisabledColorBackground: const Color(0xFF1B3560),
      buttonPrimaryDisabledColorText: const Color(0xFFE9EEF7),
      // The second mark lifts too: the brand red is too dark to read as text
      // on the navy page, so a lighter tone carries it while the solid red is
      // kept for the fill a white label sits on.
      colorBrandSecondary: const Color(0xFFFF8A80),
      colorBrandSecondaryTint: const Color(0xFF3A1512),
      // Surfaces: the design's deep navy page, with the raised tier above it.
      colorBackground: const Color(0xFF0A1628),
      formBackgroundColor: const Color(0xFF0D2040),
      offsetBackgroundColor: const Color(0xFF0D2040),
      colorSurfaceMuted: const Color(0xFF0D2040),
      colorBorder: const Color(0x1AFFFFFF),
      colorBorderSubtle: const Color(0x0FFFFFFF),
      colorText: const Color(0xFFE9EEF7),
      colorSecondaryText: const Color(0xFFA9B6CE),
      colorTextMuted: const Color(0xFF8493AE),
      colorIconMuted: const Color(0xFF8493AE),
      colorTextDisabled: const Color(0xFF5A6A88),
      // Signals: the fills stay solid so a white label holds, the inks lift.
      colorDanger: const Color(0xFFFF8A80),
      colorSuccess: const Color(0xFF5FD98A),
      colorWarning: const Color(0xFFFFB74D),
      buttonDangerColorBackground: _mobileRed,
      buttonDangerColorBorder: _mobileRed,
      // Secondary and neutral actions: the raised navy tier under a white
      // outline. The neutral base fills these with a warm grey, which reads as
      // a foreign object on a blue-cast page.
      buttonSecondaryColorBackground: const Color(0xFF0D2040),
      buttonSecondaryColorBorder: const Color(0x33FFFFFF),
      buttonSecondaryColorText: const Color(0xFFE9EEF7),
      buttonNeutralColorBackground: const Color(0xFF0D2040),
      buttonNeutralColorBorder: const Color(0x33FFFFFF),
      buttonNeutralColorText: const Color(0xFFE9EEF7),
      controlTrackColor: const Color(0x1AFFFFFF),
      statePressedTintColor: const Color(0xFF17325C),
      surfaceHoverColor: const Color(0x14FFFFFF),
      // Badges: deep washes carrying a lifted ink.
      badgeNeutralColorBackground: const Color(0xFF0D2040),
      badgeNeutralColorText: const Color(0xFFA9B6CE),
      badgeNeutralColorBorder: const Color(0x1AFFFFFF),
      // As in light, each pill carries a visible outline in its own hue, here
      // lifted from the ink rather than the fill so it reads on the dark page.
      badgeSuccessColorBackground: const Color(0xFF0E2E1E),
      badgeSuccessColorText: const Color(0xFF7BE0A5),
      badgeSuccessColorBorder: const Color(0x597BE0A5),
      badgeWarningColorBackground: const Color(0xFF33220A),
      badgeWarningColorText: const Color(0xFFFFC069),
      badgeWarningColorBorder: const Color(0x59FFC069),
      badgeDangerColorBackground: const Color(0xFF3A1512),
      badgeDangerColorText: const Color(0xFFFF9A91),
      badgeDangerColorBorder: const Color(0x59FF9A91),
      badgeInfoColorBackground: const Color(0xFF12294C),
      badgeInfoColorText: const Color(0xFF8FBEFF),
      badgeInfoColorBorder: const Color(0x598FBEFF),
      // Shape and touch geometry carried across from light, so the two modes
      // are the same object in different light.
      badgeBorderRadius: 999,
      badgePaddingX: 10,
      badgePaddingY: 4,
      badgeLabelFontSize: 13,
      badgeLabelFontWeight: DsTypography.medium,
      buttonBorderRadius: 999,
      formBorderRadius: 14,
      radiusXxs: 4,
      radiusControl: 10,
      radiusLg: 16,
      overlayBorderRadius: 28,
      borderRadius: 16,
      buttonMinHeight: 56,
      buttonPaddingX: 24,
      buttonPaddingY: 16,
      buttonIconSize: 20,
      buttonIconGap: 10,
      inputFieldPaddingX: 16,
      textFieldPaddingY: 16,
      fieldLabelGap: 8,
      focusRingWidth: 3,
      cardPadding: 20,
      iconSizeXxs: 14,
      iconSizeXs: 16,
      iconSizeSm: 18,
      iconSizeMd: 20,
      iconSizeLg: 24,
      iconSizeXl: 28,
      overlays: DsOverlayStyle.drawer,
      overlayBackdropColor: const Color(0xA6000000),
      bodyLg: const DsTypeToken(
          fontSize: 17,
          fontWeight: DsTypography.regular,
          height: 1.5,
          letterSpacing: -0.2),
      bodyMd: const DsTypeToken(
          fontSize: 15,
          fontWeight: DsTypography.regular,
          height: 1.5,
          letterSpacing: -0.2),
      bodySm: const DsTypeToken(
          fontSize: 14,
          fontWeight: DsTypography.regular,
          height: 1.4,
          letterSpacing: -0.1),
      display: const DsTypeToken(
          fontSize: 48,
          fontWeight: DsTypography.extraBold,
          height: 1.05,
          letterSpacing: -2),
      stepTitle: const DsTypeToken(
          fontSize: 34,
          fontWeight: DsTypography.bold,
          height: 1.15,
          letterSpacing: -1),
      headingXl: const DsTypeToken(
          fontSize: 28,
          fontWeight: DsTypography.bold,
          height: 1.2,
          letterSpacing: -1),
      headingLg: const DsTypeToken(
          fontSize: 22,
          fontWeight: DsTypography.bold,
          height: 1.25,
          letterSpacing: -0.5),
      headingMd: const DsTypeToken(
          fontSize: 18,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: -0.3),
      headingSm: const DsTypeToken(
          fontSize: 17,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: -0.2),
      headingXs: const DsTypeToken(
          fontSize: 12,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: -0.1),
      labelMd: const DsTypeToken(
          fontSize: 15,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: -0.2),
      labelSm: const DsTypeToken(
          fontSize: 13,
          fontWeight: DsTypography.medium,
          height: 1.35,
          letterSpacing: -0.1),
      buttonLabelFontSize: 17,
      buttonLabelFontWeight: DsTypography.semiBold,
      shadowLow: const <BoxShadow>[
        BoxShadow(color: Color(0x40000000), offset: Offset(0, 1), blurRadius: 3),
        BoxShadow(color: Color(0x33000000), offset: Offset(0, 2), blurRadius: 8),
      ],
      shadowMedium: const <BoxShadow>[
        BoxShadow(
            color: Color(0x59000000), offset: Offset(0, 8), blurRadius: 24),
      ],
      shadowHigh: const <BoxShadow>[
        BoxShadow(
            color: Color(0x73000000), offset: Offset(0, 16), blurRadius: 40),
      ],
      labelEyebrow: const DsTypeToken(
          fontSize: 13,
          fontWeight: DsTypography.semiBold,
          height: 1.3,
          letterSpacing: 1.04,
          textTransform: DsTextTransform.uppercase),
      // The gradient lifts with the rest of the brand on the dark page. Both
      // stops carry white label text, so the button ramp stays legible across
      // its whole width.
      brandGradient: const <Color>[Color(0xFF1F5FD0), Color(0xFF0D3A8A)],
      buttonPrimaryGradient: const <Color>[
        Color(0xFF1F5FD0),
        Color(0xFF0D3A8A)
      ],
      authWashGradient: const [Color(0xFF0D2040), Color(0xFF0A1628)],
      authWashStops: const [0.0, 0.55],
      bloomColor: const Color(0xFF1B3560),
      brandTintColor: const Color(0xFF12294C),
      wordmarkPrimaryText: 'Engen',
      wordmarkAccentText: 'XT',
      wordmarkPrimaryFontWeight: DsTypography.bold,
      // The lifted red, so the suffix stays legible on the navy page.
      wordmarkAccentColor: const Color(0xFFFF8A80),
    );
  }
}
