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

  /// The colour used for borders throughout components.
  static const Color border = Color(0xFFD7D7D7);

  /// The colour used to highlight form items when focused.
  static const Color formHighlightBorder = Color(0xFFD7D7D7);

  /// The colour used to fill form items such as tickboxes, radio buttons and
  /// switches.
  static const Color formAccent = Color(0xFF0074D4);

  /// The backdrop colour shown behind an open overlay.
  static const Color overlayBackdrop = Color(0xFFF9E4F1);

  // ---------------------------------------------------------------------------
  // Badges — neutral
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
  // Badges — success
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
  // Badges — warning
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
  // Badges — danger
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
