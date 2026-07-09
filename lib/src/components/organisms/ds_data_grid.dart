import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import '../atoms/ds_avatar.dart';
import '../atoms/ds_badge.dart';
import '../atoms/ds_checkbox.dart';
import '../atoms/ds_icon.dart';
import '../atoms/ds_link.dart';

/// The kind of value a [DsGridColumn] holds, which selects how each cell is
/// rendered and compared when sorting.
///
/// The value stored in [DsGridRow.cells] for a column must match the type:
///
/// * [text] — a `String`.
/// * [number] — a `num`, rendered right-aligned with thousands separators.
/// * [currency] — a `num`, rendered as `symbol` + amount to two decimals.
/// * [date] — a `DateTime`, rendered as `yyyy-MM-dd`.
/// * [singleSelect] — a `String` label, rendered as a single [DsBadge].
/// * [multiSelect] — a `List<String>`, rendered as a wrap of neutral badges.
/// * [checkbox] — a `bool`, rendered as a read-only check / empty box.
/// * [link] — a `String` label, rendered as a [DsLink].
/// * [user] — a `String` name, rendered as a [DsAvatar] plus the name.
/// * [status] — a `String` label, rendered as a semantically coloured badge.
/// * [rating] — a `num` in `0..5`, rendered as a row of star glyphs.
/// * [progress] — a `num` in `0..1`, rendered as a slim bar with a percentage.
///
/// A missing (`null`) or mistyped value always renders as an em dash in the
/// secondary text colour, so the grid never throws on ragged data.
enum DsCellType {
  /// Free-form text.
  text,

  /// A numeric value, right-aligned.
  number,

  /// A monetary value shown with a currency symbol and two decimals.
  currency,

  /// A calendar date shown as `yyyy-MM-dd`.
  date,

  /// A single choice rendered as one badge.
  singleSelect,

  /// A set of choices rendered as a wrap of badges.
  multiSelect,

  /// A boolean rendered as a read-only check / empty box.
  checkbox,

  /// A hyperlink label.
  link,

  /// A person, rendered as an avatar and name.
  user,

  /// A status label rendered as a semantically coloured badge.
  status,

  /// A star rating in the range `0..5`.
  rating,

  /// A completion ratio in the range `0..1`.
  progress,
}

/// How a [DsGridColumn]'s content is aligned within its cell.
enum DsColumnAlign {
  /// Aligned to the leading edge (left in left-to-right locales).
  start,

  /// Centred horizontally.
  center,

  /// Aligned to the trailing edge (right in left-to-right locales).
  end,
}

/// The definition of a single column in a [DsDataGrid].
///
/// A column binds a stable [key] (used to look up each row's value in
/// [DsGridRow.cells]) to a human-readable [title] and a [type] that decides how
/// the cell is rendered and sorted. Columns describe their own [width],
/// [minWidth], whether they are [frozen] (pinned to the leading edge), whether
/// they are [sortable] and [resizable], their [align]ment, an optional header
/// [icon] and, for [DsCellType.currency], a [currencySymbol].
@immutable
class DsGridColumn {
  /// Creates a column definition.
  ///
  /// [key] must be unique within the grid and match the keys used in each
  /// [DsGridRow.cells] map. When [align] is null it is resolved from [type] via
  /// [effectiveAlign]: numeric, currency and progress columns align to the end,
  /// checkbox and rating columns centre, and everything else aligns to the
  /// start.
  const DsGridColumn({
    required this.key,
    required this.title,
    this.type = DsCellType.text,
    this.width = 160,
    this.minWidth = 64,
    this.frozen = false,
    this.sortable = true,
    this.resizable = true,
    this.align,
    this.icon,
    this.currencySymbol,
  });

  /// The stable identifier used to read this column's value from each row and
  /// to key sort state. Must be unique within the grid.
  final String key;

  /// The header label shown at the top of the column. Rendered upper-cased.
  final String title;

  /// The kind of value this column holds, which selects the cell renderer.
  final DsCellType type;

  /// The initial width of the column, in logical pixels.
  final double width;

  /// The smallest width the column may be resized to, in logical pixels.
  final double minWidth;

  /// Whether the column is pinned to the leading edge and excluded from
  /// horizontal scrolling.
  final bool frozen;

  /// Whether tapping the header sorts by this column.
  final bool sortable;

  /// Whether the column may be resized by dragging its trailing edge.
  final bool resizable;

  /// The horizontal alignment of the cell content. When null it is resolved
  /// from [type]; see [effectiveAlign].
  final DsColumnAlign? align;

  /// An optional glyph shown before the title in the header.
  final IconData? icon;

  /// The currency symbol prefixed to [DsCellType.currency] values. Defaults to
  /// `$` when null.
  final String? currencySymbol;

