import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Roster view page: a fleet-drivers management screen with
/// working segment filters, search, sorting, selection, a tappable detail
/// panel (`DsRecordPanel`) and a guidance footer of `DsImportGuide`,
/// `DsStatusLegend` and mandatory-field notes. Deterministic — every expiry
/// hint is computed against the same fixed reference clock, and no timers or
/// randomness are involved.
class RosterViewDemo extends StatefulWidget {
  const RosterViewDemo({super.key});

  @override
  State<RosterViewDemo> createState() => _RosterViewDemoState();
}

class _RosterViewDemoState extends State<RosterViewDemo> {
  /// Fixed reference clock so the expiry hints never drift.
  static final DateTime _now = DateTime(2026, 7, 22);

  static const _licenceCodeOptions = [
    DsGridOption(value: 'Code B', variant: DsBadgeVariant.neutral),
    DsGridOption(value: 'Code C1', variant: DsBadgeVariant.neutral),
    DsGridOption(value: 'Code EB', variant: DsBadgeVariant.neutral),
    DsGridOption(value: 'Code EC', variant: DsBadgeVariant.neutral),
  ];

  static const _prdpOptions = [
    DsGridOption(value: 'PrDP G', variant: DsBadgeVariant.success),
    DsGridOption(value: 'No PrDP', variant: DsBadgeVariant.neutral),
  ];

  static const _groupOptions = [
    DsGridOption(value: 'Sales fleet', variant: DsBadgeVariant.neutral),
    DsGridOption(value: 'Delivery fleet', variant: DsBadgeVariant.neutral),
    DsGridOption(value: 'Night shift', variant: DsBadgeVariant.neutral),
  ];

  static const _availabilityOptions = [
    DsGridOption(value: 'Available', variant: DsBadgeVariant.success),
    DsGridOption(value: 'On trip', variant: DsBadgeVariant.neutral),
    DsGridOption(
      value: 'Temporarily unavailable',
      variant: DsBadgeVariant.warning,
    ),
    DsGridOption(value: 'Off duty', variant: DsBadgeVariant.neutral),
  ];

  static const _profileStatusOptions = [
    DsGridOption(value: 'Ready', variant: DsBadgeVariant.success),
    DsGridOption(value: 'Needs attention', variant: DsBadgeVariant.warning),
  ];

  /// Renders a date cell as a `DsExpiryDate` against the fixed clock; a null
  /// (or mistyped) value renders as an em dash, mirroring the grid's default.
  static Widget _expiryCell(
    BuildContext context,
    Object? value,
    DsGridRow row,
  ) {
    if (value is! DateTime) {
      final tokens = DsTokens.of(context);
      return Text(
        '—',
        style: tokens.bodySm.toTextStyle(
          color: tokens.colorSecondaryText,
        ),
      );
    }
    return DsExpiryDate(date: value, now: _now, dense: true);
  }

  /// One column list drives both the grid and the record panel detail.
  static final _columns = <DsGridColumn>[
    const DsGridColumn(
      key: 'name',
      title: 'Name',
      type: DsCellType.user,
      frozen: true,
      width: 200,
    ),
    const DsGridColumn(key: 'mobile', title: 'Mobile', width: 150),
    const DsGridColumn(
      key: 'licenceCode',
      title: 'Licence code',
      type: DsCellType.singleSelect,
      width: 132,
      options: _licenceCodeOptions,
    ),
    const DsGridColumn(
      key: 'licenceNumber',
      title: 'Licence number',
      width: 172,
    ),
    DsGridColumn(
      key: 'licenceExpiry',
      title: 'Licence expiry',
      type: DsCellType.date,
      width: 152,
      cellBuilder: _expiryCell,
    ),
    const DsGridColumn(
      key: 'prdp',
      title: 'PrDP',
      type: DsCellType.status,
      width: 112,
      options: _prdpOptions,
    ),
    DsGridColumn(
      key: 'prdpExpiry',
      title: 'PrDP expiry',
      type: DsCellType.date,
      width: 152,
      cellBuilder: _expiryCell,
    ),
    const DsGridColumn(
      key: 'groups',
      title: 'Groups',
      type: DsCellType.singleSelect,
      width: 140,
      options: _groupOptions,
    ),
    const DsGridColumn(
      key: 'availability',
      title: 'Availability',
      type: DsCellType.status,
      width: 196,
      options: _availabilityOptions,
    ),
    const DsGridColumn(
      key: 'profileStatus',
      title: 'Profile status',
      type: DsCellType.status,
      width: 150,
      options: _profileStatusOptions,
    ),
  ];

