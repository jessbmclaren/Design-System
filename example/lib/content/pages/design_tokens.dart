// Pure Dart, no Flutter imports.
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
      'A token is a named value the whole library reads from, one for every '
      'colour, size, radius and font. Components never hard-code how they '
      'look; they ask the active theme. So you can re-brand the entire system '
      'in one place by passing your own tokens to `DsTheme.light` or '
      '`DsTheme.dark`. Out of the box it is white-label: neutral, and ready '
      'for your brand.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Read a token for the current theme with `DsTokens.of(context)`, then '
      'use it like any other value. Swap `DsTheme.light()` for '
      '`DsTheme.dark()` and every component changes at once. Sizes are plain '
      'numbers in logical pixels. Text is left as it is written unless you set '
      'it to uppercase, lowercase or capitalised.',
    ),
    ProseBlock(
      'Type comes in levels. Each heading, body and label level is a '
      '`DsTypeToken` that bundles its size, weight, line height and letter '
      'spacing, so you can restyle a whole level in one line: '
      '`copyWith(headingXl: DsTypeToken(fontSize: 30, fontWeight: '
      'DsTypography.bold))`. Button and badge labels are the exception: their '
      'size, weight and transform are separate tokens you set on their own.',
    ),
    SubheadingBlock('Commonly used variables'),
    VariablesBlock(
      title: 'Global',
      rows: [
        VariableRow(name: 'fontFamily', type: 'String', example: 'Inter', description: 'The font family used across every component.'),
        VariableRow(name: 'fontSizeBase', type: 'double', example: '16', description: 'The base font size, in logical pixels, that body text derives from.'),
        VariableRow(name: 'spacingUnit', type: 'double', example: '8', description: 'The base spacing unit, in logical pixels, that layout spacing derives from.'),
        VariableRow(name: 'borderRadius', type: 'double', example: '6', description: 'The general border radius used as the default for components.'),
        VariableRow(name: 'colorPrimary', type: 'Color', example: '#0F766E', description: 'The primary brand colour used for primary actions and accents.'),
        VariableRow(name: 'colorBackground', type: 'Color', example: '#FFFFFF', description: 'The background colour for components, including overlays and surfaces.'),
        VariableRow(name: 'colorText', type: 'Color', example: '#1A1B25', description: 'The colour used for primary text.'),
        VariableRow(name: 'colorDanger', type: 'Color', example: '#E61947', description: 'The colour used to indicate errors or destructive actions.'),
        VariableRow(name: 'colorSuccess', type: 'Color', example: '#05690D', description: 'The bright signal colour for positive live status, such as a strength meter\'s good tier. Defaults to the success badge text colour.'),
        VariableRow(name: 'colorWarning', type: 'Color', example: '#A82C00', description: 'The bright signal colour for cautionary live status, such as a strength meter\'s fair tier. Defaults to the warning badge text colour.'),
      ],
    ),
    VariablesBlock(
      title: 'Actions and buttons',
      rows: [
        VariableRow(name: 'actionPrimaryColorText', type: 'Color', example: '#0F766E', description: 'The colour used for primary actions and links.'),
        VariableRow(name: 'actionSecondaryColorText', type: 'Color', example: '#444444', description: 'The colour used for secondary actions and links.'),
        VariableRow(name: 'buttonPrimaryColorBackground', type: 'Color', example: '#0F766E', description: 'The colour used as a background for primary buttons.'),
        VariableRow(name: 'buttonPrimaryColorBorder', type: 'Color', example: '#0F766E', description: 'The border colour used for primary buttons.'),
        VariableRow(name: 'buttonPrimaryColorText', type: 'Color', example: '#FFFFFF', description: 'The text colour used for primary buttons.'),
        VariableRow(name: 'buttonPrimaryDisabledColorBackground', type: 'Color', example: '#800F766E', description: 'The background colour for disabled primary buttons (ARGB). Defaults to the primary background at 50% opacity; a skin can supply a solid tint instead.'),
        VariableRow(name: 'buttonPrimaryDisabledColorText', type: 'Color', example: '#E6FFFFFF', description: 'The text colour for disabled primary buttons (ARGB). Defaults to the primary text colour at 90% opacity.'),
        VariableRow(name: 'buttonSecondaryColorBackground', type: 'Color', example: '#EBEEF1', description: 'The colour used as a background for secondary buttons.'),
        VariableRow(name: 'buttonSecondaryColorBorder', type: 'Color', example: '#EBEEF1', description: 'The colour used as a border for secondary buttons.'),
        VariableRow(name: 'buttonSecondaryColorText', type: 'Color', example: '#393B3E', description: 'The text colour used for secondary buttons.'),
        VariableRow(name: 'buttonDangerColorBackground', type: 'Color', example: '#E61947', description: 'The background colour for danger buttons that indicate destructive actions.'),
        VariableRow(name: 'buttonDangerColorBorder', type: 'Color', example: '#E61947', description: 'The border colour for danger buttons that indicate destructive actions.'),
        VariableRow(name: 'buttonDangerColorText', type: 'Color', example: '#FFFFFF', description: 'The text colour for danger buttons that indicate destructive actions.'),
        VariableRow(name: 'buttonNeutralColorBackground', type: 'Color', example: '#EBEEF1', description: 'The colour used as a background for neutral buttons, which carry third-party or utility actions such as federated sign-in. Defaults to the secondary button background.'),
        VariableRow(name: 'buttonNeutralColorBorder', type: 'Color', example: '#EBEEF1', description: 'The border colour used for neutral buttons. Defaults to the secondary button border.'),
        VariableRow(name: 'buttonNeutralColorText', type: 'Color', example: '#393B3E', description: 'The text colour used for neutral buttons. Defaults to the secondary button text colour.'),
        VariableRow(name: 'buttonTertiaryColorBackground', type: 'Color', example: 'transparent', description: 'The background colour for tertiary (text) buttons. Transparent by default, so the label alone carries the action.'),
        VariableRow(name: 'buttonTertiaryColorBorder', type: 'Color', example: 'transparent', description: 'The border colour for tertiary (text) buttons. Transparent by default.'),
        VariableRow(name: 'buttonTertiaryColorText', type: 'Color', example: '#0F766E', description: 'The text colour for tertiary (text) buttons. Defaults to the primary action colour.'),
      ],
    ),
    VariablesBlock(
      title: 'Text and surfaces',
      rows: [
        VariableRow(name: 'colorSecondaryText', type: 'Color', example: '#717171', description: 'The colour used for secondary text.'),
        VariableRow(name: 'colorBorder', type: 'Color', example: '#D7D7D7', description: 'The colour used for borders throughout components.'),
        VariableRow(name: 'colorBorderSubtle', type: 'Color', example: '#D7D7D7', description: 'The hairline tier beneath colorBorder: the quietest rule the system draws, used by dividers and decorative hairlines. Defaults to the border colour.'),
        VariableRow(name: 'formBackgroundColor', type: 'Color', example: '#FFFFFF', description: 'The background colour used for form items.'),
        VariableRow(name: 'offsetBackgroundColor', type: 'Color', example: '#FFFFFF', description: 'The background colour used when highlighting information, like the selected row on a table.'),
        VariableRow(name: 'colorSurfaceMuted', type: 'Color', example: '#F6F8FA', description: 'The muted surface tier: the quiet grey behind code wells, table headers and other recessed panels. Exposed to the Material scheme as surfaceContainerHighest.'),
        VariableRow(name: 'formHighlightColorBorder', type: 'Color', example: '#D7D7D7', description: 'The colour used to highlight form items when focused.'),
        VariableRow(name: 'formAccentColor', type: 'Color', example: '#0F766E', description: 'The colour used to fill form items such as tickboxes, radio buttons and switches.'),
        VariableRow(name: 'formPlaceholderTextColor', type: 'Color', example: '#767676', description: 'The colour for placeholder text in form items.'),
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
        VariableRow(name: 'strongLabelFontWeight', type: 'FontWeight', example: '600', description: 'The font weight for strong labels: group legends, table headers and other short emphasised runs.'),
      ],
    ),
    SubheadingBlock('Less commonly used variables'),
    VariablesBlock(
      title: 'Interaction states',
      rows: [
        VariableRow(name: 'stateHoverOpacity', type: 'double', example: '0.06', description: 'The state-layer alpha painted over a flat control on hover and keyboard focus.'),
        VariableRow(name: 'statePressedOpacity', type: 'double', example: '0.1', description: 'The state-layer alpha painted over a flat control while pressed.'),
        VariableRow(name: 'stateDisabledOpacity', type: 'double', example: '0.5', description: 'The fade shared by the disabled treatments that dim a whole surface: a disabled button\'s fill, a disabled tertiary button\'s label and a disabled input\'s border.'),
        VariableRow(name: 'stateDisabledTextOpacity', type: 'double', example: '0.9', description: 'The fade for a disabled filled button\'s label. Gentler than stateDisabledOpacity, so the label stays readable on the dimmed fill.'),
        VariableRow(name: 'stateDisabledIconOpacity', type: 'double', example: '0.38', description: 'The fade for a disabled icon-only control\'s glyph.'),
        VariableRow(name: 'focusRingWidth', type: 'double', example: '2', description: 'The stroke width of the keyboard focus ring on buttons and icon buttons.'),
        VariableRow(name: 'focusRingColor', type: 'Color', example: '#0F766E', description: 'The colour of the keyboard focus ring. Defaults to formAccentColor. A control whose own foreground carries the focus state instead, a filled button ringing itself in its label colour so the ring stays legible on any variant fill, is the deliberate exception.'),
        VariableRow(name: 'focusRingGap', type: 'double', example: '1', description: 'The gap held between a control\'s edge and its focus ring, so the ring stays visible against a filled control rather than merging with it.'),
        VariableRow(name: 'buttonPressedScale', type: 'double', example: '0.96', description: 'How far a button shrinks while pressed, as a scale factor. Just under 1, so the press reads as the surface giving under the finger rather than as the control changing size.'),
      ],
    ),
    VariablesBlock(
      title: 'Action text decoration',
      rows: [
        VariableRow(name: 'actionPrimaryTextDecorationLine', type: 'TextDecoration', example: 'underline', description: 'The line type used for text decoration of primary actions and links.'),
        VariableRow(name: 'actionPrimaryTextDecorationColor', type: 'Color', example: '#0F766E', description: 'The colour used for text decoration of primary actions and links.'),
        VariableRow(name: 'actionPrimaryTextDecorationStyle', type: 'TextDecorationStyle', example: 'solid', description: 'The style of text decoration of primary actions and links.'),
        VariableRow(name: 'actionPrimaryTextDecorationThickness', type: 'double', example: '1', description: 'The thickness of text decoration of primary actions and links.'),
        VariableRow(name: 'actionPrimaryTextTransform', type: 'DsTextTransform', example: 'none', description: 'The text transform for primary actions and links.'),
        VariableRow(name: 'actionSecondaryTextDecorationLine', type: 'TextDecoration', example: 'underline', description: 'The line type used for text decoration of secondary actions and links.'),
        VariableRow(name: 'actionSecondaryTextDecorationColor', type: 'Color', example: '#0F766E', description: 'The colour used for text decoration of secondary actions and links.'),
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
        VariableRow(name: 'radiusLg', type: 'double', example: '12', description: 'The corner radius for card-sized surfaces: a board lane, a panel, a raised tile. Nested surfaces derive from this rather than declaring their own, so an inner card inset by n takes radiusLg minus n and the two curves stay concentric when a skin retunes the outer one.'),
        VariableRow(name: 'buttonPaddingX', type: 'double', example: '16', description: 'The horizontal padding for buttons, the full inset the button paints.'),
        VariableRow(name: 'buttonPaddingY', type: 'double', example: '10', description: 'The vertical padding for buttons, the full inset the button paints.'),
        VariableRow(name: 'buttonMinHeight', type: 'double', example: '40', description: 'The minimum height for buttons.'),
        VariableRow(name: 'buttonIconSize', type: 'double', example: '18', description: 'The size of a glyph inside a button. Defaults to buttonLabelFontSize plus 2; keep the pair in step when a skin re-sizes the label.'),
        VariableRow(name: 'buttonRestBorderWidth', type: 'double', example: '1', description: 'The border stroke width for buttons at rest.'),
        VariableRow(name: 'inputFieldPaddingX', type: 'double', example: '8', description: 'The horizontal padding for input fields in forms.'),
        VariableRow(name: 'inputFieldPaddingY', type: 'double', example: '4', description: 'The vertical padding for input fields in forms.'),
        VariableRow(name: 'textFieldPaddingY', type: 'double', example: '16', description: 'The full vertical padding a bordered text input paints, so a skin can retune the text field without moving every other form control.'),
        VariableRow(name: 'inputBorderWidth', type: 'double', example: '1', description: 'The border stroke width for input fields at rest.'),
        VariableRow(name: 'inputFocusBorderWidth', type: 'double', example: '1.6', description: 'The border stroke width for a focused input field. The error border carries the same emphasis.'),
        VariableRow(name: 'fieldLabelGap', type: 'double', example: '6', description: 'The gap between a field\'s label and its input.'),
        VariableRow(name: 'boxBorderWidth', type: 'double', example: '1', description: 'The border stroke width a DsBox draws when given a border colour without an explicit width.'),
        VariableRow(name: 'badgePaddingX', type: 'double', example: '6', description: 'The horizontal padding for badges.'),
        VariableRow(name: 'badgePaddingY', type: 'double', example: '2', description: 'The vertical padding for badges.'),
        VariableRow(name: 'tableRowPaddingY', type: 'double', example: '8', description: 'The vertical padding for table rows.'),
      ],
    ),
    SubheadingBlock('Elevation, icons and weights'),
    ProseBlock(
      'Shadows are tokens too. A raised surface casts one of three shadows '
      '(`shadowLow`, `shadowMedium`, `shadowHigh`), so a brand can retint '
      'every shadow at once with `DsElevation.tinted`. The system also ships '
      'an icon scale and a set of font weights. The icon steps are tokens for '
      'the same reason the type ramp is: a brand that re-scales its text '
      'without re-scaling the glyphs beside it ends up with icons that no '
      'longer sit on the line. `DsIconSize` still backs the defaults. The '
      'bundled Inter font carries all four weights (400, 500, 600 and 700), '
      'so you have more than just regular and bold.',
    ),
    VariablesBlock(
      title: 'Elevation',
      rows: [
        VariableRow(name: 'shadowLow', type: 'List<BoxShadow>', example: 'DsElevation.low', description: 'The resting drop shadow for lightly raised surfaces: chips, hover cards and list cards.'),
        VariableRow(name: 'shadowMedium', type: 'List<BoxShadow>', example: 'DsElevation.medium', description: 'The drop shadow for floating surfaces: cards, menus, popovers and toasts.'),
        VariableRow(name: 'shadowHigh', type: 'List<BoxShadow>', example: 'DsElevation.high', description: 'The drop shadow for modal surfaces: dialogs, drawers and takeovers.'),
        VariableRow(name: 'DsElevation.tinted', type: 'Color → shadows', example: 'brand', description: 'A brand-tinted scale derived from a colour, ready to feed the three shadow tokens above.'),
      ],
    ),
    VariablesBlock(
      title: 'Icon scale',
      rows: [
        VariableRow(name: 'iconSizeXxs', type: 'double', example: '12', description: 'Tiny marker glyphs.'),
        VariableRow(name: 'iconSizeXs', type: 'double', example: '14', description: 'Glyphs set inline with small text.'),
        VariableRow(name: 'iconSizeSm', type: 'double', example: '16', description: 'The default control glyph, for buttons, inputs and chips.'),
        VariableRow(name: 'iconSizeMd', type: 'double', example: '18', description: 'Glyphs in list rows and toolbars.'),
        VariableRow(name: 'iconSizeLg', type: 'double', example: '20', description: 'Glyphs on prominent actions and status readouts.'),
        VariableRow(name: 'iconSizeXl', type: 'double', example: '24', description: 'Header and empty-state glyphs, the largest step.'),
      ],
    ),
    VariablesBlock(
      title: 'Font weight (DsTypography)',
      rows: [
        VariableRow(name: 'DsTypography.regular', type: 'FontWeight', example: '400', description: 'Regular body weight.'),
        VariableRow(name: 'DsTypography.medium', type: 'FontWeight', example: '500', description: 'Quiet emphasis: labels and secondary controls.'),
        VariableRow(name: 'DsTypography.semiBold', type: 'FontWeight', example: '600', description: 'Strong labels, control text, active tabs.'),
        VariableRow(name: 'DsTypography.bold', type: 'FontWeight', example: '700', description: 'Headings.'),
      ],
    ),
    SubheadingBlock('Charts'),
    ProseBlock(
      'A chart is the one surface where colour carries data rather than '
      'decoration, so its ramps are tokens in their own right. The defaults '
      'come from `DsChartPalette` and were validated for colour-vision '
      'separation, chroma and contrast against their surface; the dark theme '
      'carries its own ramp rather than a flip of the light one. A skin that '
      'replaces them owes the same check. Read a series colour with '
      '`tokens.chartColorAt(index)`: the order is fixed and assigned by series '
      'identity, never cycled, and anything past the end folds into the '
      'neutral `chartOther` bucket instead of repeating a hue that already '
      'means something else on the same chart. Status and state stay with the '
      'badge tokens, never a categorical hue.',
    ),
    VariablesBlock(
      rows: [
        VariableRow(name: 'chartCategorical', type: 'List<Color>', example: '6 hues', description: 'The fixed categorical order, assigned by series identity and never cycled.'),
        VariableRow(name: 'chartOther', type: 'Color', example: '#8A94A6', description: 'The neutral bucket for series past the end of chartCategorical.'),
        VariableRow(name: 'chartSequential', type: 'List<Color>', example: '6 steps', description: 'The sequential ramp carrying magnitude: a single hue, light to dark.'),
        VariableRow(name: 'chartDiverging', type: 'List<Color>', example: '3 stops', description: 'The diverging ramp carrying polarity, as negative pole, neutral midpoint and positive pole.'),
      ],
    ),
    SubheadingBlock('Overlays'),
    ProseBlock(
      'The `overlays` token decides how a focused overlay like `DsFocusView` '
      'appears: a centred dialog, or a drawer that slides in from the edge. '
      'Pick whichever suits your product.',
    ),
    VariablesBlock(
      rows: [
        VariableRow(name: 'overlays', type: 'DsOverlayStyle', example: 'dialog', description: 'The type of overlay used. Valid values are dialog (default) and drawer.'),
        VariableRow(name: 'overlayBorderRadius', type: 'double', example: '8', description: 'The border radius used for overlays.'),
        VariableRow(name: 'overlayBackdropColor', type: 'Color', example: '#661A1B25', description: 'The backdrop colour shown behind an open overlay: a translucent scrim (ARGB) over the page.'),
      ],
    ),
    SubheadingBlock('Auth chrome and wordmark'),
    ProseBlock(
      'The sign-in, sign-up and waiting screens paint their background from '
      'two tokens, and the wordmark\'s size and spacing are tokens too. So a '
      'brand can restyle the whole first impression without copying a '
      'component.',
    ),
    VariablesBlock(
      rows: [
        VariableRow(name: 'authWashGradient', type: 'List<Color>', example: '#FFFFFF → #EBEEF1', description: 'The colour stops of the auth wash, painted top to bottom by DsAuthGradient behind sign-in, sign-up and waiting screens. Give it at least two colours.'),
        VariableRow(name: 'bloomColor', type: 'Color', example: '#DCE2E9', description: 'The peak colour of the soft radial brand glow painted by DsBrandBloom. Neutral by default, so the glow is present without carrying a hue.'),
        VariableRow(name: 'wordmarkFontSize', type: 'double', example: '22', description: 'The default wordmark size, in logical pixels.'),
        VariableRow(name: 'wordmarkLetterSpacing', type: 'double', example: '-0.2', description: 'The wordmark\'s letter spacing. Slightly negative by default, so the mark sets a little tighter than body text.'),
        VariableRow(name: 'wordmarkHeight', type: 'double', example: '1', description: 'The wordmark\'s line height multiplier. 1 by default, so the mark occupies exactly its glyph height in chrome and headers.'),
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

// Opt into a ready-made skin. This changes nothing about the defaults.
MaterialApp(theme: DsTheme.light(tokens: DsSkins.engenLight()));

// The editorial skin: ink on paper, square corners, letter-spaced labels.
MaterialApp(theme: DsTheme.light(tokens: DsSkins.editorialLight()));

// The mobile skin: stadium controls sized for a thumb, a larger reading
// ramp, glyphs a step up and overlays that arrive from the edge.
MaterialApp(
  theme: DsTheme.light(tokens: DsSkins.engenMobileLight()),
  darkTheme: DsTheme.dark(tokens: DsSkins.engenMobileDark()),
);

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