  /// The alignment actually used, resolving the [type] default when [align] is
  /// null.
  DsColumnAlign get effectiveAlign =>
      align ??
      switch (type) {
        DsCellType.number ||
        DsCellType.currency ||
        DsCellType.progress =>
          DsColumnAlign.end,
        DsCellType.checkbox || DsCellType.rating => DsColumnAlign.center,
        _ => DsColumnAlign.start,
      };
}

/// A single row of data for a [DsDataGrid].
///
/// [cells] maps each [DsGridColumn.key] to that row's value. The runtime type
/// of a value should match the column's [DsGridColumn.type] (see [DsCellType]);
/// missing or mistyped values render as an em dash rather than throwing.
/// Provide [onTap] to make the whole row interactive.
@immutable
class DsGridRow {
  /// Creates a data row.
  ///
  /// [id] must be unique within the grid; it keys selection state.
  const DsGridRow({required this.id, required this.cells, this.onTap});

  /// The stable identifier used to key selection and row rebuilds.
  final String id;

  /// The values for this row, keyed by [DsGridColumn.key].
  final Map<String, Object?> cells;

  /// Called when the row is tapped. A null callback leaves the row
  /// non-interactive (but it can still be selected when the grid is
  /// selectable).
  final VoidCallback? onTap;
}

/// A description of the grid's current sort: the [columnKey] and direction.
@immutable
class DsGridSort {
  /// Creates a sort descriptor.
  const DsGridSort({required this.columnKey, this.ascending = true});

  /// The [DsGridColumn.key] the grid is sorted by.
  final String columnKey;

  /// Whether the sort is ascending (true) or descending (false).
  final bool ascending;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DsGridSort &&
          runtimeType == other.runtimeType &&
          columnKey == other.columnKey &&
          ascending == other.ascending;

  @override
  int get hashCode => Object.hash(columnKey, ascending);
}

/// A flagship, spreadsheet-grade data grid for the Design System.
///
/// [DsDataGrid] renders typed [rows] against a set of [columns] with the polish
/// of a modern database UI: a sticky header, frozen (pinned) leading columns, a
/// horizontally-scrolling body, three-state sortable headers, drag-to-resize
/// columns, row selection with a tri-state select-all, and a rich set of typed
/// cell renderers that reuse the Design System's atoms (badges, avatars, links,
/// checkboxes and icons). Every colour, radius, padding and type style is read
/// from [DsTokens], so the grid re-brands automatically with the active
/// white-label theme.
///
/// ## Responsiveness
///
/// The grid measures the available width with a [LayoutBuilder] (falling back
/// to [MediaQuery] when the incoming constraints are unbounded):
///
/// * **Below [compactBreakpoint]** (e.g. a 320dp phone) each row becomes a
///   bordered "stacked card" listing every column's title and value, with the
///   selection checkbox and row tap preserved. This never overflows on narrow
///   screens.
/// * **At or above [compactBreakpoint]** the full table renders, with frozen
///   columns pinned to the leading edge and the remaining columns scrolling
///   horizontally beneath a header that stays fixed while rows scroll
///   vertically.
///
/// When it is given a bounded height the body scrolls vertically beneath the
/// sticky header; when its height is unbounded it shrink-wraps to its content.
///
/// ## Sorting
///
/// Tapping a [DsGridColumn.sortable] header cycles ascending → descending →
/// none. When [onSort] is provided the widget is *controlled*: it reports the
/// next [DsGridSort] and expects the parent to reorder [rows] and pass the
/// active [sort] back for the header indicator. When [onSort] is null the grid
/// keeps sort state internally and reorders the rows itself.
///
/// ## Selection
///
/// When [selectable] is true a leading checkbox column and a tri-state
/// select-all header appear. Selection is *controlled* when [selectedRowIds] is
/// provided (changes are reported via [onSelectionChanged]); otherwise it is
/// held internally. Selected rows use [DsTokens.offsetBackgroundColor].
///
/// ## Accessibility & screenshots
///
/// Header cells expose a semantics button with a sort key and an announced sort
/// state; selection controls are labelled; interactive rows are wrapped in an
/// [InkWell] and a semantics button. The widget runs no timers or indefinite
/// animations and honours the platform reduce-motion setting, so it renders a
/// stable frame that is safe to capture in golden tests and screenshots.
class DsDataGrid extends StatefulWidget {
  /// Creates a data grid.
  const DsDataGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.selectable = false,
    this.selectedRowIds,
    this.onSelectionChanged,
    this.sort,
    this.onSort,
    this.resizableColumns = true,
    this.rowHeight = 44,
    this.compactBreakpoint = 640,
    this.emptyState,
    this.caption,
  });

  /// The column definitions, in display order. Columns with
  /// [DsGridColumn.frozen] set are pinned to the leading edge.
  final List<DsGridColumn> columns;

  /// The rows of data to display.
  final List<DsGridRow> rows;

  /// Whether a leading selection checkbox column (and select-all header) is
  /// shown.
  final bool selectable;

  /// The set of selected row ids when selection is controlled. When null,
  /// selection is held internally.
  final Set<String>? selectedRowIds;

  /// Called with the new selection whenever it changes.
  final ValueChanged<Set<String>>? onSelectionChanged;

  /// The active sort used to render the header indicator. When [onSort] is
  /// null this is only the initial sort; the grid then owns sort state.
  final DsGridSort? sort;

  /// Called when a sortable header is tapped, cycling ascending → descending →
  /// none (null). When non-null the grid is a controlled sort component and
  /// does not reorder [rows] itself.
  final ValueChanged<DsGridSort?>? onSort;

  /// Whether columns may be resized by dragging their trailing edge. Individual
  /// columns can still opt out via [DsGridColumn.resizable].
  final bool resizableColumns;

  /// The height of each data row, in logical pixels. Also used as the header
  /// height so the frozen and scrolling panes stay aligned.
  final double rowHeight;

  /// The width, in logical pixels, below which the stacked-card layout is used
  /// instead of the table.
  final double compactBreakpoint;

  /// Widget shown in place of the table when [rows] is empty. Defaults to a
  /// centred "No records" message.
  final Widget? emptyState;

  /// An optional caption rendered above the grid and used as its accessible
  /// description.
  final String? caption;

  @override
  State<DsDataGrid> createState() => _DsDataGridState();
}

