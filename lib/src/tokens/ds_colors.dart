import 'dart:ui';

/// Design System colour tokens.
///
/// These are the raw brand values that power [DsTheme]. Prefer reading
/// colours from `Theme.of(context)` (via the `DsTokens` theme extension)
/// inside widgets so that light/dark mode resolves correctly; use these
/// constants only when building a theme.
abstract final class DsColors {
  // ---------------------------------------------------------------------------
  // Brand & actions
  // ---------------------------------------------------------------------------

  /// The colour used for primary actions and links.
  static const Color actionPrimary = Color(0xFF0074D4);

  /// The colour used for secondary actions and links.
  static const Color actionSecondary = Color(0xFF444444);

  /// The colour used for text decoration of primary and secondary actions.
  static const Color actionTextDecoration = Color(0xFF0074D4);

  // ---------------------------------------------------------------------------
  // Buttons
  // ---------------------------------------------------------------------------

  /// The colour used as a background for primary buttons.
  static const Color buttonPrimaryBackground = Color(0xFF0074D4);

  /// The border colour used for primary buttons.
  static const Color buttonPrimaryBorder = Color(0xFF0074D4);

  /// The text colour used for primary buttons.
  static const Color buttonPrimaryText = Color(0xFFFFFFFF);

  /// The background colour for disabled primary buttons.
  ///
  /// Matches the fade the button used to derive at build time
  /// ([buttonPrimaryBackground] at 50% opacity), so the default disabled
  /// treatment is unchanged. A skin can supply a solid tint instead.
  static final Color buttonPrimaryDisabledBackground =
      buttonPrimaryBackground.withValues(alpha: 0.5);

  /// The text colour for disabled primary buttons.
  ///
  /// Matches the fade the button used to derive at build time
  /// ([buttonPrimaryText] at 90% opacity).
  static final Color buttonPrimaryDisabledText =
      buttonPrimaryText.withValues(alpha: 0.9);

  /// The colour used as a background for secondary buttons.
  static const Color buttonSecondaryBackground = Color(0xFFEBEEF1);

  /// The colour used as a border for secondary buttons.
  static const Color buttonSecondaryBorder = Color(0xFFEBEEF1);

  /// The text colour used for secondary buttons.
  static const Color buttonSecondaryText = Color(0xFF393B3E);

  /// The background colour for danger buttons that indicate destructive
  /// actions.
  static const Color buttonDangerBackground = Color(0xFFE61947);

  /// The border colour for danger buttons that indicate destructive actions.
  static const Color buttonDangerBorder = Color(0xFFE61947);

  /// The text colour for danger buttons that indicate destructive actions.
  static const Color buttonDangerText = Color(0xFFFFFFFF);

  /// The colour used as a background for neutral buttons.
  ///
  /// Neutral buttons carry third-party or utility actions (such as federated
  /// sign-in) that must not compete with the brand pair. The defaults match
  /// the secondary button so existing surfaces keep their appearance.
  static const Color buttonNeutralBackground = Color(0xFFEBEEF1);

  /// The border colour used for neutral buttons.
  static const Color buttonNeutralBorder = Color(0xFFEBEEF1);

  /// The text colour used for neutral buttons.
  static const Color buttonNeutralText = Color(0xFF393B3E);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  /// The colour used for primary body text.
  static const Color textPrimary = Color(0xFF1A1B25);

  /// The colour used for secondary text.
  static const Color textSecondary = Color(0xFF717171);

  /// The colour for placeholder text in form items.
  static const Color formPlaceholderText = Color(0xFFAAAAAA);

  // ---------------------------------------------------------------------------
  // Surfaces & borders
  // ---------------------------------------------------------------------------

  /// The background colour used for form items.
  static const Color formBackground = Color(0xFFFFFFFF);

  /// The background colour used when highlighting information, like the
  /// selected row on a table.
  static const Color offsetBackground = Color(0xFFFFFFFF);

  /// The muted surface tier: the quiet grey behind code wells, table headers
  /// and other recessed panels.
  static const Color surfaceMuted = Color(0xFFF6F8FA);

  /// The colour used for borders throughout components.
  static const Color border = Color(0xFFD7D7D7);

  /// The hairline tier beneath [border]: the quietest rule the system draws
  /// (dividers, decorative hairlines). The default equals [border] so nothing
  /// shifts until a skin supplies a lighter value.
  static const Color borderSubtle = Color(0xFFD7D7D7);

