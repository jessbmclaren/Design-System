import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Table workbench page: the whole working-table screen
/// assembled from parts — a `DsRosterView` shell carrying segment filters and
/// search, a density control and a `DsCheckMenu` column picker in its toolbar,
/// a `DsDataGrid` with a frozen identity column, an interactive switch cell,
/// typed value columns and a calculations footer, and a `DsRecordPanel`
/// detail alongside.
///
/// Deterministic: fixed data, no timers, no randomness, panel closed on first
/// build, so the page screenshots identically every run.
class TableWorkbenchDemo extends StatefulWidget {
  const TableWorkbenchDemo({super.key});

  @override
  State<TableWorkbenchDemo> createState() => _TableWorkbenchDemoState();
}

class _TableWorkbenchDemoState extends State<TableWorkbenchDemo> {
  static const _planOptions = [
    DsGridOption(value: 'Scale', variant: DsBadgeVariant.info),
    DsGridOption(value: 'Team', variant: DsBadgeVariant.neutral),
    DsGridOption(value: 'Trial', variant: DsBadgeVariant.warning),
  ];

  /// The full record set. The demo filters and sorts copies of this, never the
  /// source, so every control can be exercised in any order.
  static final List<_App> _all = <_App>[
    _App(
      id: 'search',
      name: 'Advanced search',
      icon: DsIcons.search,
      owner: 'Rae Mokoena',
      plan: 'Scale',
      spend: 9893.12,
      requests: 983124,
      errors: 412,
      uptime: 0.998,
      budget: 12000,
      live: true,
    ),
    _App(
      id: 'locker',
      name: 'Device locker',
      icon: DsIcons.settings,
      owner: 'Tom Whitfield',
      plan: 'Scale',
      spend: 5900.21,
      requests: 1032384,
      errors: 1083,
      uptime: 0.971,
      budget: 9000,
      live: true,
    ),
    _App(
      id: 'invoicing',
      name: 'Invoicing',
      icon: DsIcons.list,
      owner: 'Priya Naicker',
      plan: 'Team',
      spend: 123.32,
      requests: 19032,
      errors: 104,
      uptime: 0.994,
      budget: 2000,
      live: true,
    ),
    _App(
      id: 'editor',
      name: 'Media editor',
      icon: DsIcons.gridView,
      owner: 'Sam Adeyemi',
      plan: 'Trial',
      spend: 0,
      requests: 0,
      errors: 0,
      uptime: 0,
      budget: 1000,
      live: false,
    ),
    _App(
      id: 'calculator',
      name: 'Rate calculator',
      icon: DsIcons.tune,
      owner: 'Rae Mokoena',
      plan: 'Team',
      spend: 2140.40,
      requests: 214880,
      errors: 96,
      uptime: 0.999,
      budget: 4000,
      live: true,
    ),
    _App(
      id: 'reporting',
      name: 'Reporting',
      icon: DsIcons.checklist,
      owner: 'Priya Naicker',
      plan: 'Scale',
      spend: 5900.21,
      requests: 1032384,
      errors: 2210,
      uptime: 0.942,
      budget: 9000,
      live: true,
    ),
    _App(
      id: 'scheduler',
      name: 'Scheduler',
      icon: DsIcons.repeat,
      owner: 'Tom Whitfield',
      plan: 'Team',
      spend: 812.05,
      requests: 88410,
      errors: 12,
      uptime: 0.9995,
      budget: 3000,
      live: true,
    ),
    _App(
      id: 'scanner',
      name: 'Document scanner',
      icon: DsIcons.upload,
      owner: 'Sam Adeyemi',
      plan: 'Trial',
      spend: 0,
      requests: 0,
      errors: 0,
      uptime: 0,
      budget: 25000,
      live: false,
    ),
  ];

  /// Which of the switch cells are on. Held here rather than in the row data,
  /// because a custom cell reports its change and the screen owns the result.
  late final Map<String, bool> _live = <String, bool>{
    for (final _App app in _all) app.id: app.live,
  };

  String _segment = 'all';
  String _query = '';
  DsGridDensity _density = DsGridDensity.cosy;
  Set<String> _selected = <String>{};
  String? _openId;

  /// Every column that can be hidden, in display order. The two identity
  /// columns are deliberately absent: they are locked in the picker.
  static const List<String> _optionalKeys = <String>[
    'owner',
    'plan',
    'spend',
    'requests',
    'errors',
    'uptime',
    'budget',
  ];