class _DsDataGridState extends State<DsDataGrid> {
  static const double _selectionColumnWidth = 48;
  static const double _seamWidth = 6;
  static const double _resizeHandleWidth = 6;
  static const double _checkboxSize = 18;

  final ScrollController _verticalController = ScrollController();
  final ScrollController _headerHController = ScrollController();
  final ScrollController _bodyHController = ScrollController();

  /// Live column widths, keyed by column key. Seeded from the column
  /// definitions and mutated by drag-to-resize.
  final Map<String, double> _widths = <String, double>{};

  /// Internal sort, used only when [DsDataGrid.onSort] is null.
  DsGridSort? _internalSort;

  /// Internal selection, used only when [DsDataGrid.selectedRowIds] is null.
  Set<String> _internalSelection = <String>{};

  /// Horizontal padding inside header and data cells. Resolved from the window
  /// size class each build so expanded windows breathe a little more.
  double _cellPaddingX = DsSpacing.md;

  @override
  void initState() {
    super.initState();
    _internalSort = widget.sort;
    _syncWidths();
    // The header follows the body's horizontal offset; it is not user-driven.
    _bodyHController.addListener(_syncHeaderOffset);
  }

  @override
  void didUpdateWidget(DsDataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWidths();
  }

  @override
  void dispose() {
    _bodyHController.removeListener(_syncHeaderOffset);
    _verticalController.dispose();
    _headerHController.dispose();
    _bodyHController.dispose();
    super.dispose();
  }

  // --- State plumbing -------------------------------------------------------

  void _syncWidths() {
    final keys = widget.columns.map((c) => c.key).toSet();
    _widths.removeWhere((key, _) => !keys.contains(key));
    for (final column in widget.columns) {
      _widths.putIfAbsent(
        column.key,
        () => math.max(column.width, column.minWidth),
      );
    }
  }

  void _syncHeaderOffset() {
    if (!_headerHController.hasClients || !_bodyHController.hasClients) return;
    final position = _headerHController.position;
    final target = _bodyHController.offset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((_headerHController.offset - target).abs() > 0.5) {
      _headerHController.jumpTo(target);
    }
  }

  double _columnWidth(DsGridColumn column) =>
      _widths[column.key] ?? math.max(column.width, column.minWidth);

  void _resizeColumn(DsGridColumn column, double delta) {
    setState(() {
      final current = _columnWidth(column);
      _widths[column.key] = math.max(column.minWidth, current + delta);
    });
  }

  List<DsGridColumn> get _pinnedColumns =>
      widget.columns.where((c) => c.frozen).toList(growable: false);

  List<DsGridColumn> get _scrollableColumns =>
      widget.columns.where((c) => !c.frozen).toList(growable: false);

  DsGridSort? get _activeSort =>
      widget.onSort != null ? widget.sort : _internalSort;

  double get _headerHeight => widget.rowHeight;

  DsGridColumn? _columnForKey(String key) {
    for (final column in widget.columns) {
      if (column.key == key) return column;
    }
    return null;
  }

  /// The rows in display order — reordered locally when the grid owns its sort.
  List<DsGridRow> get _displayRows {
    final sort = _activeSort;
    if (widget.onSort != null || sort == null) return widget.rows;
    final column = _columnForKey(sort.columnKey);
    if (column == null) return widget.rows;
    final ordered = List<DsGridRow>.of(widget.rows);
    ordered.sort((a, b) {
      final result = _compareValues(
        column,
        a.cells[sort.columnKey],
        b.cells[sort.columnKey],
      );
      return sort.ascending ? result : -result;
    });
    return ordered;
  }

