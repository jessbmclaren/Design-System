import 'package:flutter/widgets.dart';

import 'action_buttons_demo.dart';
import 'additional_context_demo.dart';
import 'back_link_demo.dart';
import 'communicating_state_demo.dart';
import 'design_tokens_demo.dart';
import 'empty_state_demo.dart';
import 'filter_controls_demo.dart';
import 'full_page_layouts_demo.dart';
import 'lists_demo.dart';
import 'loading_demo.dart';
import 'onboarding_demo.dart';
import 'progress_stepping_demo.dart';
import 'redirects_demo.dart';
import 'select_dropdown_demo.dart';
import 'selection_controls_demo.dart';
import 'settings_sign_in_demo.dart';
import 'sign_in_demo.dart';
import 'sign_out_demo.dart';
import 'text_fields_demo.dart';
import 'waiting_screens_demo.dart';

/// Maps a page id to its live demo widget. Used by the docs app to render the
/// "Live example" frame and by the screenshot harness to capture it.
final Map<String, Widget Function()> _demos = {
  'design-tokens': () => const DesignTokensDemo(),
  'full-page-layouts': () => const FullPageLayoutsDemo(),
  'lists': () => const ListsDemo(),
  'filter-controls': () => const FilterControlsDemo(),
  'select': () => const SelectDropdownDemo(),
  'onboarding': () => const OnboardingDemo(),
  'sign-in': () => const SignInDemo(),
  'settings-sign-in': () => const SettingsSignInDemo(),
  'additional-context': () => const AdditionalContextDemo(),
  'redirects': () => const RedirectsDemo(),
  'sign-out': () => const SignOutDemo(),
  'text-fields': () => const TextFieldsDemo(),
  'selection-controls': () => const SelectionControlsDemo(),
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