  /// The drivers, keyed by row id, in display order. Held in state so record
  /// panel edits flow back into the grid.
  late final Map<String, Map<String, Object?>> _drivers = {
    'ayanda': {
      'name': 'Ayanda Zulu',
      'mobile': '+27 82 111 2222',
      'licenceCode': 'Code C1',
      'licenceNumber': 'C1123456789012',
      'licenceExpiry': DateTime(2028, 3, 14),
      'prdp': 'PrDP G',
      'prdpExpiry': DateTime(2027, 9, 30),
      'groups': 'Delivery fleet',
      'availability': 'Available',
      'profileStatus': 'Ready',
    },
    'bongani': {
      'name': 'Bongani Khumalo',
      'mobile': '+27 83 222 3333',
      'licenceCode': 'Code EC',
      'licenceNumber': 'EC987654321098',
      'licenceExpiry': DateTime(2027, 11, 2),
      'prdp': 'PrDP G',
      'prdpExpiry': DateTime(2027, 4, 18),
      'groups': 'Delivery fleet',
      'availability': 'On trip',
      'profileStatus': 'Ready',
    },
    'derek': {
      'name': 'Derek Naidoo',
      'mobile': '+27 82 333 4444',
      'licenceCode': 'Code B',
      'licenceNumber': 'B345678901234',
      'licenceExpiry': DateTime(2026, 9, 19),
      'prdp': 'No PrDP',
      'prdpExpiry': null,
      'groups': 'Sales fleet',
      'availability': 'Available',
      'profileStatus': 'Needs attention',
    },
    'johan': {
      'name': 'Johan van der Merwe',
      'mobile': '+27 84 555 6666',
      'licenceCode': 'Code EB',
      'licenceNumber': 'EB456789123456',
      'licenceExpiry': DateTime(2027, 1, 7),
      'prdp': 'PrDP G',
      'prdpExpiry': DateTime(2026, 12, 15),
      'groups': 'Sales fleet',
      'availability': 'Temporarily unavailable',
      'profileStatus': 'Needs attention',
    },
    'mandla': {
      'name': 'Mandla Nkosi',
      'mobile': '+27 82 666 7777',
      'licenceCode': 'Code EC',
      'licenceNumber': 'EC246813579024',
      'licenceExpiry': DateTime(2029, 5, 23),
      'prdp': 'PrDP G',
      'prdpExpiry': DateTime(2028, 2, 9),
      'groups': 'Night shift',
      'availability': 'Off duty',
      'profileStatus': 'Ready',
    },
    'nandi': {
      'name': 'Nandi Mthembu',
      'mobile': '+27 83 777 8888',
      'licenceCode': 'Code B',
      'licenceNumber': 'B135792468013',
      'licenceExpiry': DateTime(2027, 8, 30),
      'prdp': 'No PrDP',
      'prdpExpiry': null,
      'groups': 'Sales fleet',
      'availability': 'Available',
      'profileStatus': 'Ready',
    },
  };

  String _segment = 'all';
  String _query = '';
  Set<String> _selected = {};
  DsGridSort? _sort;
  String? _openDriverId;
  int _page = 1;
  int _pageSize = 25;

  static const int _totalItems = 12;