  void _onHeaderTap(DsGridColumn column) {
    if (!column.sortable) return;
    final current = _activeSort;
    final DsGridSort? next;
    if (current == null || current.columnKey != column.key) {
      next = DsGridSort(columnKey: column.key);
    } else if (current.ascending) {
      next = DsGridSort(columnKey: column.key, ascending: false);
    } else {
      next = null;
    }
    if (widget.onSort != null) {
      widget.onSort!(next);
    } else {
      setState(() => _internalSort = next);
    }
  }

  Set<String> get _selection => widget.selectedRowIds ?? _internalSelection;

  bool _isSelected(String id) => _selection.contains(id);

  void _setSelection(Set<String> next) {
    widget.onSelectionChanged?.call(next);
    if (widget.selectedRowIds == null) {
      setState(() => _internalSelection = next);
    }
  }

  void _toggleRow(String id, bool selected) {
    final next = Set<String>.of(_selection);
    if (selected) {
      next.add(id);
    } else {
      next.remove(id);
    }
    _setSelection(next);
  }

  void _toggleSelectAll(List<DsGridRow> rows) {
    final ids = rows.map((r) => r.id).toSet();
    final allSelected = ids.isNotEmpty && ids.every(_selection.contains);
    final next = Set<String>.of(_selection);
    if (allSelected) {
      next.removeAll(ids);
    } else {
      next.addAll(ids);
    }
    _setSelection(next);
  }

  // --- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final double? viewportHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : null;

        // Give expanded (desktop-class) windows a touch more horizontal room
        // inside cells than compact/medium windows.
        _cellPaddingX =
            DsBreakpoints.windowSizeFor(maxWidth) >= DsWindowSize.expanded
                ? DsSpacing.lg
                : DsSpacing.md;

        final caption = widget.caption;
        final captionReserve = caption == null
            ? 0.0
            : (tokens.bodySm.fontSize * (tokens.bodySm.height ?? 1.4)) +
                DsSpacing.sm;
        final double? bodyBudget =
            viewportHeight == null ? null : viewportHeight - captionReserve;

        final Widget core;
        if (widget.rows.isEmpty) {
          core = _buildEmpty(tokens, bodyBudget);
        } else if (maxWidth < widget.compactBreakpoint) {
          core = _buildCompact(tokens, bodyBudget);
        } else {
          core = _buildTable(tokens, maxWidth, bodyBudget);
        }

