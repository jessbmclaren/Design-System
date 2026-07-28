import 'package:flutter/widgets.dart';

import 'design_tokens_demo.dart';
import 'motion_demo.dart';
import 'iconography_demo.dart';
import 'breakpoints_demo.dart';
import 'accordion_demo.dart';
import 'avatar_demo.dart';
import 'divider_demo.dart';
import 'icon_button_demo.dart';
import 'icon_demo.dart';
import 'img_demo.dart';
import 'inline_demo.dart';
import 'link_demo.dart';
import 'menu_demo.dart';
import 'check_list_demo.dart';
import 'check_menu_demo.dart';
import 'tooltip_demo.dart';
import 'text_fields_demo.dart';
import 'password_field_demo.dart';
import 'choose_password_demo.dart';
import 'password_requirements_demo.dart';
import 'resend_control_demo.dart';
import 'password_strength_demo.dart';
import 'text_area_demo.dart';
import 'selection_controls_demo.dart';
import 'radio_group_demo.dart';
import 'select_dropdown_demo.dart';
import 'currency_field_demo.dart';
import 'date_field_demo.dart';
import 'form_field_group_demo.dart';
import 'sparkline_demo.dart';
import 'bar_chart_demo.dart';
import 'line_chart_demo.dart';
import 'meter_chart_demo.dart';
import 'data_grid_demo.dart';
import 'data_table_demo.dart';
import 'cell_types_demo.dart';
import 'grouping_demo.dart';
import 'filtering_sorting_demo.dart';
import 'board_view_demo.dart';
import 'group_hierarchy_demo.dart';
import 'policies_demo.dart';
import 'data_import_demo.dart';
import 'expiry_date_demo.dart';
import 'import_guide_demo.dart';
import 'pagination_demo.dart';
import 'record_panel_demo.dart';
import 'roster_view_demo.dart';
import 'table_workbench_demo.dart';
import 'status_legend_demo.dart';
import 'full_page_layouts_demo.dart';
import 'lists_demo.dart';
import 'filter_controls_demo.dart';
import 'focus_view_demo.dart';
import 'box_demo.dart';
import 'button_group_demo.dart';
import 'context_view_demo.dart';
import 'settings_view_demo.dart';
import 'onboarding_demo.dart';
import 'sign_in_demo.dart';
import 'sign_up_demo.dart';
import 'settings_sign_in_demo.dart';
import 'additional_context_demo.dart';
import 'redirects_demo.dart';
import 'sign_out_demo.dart';
import 'coachmark_demo.dart';
import 'onboarding_wizard_demo.dart';
import 'business_verification_demo.dart';
import 'setup_guide_demo.dart';
import 'back_link_demo.dart';
import 'action_buttons_demo.dart';
import 'communicating_state_demo.dart';
import 'empty_state_demo.dart';
import 'loading_demo.dart';
import 'progress_bar_demo.dart';
import 'progress_stepping_demo.dart';
import 'waiting_screens_demo.dart';
import 'verify_email_demo.dart';
import 'spotlight_demo.dart';

/// Maps a page id to its live demo widget. Used by the docs app and the
/// screenshot harness. Reconciled deterministically with the content registry.
final Map<String, Widget Function()> _demos = {
  'design-tokens': () => const DesignTokensDemo(),
  'motion': () => const MotionDemo(),
  'iconography': () => const IconographyDemo(),
  'breakpoints': () => const BreakpointsDemo(),
  'accordion': () => const AccordionDemo(),
  'avatar': () => const AvatarDemo(),
  'divider': () => const DividerDemo(),
  'icon': () => const IconDemo(),
  'icon-button': () => const IconButtonDemo(),
  'img': () => const ImgDemo(),
  'inline': () => const InlineDemo(),
  'link': () => const LinkDemo(),
  'menu': () => const MenuDemo(),
  'check-menu': () => const CheckMenuDemo(),
  'check-list': () => const CheckListDemo(),
  'tooltip': () => const TooltipDemo(),
  'text-fields': () => const TextFieldsDemo(),
  'password-field': () => const PasswordFieldDemo(),
  'password-requirements': () => const PasswordRequirementsDemo(),
  'resend-control': () => const ResendControlDemo(),
  'choose-password': () => const ChoosePasswordDemo(),
  'password-strength': () => const PasswordStrengthDemo(),
  'text-area': () => const TextAreaDemo(),
  'selection-controls': () => const SelectionControlsDemo(),
  'radio-group': () => const RadioGroupDemo(),
  'select': () => const SelectDropdownDemo(),
  'currency-field': () => const CurrencyFieldDemo(),
  'date-field': () => const DateFieldDemo(),
  'form-field-group': () => const FormFieldGroupDemo(),
  'sparkline': () => const SparklineDemo(),
  'bar-chart': () => const BarChartDemo(),
  'line-chart': () => const LineChartDemo(),
  'meter-chart': () => const MeterChartDemo(),
  'data-grid': () => const DataGridDemo(),
  'data-table': () => const DataTableDemo(),
  'cell-types': () => const CellTypesDemo(),
  'grouping': () => const GroupingDemo(),
  'filtering-sorting': () => const FilteringSortingDemo(),
  'board-view': () => const BoardViewDemo(),
  'group-hierarchy': () => const GroupHierarchyDemo(),
  'policies': () => const PoliciesDemo(),
  'data-import': () => const DataImportDemo(),
  'record-panel': () => const RecordPanelDemo(),
  'expiry-date': () => const ExpiryDateDemo(),
  'status-legend': () => const StatusLegendDemo(),
  'pagination': () => const PaginationDemo(),
  'import-guide': () => const ImportGuideDemo(),
  'roster-view': () => const RosterViewDemo(),
  'table-workbench': () => const TableWorkbenchDemo(),
  'full-page-layouts': () => const FullPageLayoutsDemo(),
  'lists': () => const ListsDemo(),
  'filter-controls': () => const FilterControlsDemo(),
  'focus-view': () => const FocusViewDemo(),
  'box': () => const BoxDemo(),
  'button-group': () => const ButtonGroupDemo(),
  'context-view': () => const ContextViewDemo(),
  'settings-view': () => const SettingsViewDemo(),
  'onboarding': () => const OnboardingDemo(),
  'sign-in': () => const SignInDemo(),
  'sign-up': () => const SignUpDemo(),
  'settings-sign-in': () => const SettingsSignInDemo(),
  'additional-context': () => const AdditionalContextDemo(),
  'redirects': () => const RedirectsDemo(),
  'sign-out': () => const SignOutDemo(),
  'coachmark': () => const CoachmarkDemo(),
  'onboarding-wizard': () => const OnboardingWizardDemo(),
  'business-verification': () => const BusinessVerificationDemo(),
  'verify-email': () => const VerifyEmailDemo(),
  'setup-guide': () => const SetupGuideDemo(),
  'spotlight': () => const SpotlightDemo(),
  'back-link': () => const BackLinkDemo(),
  'action-buttons': () => const ActionButtonsDemo(),
  'communicating-state': () => const CommunicatingStateDemo(),
  'empty-state': () => const EmptyStateDemo(),
  'loading': () => const LoadingDemo(),
  'progress-bar': () => const ProgressBarDemo(),
  'progress-stepping': () => const ProgressSteppingDemo(),
  'waiting-screens': () => const WaitingScreensDemo(),
};

/// Returns the live demo for [id], or null if there is none.
Widget? demoFor(String id) => _demos[id]?.call();

/// The ids that have a live demo.
Iterable<String> get demoIds => _demos.keys;
