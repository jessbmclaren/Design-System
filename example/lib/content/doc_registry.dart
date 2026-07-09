// Pure Dart — NO Flutter imports.
//
// The registry of every documentation page, in navigation order. Both the
// docs app and tool/generate_markdown.dart import this.

import 'pattern_page_content.dart';
import 'pages/design_tokens.dart';
import 'pages/full_page_layouts.dart';
import 'pages/lists.dart';
import 'pages/filter_controls.dart';
import 'pages/text_fields.dart';
import 'pages/selection_controls.dart';
import 'pages/select_dropdown.dart';
import 'pages/onboarding.dart';
import 'pages/sign_in.dart';
import 'pages/settings_sign_in.dart';
import 'pages/additional_context.dart';
import 'pages/redirects.dart';
import 'pages/sign_out.dart';
import 'pages/back_link.dart';
import 'pages/action_buttons.dart';
import 'pages/communicating_state.dart';
import 'pages/empty_state.dart';
import 'pages/loading.dart';
import 'pages/progress_stepping.dart';
import 'pages/waiting_screens.dart';

/// Every documentation page, in sidebar order.
final List<PatternPage> allPages = [
  // Foundations
  designTokensPage,
  // Layout
  fullPageLayoutsPage,
  listsPage,
  filterControlsPage,
  // Forms
  textFieldsPage,
  selectionControlsPage,
  selectDropdownPage,
  // Onboarding
  onboardingPage,
  signInPage,
  settingsSignInPage,
  additionalContextPage,
  redirectsPage,
  signOutPage,
  // User actions
  backLinkPage,
  actionButtonsPage,
  // Status
  communicatingStatePage,
  emptyStatePage,
  loadingPage,
  progressSteppingPage,
  waitingScreensPage,
];

/// Lookup by page id.
final Map<String, PatternPage> pageIndex = {
  for (final page in allPages) page.id: page,
};

/// The pages belonging to [group], in order.
List<PatternPage> pagesInGroup(DocGroup group) =>
    allPages.where((p) => p.group == group).toList();

/// The groups that have at least one page, in display order.
List<DocGroup> get orderedGroups =>
    DocGroup.values.where((g) => pagesInGroup(g).isNotEmpty).toList();