        if (caption == null) return core;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: DsSpacing.sm),
              child: Semantics(
                container: true,
                label: caption,
                child: Text(
                  caption,
                  style: tokens.bodySm.toTextStyle(
                    color: tokens.colorSecondaryText,
                  ),
                ),
              ),
            ),
            core,
          ],
        );
      },
    );
  }

  Widget _buildEmpty(DsTokens tokens, double? height) {
    final message = widget.emptyState ??
        Text(
          'No records',
          style: tokens.bodyMd.toTextStyle(color: tokens.colorSecondaryText),
        );
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(DsSpacing.xl),
        child: message,
      ),
    );
    final framed = DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.colorBackground,
        border: Border.all(color: tokens.colorBorder),
        borderRadius: BorderRadius.circular(tokens.formBorderRadius),
      ),
      child: content,
    );
    if (height == null) return framed;
    return SizedBox(height: math.max(0, height), child: framed);
  }

  // --- Compact (stacked cards) ---------------------------------------------

  Widget _buildCompact(DsTokens tokens, double? height) {
    final rows = _displayRows;
    final list = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: DsSpacing.sm),
          _buildCard(tokens, rows[i]),
        ],
      ],
    );
    if (height == null) return list;
    return SizedBox(
      height: math.max(0, height),
      child: Scrollbar(
        controller: _verticalController,
        child: SingleChildScrollView(
          controller: _verticalController,
          child: list,
        ),
      ),
    );
  }

  Widget _buildCard(DsTokens tokens, DsGridRow row) {
    final selected = _isSelected(row.id);
    final radius = BorderRadius.circular(tokens.formBorderRadius);
    final fields = <Widget>[
      if (widget.selectable)
        Padding(
          padding: const EdgeInsets.only(bottom: DsSpacing.xs),
          child: Align(
            alignment: Alignment.centerLeft,
            child: DsCheckbox(
              value: selected,
              onChanged: (value) => _toggleRow(row.id, value),
            ),
          ),
        ),
      for (final column in widget.columns)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DsSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  column.title,
                  style: tokens.bodySm.toTextStyle(
                    color: tokens.colorSecondaryText,
                  ),
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _cellContent(
                    tokens,
                    column,
                    row.cells[column.key],
                    dense: false,
                    align: DsColumnAlign.end,
                  ),
                ),
              ),
            ],
          ),
        ),
    ];

    final container = Container(
      decoration: BoxDecoration(
        color: selected ? tokens.offsetBackgroundColor : null,
        border: Border.all(color: tokens.colorBorder),
        borderRadius: radius,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.md,
        vertical: DsSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: fields,
      ),
    );

    return Semantics(
      button: row.onTap != null,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: row.onTap == null
            ? container
            : InkWell(onTap: row.onTap, child: container),
      ),
    );
  }

  // --- Table ----------------------------------------------------------------

  Widget _buildTable(DsTokens tokens, double maxWidth, double? height) {
    final rows = _displayRows;
    final pinnedColumns = _pinnedColumns;
    final scrollableColumns = _scrollableColumns;

    final double pinnedWidth = (widget.selectable ? _selectionColumnWidth : 0) +
        pinnedColumns.fold<double>(0, (sum, c) => sum + _columnWidth(c));
    final hasPinned = pinnedWidth > 0;
    final scrollContentWidth =
        scrollableColumns.fold<double>(0, (sum, c) => sum + _columnWidth(c));

    final contentHeight = rows.length * widget.rowHeight;
    final headerHeight = _headerHeight;
    final availableBody = height != null
        ? math.max(0.0, height - headerHeight - 1)
        : contentHeight;
    final bodyHeight = math.min(contentHeight, availableBody);

    final header = _buildHeader(
      tokens,
      pinnedColumns,
      scrollableColumns,
      pinnedWidth,
      hasPinned,
      scrollContentWidth,
    );

    final body = _buildBody(
      tokens,
      rows,
      pinnedColumns,
      scrollableColumns,
      pinnedWidth,
      hasPinned,
      scrollContentWidth,
      contentHeight,
      bodyHeight,
    );

    return SizedBox(
      width: maxWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.colorBackground,
          border: Border.all(color: tokens.colorBorder),
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [header, body],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    DsTokens tokens,
    List<DsGridColumn> pinnedColumns,
    List<DsGridColumn> scrollableColumns,
    double pinnedWidth,
    bool hasPinned,
    double scrollContentWidth,
  ) {
    final rows = _displayRows;
    final ids = rows.map((r) => r.id).toSet();
    final allSelected = ids.isNotEmpty && ids.every(_selection.contains);
    final anySelected = ids.any(_selection.contains);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.colorBackground,
        border: Border(bottom: BorderSide(color: tokens.colorBorder)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          height: _headerHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasPinned)
                SizedBox(
                  width: pinnedWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.selectable)
                        _selectAllCell(tokens, rows, allSelected, anySelected),
                      for (final column in pinnedColumns)
                        _headerCell(tokens, column),
                    ],
                  ),
                ),
              if (hasPinned) _seam(tokens),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width =
                        math.max(scrollContentWidth, constraints.maxWidth);
                    return SingleChildScrollView(
                      controller: _headerHController,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        width: width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final column in scrollableColumns)
                              _headerCell(tokens, column),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    DsTokens tokens,
    List<DsGridRow> rows,
    List<DsGridColumn> pinnedColumns,
    List<DsGridColumn> scrollableColumns,
    double pinnedWidth,
    bool hasPinned,
    double scrollContentWidth,
    double contentHeight,
    double bodyHeight,
  ) {
    final bodyRow = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasPinned)
          SizedBox(
            width: pinnedWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final row in rows)
                  _rowSegment(
                    tokens,
                    row,
                    Row(
                      children: [
                        if (widget.selectable) _selectionCell(tokens, row),
                        for (final column in pinnedColumns)
                          _dataCell(tokens, column, row),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (hasPinned) _seam(tokens),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width =
                  math.max(scrollContentWidth, constraints.maxWidth);
              return SingleChildScrollView(
                controller: _bodyHController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final row in rows)
                        _rowSegment(
                          tokens,
                          row,
                          Row(
                            children: [
                              for (final column in scrollableColumns)
                                _dataCell(tokens, column, row),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    return SizedBox(
      height: bodyHeight,
      child: Scrollbar(
        controller: _verticalController,
        child: SingleChildScrollView(
          controller: _verticalController,
          child: SizedBox(height: contentHeight, child: bodyRow),
        ),
      ),
    );
  }

  Widget _seam(DsTokens tokens) => SizedBox(
        width: _seamWidth,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: tokens.colorBorder)),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                tokens.colorText.withValues(alpha: 0.10),
                tokens.colorText.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      );

  // --- Header cells ---------------------------------------------------------

  Widget _headerCell(DsTokens tokens, DsGridColumn column) {
    final align = column.effectiveAlign;
    final width = _columnWidth(column);
    final active = _activeSort?.columnKey == column.key ? _activeSort : null;
    final index = widget.columns.indexOf(column);

    final row = Row(
      mainAxisAlignment: _mainAxisOf(align),
      children: [
        if (column.icon != null) ...[
          DsIcon(
            icon: column.icon!,
            size: DsIconSize.xs,
            color: tokens.colorSecondaryText,
          ),
          const SizedBox(width: DsSpacing.xs),
        ],
        Flexible(
          child: Text(
            DsTextTransform.uppercase.apply(column.title),
            style: tokens.headingXs.toTextStyle(
              color: tokens.colorSecondaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: _textAlignOf(align),
          ),
        ),
        if (active != null) ...[
          const SizedBox(width: DsSpacing.xs),
          DsIcon(
            icon: active.ascending ? Icons.arrow_upward : Icons.arrow_downward,
            size: DsIconSize.xs,
            color: tokens.colorSecondaryText,
          ),
        ],
      ],
    );

    final padded = Padding(
      padding: EdgeInsets.symmetric(horizontal: _cellPaddingX),
      child: row,
    );

    final sortState = active == null
        ? 'not sorted'
        : active.ascending
            ? 'sorted ascending'
            : 'sorted descending';

    final Widget content = column.sortable
        ? Semantics(
            button: true,
            sortKey: OrdinalSortKey(index.toDouble()),
            label: '${column.title}, $sortState',
            child: InkWell(onTap: () => _onHeaderTap(column), child: padded),
          )
        : Semantics(
            header: true,
            sortKey: OrdinalSortKey(index.toDouble()),
            label: column.title,
            child: padded,
          );

    final resizable = widget.resizableColumns && column.resizable;

    return SizedBox(
      width: width,
      height: _headerHeight,
      child: Stack(
        children: [
          Positioned.fill(child: content),
          if (resizable)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: _ResizeHandle(
                onDelta: (delta) => _resizeColumn(column, delta),
              ),
            ),
        ],
      ),
    );
  }

  Widget _selectAllCell(
    DsTokens tokens,
    List<DsGridRow> rows,
    bool allSelected,
    bool anySelected,
  ) {
    final bool? value = allSelected ? true : (anySelected ? null : false);
    return InkWell(
      onTap: () => _toggleSelectAll(rows),
      child: Semantics(
        container: true,
        checked: allSelected,
        mixed: anySelected && !allSelected,
        label: 'Select all rows',
        excludeSemantics: true,
        child: SizedBox(
          width: _selectionColumnWidth,
          height: _headerHeight,
          child: Center(child: _GridCheck(value: value, size: _checkboxSize)),
        ),
      ),
    );
  }

  // --- Body cells -----------------------------------------------------------

  Widget _rowSegment(DsTokens tokens, DsGridRow row, Widget child) {
    final selected = _isSelected(row.id);
    final content = Container(
      height: widget.rowHeight,
      decoration: BoxDecoration(
        color: selected ? tokens.offsetBackgroundColor : null,
        border: Border(bottom: BorderSide(color: tokens.colorBorder)),
      ),
      child: child,
    );
    final inner = row.onTap != null
        ? Semantics(
            button: true,
            child: InkWell(onTap: row.onTap, child: content),
          )
        : content;
    return Material(type: MaterialType.transparency, child: inner);
  }

  Widget _selectionCell(DsTokens tokens, DsGridRow row) {
    final selected = _isSelected(row.id);
    return InkWell(
      onTap: () => _toggleRow(row.id, !selected),
      child: Semantics(
        container: true,
        checked: selected,
        label: 'Select row',
        excludeSemantics: true,
        child: SizedBox(
          width: _selectionColumnWidth,
          height: widget.rowHeight,
          child: Center(
            child: _GridCheck(value: selected, size: _checkboxSize),
          ),
        ),
      ),
    );
  }

  Widget _dataCell(DsTokens tokens, DsGridColumn column, DsGridRow row) {
    final align = column.effectiveAlign;
    final content = _cellContent(
      tokens,
      column,
      row.cells[column.key],
      dense: true,
      align: align,
    );
    return SizedBox(
      width: _columnWidth(column),
      height: widget.rowHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _cellPaddingX),
        child: Align(alignment: _alignmentOf(align), child: content),
      ),
    );
  }

  // --- Cell renderers -------------------------------------------------------

  Widget _cellContent(
    DsTokens tokens,
    DsGridColumn column,
    Object? value, {
    required bool dense,
    required DsColumnAlign align,
  }) {
    final emDash = Text(
      '—',
      style: (dense ? tokens.bodySm : tokens.bodyMd)
          .toTextStyle(color: tokens.colorSecondaryText),
      textAlign: _textAlignOf(align),
    );

    Widget text(String value) => Text(
          value,
          style: (dense ? tokens.bodySm : tokens.bodyMd)
              .toTextStyle(color: tokens.colorText),
          maxLines: dense ? 1 : null,
          overflow: dense ? TextOverflow.ellipsis : TextOverflow.clip,
          textAlign: _textAlignOf(align),
        );

    switch (column.type) {
      case DsCellType.text:
        final string = _asString(value);
        return string == null ? emDash : text(string);
      case DsCellType.number:
        final number = _asNum(value);
        return number == null ? emDash : text(_formatNumber(number));
      case DsCellType.currency:
        final number = _asNum(value);
        if (number == null) return emDash;
        final symbol = column.currencySymbol ?? r'$';
        return text('$symbol${_formatNumber(number, decimals: 2)}');
      case DsCellType.date:
        final date = _asDate(value);
        return date == null ? emDash : text(_formatDate(date));
      case DsCellType.checkbox:
        final boolean = _asBool(value);
        return boolean == null
            ? emDash
            : _GridCheck(value: boolean, size: _checkboxSize);
      case DsCellType.singleSelect:
      case DsCellType.status:
        final string = _asString(value);
        return string == null || string.isEmpty
            ? emDash
            : DsBadge(label: string, variant: _variantForStatus(string));
      case DsCellType.multiSelect:
        final list = _asStringList(value);
        if (list == null || list.isEmpty) return emDash;
        if (!dense) {
          return Wrap(
            spacing: DsSpacing.xs,
            runSpacing: DsSpacing.xs,
            alignment:
                align == DsColumnAlign.end ? WrapAlignment.end : WrapAlignment.start,
            children: [for (final item in list) DsBadge(label: item)],
          );
        }
        return _guarded(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < list.length; i++) ...[
                if (i > 0) const SizedBox(width: DsSpacing.xs),
                DsBadge(label: list[i]),
              ],
            ],
          ),
        );
      case DsCellType.link:
        final string = _asString(value);
        return string == null || string.isEmpty
            ? emDash
            : DsLink(label: string, onPressed: _noop);
      case DsCellType.user:
        final string = _asString(value);
        return string == null || string.isEmpty
            ? emDash
            : _userCell(tokens, string, dense: dense);
      case DsCellType.rating:
        final number = _asNum(value);
        if (number == null) return emDash;
        final stars = _ratingRow(tokens, number);
        return dense ? _guarded(stars) : stars;
      case DsCellType.progress:
        final number = _asNum(value);
        return number == null ? emDash : _progressBar(tokens, number);
    }
  }

  Widget _userCell(DsTokens tokens, String name, {required bool dense}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DsAvatar(name: name, size: 24),
        const SizedBox(width: DsSpacing.sm),
        Flexible(
          child: Text(
            name,
            style: (dense ? tokens.bodySm : tokens.bodyMd)
                .toTextStyle(color: tokens.colorText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _ratingRow(DsTokens tokens, num value) {
    final filled = value.clamp(0, 5).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: DsIcon(
              icon: i < filled ? Icons.star : Icons.star_border,
              size: DsIconSize.sm,
              color: i < filled ? tokens.colorPrimary : tokens.colorBorder,
            ),
          ),
      ],
    );
  }

  Widget _progressBar(DsTokens tokens, num value) {
    final fraction = value.toDouble().clamp(0.0, 1.0);
    final percent = (fraction * 100).round();
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Positioned.fill(child: ColoredBox(color: tokens.colorBorder)),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: ColoredBox(
                      color: tokens.buttonPrimaryColorBackground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: DsSpacing.sm),
        Text(
          '$percent%',
          style: tokens.labelSm.toTextStyle(color: tokens.colorSecondaryText),
        ),
      ],
    );
  }

  /// Wraps [child] so it can exceed the cell width without a layout overflow,
  /// clipping any surplus. Used for the intrinsically-sized rating and
  /// multi-select cells in the dense table.
  Widget _guarded(Widget child) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: child,
      );

  // --- Value coercion & comparison -----------------------------------------

  int _compareValues(DsGridColumn column, Object? a, Object? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    switch (column.type) {
      case DsCellType.number:
      case DsCellType.currency:
      case DsCellType.rating:
      case DsCellType.progress:
        final x = _asNum(a);
        final y = _asNum(b);
        if (x == null && y == null) return 0;
        if (x == null) return 1;
        if (y == null) return -1;
        return x.compareTo(y);
      case DsCellType.date:
        final x = _asDate(a);
        final y = _asDate(b);
        if (x == null && y == null) return 0;
        if (x == null) return 1;
        if (y == null) return -1;
        return x.compareTo(y);
      case DsCellType.checkbox:
        final x = (_asBool(a) ?? false) ? 1 : 0;
        final y = (_asBool(b) ?? false) ? 1 : 0;
        return x.compareTo(y);
      case DsCellType.multiSelect:
        final x = _asStringList(a)?.join(', ') ?? '';
        final y = _asStringList(b)?.join(', ') ?? '';
        return x.toLowerCase().compareTo(y.toLowerCase());
      case DsCellType.text:
      case DsCellType.singleSelect:
      case DsCellType.status:
      case DsCellType.link:
      case DsCellType.user:
        final x = a is String ? a : a.toString();
        final y = b is String ? b : b.toString();
        return x.toLowerCase().compareTo(y.toLowerCase());
    }
  }
}