  DsGridView _view = const DsGridView(
    visibleColumns: <String>[
      'live',
      'app',
      'owner',
      'plan',
      'spend',
      'requests',
      'errors',
      'uptime',
      'budget',
    ],
    calculations: <String, DsAggregation>{
      'spend': DsAggregation.sum,
      'requests': DsAggregation.sum,
      'errors': DsAggregation.sum,
      'uptime': DsAggregation.average,
    },
  );

  // --- Columns --------------------------------------------------------------

  /// Built in `build` rather than held as a `static const` list, because two
  /// columns render interactive cells that call back into this state.
  List<DsGridColumn> _columns() => <DsGridColumn>[
        DsGridColumn(
          key: 'live',
          title: 'Live',
          width: 76,
          frozen: true,
          sortable: true,
          resizable: false,
          align: DsColumnAlign.center,
          // An interactive custom cell: the switch reads the row's value and
          // reports the row it belongs to, so the screen knows what changed.
          cellBuilder: (context, value, row) => DsSwitch(
            value: value == true,
            semanticLabel: 'Live: ${row.cells['app']}',
            onChanged: (bool next) => setState(() => _live[row.id] = next),
          ),
        ),
        DsGridColumn(
          key: 'app',
          title: 'Application',
          width: 220,
          frozen: true,
          cellBuilder: _appCell,
        ),
        const DsGridColumn(
          key: 'owner',
          title: 'Owner',
          type: DsCellType.user,
          width: 180,
        ),
        const DsGridColumn(
          key: 'plan',
          title: 'Plan',
          type: DsCellType.status,
          width: 110,
          options: _planOptions,
        ),
        const DsGridColumn(
          key: 'spend',
          title: 'Spend',
          type: DsCellType.currency,
          width: 130,
        ),
        const DsGridColumn(
          key: 'requests',
          title: 'Requests',
          type: DsCellType.number,
          width: 130,
        ),
        const DsGridColumn(
          key: 'errors',
          title: 'Errors',
          type: DsCellType.number,
          width: 110,
        ),
        const DsGridColumn(
          key: 'uptime',
          title: 'Uptime',
          type: DsCellType.progress,
          width: 150,
        ),
        const DsGridColumn(
          key: 'budget',
          title: 'Budget',
          type: DsCellType.currency,
          width: 130,
        ),
      ];

