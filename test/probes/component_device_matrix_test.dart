// Systematic device matrix over every exported Ds component.
//
// Sweep 1 pumps each specimen across the full device span (320dp small phone
// to 1920dp large desktop) under all four themes (light, dark, engen light,
// engen dark) and asserts nothing overflows or throws.
// Sweep 2 pumps each specimen at 320dp with a 1.3 text scale.
//
// Animated components (DsSpinner, DsAnimatedEllipsis, DsFadeSlideIn,
// DsBrandBloom, DsSpotlight and friends) are settled with fixed-duration
// pumps only, never pumpAndSettle, so the sweep stays deterministic.
//
// Not swept:
// - DsHeadingAlignment: an enum only (no widget to render).
// Every other barrel export with a render surface appears below, either in
// the inline scroll harness or, for full-page organisms and templates, as
// the Scaffold body at the device size.
//
// Known genuine defects (expectations left failing on purpose, since fixing
// them means changing lib/):
// - DsMeterChart: the legend item row (ds_meter_chart.dart:314) does not
//   flex its texts, so it overflows 68px to the right at 320dp with a 1.3
//   text scale.
// - DsStatusBar: the trailing slot is unflexed in the bar row
//   (ds_status_bar.dart:66), so a single text link overflows 29px to the
//   right at 320dp with a 1.3 text scale while the label ellipsizes to zero.
// - DsAppShell: the fixed 60dp top bar cannot hold the search field once
//   text scales to 1.3 at 320dp; the DsTextField column inside DsSearchField
//   overflows 4px on the bottom (ds_text_field.dart:218 via
//   ds_app_shell.dart's fixed topBarHeight).
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Representative device widths from a 320dp small phone to a 1920dp desktop.
const List<double> _widths = <double>[
  320, 360, 390, 414, 600, 768, 834, 1024, 1280, 1440, 1920,
];

// ---------------------------------------------------------------------------
// Shared realistic fixtures
// ---------------------------------------------------------------------------

const List<DsGridColumn> _gridColumns = <DsGridColumn>[
  DsGridColumn(key: 'name', title: 'Name'),
  DsGridColumn(
    key: 'amount',
    title: 'Amount',
    type: DsCellType.currency,
    currencySymbol: 'R',
  ),
  DsGridColumn(
    key: 'status',
    title: 'Status',
    type: DsCellType.status,
    options: <DsGridOption>[
      DsGridOption(
        value: 'active',
        label: 'Active',
        variant: DsBadgeVariant.success,
      ),
      DsGridOption(
        value: 'overdue',
        label: 'Overdue',
        variant: DsBadgeVariant.danger,
      ),
    ],
  ),
  DsGridColumn(key: 'due', title: 'Due', type: DsCellType.date),
];

final List<DsGridRow> _gridRows = <DsGridRow>[
  DsGridRow(id: 'inv-1', cells: <String, Object?>{
    'name': 'Acme Ltd',
    'amount': 1240.5,
    'status': 'active',
    'due': DateTime(2026, 7, 31),
  }),
  DsGridRow(id: 'inv-2', cells: <String, Object?>{
    'name': 'Globex Trading',
    'amount': 860,
    'status': 'overdue',
    'due': DateTime(2026, 6, 15),
  }),
  DsGridRow(id: 'inv-3', cells: <String, Object?>{
    'name': 'Initech',
    'amount': 300,
    'status': 'active',
    'due': DateTime(2026, 8, 2),
  }),
];

const List<DsNavItem> _navItems = <DsNavItem>[
  DsNavItem(label: 'Home', icon: DsIcons.gridView, route: '/home'),
  DsNavItem(label: 'Invoices', icon: DsIcons.list, route: '/invoices'),
  DsNavItem(label: 'Settings', icon: DsIcons.settings, route: '/settings'),
];

Widget _signInForm() => Column(
      children: <Widget>[
        DsTextField(label: 'Email address', onChanged: (_) {}),
        const SizedBox(height: 12),
        DsPasswordField(label: 'Password', onChanged: (_) {}),
      ],
    );

// ---------------------------------------------------------------------------
// Specimen registry: one entry per exported Ds widget, in barrel order.
// Inline specimens run in the scroll harness; full-page specimens (below)
// become the Scaffold body directly because they own their own layout.
// ---------------------------------------------------------------------------