  /// The colour used to highlight form items when focused.
  static const Color formHighlightBorder = Color(0xFFD7D7D7);

  /// The colour used to fill form items such as tickboxes, radio buttons and
  /// switches.
  static const Color formAccent = Color(0xFF0074D4);

  /// The backdrop colour shown behind an open overlay: a translucent scrim
  /// derived from [textPrimary] so the page recedes without changing hue.
  static const Color overlayBackdrop = Color(0x661A1B25);

  // ---------------------------------------------------------------------------
  // Auth chrome
  // ---------------------------------------------------------------------------

  /// The first stop of the default auth wash: the plain form background, so
  /// the backdrop opens on the same paper as the rest of the page.
  static const Color authWashStart = formBackground;

  /// The last stop of the default auth wash: the secondary button fill, a
  /// quiet neutral the page can drift into without reading as a brand
  /// statement.
  static const Color authWashEnd = buttonSecondaryBackground;

  /// The colour stops of the default auth wash, painted top to bottom.
  static const List<Color> authWash = [authWashStart, authWashEnd];

  /// The peak of the default brand bloom: one step deeper than [authWashEnd],
  /// so the glow reads against the wash while staying neutral. A skin
  /// supplies its brand tint instead.
  static const Color bloom = Color(0xFFDCE2E9);

  // ---------------------------------------------------------------------------
  // Signals
  // ---------------------------------------------------------------------------

  /// The bright signal colour for positive live status, such as a strength
  /// meter's good tier. Defaults to [badgeSuccessText] so existing readouts
  /// keep their colour; a skin can supply a brighter indicator instead.
  static const Color success = Color(0xFF05690D);

  /// The bright signal colour for cautionary live status, such as a strength
  /// meter's fair tier. Defaults to [badgeWarningText] so existing readouts
  /// keep their colour.
  static const Color warning = Color(0xFFA82C00);

  // ---------------------------------------------------------------------------
  // Badges: neutral
  // ---------------------------------------------------------------------------

  /// The background colour used to represent neutral state or lack of state
  /// in status badges.
  static const Color badgeNeutralBackground = Color(0xFFE4ECEC);

  /// The text colour used to represent neutral state or lack of state in
  /// status badges.
  static const Color badgeNeutralText = Color(0xFF545969);

  /// The border colour used to represent neutral state or lack of state in
  /// status badges.
  static const Color badgeNeutralBorder = Color(0xFFCBD5D6);

  // ---------------------------------------------------------------------------
  // Badges: success
  // ---------------------------------------------------------------------------

  /// The background colour used to reinforce a successful outcome in status
  /// badges.
  static const Color badgeSuccessBackground = Color(0xFFCEF6BB);

  /// The text colour used to reinforce a successful outcome in status badges.
  static const Color badgeSuccessText = Color(0xFF05690D);

  /// The border colour used to reinforce a successful outcome in status
  /// badges.
  static const Color badgeSuccessBorder = Color(0xFFB4E1A2);

  // ---------------------------------------------------------------------------
  // Badges: warning
  // ---------------------------------------------------------------------------

  /// The background colour used in status badges to highlight things that
  /// might require action, but are optional to resolve.
  static const Color badgeWarningBackground = Color(0xFFFCEEBA);

  /// The text colour used in status badges to highlight things that might
  /// require action, but are optional to resolve.
  static const Color badgeWarningText = Color(0xFFA82C00);

  /// The border colour used in status badges to highlight things that might
  /// require action, but are optional to resolve.
  static const Color badgeWarningBorder = Color(0xFFF5DA80);

  // ---------------------------------------------------------------------------
  // Badges: danger
  // ---------------------------------------------------------------------------

  /// The background colour used in status badges for high-priority, critical
  /// situations that the user must address immediately, and to indicate
  /// failed or unsuccessful outcomes.
  static const Color badgeDangerBackground = Color(0xFFF9E4F1);

  /// The text colour used in status badges for high-priority, critical
  /// situations that the user must address immediately, and to indicate
  /// failed or unsuccessful outcomes.
  static const Color badgeDangerText = Color(0xFFB3063D);

  /// The border colour used in status badges for high-priority, critical
  /// situations that the user must address immediately, and to indicate
  /// failed or unsuccessful outcomes.
  static const Color badgeDangerBorder = Color(0xFFF2C9E3);
}