  /// The identity cell: the application's glyph beside its name, the pairing
  /// the default `link` renderer cannot express on its own.
  static Widget _appCell(BuildContext context, Object? value, DsGridRow row) {
    final DsTokens tokens = DsTokens.of(context);
    final Object? icon = row.cells['icon'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon is IconData) ...<Widget>[
          DsIcon(icon: icon, size: DsIconSize.sm, color: tokens.colorPrimary),
          const SizedBox(width: DsSpacing.sm),
        ],
        Flexible(
          child: Text(
            value is String ? value : '—',
            style: tokens.bodySm.toTextStyle(color: tokens.colorPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // --- Data -----------------------------------------------------------------

  List<_App> get _filtered {
    final String needle = _query.trim().toLowerCase();
    return _all.where((_App app) {
      final bool matchesSegment = switch (_segment) {
        'live' => _live[app.id] == true,
        'paused' => _live[app.id] != true,
        _ => true,
      };
      final bool matchesQuery = needle.isEmpty ||
          app.name.toLowerCase().contains(needle) ||
          app.owner.toLowerCase().contains(needle);
      return matchesSegment && matchesQuery;
    }).toList();
  }

  DsGridRow _rowFor(_App app) => DsGridRow(
        id: app.id,
        cells: <String, Object?>{
          'live': _live[app.id] ?? false,
          'app': app.name,
          'icon': app.icon,
          'owner': app.owner,
          'plan': app.plan,
          'spend': app.spend,
          'requests': app.requests,
          'errors': app.errors,
          'uptime': app.uptime,
          'budget': app.budget,
        },
        onTap: () => setState(() => _openId = app.id),
      );

  int get _liveCount =>
      _all.where((_App app) => _live[app.id] == true).length;

  // --- Toolbar --------------------------------------------------------------

  Widget _densityControl() => DsSegmentedControl<DsGridDensity>(
        value: _density,
        onChanged: (DsGridDensity next) => setState(() => _density = next),
        segments: const <DsSegment<DsGridDensity>>[
          DsSegment<DsGridDensity>(
            value: DsGridDensity.comfortable,
            icon: DsIcons.densityComfortable,
            semanticLabel: 'Comfortable rows',
          ),
          DsSegment<DsGridDensity>(
            value: DsGridDensity.cosy,
            icon: DsIcons.densityCosy,
            semanticLabel: 'Cosy rows',
          ),
          DsSegment<DsGridDensity>(
            value: DsGridDensity.compact,
            icon: DsIcons.densityCompact,
            semanticLabel: 'Compact rows',
          ),
        ],
      );

  Widget _columnPicker() {
    final Map<String, String> titles = <String, String>{
      for (final DsGridColumn column in _columns()) column.key: column.title,
    };
    return DsCheckMenu(
      trigger: const DsIcon(icon: DsIcons.tune, semanticLabel: 'Columns'),
      options: <DsCheckOption>[
        // The two frozen identity columns are locked, which is what guarantees
        // the table can never be emptied of columns.
        const DsCheckOption(value: 'live', label: 'Live', enabled: false),
        const DsCheckOption(
          value: 'app',
          label: 'Application',
          enabled: false,
        ),
        for (final String key in _optionalKeys)
          DsCheckOption(value: key, label: titles[key] ?? key),
      ],
      selected: (_view.visibleColumns ?? const <String>[]).toSet(),
      onChanged: (Set<String> next) {
        setState(() {
          // Rebuild the visible list in the columns' own order, so ticking a
          // column restores it where it belongs rather than at the end.
          _view = _view.copyWith(
            visibleColumns: <String>[
              for (final DsGridColumn column in _columns())
                if (next.contains(column.key)) column.key,
            ],
          );
        });
      },
    );
  }

  // --- Detail ---------------------------------------------------------------

  Widget? _detail() {
    final String? id = _openId;
    if (id == null) return null;
    final _App app = _all.firstWhere((_App a) => a.id == id);
    final DsGridRow row = _rowFor(app);
    return DsRecordPanel(
      title: app.name,
      subtitle: 'Owned by ${app.owner}',
      // Every column is read-only here: the panel is a detail view, and the
      // one thing this record can change is the switch out on its row.
      columns: _columns()
          .where((DsGridColumn c) => c.key != 'live' && c.key != 'app')
          .toList(),
      values: row.cells,
      readOnlyKeys: const <String>{
        'owner',
        'plan',
        'spend',
        'requests',
        'errors',
        'uptime',
        'budget',
      },
      onChanged: (_) {},
      onClose: () => setState(() => _openId = null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_App> visible = _filtered;
    return DsRosterView(
      title: 'Applications',
      subtitle: 'Spend, traffic and reliability across every connected app.',
      countLabel: '${_all.length} applications',
      segments: <DsRosterSegment>[
        DsRosterSegment(value: 'all', label: 'All', count: _all.length),
        DsRosterSegment(value: 'live', label: 'Live', count: _liveCount),
        DsRosterSegment(
          value: 'paused',
          label: 'Paused',
          count: _all.length - _liveCount,
        ),
      ],
      segmentValue: _segment,
      onSegmentChanged: (String next) => setState(() => _segment = next),
      searchHint: 'Application or owner',
      onSearchChanged: (String next) => setState(() => _query = next),
      toolbarActions: <Widget>[_densityControl(), _columnPicker()],
      columns: _columns(),
      rows: visible.map(_rowFor).toList(),
      selectable: true,
      selectedRowIds: _selected,
      onSelectionChanged: (Set<String> next) =>
          setState(() => _selected = next),
      density: _density,
      view: _view,
      onViewChanged: (DsGridView next) => setState(() => _view = next),
      emptyState: const DsEmptyState(
        title: 'No applications match',
        message: 'Clear the search or pick another filter.',
      ),
      detail: _detail(),
      tableHeight: 520,
    );
  }
}

/// One application in the demo's fixed data set.
@immutable
class _App {
  const _App({
    required this.id,
    required this.name,
    required this.icon,
    required this.owner,
    required this.plan,
    required this.spend,
    required this.requests,
    required this.errors,
    required this.uptime,
    required this.budget,
    required this.live,
  });

  final String id;
  final String name;
  final IconData icon;
  final String owner;
  final String plan;
  final num spend;
  final num requests;
  final num errors;
  final num uptime;
  final num budget;
  final bool live;
}
