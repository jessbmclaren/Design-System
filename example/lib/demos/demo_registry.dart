import 'package:flutter/widgets.dart';

import 'design_tokens_demo.dart';
import 'accordion_demo.dart';
import 'avatar_demo.dart';
import 'divider_demo.dart';
import 'icon_demo.dart';
import 'img_demo.dart';
import 'inline_demo.dart';
import 'link_demo.dart';
import 'menu_demo.dart';
import 'tooltip_demo.dart';
import 'text_fields_demo.dart';
import 'text_area_demo.dart';
import 'selection_controls_demo.dart';
import 'select_dropdown_demo.dart';
import 'currency_field_demo.dart';
import 'date_field_demo.dart';
import 'form_field_group_demo.dart';
import 'sparkline_demo.dart';
import 'bar_chart_demo.dart';
import 'line_chart_demo.dart';
import 'meter_chart_demo.dart';
import 'data_grid_demo.dart';
import 'cell_types_demo.dart';
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
import 'back_link_demo.dart';
import 'action_buttons_demo.dart';
import 'communicating_state_demo.dart';
import 'empty_state_demo.dart';
import 'loading_demo.dart';
import 'progress_stepping_demo.dart';
import 'waiting_screens_demo.dart';

/// Maps a page id to its live demo widget. Used by the docs app and the
/// screenshot harness. Reconciled deterministically with the content registry.
final Map<String, Widget Function()> _demos = {
  'design-tokens': () => const DesignTokensDemo(),
  'accordion': () => const AccordionDemo(),
  'avatar': () => const AvatarDemo(),
  'divider': () => const DividerDemo(),
  'icon': () => const IconDemo(),
  'img': () => const ImgDemo(),
  'inline': () => const InlineDemo(),
  'link': () => const LinkDemo(),
  'menu': () => const MenuDemo(),
  'tooltip': () => const TooltipDemo(),
  'text-fields': () => const TextFieldsDemo(),
  'text-area': () => const TextAreaDemo(),
  'selection-controls': () => const SelectionControlsDemo(),
  'select': () => const SelectDropdownDemo(),
  'currency-field': () => const CurrencyFieldDemo(),
  'date-field': () => const DateFieldDemo(),
  'form-field-group': () => const FormFieldGroupDemo(),
  'sparkline': () => const SparklineDemo(),
  'bar-chart': () => const BarChartDemo(),
  'line-chart': () => const LineChartDemo(),
  'meter-chart': () => const MeterChartDemo(),
  'data-grid': () => const DataGridDemo(),
  'cell-types': () => const CellTypesDemo(),
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
  'back-link': () => const BackLinkDemo(),
  'action-buttons': () => const ActionButtonsDemo(),
  'communicating-state': () => const CommunicatingStateDemo(),
  'empty-state': () => const EmptyStateDemo(),
  'loading': () => const LoadingDemo(),
  'progress-stepping': () => const ProgressSteppingDemo(),
  'waiting-screens': () => const WaitingScreensDemo(),
};

/// Returns the live demo for [id], or null if there is none.
Widget? demoFor(String id) => _demos[id]?.call();

/// The ids that have a live demo.
Iterable<String> get demoIds => _demos.keys;
