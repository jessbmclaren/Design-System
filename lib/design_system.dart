/// Design System — a Material 3 based Flutter component library.
///
/// White-label by default: build your theme with [DsTheme.light] /
/// [DsTheme.dark], optionally passing your own [DsTokens] to re-brand every
/// component at once.
library;

// Tokens
export 'src/tokens/ds_breakpoints.dart';
export 'src/tokens/ds_colors.dart';
export 'src/tokens/ds_radii.dart';
export 'src/tokens/ds_spacing.dart';
export 'src/tokens/ds_typography.dart';

// Theme
export 'src/theme/ds_theme.dart';
export 'src/theme/ds_tokens_extension.dart';

// Components — organised by Atomic Design layer.
//
// Atoms
export 'src/components/atoms/ds_back_link.dart';
export 'src/components/atoms/ds_badge.dart';
export 'src/components/atoms/ds_button.dart';
export 'src/components/atoms/ds_chip.dart';
export 'src/components/atoms/ds_spinner.dart';
// Molecules
export 'src/components/molecules/ds_banner.dart';
export 'src/components/molecules/ds_empty_state.dart';
export 'src/components/molecules/ds_filter_chip.dart';
export 'src/components/molecules/ds_list_item.dart';
export 'src/components/molecules/ds_page_header.dart';
export 'src/components/molecules/ds_tabs.dart';
export 'src/components/molecules/ds_toast.dart';
// Organisms
export 'src/components/organisms/ds_data_table.dart';
export 'src/components/organisms/ds_focus_view.dart';
export 'src/components/organisms/ds_list.dart';
export 'src/components/organisms/ds_progress_stepper.dart';
export 'src/components/organisms/ds_sign_in_view.dart';
// Templates
export 'src/components/templates/ds_page_scaffold.dart';