// --- Alignment helpers ------------------------------------------------------

Alignment _alignmentOf(DsColumnAlign align) => switch (align) {
      DsColumnAlign.start => Alignment.centerLeft,
      DsColumnAlign.center => Alignment.center,
      DsColumnAlign.end => Alignment.centerRight,
    };

MainAxisAlignment _mainAxisOf(DsColumnAlign align) => switch (align) {
      DsColumnAlign.start => MainAxisAlignment.start,
      DsColumnAlign.center => MainAxisAlignment.center,
      DsColumnAlign.end => MainAxisAlignment.end,
    };

TextAlign _textAlignOf(DsColumnAlign align) => switch (align) {
      DsColumnAlign.start => TextAlign.left,
      DsColumnAlign.center => TextAlign.center,
      DsColumnAlign.end => TextAlign.right,
    };

// --- Value coercion helpers -------------------------------------------------

String? _asString(Object? value) => value is String ? value : null;

num? _asNum(Object? value) => value is num ? value : null;

bool? _asBool(Object? value) => value is bool ? value : null;

DateTime? _asDate(Object? value) => value is DateTime ? value : null;

List<String>? _asStringList(Object? value) => value is List
    ? value.map((e) => e?.toString() ?? '').toList(growable: false)
    : null;

/// Maps a common status label to a badge variant. Unknown labels are neutral.
DsBadgeVariant _variantForStatus(String value) {
  final normalized = value.trim().toLowerCase();
  const success = {
    'active',
    'success',
    'succeeded',
    'paid',
    'complete',
    'completed',
    'approved',
    'done',
    'live',
    'enabled',
    'on',
    'available',
  };
  const warning = {
    'pending',
    'warning',
    'in progress',
    'processing',
    'review',
    'in review',
    'waiting',
    'draft',
    'scheduled',
    'paused',
  };
  const danger = {
    'failed',
    'error',
    'danger',
    'declined',
    'rejected',
    'overdue',
    'cancelled',
    'canceled',
    'disabled',
    'off',
    'inactive',
    'blocked',
    'expired',
  };
  if (success.contains(normalized)) return DsBadgeVariant.success;
  if (warning.contains(normalized)) return DsBadgeVariant.warning;
  if (danger.contains(normalized)) return DsBadgeVariant.danger;
  return DsBadgeVariant.neutral;
}

