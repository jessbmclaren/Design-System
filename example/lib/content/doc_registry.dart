// Pure Dart, no Flutter imports.
//
// The registry of every documentation page, in navigation order. Both the
// docs app and tool/generate_markdown.dart import this. Generated/reconciled
// deterministically. Keep it in sync with lib/content/pages/.

import 'pattern_page_content.dart';
import 'pages/documentation.dart';
import 'pages/design_tokens.dart';
import 'pages/motion.dart';
import 'pages/iconography.dart';
import 'pages/breakpoints.dart';
import 'pages/accordion.dart';
import 'pages/avatar.dart';
import 'pages/divider.dart';
import 'pages/expiry_date.dart';
import 'pages/status_legend.dart';
import 'pages/icon.dart';
import 'pages/img.dart';
import 'pages/inline.dart';
import 'pages/link.dart';
import 'pages/check_list.dart';
import 'pages/check_menu.dart';
import 'pages/menu.dart';
import 'pages/tooltip.dart';
import 'pages/text_fields.dart';
import 'pages/text_area.dart';
import 'pages/segmented_control.dart';
import 'pages/selection_controls.dart';
import 'pages/radio_group.dart';
import 'pages/select_dropdown.dart';
import 'pages/currency_field.dart';
import 'pages/date_field.dart';
import 'pages/form_field_group.dart';
import 'pages/field_label.dart';
import 'pages/password_field.dart';
import 'pages/choose_password.dart';
import 'pages/password_requirements.dart';
import 'pages/resend_control.dart';
import 'pages/password_strength.dart';
import 'pages/icon_button.dart';
import 'pages/wordmark.dart';
import 'pages/labeled_divider.dart';
import 'pages/sparkline.dart';
import 'pages/bar_chart.dart';
import 'pages/line_chart.dart';
import 'pages/meter_chart.dart';
import 'pages/data_grid.dart';
import 'pages/data_table.dart';
import 'pages/cell_types.dart';
import 'pages/grouping.dart';
import 'pages/filtering_sorting.dart';
import 'pages/board_view.dart';
import 'pages/group_hierarchy.dart';
import 'pages/policies.dart';
import 'pages/data_import.dart';
import 'pages/import_guide.dart';
import 'pages/pagination.dart';
import 'pages/record_panel.dart';
import 'pages/roster_view.dart';
import 'pages/full_page_layouts.dart';
import 'pages/search_field.dart';
import 'pages/menu_sheet.dart';
import 'pages/nav_rail.dart';
import 'pages/status_bar.dart';
import 'pages/app_shell.dart';
import 'pages/table_views.dart';
import 'pages/table_workbench.dart';
import 'pages/task_view.dart';
import 'pages/dialog.dart';
import 'pages/key_hint.dart';
import 'pages/stat_tile.dart';
import 'pages/phone_field.dart';
import 'pages/choice_chips.dart';
import 'pages/time_field.dart';
import 'pages/site_nav.dart';
import 'pages/intro_card.dart';
import 'pages/summary_section.dart';
import 'pages/validators.dart';
import 'pages/lists.dart';
import 'pages/filter_controls.dart';
import 'pages/focus_view.dart';
import 'pages/box.dart';
import 'pages/button_group.dart';
import 'pages/footer_actions.dart';
import 'pages/context_view.dart';
import 'pages/settings_view.dart';
import 'pages/onboarding.dart';
import 'pages/sign_in.dart';
import 'pages/sign_up.dart';
import 'pages/settings_sign_in.dart';
import 'pages/additional_context.dart';
import 'pages/redirects.dart';
import 'pages/sign_out.dart';
import 'pages/coachmark.dart';
import 'pages/onboarding_wizard.dart';
import 'pages/business_verification.dart';
import 'pages/back_link.dart';
import 'pages/action_buttons.dart';
import 'pages/communicating_state.dart';
import 'pages/empty_state.dart';
import 'pages/loading.dart';
import 'pages/progress_bar.dart';
import 'pages/progress_stepping.dart';
import 'pages/setup_guide.dart';
import 'pages/waiting_screens.dart';
import 'pages/step_header.dart';
import 'pages/icon_badge.dart';
import 'pages/animated_ellipsis.dart';
import 'pages/fade_slide_in.dart';
import 'pages/auth_gradient.dart';
import 'pages/brand_bloom.dart';
import 'pages/takeover.dart';
import 'pages/address_field_group.dart';
import 'pages/upload_field.dart';
import 'pages/verification_rail.dart';
import 'pages/auth_shell.dart';
import 'pages/cookie_banner.dart';
import 'pages/cookie_preferences.dart';
import 'pages/tour_card.dart';
import 'pages/verify_email.dart';
import 'pages/spotlight.dart';

