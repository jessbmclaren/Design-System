// Pure Dart — NO Flutter imports.
import '../pattern_page_content.dart';

/// Foundations → Design tokens & theming.
///
/// The variable tables below enumerate every appearance variable in the
/// system, grouped the way you reach for them.
final PatternPage designTokensPage = PatternPage(
  id: 'design-tokens',
  group: DocGroup.foundations,
  navTitle: 'Design tokens',
  title: 'Design tokens & theming',
  description:
      'The Design System is theme-driven. Every colour, type ramp, radius and '
      'spacing value is a token exposed through the `DsTokens` theme extension, '
      'and every component reads its appearance from the active theme. Because '
      'nothing is hard-coded, you re-brand the entire system by supplying your '
      'own token set to `DsTheme.light` or `DsTheme.dark` — the system is '
      'white-label by default.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Read tokens for the active theme with `DsTokens.of(context)`. Switch '
      'between `DsTheme.light()` and `DsTheme.dark()` to flip every component '
      'at once. Sizes are expressed in logical pixels (`double`); text '
      'transforms default to `none` and accept `uppercase`, `lowercase` or '
      '`capitalize`. Each typography row below is a property of that level\'s '
      '`DsTypeToken` (`headingXl`, `bodyMd`, …), so you can re-scale a level '
      'with `copyWith(headingXl: DsTypeToken(fontSize: 30, ...))`.',
    ),
    SubheadingBlock('Commonly used variables'),
    VariablesBlock(
      title: 'Global',
      rows: [
        VariableRow(name: 'fontFamily', type: 'String', example: 'Inter', description: 'The font family used across every component.'),
        VariableRow(name: 'fontSizeBase', type: 'double', example: '16', description: 'The base font size, in logical pixels, that body text derives from.'),
        VariableRow(name: 'spacingUnit', type: 'double', example: '8', description: 'The base spacing unit, in logical pixels, that layout spacing derives from.'),
        VariableRow(name: 'borderRadius', type: 'double', example: '6', description: 'The general border radius used as the default for components.'),
        VariableRow(name: 'colorPrimary', type: 'Color', example: '#0074D4', description: 'The primary brand colour used for primary actions and accents.'),
        VariableRow(name: 'colorBackground', type: 'Color', example: '#FFFFFF', description: 'The background colour for components, including overlays and surfaces.'),
        VariableRow(name: 'colorText', type: 'Color', example: '#1A1B25', description: 'The colour used for primary text.'),
        VariableRow(name: 'colorDanger', type: 'Color', example: '#E61947', description: 'The colour used to indicate errors or destructive actions.'),
      ],
    ),
    VariablesBlock(
      title: 'Actions and buttons',
      rows: [
        VariableRow(name: 'actionPrimaryColorText', type: 'Color', example: '#0074D4', description: 'The colour used for primary actions and links.'),
        VariableRow(name: 'actionSecondaryColorText', type: 'Color', example: '#444444', description: 'The colour used for secondary actions and links.'),
        VariableRow(name: 'buttonPrimaryColorBackground', type: 'Color', example: '#0074D4', description: 'The colour used as a background for primary buttons.'),
        VariableRow(name: 'buttonPrimaryColorBorder', type: 'Color', example: '#0074D4', description: 'The border colour used for primary buttons.'),
        VariableRow(name: 'buttonPrimaryColorText', type: 'Color', example: '#FFFFFF', description: 'The text colour used for primary buttons.'),
        VariableRow(name: 'buttonSecondaryColorBackground', type: 'Color', example: '#EBEEF1', description: 'The colour used as a background for secondary buttons.'),
        VariableRow(name: 'buttonSecondaryColorBorder', type: 'Color', example: '#EBEEF1', description: 'The colour used as a border for secondary buttons.'),
        VariableRow(name: 'buttonSecondaryColorText', type: 'Color', example: '#393B3E', description: 'The text colour used for secondary buttons.'),
        VariableRow(name: 'buttonDangerColorBackground', type: 'Color', example: '#E61947', description: 'The background colour for danger buttons that indicate destructive actions.'),
        VariableRow(name: 'buttonDangerColorBorder', type: 'Color', example: '#E61947', description: 'The border colour for danger buttons that indicate destructive actions.'),
        VariableRow(name: 'buttonDangerColorText', type: 'Color', example: '#FFFFFF', description: 'The text colour for danger buttons that indicate destructive actions.'),
      ],
    ),
    VariablesBlock(
      title: 'Text and surfaces',
      rows: [
        VariableRow(name: 'colorSecondaryText', type: 'Color', example: '#717171', description: 'The colour used for secondary text.'),
        VariableRow(name: 'colorBorder', type: 'Color', example: '#D7D7D7', description: 'The colour used for borders throughout components.'),
        VariableRow(name: 'formBackgroundColor', type: 'Color', example: '#FFFFFF', description: 'The background colour used for form items.'),
        VariableRow(name: 'offsetBackgroundColor', type: 'Color', example: '#FFFFFF', description: 'The background colour used when highlighting information, like the selected row on a table.'),
        VariableRow(name: 'formHighlightColorBorder', type: 'Color', example: '#D7D7D7', description: 'The colour used to highlight form items when focused.'),
        VariableRow(name: 'formAccentColor', type: 'Color', example: '#0074D4', description: 'The colour used to fill form items such as tickboxes, radio buttons and switches.'),
        VariableRow(name: 'formPlaceholderTextColor', type: 'Color', example: '#AAAAAA', description: 'The colour for placeholder text in form items.'),
      ],
    ),
    VariablesBlock(
      title: 'Typography',
      rows: [
        VariableRow(name: 'headingXlFontSize', type: 'double', example: '28', description: 'The font size for the extra large heading typography.'),
        VariableRow(name: 'headingXlFontWeight', type: 'FontWeight', example: '700', description: 'The font weight for the extra large heading typography.'),
        VariableRow(name: 'headingXlTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for the extra large heading typography.'),
        VariableRow(name: 'headingLgFontSize', type: 'double', example: '24', description: 'The font size for the large heading typography.'),
        VariableRow(name: 'headingLgFontWeight', type: 'FontWeight', example: '700', description: 'The font weight for the large heading typography.'),
        VariableRow(name: 'headingLgTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for the large heading typography.'),
        VariableRow(name: 'headingMdFontSize', type: 'double', example: '20', description: 'The font size for the medium heading typography.'),
        VariableRow(name: 'headingMdFontWeight', type: 'FontWeight', example: '700', description: 'The font weight for the medium heading typography.'),
        VariableRow(name: 'headingMdTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for the medium heading typography.'),
        VariableRow(name: 'headingSmFontSize', type: 'double', example: '16', description: 'The font size for the small heading typography.'),
        VariableRow(name: 'headingSmFontWeight', type: 'FontWeight', example: '700', description: 'The font weight for the small heading typography.'),
        VariableRow(name: 'headingSmTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for the small heading typography.'),
        VariableRow(name: 'headingXsFontSize', type: 'double', example: '12', description: 'The font size for the extra small heading typography.'),
        VariableRow(name: 'headingXsFontWeight', type: 'FontWeight', example: '700', description: 'The font weight for the extra small heading typography.'),
        VariableRow(name: 'headingXsTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for the extra small heading typography.'),
        VariableRow(name: 'bodyMdFontSize', type: 'double', example: '16', description: 'The font size for the medium body typography.'),
        VariableRow(name: 'bodyMdFontWeight', type: 'FontWeight', example: '400', description: 'The font weight for the medium body typography.'),
        VariableRow(name: 'bodySmFontSize', type: 'double', example: '14', description: 'The font size for the small body typography.'),
        VariableRow(name: 'bodySmFontWeight', type: 'FontWeight', example: '400', description: 'The font weight for the small body typography.'),
        VariableRow(name: 'labelMdFontSize', type: 'double', example: '14', description: 'The font size for the medium label typography.'),
        VariableRow(name: 'labelMdFontWeight', type: 'FontWeight', example: '400', description: 'The font weight for the medium label typography.'),
        VariableRow(name: 'labelMdTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for the medium label typography.'),
        VariableRow(name: 'labelSmFontSize', type: 'double', example: '12', description: 'The font size for the small label typography.'),
        VariableRow(name: 'labelSmFontWeight', type: 'FontWeight', example: '400', description: 'The font weight for the small label typography.'),
        VariableRow(name: 'labelSmTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for the small label typography.'),
        VariableRow(name: 'buttonLabelFontSize', type: 'double', example: '16', description: 'The font size for button label typography.'),
        VariableRow(name: 'buttonLabelFontWeight', type: 'FontWeight', example: '400', description: 'The font weight for button label typography.'),
        VariableRow(name: 'buttonLabelTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for button label typography.'),
        VariableRow(name: 'badgeLabelFontSize', type: 'double', example: '14', description: 'The font size for badge label typography.'),
        VariableRow(name: 'badgeLabelFontWeight', type: 'FontWeight', example: '400', description: 'The font weight for badge label typography.'),
        VariableRow(name: 'badgeLabelTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for badge label typography.'),
      ],
    ),
    SubheadingBlock('Less commonly used variables'),
    VariablesBlock(
      title: 'Action text decoration',
      rows: [
        VariableRow(name: 'actionPrimaryTextDecorationLine', type: 'TextDecoration', example: 'underline', description: 'The line type used for text decoration of primary actions and links.'),
        VariableRow(name: 'actionPrimaryTextDecorationColor', type: 'Color', example: '#0074D4', description: 'The colour used for text decoration of primary actions and links.'),
        VariableRow(name: 'actionPrimaryTextDecorationStyle', type: 'TextDecorationStyle', example: 'solid', description: 'The style of text decoration of primary actions and links.'),
        VariableRow(name: 'actionPrimaryTextDecorationThickness', type: 'double', example: '1', description: 'The thickness of text decoration of primary actions and links.'),
        VariableRow(name: 'actionPrimaryTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for primary actions and links.'),
        VariableRow(name: 'actionSecondaryTextDecorationLine', type: 'TextDecoration', example: 'underline', description: 'The line type used for text decoration of secondary actions and links.'),
        VariableRow(name: 'actionSecondaryTextDecorationColor', type: 'Color', example: '#0074D4', description: 'The colour used for text decoration of secondary actions and links.'),
        VariableRow(name: 'actionSecondaryTextDecorationStyle', type: 'TextDecorationStyle', example: 'solid', description: 'The style of text decoration of secondary actions and links.'),
        VariableRow(name: 'actionSecondaryTextDecorationThickness', type: 'double', example: '1', description: 'The thickness of text decoration of secondary actions and links.'),
        VariableRow(name: 'actionSecondaryTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for secondary actions and links.'),
      ],
    ),
    VariablesBlock(
      title: 'Badges',
      rows: [
        VariableRow(name: 'badgeNeutralColorBackground', type: 'Color', example: '#E4ECEC', description: 'The background colour used to represent neutral state in status badges.'),
        VariableRow(name: 'badgeNeutralColorText', type: 'Color', example: '#545969', description: 'The text colour used to represent neutral state in status badges.'),
        VariableRow(name: 'badgeNeutralColorBorder', type: 'Color', example: '#CBD5D6', description: 'The border colour used to represent neutral state in status badges.'),
        VariableRow(name: 'badgeSuccessColorBackground', type: 'Color', example: '#CEF6BB', description: 'The background colour used to reinforce a successful outcome in status badges.'),
        VariableRow(name: 'badgeSuccessColorText', type: 'Color', example: '#05690D', description: 'The text colour used to reinforce a successful outcome in status badges.'),
        VariableRow(name: 'badgeSuccessColorBorder', type: 'Color', example: '#B4E1A2', description: 'The border colour used to reinforce a successful outcome in status badges.'),
        VariableRow(name: 'badgeWarningColorBackground', type: 'Color', example: '#FCEEBA', description: 'The background colour used in status badges to highlight things that might require action.'),
        VariableRow(name: 'badgeWarningColorText', type: 'Color', example: '#A82C00', description: 'The text colour used in status badges to highlight things that might require action.'),
        VariableRow(name: 'badgeWarningColorBorder', type: 'Color', example: '#F5DA80', description: 'The border colour used in status badges to highlight things that might require action.'),
        VariableRow(name: 'badgeDangerColorBackground', type: 'Color', example: '#F9E4F1', description: 'The background colour used in status badges for critical situations and failed outcomes.'),
        VariableRow(name: 'badgeDangerColorText', type: 'Color', example: '#B3063D', description: 'The text colour used in status badges for critical situations and failed outcomes.'),
        VariableRow(name: 'badgeDangerColorBorder', type: 'Color', example: '#F2C9E3', description: 'The border colour used in status badges for critical situations and failed outcomes.'),
      ],
    ),
    VariablesBlock(
      title: 'Shape and spacing',
      rows: [
        VariableRow(name: 'buttonBorderRadius', type: 'double', example: '4', description: 'The border radius used for buttons.'),
        VariableRow(name: 'formBorderRadius', type: 'double', example: '6', description: 'The border radius used for form elements.'),
        VariableRow(name: 'badgeBorderRadius', type: 'double', example: '4', description: 'The border radius used for badges.'),
        VariableRow(name: 'buttonPaddingX', type: 'double', example: '4', description: 'The horizontal padding for buttons.'),
        VariableRow(name: 'buttonPaddingY', type: 'double', example: '4', description: 'The vertical padding for buttons.'),
        VariableRow(name: 'inputFieldPaddingX', type: 'double', example: '8', description: 'The horizontal padding for input fields in forms.'),
        VariableRow(name: 'inputFieldPaddingY', type: 'double', example: '4', description: 'The vertical padding for input fields in forms.'),
        VariableRow(name: 'badgePaddingX', type: 'double', example: '6', description: 'The horizontal padding for badges.'),
        VariableRow(name: 'badgePaddingY', type: 'double', example: '2', description: 'The vertical padding for badges.'),
        VariableRow(name: 'tableRowPaddingY', type: 'double', example: '8', description: 'The vertical padding for table rows.'),
      ],
    ),
    SubheadingBlock('Overlays'),
    ProseBlock(
      'The `overlays` token controls whether a focused overlay (such as '
      '`DsFocusView`) presents as a centred dialog or a drawer that slides in '
      'from the edge. Choose the value that best suits your product.',
    ),
    VariablesBlock(
      rows: [
        VariableRow(name: 'overlays', type: 'DsOverlayStyle', example: 'dialog', description: 'The type of overlay used. Valid values are dialog (default) and drawer.'),
        VariableRow(name: 'overlayBorderRadius', type: 'double', example: '8', description: 'The border radius used for overlays.'),
        VariableRow(name: 'overlayBackdropColor', type: 'Color', example: '#F9E4F1', description: 'The backdrop colour shown behind an open overlay.'),
      ],
    ),
  ],
  code: '''
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

// Use the default appearance…
MaterialApp(
  theme: DsTheme.light(),
  darkTheme: DsTheme.dark(),
);

// …or white-label it with your own brand in one place.
final brand = DsTokens.light().copyWith(
  buttonPrimaryColorBackground: const Color(0xFF6D28D9),
  actionPrimaryColorText: const Color(0xFF6D28D9),
  formAccentColor: const Color(0xFF6D28D9),
);

MaterialApp(theme: DsTheme.light(tokens: brand));

// Read a token inside a widget.
final tokens = DsTokens.of(context);
final border = tokens.colorBorder;
''',
  shots: const [
    Shot(pageId: 'design-tokens', size: ShotSize.desktop),
    Shot(pageId: 'design-tokens', size: ShotSize.phone),
  ],
  related: ['action-buttons', 'communicating-state'],
);