/// Formats [value] with thousands separators and, when [decimals] is given, a
/// fixed number of fractional digits. Implemented without `intl`.
String _formatNumber(num value, {int? decimals}) {
  final negative = value < 0;
  final absolute = value.abs();

  String integerPart;
  String fractionPart;
  if (decimals != null) {
    final fixed = absolute.toStringAsFixed(decimals);
    final dot = fixed.indexOf('.');
    integerPart = dot == -1 ? fixed : fixed.substring(0, dot);
    fractionPart = dot == -1 ? '' : fixed.substring(dot);
  } else if (absolute == absolute.roundToDouble()) {
    integerPart = absolute.toStringAsFixed(0);
    fractionPart = '';
  } else {
    final string = absolute.toString();
    final dot = string.indexOf('.');
    integerPart = dot == -1 ? string : string.substring(0, dot);
    fractionPart = dot == -1 ? '' : string.substring(dot);
  }

  final grouped = _groupThousands(integerPart);
  return '${negative ? '-' : ''}$grouped$fractionPart';
}

String _groupThousands(String digits) {
  final buffer = StringBuffer();
  final length = digits.length;
  for (var i = 0; i < length; i++) {
    if (i > 0 && (length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// A no-op used to render [DsLink] cells as active links; the real action is
/// wired through [DsGridRow.onTap].
void _noop() {}

/// A compact, read-only checkbox glyph used inside dense grid cells and the
/// select-all / row-select controls.
///
/// [value] is `true` (checked), `false` (empty) or `null` (indeterminate — a
/// dash). Interactivity and tap targets are the responsibility of the enclosing
/// cell, which wraps this glyph in an [InkWell] sized to the cell.
class _GridCheck extends StatelessWidget {
  const _GridCheck({required this.value, required this.size});

  final bool? value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final checked = value == true;
    final indeterminate = value == null;
    final filled = checked || indeterminate;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? tokens.formAccentColor : tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: filled ? tokens.formAccentColor : tokens.colorBorder,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: DsIconSize.xs, color: Colors.white)
          : indeterminate
              ? const Icon(
                  Icons.remove,
                  size: DsIconSize.xs,
                  color: Colors.white,
                )
              : null,
    );
  }
}

/// The drag affordance on a column header's trailing edge. Reports horizontal
/// drag deltas so the grid can resize the column.
class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({required this.onDelta});

  final ValueChanged<double> onDelta;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) => onDelta(details.delta.dx),
        child: const SizedBox(
          width: _DsDataGridState._resizeHandleWidth,
          height: double.infinity,
        ),
      ),
    );
  }
}