/// Every documentation page, in sidebar order.
final List<PatternPage> allPages = [
  // Foundations
  documentationPage,
  designTokensPage,
  motionPage,
  iconographyPage,
  breakpointsPage,
  validatorsPage,
  // Actions
  actionButtonsPage,
  backLinkPage,
  buttonGroupPage,
  footerActionsPage,
  linkPage,
  iconButtonPage,
  keyHintPage,
  // Inputs
  textFieldsPage,
  fieldLabelPage,
  passwordFieldPage,
  passwordRequirementsPage,
  resendControlPage,
  choosePasswordPage,
  passwordStrengthPage,
  textAreaPage,
  selectDropdownPage,
  segmentedControlPage,
  selectionControlsPage,
  checkListPage,
  radioGroupPage,
  currencyFieldPage,
  dateFieldPage,
  formFieldGroupPage,
  addressFieldGroupPage,
  uploadFieldPage,
  filterControlsPage,
  searchFieldPage,
  phoneFieldPage,
  choiceChipsPage,
  timeFieldPage,
  // Display
  accordionPage,
  avatarPage,
  dividerPage,
  labeledDividerPage,
  expiryDatePage,
  iconPage,
  iconBadgePage,
  imgPage,
  inlinePage,
  listsPage,
  statusLegendPage,
  stepHeaderPage,
  wordmarkPage,
  summarySectionPage,
  // Feedback
  animatedEllipsisPage,
  communicatingStatePage,
  emptyStatePage,
  loadingPage,
  progressBarPage,
  progressSteppingPage,
  verificationRailPage,
  waitingScreensPage,
  // Overlays
  menuPage,
  checkMenuPage,
  menuSheetPage,
  dialogPage,
  tooltipPage,
  coachmarkPage,
  focusViewPage,
  contextViewPage,
  takeoverPage,
  cookieBannerPage,
  cookiePreferencesPage,
  // Data
  dataGridPage,
  dataTablePage,
  tableViewsPage,
  statTilePage,
  cellTypesPage,
  groupingPage,
  filteringSortingPage,
  paginationPage,
  boardViewPage,
  groupHierarchyPage,
  policiesPage,
  dataImportPage,
  importGuidePage,
  recordPanelPage,
  rosterViewPage,
  tableWorkbenchPage,
  // Charts
  barChartPage,
  lineChartPage,
  meterChartPage,
  sparklinePage,
  // Layout
  appShellPage,
  authGradientPage,
  authShellPage,
  navRailPage,
  statusBarPage,
  taskViewPage,
  siteNavPage,
  boxPage,
  brandBloomPage,
  fadeSlideInPage,
  fullPageLayoutsPage,
  settingsViewPage,
  // Patterns
  onboardingPage,
  onboardingWizardPage,
  signInPage,
  signUpPage,
  signOutPage,
  settingsSignInPage,
  businessVerificationPage,
  verifyEmailPage,
  setupGuidePage,
  spotlightPage,
  tourCardPage,
  introCardPage,
  additionalContextPage,
  redirectsPage,
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