final List<(String, WidgetBuilder)> specimens = <(String, WidgetBuilder)>[
  // -------------------------------------------------------------- Atoms
  ('DsAnimatedEllipsis', (_) => const DsAnimatedEllipsis()),
  // Paints an edge-to-edge wash, so it needs a bounded height inline.
  (
    'DsAuthGradient',
    (_) => const SizedBox(height: 240, child: DsAuthGradient()),
  ),
  ('DsAvatar', (_) => const DsAvatar(name: 'Amara Okafor')),
  ('DsBackLink', (_) => DsBackLink(label: 'Back to sign in', onPressed: () {})),
  (
    'DsBadge',
    (_) => const DsBadge(
          label: 'Paid',
          variant: DsBadgeVariant.success,
          icon: DsIcons.success,
        ),
  ),
  (
    'DsBox',
    (_) => const DsBox(
          padding: EdgeInsets.all(12),
          borderRadius: 8,
          child: Text('Quarterly summary for the finance team'),
        ),
  ),
  // Paints an edge-to-edge bloom, so it needs a bounded height inline.
  ('DsBrandBloom', (_) => const SizedBox(height: 240, child: DsBrandBloom())),
  (
    'DsButton',
    (_) => DsButton(label: 'Create account', icon: DsIcons.add, onPressed: () {}),
  ),
  (
    'DsButton.social',
    (_) => DsButton.social(
          icon: DsIcons.launch,
          label: 'Continue with SSO',
          onPressed: () {},
        ),
  ),
  (
    'DsCheckbox',
    (_) => DsCheckbox(
          value: true,
          onChanged: (_) {},
          label: 'Email me product updates',
        ),
  ),
  ('DsChip', (_) => DsChip(label: 'Design', onTap: () {})),
  (
    'DsChoiceChip',
    (_) => DsChoiceChip(
          label: 'Weekdays',
          selected: true,
          onSelected: (_) {},
          onRemoved: () {},
        ),
  ),
  (
    'DsChipGroup',
    (_) => DsChipGroup<String>(
          options: const <DsChipOption<String>>[
            DsChipOption<String>(value: 'mon', label: 'Monday'),
            DsChipOption<String>(value: 'tue', label: 'Tuesday'),
            DsChipOption<String>(value: 'wed', label: 'Wednesday'),
          ],
          selected: const <String>{'mon'},
          onChanged: (_) {},
          errorText: 'Choose at least one day',
        ),
  ),
  ('DsDivider', (_) => const DsDivider()),
  ('DsFadeSlideIn', (_) => const DsFadeSlideIn(child: Text('Welcome back'))),
  ('DsFieldLabel', (_) => const DsFieldLabel(label: 'Email address')),
  ('DsCheckDot', (_) => const DsCheckDot(met: true)),
  (
    'DsIcon',
    (_) => const DsIcon(icon: DsIcons.search, semanticLabel: 'Search'),
  ),
  (
    'DsIconBadge',
    (_) => const DsIconBadge(
          icon: DsIcons.check,
          tone: DsIconBadgeTone.success,
          semanticLabel: 'Step complete',
        ),
  ),
  (
    'DsIconButton',
    (_) => DsIconButton(
          icon: DsIcons.close,
          onPressed: () {},
          semanticLabel: 'Close panel',
        ),
  ),
  // No source given, so it renders its tokened skeleton box: deterministic
  // and network-free.
  (
    'DsImg',
    (_) => const DsImg(
          width: 120,
          height: 80,
          borderRadius: 8,
          semanticLabel: 'Product photo',
        ),
  ),
  ('DsInline', (_) => const DsInline(text: 'Amount due: R1,240.50', bold: true)),
  ('DsLink', (_) => DsLink(label: 'Forgot password?', onPressed: () {})),
  (
    'DsProgressBar',
    (_) => const DsProgressBar(value: 0.6, semanticLabel: 'Upload progress'),
  ),
  (
    'DsRadio',
    (_) => DsRadio<String>(
          value: 'card',
          groupValue: 'card',
          onChanged: (_) {},
          label: 'Pay by card',
        ),
  ),
  (
    'DsSegmentedControl',
    (_) => DsSegmentedControl<String>(
          segments: const <DsSegment<String>>[
            DsSegment(value: 'list', label: 'List'),
            DsSegment(value: 'board', label: 'Board'),
          ],
          value: 'list',
          onChanged: (_) {},
        ),
  ),
  ('DsSpinner', (_) => const DsSpinner()),
  ('DsShake', (_) => const DsShake(trigger: 0, child: Text('Card'))),
  (
    'DsNavLink',
    (_) => DsNavLink(label: 'Pricing', dropdown: true, onTap: () {}),
  ),
  (
    'DsKeyHint',
    (_) => const DsKeyHint(keys: <String>['⌘', '↵']),
  ),
  (
    'DsStatTile',
    (_) => DsStatTile(
          label: 'Open',
          value: '1,284',
          caption: 'up 12 this week',
          selected: true,
          onTap: () {},
        ),
  ),
  ('DsSparkline', (_) => const DsSparkline(values: <double>[3, 5, 4, 7, 6, 9, 8])),
  (
    'DsStepHeader',
    (_) => const DsStepHeader(
          title: 'Verify your business',
          lead: 'We need a few details to keep your account secure.',
        ),
  ),
  (
    'DsSwitch',
    (_) => DsSwitch(value: true, onChanged: (_) {}, label: 'Enable notifications'),
  ),
  ('DsWordmark', (_) => const DsWordmark()),
  // -------------------------------------------------------------- Molecules
  (
    'DsAccordion',
    (_) => const DsAccordion(
          items: <DsAccordionItem>[
            DsAccordionItem(
              title: 'Delivery',
              child: Text('Orders placed before noon ship the same day.'),
            ),
            DsAccordionItem(
              title: 'Returns',
              initiallyExpanded: true,
              child: Text('Unused items can be returned within 30 days.'),
            ),
          ],
        ),
  ),
  (
    'DsAddressFieldGroup',
    (_) => DsAddressFieldGroup(
          value: const DsAddressValue(
            street: '12 Harbour Lane',
            city: 'Cape Town',
            postalCode: '8001',
          ),
          onChanged: (_) {},
          countries: const <DsSelectOption<String>>[
            DsSelectOption(value: 'ZA', label: 'South Africa'),
            DsSelectOption(value: 'NZ', label: 'New Zealand'),
          ],
          legend: 'Registered address',
        ),
  ),
  (
    'DsBanner',
    (_) => DsBanner(
          variant: DsBannerVariant.warning,
          title: 'Card expiring soon',
          message: 'Your Visa ending 4242 expires at the end of July.',
          action: DsBannerAction(label: 'Update card', onPressed: () {}),
          onDismiss: () {},
        ),
  ),
  (
    'DsButtonGroup',
    (_) => DsButtonGroup(
          children: <Widget>[
            DsButton(label: 'Save changes', onPressed: () {}),
            DsButton(
              label: 'Cancel',
              variant: DsButtonVariant.secondary,
              onPressed: () {},
            ),
          ],
        ),
  ),
  (
    'DsCoachmark',
    (_) => DsCoachmark(
          title: 'Try saved filters',
          body: 'Keep your most-used views one tap away.',
          primaryActionLabel: 'Got it',
          onPrimary: () {},
          secondaryActionLabel: 'Later',
          onSecondary: () {},
          onDismiss: () {},
          stepIndex: 0,
          stepCount: 3,
        ),
  ),
  (
    'DsCookieBanner',
    (_) => DsCookieBanner(
          message: 'We use cookies to keep you signed in and improve the product.',
          onAcceptAll: () {},
          onRejectNonEssential: () {},
          onManagePreferences: () {},
        ),
  ),
  (
    'DsCurrencyField',
    (_) => DsCurrencyField(
          symbol: 'R',
          label: 'Amount',
          value: 1240.5,
          onChanged: (_) {},
        ),
  ),
  (
    'DsDateField',
    (_) => DsDateField(
          label: 'Due date',
          value: DateTime(2026, 7, 31),
          onChanged: (_) {},
        ),
  ),
  ('DsDropzone', (_) => DsDropzone(onBrowse: () {})),
  (
    'DsEmptyState',
    (_) => DsEmptyState(
          title: 'No invoices yet',
          message: 'Invoices you raise will appear here.',
          icon: DsIcons.archive,
          action: DsEmptyStateAction(label: 'Create an invoice', onPressed: () {}),
        ),
  ),
  (
    'DsFilterChip',
    (_) => DsFilterChip<String>(
          label: 'Status',
          options: const <DsFilterOption<String>>[
            DsFilterOption(value: 'active', label: 'Active'),
            DsFilterOption(value: 'overdue', label: 'Overdue'),
          ],
          value: 'active',
          onChanged: (_) {},
        ),
  ),
  (
    'DsFooterActions',
    (_) => DsFooterActions(
          primaryLabel: 'Continue',
          onPrimary: () {},
          backLabel: 'Back',
          onBack: () {},
          tertiaryLabel: 'Skip for now',
          onTertiary: () {},
        ),
  ),
  (
    'DsFormFieldGroup',
    (_) => DsFormFieldGroup(
          legend: 'Contact details',
          description: 'How we reach you about this order.',
          children: <Widget>[
            DsTextField(label: 'First name', onChanged: (_) {}),
            DsTextField(label: 'Last name', onChanged: (_) {}),
          ],
        ),
  ),
  (
    'DsInlineNotice',
    (_) => DsInlineNotice(
          message: 'That email address is already in use.',
          actionLabel: 'Sign in instead',
          onAction: () {},
        ),
  ),
  ('DsLabeledDivider', (_) => const DsLabeledDivider(label: 'or')),
  (
    'DsListItem',
    (_) => DsListItem(
          leading: const DsAvatar(name: 'Amara Okafor'),
          title: 'Amara Okafor',
          subtitle: 'amara@futurenet.example',
          trailing: const DsBadge(label: 'Owner'),
          onTap: () {},
        ),
  ),
  (
    'DsMenu',
    (_) => DsMenu(
          trigger: const DsIcon(
            icon: DsIcons.moreHorizontal,
            semanticLabel: 'More actions',
          ),
          items: <DsMenuItem>[
            DsMenuItem(label: 'Rename', icon: DsIcons.edit, onSelected: () {}),
            DsMenuItem(
              label: 'Delete',
              icon: DsIcons.delete,
              destructive: true,
              onSelected: () {},
            ),
          ],
        ),
  ),
  (
    'DsMenuSheet',
    (_) => DsMenuSheet(
          items: <DsMenuSheetItem>[
            DsMenuSheetItem(
              label: 'Rename',
              icon: DsIcons.edit,
              onSelected: () {},
            ),
            DsMenuSheetItem(
              label: 'Duplicate',
              icon: DsIcons.copy,
              selected: true,
              onSelected: () {},
            ),
            DsMenuSheetItem(
              label: 'Delete',
              icon: DsIcons.delete,
              destructive: true,
              onSelected: () {},
            ),
          ],
        ),
  ),
  (
    'DsPageHeader',
    (_) => DsPageHeader(
          title: 'Invoices',
          subtitle: '18 open, R42,300 outstanding',
          actions: <Widget>[
            DsButton(label: 'New invoice', onPressed: () {}),
          ],
        ),
  ),
  ('DsPasswordField', (_) => DsPasswordField(label: 'Password', onChanged: (_) {})),
  ('DsPasswordRequirements', (_) => const DsPasswordRequirements(value: 'Tr0ub4dor!')),
  (
    'DsPasswordRequirementRow',
    (_) => DsPasswordRequirementRow(
          rule: DsPasswordRule('At least 8 characters', true),
        ),
  ),
  ('DsPasswordStrength', (_) => const DsPasswordStrength(value: 'Tr0ub4dor!')),
  ('DsPasswordStrengthHint', (_) => const DsPasswordStrengthHint(value: 'Tr0ub4dor!')),
  (
    'DsProgressStepper',
    (_) => const DsProgressStepper(
          steps: <DsStep>[
            DsStep(label: 'Account'),
            DsStep(label: 'Business'),
            DsStep(label: 'Review'),
          ],
          currentIndex: 1,
        ),
  ),
  (
    'DsResendControl',
    (_) => DsResendControl(
          onResend: () async => const DsResendResult.sent(),
        ),
  ),
  (
    'DsPhoneField',
    (_) => DsPhoneField(
          label: 'Phone',
          countries: const <DsDialCode>[
            DsDialCode(code: 'ZA', dialCode: '+27', hintExample: '00 000 0000'),
            DsDialCode(code: 'GB', dialCode: '+44', hintExample: '0000 000000'),
          ],
          value: const DsPhoneValue(code: 'ZA', number: '821234567'),
          onChanged: (_) {},
        ),
  ),
  (
    'DsFloatingBar',
    (_) => const DsFloatingBar(
          floating: true,
          child: SizedBox(height: 60),
        ),
  ),
  (
    'DsTopNav',
    (_) => DsTopNav(
          brand: const Text('acme'),
          links: <DsTopNavLink>[
            DsTopNavLink(label: 'Product', dropdown: true, onTap: () {}),
            DsTopNavLink(label: 'Pricing', onTap: () {}),
          ],
          secondaryActions: <Widget>[
            DsButton(
              label: 'Log in',
              variant: DsButtonVariant.tertiary,
              onPressed: () {},
            ),
          ],
          primaryAction: DsButton(label: 'Get started', onPressed: () {}),
        ),
  ),
  (
    'DsSearchField',
    (_) => DsSearchField(onChanged: (_) {}, hintText: 'Search invoices'),
  ),
  (
    'DsSelect',
    (_) => DsSelect<String>(
          label: 'Country',
          value: 'ZA',
          options: const <DsSelectOption<String>>[
            DsSelectOption(value: 'ZA', label: 'South Africa'),
            DsSelectOption(value: 'NZ', label: 'New Zealand'),
          ],
          onChanged: (_) {},
        ),
  ),
  (
    'DsTabs',
    (_) => DsTabs(
          tabs: const <DsTab>[
            DsTab(label: 'Overview'),
            DsTab(label: 'Activity'),
            DsTab(label: 'Billing'),
          ],
          selectedIndex: 0,
          onChanged: (_) {},
        ),
  ),
  (
    'DsTextArea',
    (_) => DsTextArea(
          label: 'Notes',
          hintText: 'Anything the courier should know',
          onChanged: (_) {},
        ),
  ),
  (
    'DsTextField',
    (_) => DsTextField(
          label: 'Email address',
          hintText: 'you@company.com',
          onChanged: (_) {},
        ),
  ),
  (
    'DsToast',
    (_) => DsToast(
          message: 'Invoice INV-0042 sent',
          icon: DsIcons.success,
          action: DsToastAction(label: 'Undo', onPressed: () {}),
        ),
  ),
  // Exported alongside the molecules in the barrel; the file lives in atoms.
  (
    'DsTooltip',
    (_) => const DsTooltip(
          message: 'Copy account number',
          child: Text('20-41-77 88991234'),
        ),
  ),
  (
    'DsUploadField',
    (_) => DsUploadField(
          state: DsUploadFieldState.uploading,
          progress: 0.45,
          fileName: 'bank-statement.csv',
          onPick: () {},
          onRetry: () {},
          onRemove: () {},
        ),
  ),
  (
    'DsVerificationRail',
    (_) => const DsVerificationRail(
          sections: <DsVerificationSection>[
            DsVerificationSection(
              label: 'Business details',
              state: DsVerificationSectionState.done,
            ),
            DsVerificationSection(
              label: 'Identity',
              state: DsVerificationSectionState.active,
              subSteps: <String>['Upload ID', 'Selfie check'],
            ),
            DsVerificationSection(label: 'Review'),
          ],
        ),
  ),
  // -------------------------------------------------------------- Organisms
  (
    'DsBarChart',
    (_) => const DsBarChart(
          title: 'Revenue by month',
          data: <DsBarDatum>[
            DsBarDatum(label: 'Feb', value: 12),
            DsBarDatum(label: 'Mar', value: 18),
            DsBarDatum(label: 'Apr', value: 15),
            DsBarDatum(label: 'May', value: 22),
            DsBarDatum(label: 'Jun', value: 19),
            DsBarDatum(label: 'Jul', value: 27),
          ],
        ),
  ),
  // Lanes fill their height, so the board needs a bounded height inline.
  (
    'DsBoardView',
    (_) => SizedBox(
          height: 480,
          child: DsBoardView(
            columns: _gridColumns,
            rows: _gridRows,
            groupByKey: 'status',
          ),
        ),
  ),
  // The body slot is expanded, so the panel needs a bounded height inline.
  (
    'DsContextView',
    (_) => SizedBox(
          height: 480,
          child: DsContextView(
            title: 'Invoice INV-0042',
            onClose: () {},
            actions: <Widget>[
              DsIconButton(
                icon: DsIcons.edit,
                onPressed: () {},
                semanticLabel: 'Edit invoice',
              ),
            ],
            footer: DsButton(label: 'Mark as paid', fullWidth: true, onPressed: () {}),
            child: const Text('Raised 12 July 2026, due 31 July 2026.'),
          ),
        ),
  ),
  (
    'DsCookiePreferences',
    (_) => DsCookiePreferences(
          categories: const <DsCookieCategory>[
            DsCookieCategory(
              id: 'essential',
              title: 'Essential',
              description: 'Required to keep you signed in.',
              enabled: true,
              locked: true,
            ),
            DsCookieCategory(
              id: 'analytics',
              title: 'Analytics',
              description: 'Helps us understand which features are used.',
            ),
          ],
          onChanged: (_, _) {},
          onSave: () {},
          onAcceptAll: () {},
        ),
  ),
  // The grid scrolls internally, so it needs a bounded height inline.
  (
    'DsDataGrid',
    (_) => SizedBox(
          height: 400,
          child: DsDataGrid(columns: _gridColumns, rows: _gridRows),
        ),
  ),
  (
    'DsDataTable',
    (_) => const DsDataTable(
          columns: <DsColumn>[
            DsColumn(label: 'Invoice'),
            DsColumn(label: 'Amount', numeric: true),
            DsColumn(label: 'Status'),
          ],
          rows: <DsDataRow>[
            DsDataRow(cells: <String>['INV-0042', 'R1,240.50', 'Paid']),
            DsDataRow(cells: <String>['INV-0043', 'R860.00', 'Overdue']),
          ],
        ),
  ),
  (
    'DsFilterBar',
    (_) => DsFilterBar(
          columns: _gridColumns,
          value: const DsFilter(
            conditions: <DsFilterCondition>[
              DsFilterCondition(
                columnKey: 'name',
                operator: DsFilterOperator.contains,
                value: 'Acme',
              ),
            ],
          ),
          onChanged: (_) {},
          initiallyOpen: true,
        ),
  ),
  (
    'DsFocusView',
    (_) => DsFocusView(
          title: 'Edit invoice',
          onClose: () {},
          footer: DsFooterActions(primaryLabel: 'Save', onPrimary: () {}),
          child: DsTextField(label: 'Customer', onChanged: (_) {}),
        ),
  ),
  // The mapping step hosts an internally expanding preview, so the wizard
  // needs a bounded height inline (its own tests always give it a size).
  (
    'DsImportWizard',
    (_) => SizedBox(
          height: 560,
          child: DsImportWizard(
            destinationColumns: _gridColumns,
            source: const ImportSource(
              headers: <String>['name', 'amount'],
              rows: <List<String>>[
                <String>['Acme Ltd', '1240.50'],
                <String>['Globex Trading', '860.00'],
              ],
            ),
            onCommit: (_) {},
            onBrowse: () {},
            onCancel: () {},
          ),
        ),
  ),
  (
    'DsLineChart',
    (_) => const DsLineChart(
          title: 'Sign-ups',
          series: <DsLineSeries>[
            DsLineSeries(name: 'Web', values: <double>[4, 6, 5, 9, 8, 11]),
            DsLineSeries(name: 'Mobile', values: <double>[2, 3, 4, 4, 6, 7]),
          ],
          xLabels: <String>['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
        ),
  ),
  (
    'DsList',
    (_) => DsList(
          bordered: true,
          children: <Widget>[
            DsListItem(
              title: 'Acme Ltd',
              subtitle: 'R1,240.50 due 31 July',
              trailing: const DsBadge(
                label: 'Active',
                variant: DsBadgeVariant.success,
              ),
              onTap: () {},
            ),
            DsListItem(
              title: 'Globex Trading',
              subtitle: 'R860.00 due 15 June',
              trailing: const DsBadge(
                label: 'Overdue',
                variant: DsBadgeVariant.danger,
              ),
              onTap: () {},
            ),
          ],
        ),
  ),
  (
    'DsMeterChart',
    (_) => const DsMeterChart(
          title: 'Monthly budget',
          segments: <DsMeterSegment>[
            DsMeterSegment(label: 'Rent', value: 1200),
            DsMeterSegment(label: 'Utilities', value: 450),
            DsMeterSegment(label: 'Groceries', value: 800),
          ],
        ),
  ),
  // The rail expands to fill its height, so it needs a bounded height inline.
  (
    'DsNavRail',
    (_) => SizedBox(
          height: 520,
          child: DsNavRail(
            items: _navItems,
            selectedRoute: '/invoices',
            onNavigate: (_) {},
            extended: true,
          ),
        ),
  ),
  (
    'DsPolicyBuilder',
    (_) => DsPolicyBuilder(
          columns: _gridColumns,
          value: const DsPolicy(
            id: 'expenses',
            name: 'Expense policy',
            description: 'Rules applied to expense claims.',
            rules: <DsPolicyRule>[
              DsPolicyRule(
                effect: DsPolicyEffect.require,
                description: 'Claims over R500 need a receipt',
              ),
            ],
          ),
          onChanged: (_) {},
        ),
  ),
  // The panel body is expanded, so it needs a bounded height inline.
  (
    'DsRecordPanel',
    (_) => SizedBox(
          height: 520,
          child: DsRecordPanel(
            columns: _gridColumns,
            values: <String, Object?>{
              'name': 'Acme Ltd',
              'amount': 1240.5,
              'status': 'active',
              'due': DateTime(2026, 7, 31),
            },
            onChanged: (_) {},
            title: 'Acme Ltd',
            subtitle: 'Customer since 2023',
            onSave: () {},
            onClose: () {},
          ),
        ),
  ),
  // Hosts its own ListView, so it needs a bounded height inline.
  (
    'DsSettingsView',
    (_) => SizedBox(
          height: 480,
          child: DsSettingsView(
            sections: <DsSettingsSection>[
              DsSettingsSection(
                title: 'Notifications',
                description: 'Choose what we email you about.',
                children: <Widget>[
                  DsListItem(
                    title: 'Product updates',
                    trailing: DsSwitch(
                      value: true,
                      onChanged: (_) {},
                      semanticLabel: 'Product updates',
                    ),
                  ),
                  DsListItem(
                    title: 'Billing alerts',
                    trailing: DsSwitch(
                      value: false,
                      onChanged: (_) {},
                      semanticLabel: 'Billing alerts',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
  ),
  (
    'DsSetupGuide',
    (_) => DsSetupGuide(
          title: 'Get set up',
          tasks: <DsSetupTask>[
            const DsSetupTask(label: 'Create your account', done: true),
            DsSetupTask(label: 'Verify your email', onTap: () {}),
            const DsSetupTask(
              label: 'Add a payment method',
              locked: true,
              lockedMessage: 'Verify your email first',
            ),
          ],
        ),
  ),
  (
    'DsSortBuilder',
    (_) => DsSortBuilder(
          columns: _gridColumns,
          value: const <DsGridSort>[DsGridSort(columnKey: 'name')],
          onChanged: (_) {},
        ),
  ),
  (
    'DsSortPill',
    (_) => DsSortPill(
          columns: _gridColumns,
          sorts: const <DsGridSort>[
            DsGridSort(columnKey: 'amount', ascending: false),
          ],
          onChanged: (_) {},
        ),
  ),
  (
    'DsStatusBar',
    (_) => DsStatusBar(
          label: 'Sandbox mode',
          icon: DsIcons.info,
          trailing: <Widget>[
            DsLink(label: 'Exit sandbox', onPressed: () {}),
          ],
        ),
  ),
  (
    'DsTourCard',
    (_) => DsTourCard(
          steps: const <DsTourStep>[
            DsTourStep(
              title: 'Welcome to invoices',
              body: 'Raise, send and track invoices in one place.',
            ),
            DsTourStep(
              title: 'Automatic reminders',
              body: 'Overdue invoices nudge your customers for you.',
            ),
          ],
          currentStep: 0,
          onStepChanged: (_) {},
          onSkip: () {},
          onDone: () {},
        ),
  ),
  (
    'DsTreeView',
    (_) => DsTreeView(
          nodes: const <DsTreeNode>[
            DsTreeNode(
              id: 'finance',
              label: 'Finance',
              children: <DsTreeNode>[
                DsTreeNode(id: 'invoices', label: 'Invoices', badgeCount: 18),
                DsTreeNode(id: 'expenses', label: 'Expenses'),
              ],
            ),
            DsTreeNode(id: 'people', label: 'People'),
          ],
          selectedId: 'invoices',
          onSelect: (_) {},
        ),
  ),
  (
    'DsVerifyEmailCard',
    (_) => DsVerifyEmailCard(
          email: 'amara@futurenet.example',
          onContinue: () {},
          onResend: () {},
        ),
  ),
];

// Full-page organisms and templates: they own their own scrolling and
// alignment, so they become the Scaffold body directly at the device size.
final List<(String, WidgetBuilder)> fullPageSpecimens = <(String, WidgetBuilder)>[
  // -------------------------------------------------------------- Organisms
  ('DsBusinessVerification', (_) => const DsBusinessVerification()),
  (
    'DsOnboardingWizard',
    (_) => DsOnboardingWizard(
          steps: const <DsWizardStep>[
            DsWizardStep(label: 'Account'),
            DsWizardStep(label: 'Business'),
            DsWizardStep(label: 'Review'),
          ],
          currentIndex: 1,
          title: 'Tell us about your business',
          subtitle: 'We use this to verify your account.',
          onBack: () {},
          onNext: () {},
          child: DsTextField(label: 'Legal name', onChanged: (_) {}),
        ),
  ),
  (
    'DsChoosePasswordView',
    (_) => DsChoosePasswordView(
          value: 'Tr0ub4dor!42',
          primaryAction: DsSignInAction(label: 'Save new password', onPressed: () {}),
          autofocus: false,
        ),
  ),
  (
    'DsForgotPasswordView',
    (_) => DsForgotPasswordView(
          title: 'Reset your password',
          description: 'Enter your email and we will send you a reset link.',
          primaryAction: DsSignInAction(label: 'Email me a reset link', onPressed: () {}),
          form: DsTextField(label: 'Email address', onChanged: (_) {}),
        ),
  ),
  (
    'DsSignInView',
    (_) => DsSignInView(
          title: 'Sign in to FutureNet',
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
          form: _signInForm(),
          footer: DsLink(label: 'Forgot password?', onPressed: () {}),
        ),
  ),
  (
    'DsSignUpView',
    (_) => DsSignUpView(
          title: 'Create your account',
          form: _signInForm(),
          primaryActionLabel: 'Create account',
          onSubmit: () {},
          secondaryActionLabel: 'Sign in instead',
          onSecondaryAction: () {},
        ),
  ),
  (
    'DsSpotlight',
    (_) => DsSpotlight(
          title: 'Introducing insights',
          body: 'See how your revenue is trending each month.',
          actionLabel: 'Take a look',
          onAction: () {},
          child: const Center(child: Text('Dashboard content')),
        ),
  ),
  (
    'DsTakeover',
    (context) => DsTakeover(
          background: ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: const Center(child: Text('Dashboard content')),
          ),
          child: DsVerifyEmailCard(
            email: 'amara@futurenet.example',
            onContinue: () {},
            onResend: () {},
          ),
        ),
  ),
  (
    'DsWaitingScreen',
    (_) => const DsWaitingScreen(
          headline: 'Setting up your workspace',
          supportingText: 'This usually takes under a minute.',
        ),
  ),
  // -------------------------------------------------------------- Templates
  (
    'DsAppShell',
    (_) => DsAppShell(
          navItems: _navItems,
          selectedRoute: '/invoices',
          onNavigate: (_) {},
          brand: const DsWordmark(),
          search: DsSearchField(onChanged: (_) {}),
          body: const Center(child: Text('Invoices')),
        ),
  ),
  (
    'DsAuthShell',
    (_) => DsAuthShell(
          onBack: () {},
          child: DsVerifyEmailCard(
            email: 'amara@futurenet.example',
            onContinue: () {},
            onResend: () {},
          ),
        ),
  ),
  (
    'DsPageScaffold',
    (_) => DsPageScaffold(
          title: 'Invoices',
          subtitle: '18 open, R42,300 outstanding',
          actions: <Widget>[
            DsButton(label: 'New invoice', onPressed: () {}),
          ],
          body: const Text('Invoices you raise will appear here.'),
        ),
  ),
];

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

Widget _harness({
  required ThemeData theme,
  required double width,
  required WidgetBuilder builder,
  required bool fullPage,
  TextScaler? textScaler,
}) {
  final Widget body = fullPage
      ? Builder(builder: builder)
      : SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: width - 32, child: Builder(builder: builder)),
          ),
        );
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    builder: textScaler == null
        ? null
        : (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child!,
            ),
    home: Scaffold(body: body),
  );
}

Future<void> _sweepWidths(
  WidgetTester tester, {
  required String name,
  required String themeName,
  required ThemeData theme,
  required WidgetBuilder builder,
  required bool fullPage,
}) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;

  for (final double w in _widths) {
    tester.view.physicalSize = Size(w, 900);
    await tester.pumpWidget(
      _harness(theme: theme, width: w, builder: builder, fullPage: fullPage),
    );
    // Settle one-shot delays without waiting on repeating animations.
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      tester.takeException(),
      isNull,
      reason: '$name · $themeName at ${w.toStringAsFixed(0)}dp',
    );
  }
}

void main() {
  final Map<String, ThemeData> themes = <String, ThemeData>{
    'light': DsTheme.light(),
    'dark': DsTheme.dark(),
    'engen light': DsTheme.light(tokens: DsSkins.engenLight()),
    'engen dark': DsTheme.dark(tokens: DsSkins.engenDark()),
  };

  final List<(String, WidgetBuilder, bool)> all = <(String, WidgetBuilder, bool)>[
    for (final (String name, WidgetBuilder builder) in specimens)
      (name, builder, false),
    for (final (String name, WidgetBuilder builder) in fullPageSpecimens)
      (name, builder, true),
  ];

  // Sweep 1: every specimen, every theme, every width.
  for (final (String name, WidgetBuilder builder, bool fullPage) in all) {
    for (final MapEntry<String, ThemeData> entry in themes.entries) {
      testWidgets('$name · ${entry.key} — 320dp to 1920dp', (tester) async {
        await _sweepWidths(
          tester,
          name: name,
          themeName: entry.key,
          theme: entry.value,
          builder: builder,
          fullPage: fullPage,
        );
      });
    }
  }

  // Sweep 2: every specimen at 320dp with a 1.3 text scale.
  for (final (String name, WidgetBuilder builder, bool fullPage) in all) {
    testWidgets('$name · light at 320dp, text scale 1.3', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(320, 900);

      await tester.pumpWidget(
        _harness(
          theme: themes['light']!,
          width: 320,
          builder: builder,
          fullPage: fullPage,
          textScaler: const TextScaler.linear(1.3),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      expect(
        tester.takeException(),
        isNull,
        reason: '$name · light at 320dp with text scale 1.3',
      );
    });
  }
}