  void _notify(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Pans [child] horizontally instead of overflowing when the layout is
  /// narrower than [minWidth] (the pager row and the widest legend badge have
  /// fixed intrinsic widths).
  static Widget _panBelow(double minWidth, Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= minWidth) return child;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: child),
        );
      },
    );
  }

  static int _compare(Object? a, Object? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is DateTime && b is DateTime) return a.compareTo(b);
    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }

  /// The rows, filtered by segment and search and sorted — prepared by the
  /// caller, exactly as `DsRosterView` expects.
  List<DsGridRow> _visibleRows() {
    final query = _query.trim().toLowerCase();
    final entries = _drivers.entries.where((entry) {
      final cells = entry.value;
      final matchesSegment = switch (_segment) {
        'ready' => cells['profileStatus'] == 'Ready',
        'attention' => cells['profileStatus'] == 'Needs attention',
        _ => true,
      };
      final matchesQuery = query.isEmpty ||
          (cells['name'] as String).toLowerCase().contains(query);
      return matchesSegment && matchesQuery;
    }).toList();

    final sort = _sort;
    if (sort != null) {
      entries.sort((a, b) {
        final result = _compare(
          a.value[sort.columnKey],
          b.value[sort.columnKey],
        );
        return sort.ascending ? result : -result;
      });
    }

    return [
      for (final entry in entries)
        DsGridRow(
          id: entry.key,
          cells: entry.value,
          onTap: () => setState(() => _openDriverId = entry.key),
        ),
    ];
  }

  Widget _headerMenu() {
    return DsMenu(
      // The menu's own wrapper handles taps, focus and announcement, so the
      // button inside is display-only: pointer-transparent and out of the
      // focus and semantics trees, while keeping its enabled look.
      trigger: Semantics(
        label: 'Add via CSV',
        child: ExcludeFocus(
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: DsButton(
                label: 'Add via CSV',
                variant: DsButtonVariant.secondary,
                trailingIcon: DsIcons.expandMore,
                onPressed: _menuHandledTap,
              ),
            ),
          ),
        ),
      ),
      items: [
        DsMenuItem(
          label: 'Upload CSV',
          icon: DsIcons.upload,
          onSelected: () => _notify('Uploading a CSV…'),
        ),
        DsMenuItem(
          label: 'Download CSV template',
          icon: DsIcons.download,
          onSelected: () => _notify('Downloading the CSV template…'),
        ),
      ],
    );
  }

  /// Never invoked: taps are claimed by the enclosing [DsMenu] trigger. Kept
  /// non-null so the button renders enabled.
  static void _menuHandledTap() {}

  Widget _footer(DsTokens tokens) {
    final headingStyle = tokens.labelMd
        .toTextStyle(color: tokens.colorText)
        .copyWith(fontWeight: tokens.strongLabelFontWeight);
    final bodyStyle = tokens.bodySm.toTextStyle(
      color: tokens.colorSecondaryText,
    );

    return Wrap(
      spacing: 48,
      runSpacing: 32,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: DsImportGuide(
            title: 'Add via CSV',
            description: 'Import many drivers at once from a spreadsheet.',
            steps: const [
              'Download the CSV template',
              'Complete all required fields (do not change the column '
                  'headings or format)',
              'Upload your completed template',
            ],
            downloadLabel: 'Download CSV template',
            onDownloadTemplate: () => _notify('Downloading the CSV template…'),
          ),
        ),
        _panBelow(
          480,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: DsStatusLegend(
              title: 'Statuses explained',
              entries: const [
                DsStatusLegendEntry(
                  label: 'Ready',
                  description: 'Fully compliant and available to take trips.',
                  variant: DsBadgeVariant.success,
                ),
                DsStatusLegendEntry(
                  label: 'Needs attention',
                  description: 'A document is missing or about to expire.',
                  variant: DsBadgeVariant.warning,
                ),
                DsStatusLegendEntry(
                  label: 'Temporarily unavailable',
                  description: 'Off the road for now, for example on leave.',
                ),
                DsStatusLegendEntry(
                  label: 'Off duty',
                  description: 'Outside working hours and not taking trips.',
                ),
                DsStatusLegendEntry(
                  label: 'Deactivated',
                  description:
                      'Removed from the roster and cannot be assigned.',
                  variant: DsBadgeVariant.danger,
                ),
              ],
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mandatory fields', style: headingStyle),
              const SizedBox(height: 12),
              for (final field in const [
                'Full name',
                'Mobile number',
                'Licence code',
                'Licence number',
                'Licence expiry',
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('•  $field', style: bodyStyle),
                ),
              const SizedBox(height: 8),
              DsLink(
                label: 'View all requirements',
                trailingIcon: DsIcons.arrowForward,
                onPressed: () => _notify('Opening the driver requirements…'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _detail() {
    final openId = _openDriverId;
    if (openId == null) return null;
    final values = _drivers[openId];
    if (values == null) return null;
    return DsRecordPanel(
      columns: _columns,
      values: values,
      title: values['name'] as String?,
      subtitle: 'Driver profile',
      onChanged: (next) => setState(() => _drivers[openId] = next),
      onClose: () => setState(() => _openDriverId = null),
      groups: const [
        DsRecordFieldGroup(title: 'Personal', columnKeys: ['name', 'mobile']),
        DsRecordFieldGroup(
          title: 'Licence',
          columnKeys: ['licenceCode', 'licenceNumber', 'licenceExpiry'],
        ),
        DsRecordFieldGroup(title: 'PrDP', columnKeys: ['prdp', 'prdpExpiry']),
        DsRecordFieldGroup(
          title: 'Company',
          columnKeys: ['groups', 'availability', 'profileStatus'],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return DsRosterView(
      title: 'Drivers',
      subtitle: 'The drivers operating your vehicles.',
      headerActions: [
        _headerMenu(),
        DsButton(
          label: 'Add driver',
          icon: DsIcons.add,
          onPressed: () => _notify('Adding a driver…'),
        ),
      ],
      countLabel: '12 drivers',
      segments: const [
        DsRosterSegment(value: 'all', label: 'All drivers', count: 12),
        DsRosterSegment(value: 'ready', label: 'Ready', count: 10),
        DsRosterSegment(value: 'attention', label: 'Needs attention', count: 2),
      ],
      segmentValue: _segment,
      onSegmentChanged: (next) => setState(() => _segment = next),
      searchHint: 'Search drivers…',
      onSearchChanged: (query) => setState(() => _query = query),
      toolbarActions: [
        DsButton(
          label: 'Filter',
          icon: DsIcons.filter,
          variant: DsButtonVariant.tertiary,
          onPressed: () {},
        ),
        DsButton(
          label: 'Group',
          icon: DsIcons.workspace,
          variant: DsButtonVariant.tertiary,
          onPressed: () {},
        ),
        DsButton(
          label: 'Sort',
          icon: DsIcons.sort,
          variant: DsButtonVariant.tertiary,
          onPressed: () {},
        ),
        DsButton(
          label: 'Fields',
          icon: DsIcons.list,
          variant: DsButtonVariant.tertiary,
          onPressed: () {},
        ),
      ],
      columns: _columns,
      rows: _visibleRows(),
      selectable: true,
      selectedRowIds: _selected,
      onSelectionChanged: (next) => setState(() => _selected = next),
      sort: _sort,
      onSort: (next) => setState(() => _sort = next),
      pagination: _panBelow(
        340,
        DsPagination(
          page: _page,
          pageCount: (_totalItems / _pageSize).ceil(),
          totalItems: _totalItems,
          pageSize: _pageSize,
          onPageChanged: (next) => setState(() => _page = next),
          onPageSizeChanged: (size) => setState(() {
            _pageSize = size;
            _page = 1;
          }),
        ),
      ),
      footer: _footer(tokens),
      detail: _detail(),
      tableHeight: 480,
    );
  }
}
