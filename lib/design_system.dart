/// Design System — a Material 3 based Flutter component library.
///
/// White-label by default: build your theme with [DsTheme.light] /
/// [DsTheme.dark], optionally passing your own [DsTokens] to re-brand every
/// component at once.
library;

// Tokens
export 'src/tokens/ds_breakpoints.dart';
export 'src/tokens/ds_chart_palette.dart';
export 'src/tokens/ds_colors.dart';
export 'src/tokens/ds_elevation.dart';
export 'src/tokens/ds_icon_size.dart';
export 'src/tokens/ds_radii.dart';
export 'src/tokens/ds_spacing.dart';
export 'src/tokens/ds_typography.dart';

// Theme
export 'src/theme/ds_skins.dart';
export 'src/theme/ds_theme.dart';
export 'src/theme/ds_tokens_extension.dart';

// Utilities
export 'src/util/ds_motion.dart';

// Components — organised by Atomic Design layer.
//
// Atoms
export 'src/components/atoms/ds_avatar.dart';
export 'src/components/atoms/ds_back_link.dart';
export 'src/components/atoms/ds_badge.dart';
export 'src/components/atoms/ds_box.dart';
export 'src/components/atoms/ds_button.dart';
export 'src/components/atoms/ds_checkbox.dart';
export 'src/components/atoms/ds_chip.dart';
export 'src/components/atoms/ds_divider.dart';
export 'src/components/atoms/ds_icon.dart';
export 'src/components/atoms/ds_img.dart';
export 'src/components/atoms/ds_inline.dart';
export 'src/components/atoms/ds_link.dart';
export 'src/components/atoms/ds_radio.dart';
export 'src/components/atoms/ds_spinner.dart';
export 'src/components/atoms/ds_sparkline.dart';
export 'src/components/atoms/ds_switch.dart';
// Molecules
export 'src/components/molecules/ds_accordion.dart';
export 'src/components/molecules/ds_banner.dart';
export 'src/components/molecules/ds_button_group.dart';
export 'src/components/molecules/ds_coachmark.dart';
export 'src/components/molecules/ds_currency_field.dart';
export 'src/components/molecules/ds_date_field.dart';
export 'src/components/molecules/ds_empty_state.dart';
export 'src/components/molecules/ds_filter_chip.dart';
export 'src/components/molecules/ds_form_field_group.dart';
export 'src/components/molecules/ds_list_item.dart';
export 'src/components/molecules/ds_menu.dart';
export 'src/components/molecules/ds_page_header.dart';
export 'src/components/molecules/ds_select.dart';
export 'src/components/molecules/ds_tabs.dart';
export 'src/components/molecules/ds_text_area.dart';
export 'src/components/molecules/ds_text_field.dart';
export 'src/components/molecules/ds_toast.dart';
export 'src/components/molecules/ds_tooltip.dart';
// Organisms
export 'src/components/organisms/ds_bar_chart.dart';
export 'src/components/organisms/ds_business_verification.dart';
export 'src/components/organisms/ds_context_view.dart';
export 'src/components/organisms/ds_data_grid.dart';
export 'src/components/organisms/ds_data_table.dart';
export 'src/components/organisms/ds_focus_view.dart';
export 'src/components/organisms/ds_line_chart.dart';
export 'src/components/organisms/ds_list.dart';
export 'src/components/organisms/ds_meter_chart.dart';
export 'src/components/organisms/ds_onboarding_wizard.dart';
export 'src/components/organisms/ds_progress_stepper.dart';
export 'src/components/organisms/ds_settings_view.dart';
export 'src/components/organisms/ds_sign_in_view.dart';
export 'src/components/organisms/ds_sign_up_view.dart';
// Templates
export 'src/components/templates/ds_page_scaffold.dart';
