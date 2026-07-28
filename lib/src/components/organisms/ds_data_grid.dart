import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals, mapEquals;
import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_elevation.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import '../atoms/ds_avatar.dart';
import '../atoms/ds_badge.dart';
import '../atoms/ds_checkbox.dart';
import '../atoms/ds_icon.dart';
import '../atoms/ds_link.dart';
import '../molecules/ds_menu.dart';

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

/// How tightly a [DsDataGrid] packs its rows.
///
/// Density is a systematic choice rather than three hand-picked numbers, so a
/// density switcher (a `DsSegmentedControl` over these values) reads the same
/// in every table:
///
/// * [comfortable] — for tables read at a glance or on touch.
/// * [cosy] — the default, and what a table with badges and avatars needs to
///   breathe.
/// * [compact] — for scanning many rows of numbers on a pointer-first desktop.
///
/// The enum is the vocabulary; the heights themselves are tokens
/// ([DsTokens.tableRowHeightComfortable] and its pair), so a brand that reads
/// denser or airier than the base restyles every table at once through its
/// skin. Resolve one with [rowHeightFrom]. Pass [DsDataGrid.rowHeight] only for
/// a table whose cells genuinely need a size no density describes.
///
/// The default heights sit below the 48dp touch-target guidance that applies
/// to standalone controls: a grid row is a scanning surface, not a button, and
/// below [DsDataGrid.compactBreakpoint] the grid switches to a stacked-card
/// layout whose controls are full size.
enum DsGridDensity {
  /// Loosely packed rows.
  comfortable,

  /// The default row packing.
  cosy,

  /// Tightly packed rows.
  compact;

  /// The row height this density stands for, read from [tokens] so a skin can
  /// restyle it.
  double rowHeightFrom(DsTokens tokens) => switch (this) {
        DsGridDensity.comfortable => tokens.tableRowHeightComfortable,
        DsGridDensity.cosy => tokens.tableRowHeightCosy,
        DsGridDensity.compact => tokens.tableRowHeightCompact,
      };
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

/// How a column is summarised within a group when [DsDataGrid.groupBy] is set.
///
/// The result is rendered in each group's header band, aligned under the
/// column it summarises (see [DsDataGrid.aggregations]):
///
/// * [none] — no summary is shown (the default for an unlisted column).
/// * [count] — the number of rows in the group with a non-null value.
/// * [sum] — the total of the group's numeric values.
/// * [average] — the mean of the group's numeric values.
/// * [min] — the smallest of the group's numeric values.
/// * [max] — the largest of the group's numeric values.
///
/// The four numeric aggregations ignore non-numeric and null values and render
/// nothing when a group has no numeric value; [count] applies to any column.
enum DsAggregation {
  /// No summary is shown for the column.
  none,

  /// The count of non-null values in the group.
  count,

  /// The sum of the group's numeric values.
  sum,

  /// The mean of the group's numeric values.
  average,

  /// The smallest of the group's numeric values.
  min,

  /// The largest of the group's numeric values.
  max,
}

/// A single choice offered by a [DsGridColumn] for the select and status cell
/// types.
///
/// An option binds a stored [value] (the key written back through
/// [DsDataGrid.onCellChanged]) to an optional display [label]. Provide a
/// [variant] to tint the option's badge with one of the shared semantic badge
/// styles, or a [color] to paint an explicit swatch that overrides the variant.
/// Options are used both to render a cell's label and colour and to populate
/// the menu shown while editing a [DsCellType.singleSelect],
/// [DsCellType.multiSelect] or [DsCellType.status] cell.
@immutable
class DsGridOption {
  /// Creates a grid option.
  ///
  /// Only [value] is required. When [label] is null the [value] is shown
  /// verbatim (see [effectiveLabel]).
  const DsGridOption({
    required this.value,
    this.label,
    this.variant,
    this.color,
  });

  /// The stored value / key written back when this option is chosen.
  final String value;

  /// The human-readable label shown for this option. Falls back to [value].
  final String? label;

  /// An optional semantic badge variant for select and status chips.
  final DsBadgeVariant? variant;

  /// An optional explicit swatch colour. When set it overrides [variant].
  final Color? color;

  /// The label actually rendered, resolving to [value] when [label] is null.
  String get effectiveLabel => label ?? value;
}

/// Builds a custom cell for a [DsGridColumn], from the raw [value] stored in
/// the row's [DsGridRow.cells] map and the [row] it came from.
///
/// The [row] is passed so a custom cell can be interactive and still report
/// *which* record it acted on — a switch that toggles a campaign, say, needs
/// [DsGridRow.id] to send back. Anything returned here is laid out inside the
/// cell's padding and receives pointer events normally.
typedef DsGridCellBuilder = Widget Function(
  BuildContext context,
  Object? value,
  DsGridRow row,
);

/// The definition of a single column in a [DsDataGrid].
///
/// A column binds a stable [key] (used to look up each row's value in
/// [DsGridRow.cells]) to a human-readable [title] and a [type] that decides how
/// the cell is rendered and sorted. Columns describe their own [width],
/// [minWidth], whether they are [frozen] (pinned to the leading edge), whether
/// they are [sortable] and [resizable], their [align]ment, an optional header
/// [icon] and, for [DsCellType.currency], a [currencySymbol]. A column can also
/// opt into inline [editable] editing and, for the select and status types,
/// declare its choice set through [options].
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
    this.editable = false,
    this.options,
    this.cellBuilder,
    this.statusTooltip,
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

  /// Whether cells in this column can be edited inline. Editing is only offered
  /// when both this flag and [DsDataGrid.editable] are true; otherwise the
  /// column renders read-only exactly as before.
  final bool editable;

  /// The choice set for [DsCellType.singleSelect], [DsCellType.multiSelect] and
  /// [DsCellType.status] columns. The options render each cell's label and
  /// colour and populate the menu shown while editing. Optional (and unused)
  /// for other cell types.
  final List<DsGridOption>? options;

  /// An optional custom renderer for this column's cells.
  ///
  /// When set it replaces the [type]-based cell renderer, receiving the raw
  /// cell value and the row it belongs to. Sorting, filtering and grouping
  /// still operate on the underlying value via [type], so a column can present
  /// richly — an expiry date with a relative hint, a switch that toggles the
  /// record — while remaining sortable.
  ///
  /// A custom cell may be interactive. It is exempt from inline [editable]
  /// editing (the builder owns the whole cell, including how it changes), so
  /// set one or the other, not both.
  final DsGridCellBuilder? cellBuilder;

  /// The tooltip shown on a [DsCellType.status] cell in this column, resolved
  /// per row: the reason behind the state ("Missing licence expiry" on a
  /// Needs review badge). Return null to leave a row's badge untipped. The
  /// text is also announced to assistive technology, so the reason is never
  /// pointer-only.
  final String? Function(DsGridRow row)? statusTooltip;

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

/// One action offered on a [DsDataGrid] row's overflow menu.
///
/// Row actions are the secondary things a row can do: the primary action
/// stays the row tap, and everything else lives behind the trailing overflow
/// menu, so a dense table is not a wall of icon buttons.
@immutable
class DsRowAction {
  /// Creates a row action.
  const DsRowAction({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.destructive = false,
  });

  /// The action's name, shown in the menu and announced.
  final String label;

  /// The action's glyph, from the `DsIcons` vocabulary.
  final IconData icon;

  /// Called after the menu closes when the action is chosen.
  final VoidCallback? onSelected;

  /// Whether the action is irreversible, rendering it in the danger colour.
  final bool destructive;
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

/// A table-view configuration for a [DsDataGrid]: which columns show, in what
/// order, under what display labels, with what sort and which column-bottom
/// calculations.
///
/// A view is plain data the caller owns. Pass one to [DsDataGrid.view] and the
/// grid renders it; also pass [DsDataGrid.onViewChanged] and the grid grows
/// its management surface (a per-column header menu, drag-to-reorder headers,
/// an add-column affordance and an editable calculations footer), reporting
/// every change back as a new value. Persisting, naming and switching between
/// saved views is the application's concern; a view switcher composes from
/// `DsTabs` or `DsMenu`.
@immutable
class DsGridView {
  /// Creates a table-view configuration.
  const DsGridView({
    this.visibleColumns,
    this.columnLabels = const <String, String>{},
    this.sort,
    this.sorts = const <DsGridSort>[],
    this.calculations = const <String, DsAggregation>{},
  });

  /// The [DsGridColumn.key]s to show, in display order. Null shows every
  /// column in its definition order.
  final List<String>? visibleColumns;

  /// Display-only header relabels, keyed by column key. A column absent from
  /// the map keeps its [DsGridColumn.title]; relabelling never renames the
  /// underlying column.
  final Map<String, String> columnLabels;

  /// The view's single sort, a convenience for the common case. Ignored while
  /// [sorts] is non-empty; the grid keeps it in step with the primary rule
  /// when it emits a changed view.
  final DsGridSort? sort;

  /// The view's precedence-ordered sorts: the first rule is the primary sort
  /// and each later rule breaks the ties of the ones before it. When
  /// non-empty this list is authoritative and [sort] is ignored. Edit it with
  /// `DsSortBuilder` or `DsSortPill`; header taps rewrite the primary rule
  /// and keep the tie-breaks.
  final List<DsGridSort> sorts;

  /// The column-bottom calculations shown in the footer band, keyed by column
  /// key. An empty map renders no values (the managed grid still offers the
  /// add-calculation affordance).
  final Map<String, DsAggregation> calculations;

  static const Object _unset = Object();

  /// Returns a copy with the given fields replaced. Pass `sort: null`
  /// explicitly to clear the sort.
  /// The effective precedence-ordered sorts: [sorts] when non-empty,
  /// otherwise the single [sort] as a one-rule list.
  List<DsGridSort> get effectiveSorts =>
      sorts.isNotEmpty ? sorts : [?sort];

  DsGridView copyWith({
    Object? visibleColumns = _unset,
    Map<String, String>? columnLabels,
    Object? sort = _unset,
    List<DsGridSort>? sorts,
    Map<String, DsAggregation>? calculations,
  }) {
    return DsGridView(
      visibleColumns: identical(visibleColumns, _unset)
          ? this.visibleColumns
          : visibleColumns as List<String>?,
      columnLabels: columnLabels ?? this.columnLabels,
      sort: identical(sort, _unset) ? this.sort : sort as DsGridSort?,
      sorts: sorts ?? this.sorts,
      calculations: calculations ?? this.calculations,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DsGridView &&
          runtimeType == other.runtimeType &&
          listEquals(visibleColumns, other.visibleColumns) &&
          mapEquals(columnLabels, other.columnLabels) &&
          sort == other.sort &&
          listEquals(sorts, other.sorts) &&
          mapEquals(calculations, other.calculations);

  @override
  int get hashCode => Object.hash(
        visibleColumns == null ? null : Object.hashAll(visibleColumns!),
        Object.hashAll(
            columnLabels.entries.map((e) => Object.hash(e.key, e.value))),
        sort,
        Object.hashAll(sorts),
        Object.hashAll(
            calculations.entries.map((e) => Object.hash(e.key, e.value))),
      );
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
/// ## Editing
///
/// When [editable] is true, cells in columns that opt in via
/// [DsGridColumn.editable] become editable inline in both the wide table and
/// the stacked-card layout. Editing is *controlled*: committing an edit reports
/// the new value through [onCellChanged] and expects the parent to update
/// [rows]. Only one cell edits at a time and Escape always cancels. Each cell
/// type edits in the way that suits it — a `text`, `number` or `currency` cell
/// opens an inline field; a `date` cell opens the Material date picker; a
/// `checkbox` toggles and a `rating` sets its stars in place; a `singleSelect`
/// or `status` cell opens a menu of [DsGridColumn.options]; and a `multiSelect`
/// cell opens a checkable menu. `progress` cells are never editable.
///
/// ## Grouping
///
/// When [groupBy] lists one or more column keys the rows (after the grid's own
/// sort) are partitioned into groups, outermost key first. A single key yields
/// flat groups; several keys nest them (group → subgroup → …). Each group
/// renders a collapsible header band spanning the full grid width: a disclosure
/// chevron, the group's value label (resolved through the column's
/// [DsGridColumn.options] for select and status columns, and shown as
/// "Ungrouped" for a null or empty value) and the record count. Per-column
/// summaries requested through [aggregations] render in that band, aligned under
/// the columns they summarise. Collapsing a group hides its rows — and any
/// subgroups — in both the frozen and scrolling panes, which stay row-aligned
/// because both iterate the same ordered sequence of header and row segments at
/// matching heights. Collapse state is held internally per group path, starts
/// from [initiallyExpanded] and is keyboard-toggleable: each band is a semantics
/// button announcing its label, count and expanded state. Grouping also applies
/// to the stacked-card layout, where a collapsible header precedes each group's
/// cards. When [groupBy] is empty the grid renders exactly as an ungrouped one.
///
/// ## Views
///
/// Pass a [DsGridView] to [view] and the grid renders that configuration:
/// only the view's columns, in its order, under its display labels, sorted by
/// its sort, with its column-bottom calculations in a footer band. Also pass
/// [onViewChanged] and the grid grows its management surface: every header
/// gains a column menu (sort, move, relabel, hide), headers reorder by
/// long-press drag, a trailing add-column affordance restores hidden columns
/// and each footer slot opens a calculation picker. The view is controlled
/// data the caller owns — the grid reports each change as a new value and
/// never stores one itself, so saved views, naming and switching are the
/// application's to build (a switcher composes from `DsTabs` or `DsMenu`).
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
    this.density = DsGridDensity.cosy,
    this.rowHeight,
    this.compactBreakpoint = 640,
    this.emptyState,
    this.caption,
    this.editable = false,
    this.onCellChanged,
    this.groupBy = const [],
    this.aggregations = const {},
    this.initiallyExpanded = true,
    this.view,
    this.onViewChanged,
    this.enableCellNavigation = true,
    this.rowActions,
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

  /// How tightly rows are packed. Defaults to [DsGridDensity.cosy]. Ignored
  /// when [rowHeight] is set.
  final DsGridDensity density;

  /// An explicit height for each data row, in logical pixels, overriding
  /// [density]. Also used as the header height so the frozen and scrolling
  /// panes stay aligned. Null (the default) takes the height from [density].
  final double? rowHeight;

  /// The width, in logical pixels, below which the stacked-card layout is used
  /// instead of the table.
  final double compactBreakpoint;

  /// Widget shown in place of the table when [rows] is empty. Defaults to a
  /// centred "No records" message.
  final Widget? emptyState;

  /// An optional caption rendered as a heading above the grid, exposed to
  /// assistive technology as a heading so it introduces the table in reading
  /// order.
  final String? caption;

  /// The master switch for inline editing. A cell is only editable when this is
  /// true *and* its [DsGridColumn.editable] is true. Defaults to false, leaving
  /// the grid entirely read-only.
  final bool editable;

  /// Called when an inline edit commits, with the row id, column key and the
  /// new value. The grid is a controlled editing component: it does not mutate
  /// [rows] itself, so the parent should apply the change and pass the updated
  /// rows back.
  final void Function(String rowId, String columnKey, Object? value)?
      onCellChanged;

  /// The column keys to group the rows by, outermost first. A single key
  /// produces flat groups; several keys nest them (group → subgroup → …).
  /// Defaults to `const []`, which leaves the grid ungrouped and renders exactly
  /// as before. Keys that do not match a [DsGridColumn] still group by the raw
  /// cell value.
  final List<String> groupBy;

  /// The per-column summary to show in each group's header band, keyed by
  /// [DsGridColumn.key]. An unlisted column (or one mapped to
  /// [DsAggregation.none]) shows no summary. Only consulted when [groupBy] is
  /// non-empty. Defaults to `const {}`.
  final Map<String, DsAggregation> aggregations;

  /// Whether groups start expanded when [groupBy] is set. Defaults to true. Each
  /// group's collapse state is then held internally and can be toggled from its
  /// header band.
  final bool initiallyExpanded;

  /// The table-view configuration to render: visible columns and their order,
  /// display labels, the view's sort and the footer calculations. Null renders
  /// every column exactly as before. When set, [view]'s sort is authoritative
  /// and [columns] acts as the catalogue the view picks from.
  final DsGridView? view;

  /// Called with the next [DsGridView] whenever the user changes the view.
  /// Providing it (alongside [view]) enables the management surface: each
  /// header gains a column menu (sort, move, relabel, hide), headers reorder
  /// by long-press drag, a trailing add-column affordance restores hidden
  /// columns and the calculations footer becomes editable. The grid never
  /// mutates the view itself; the caller stores it and passes it back.
  final ValueChanged<DsGridView>? onViewChanged;

  /// The actions offered on each row's trailing overflow menu, resolved per
  /// row so a row can offer only what applies to it. Returning an empty list
  /// leaves the row's menu off while the column stays aligned. Null (the
  /// default) renders no actions column at all.
  final List<DsRowAction> Function(DsGridRow row)? rowActions;

  /// Whether the table body joins the focus order for spreadsheet-style
  /// keyboarding: arrow keys move a focused cell, Shift with the arrows
  /// grows a rectangular range, Ctrl or Cmd with C copies the cell or range
  /// as tab-separated text, Ctrl or Cmd with V pastes tab-separated text
  /// into editable cells and Enter opens the focused cell's inline editor
  /// (or toggles a checkbox). Defaults to true; the compact stacked-card
  /// layout never keyboards.
  final bool enableCellNavigation;

  @override
  State<DsDataGrid> createState() => _DsDataGridState();
}

class _DsDataGridState extends State<DsDataGrid> {
  static const double _selectionColumnWidth = 48;
  static const double _seamWidth = 6;
  static const double _resizeHandleWidth = 6;
  static const double _checkboxSize = 18;
  static const double _addColumnWidth = 44;
  static const double _actionsColumnWidth = 48;

  final ScrollController _verticalController = ScrollController();
  final ScrollController _headerHController = ScrollController();
  final ScrollController _bodyHController = ScrollController();
  final ScrollController _footerHController = ScrollController();

  /// Live column widths, keyed by column key. Seeded from the column
  /// definitions and mutated by drag-to-resize.
  final Map<String, double> _widths = <String, double>{};

  /// Internal sort, used only when [DsDataGrid.onSort] is null.
  DsGridSort? _internalSort;

  /// Internal selection, used only when [DsDataGrid.selectedRowIds] is null.
  Set<String> _internalSelection = <String>{};

  /// Per-group-path expansion overrides. A path absent from the map falls back
  /// to [DsDataGrid.initiallyExpanded]; toggling a group header writes the
  /// opposite here so only user-changed groups are remembered.
  final Map<String, bool> _expansionOverrides = <String, bool>{};

  /// The row id of the cell currently in an inline text editor, or null when no
  /// cell is being edited. Paired with [_editingColumnKey].
  String? _editingRowId;

  /// The column key of the cell currently in an inline text editor.
  String? _editingColumnKey;

  /// The key of the column whose header label is being edited inline, or null.
  String? _editingHeaderKey;

  /// The focus node that hosts spreadsheet keyboarding over the table body.
  final FocusNode _cellsFocusNode =
      FocusNode(debugLabel: 'DsDataGrid cells');

  /// The keyboard-focused cell as (row, column) indices into the navigable
  /// rows and display columns, or null while no cell is focused.
  int? _focusRow;
  int? _focusCol;

  /// The anchor of a Shift-grown rectangular range, or null without a range.
  int? _anchorRow;
  int? _anchorCol;

  /// The navigable rows in display order, cached each build for the key
  /// handler and the cell highlight lookups.
  List<DsGridRow> _navRows = const <DsGridRow>[];

  /// Row-id → navigable index, rebuilt each build.
  Map<String, int> _navRowIndex = const <String, int>{};

  /// Column-key → navigable index ([_pinnedColumns] then
  /// [_scrollableColumns]), rebuilt each build.
  Map<String, int> _navColIndex = const <String, int>{};

  /// The live overlay entry for an open select / multi-select menu, kept so at
  /// most one is shown at a time and so it can be dismissed and disposed.
  OverlayEntry? _optionsOverlay;

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
    // Stop editing if the grid was switched out of edit mode.
    if (!widget.editable) {
      _editingRowId = null;
      _editingColumnKey = null;
      _dismissOptionsOverlay();
    }
  }

  @override
  void dispose() {
    _dismissOptionsOverlay();
    _bodyHController.removeListener(_syncHeaderOffset);
    _verticalController.dispose();
    _headerHController.dispose();
    _bodyHController.dispose();
    _footerHController.dispose();
    _cellsFocusNode.dispose();
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
    if (!_bodyHController.hasClients) return;
    // The header and the calculations footer both mirror the body's offset;
    // neither is user-scrollable itself.
    for (final follower in <ScrollController>[
      _headerHController,
      _footerHController,
    ]) {
      if (!follower.hasClients) continue;
      final position = follower.position;
      final target = _bodyHController.offset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if ((follower.offset - target).abs() > 0.5) {
        follower.jumpTo(target);
      }
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

  // --- View plumbing --------------------------------------------------------

  /// Whether the grid renders a caller-owned view with its management surface.
  bool get _viewManaged => widget.view != null && widget.onViewChanged != null;

  /// The columns actually displayed, honouring the view's visible set and
  /// order. Without a view (or with its default null set) this is the full
  /// catalogue in definition order.
  List<DsGridColumn> get _displayColumns {
    final List<String>? visible = widget.view?.visibleColumns;
    if (visible == null) return widget.columns;
    return [
      for (final key in visible)
        if (_columnForKey(key) != null) _columnForKey(key)!,
    ];
  }

  /// The catalogue columns the view currently hides, in definition order.
  List<DsGridColumn> get _hiddenColumns {
    final visible = {for (final c in _displayColumns) c.key};
    return [
      for (final column in widget.columns)
        if (!visible.contains(column.key)) column,
    ];
  }

  /// The display keys in order, materialised for view mutations.
  List<String> get _visibleKeys =>
      [for (final c in _displayColumns) c.key];

  /// The header title for [column], honouring the view's display relabel.
  String _titleFor(DsGridColumn column) =>
      widget.view?.columnLabels[column.key] ?? column.title;

  void _emitView(DsGridView next) => widget.onViewChanged?.call(next);

  void _hideColumn(DsGridColumn column) {
    final keys = _visibleKeys;
    if (keys.length <= 1) return;
    keys.remove(column.key);
    _emitView(widget.view!.copyWith(visibleColumns: keys));
  }

  void _showColumn(DsGridColumn column) {
    final keys = _visibleKeys..add(column.key);
    _emitView(widget.view!.copyWith(visibleColumns: keys));
  }

  /// Moves [column] by [delta] places within the visible order.
  void _moveColumn(DsGridColumn column, int delta) {
    final keys = _visibleKeys;
    final from = keys.indexOf(column.key);
    final to = from + delta;
    if (from == -1 || to < 0 || to >= keys.length) return;
    keys.removeAt(from);
    keys.insert(to, column.key);
    _emitView(widget.view!.copyWith(visibleColumns: keys));
  }

  /// Moves the dragged column [key] to sit before [target] in the visible
  /// order (or after it when dragged from the left).
  void _reorderColumn(String key, DsGridColumn target) {
    if (key == target.key) return;
    final keys = _visibleKeys;
    final from = keys.indexOf(key);
    var to = keys.indexOf(target.key);
    if (from == -1 || to == -1) return;
    keys.removeAt(from);
    if (from < to) to -= 1;
    keys.insert(to, key);
    _emitView(widget.view!.copyWith(visibleColumns: keys));
  }

  /// Commits an inline header relabel: an empty or unchanged label clears the
  /// override, anything else stores it.
  void _commitHeaderLabel(DsGridColumn column, String raw) {
    final labels = Map<String, String>.of(widget.view!.columnLabels);
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == column.title) {
      labels.remove(column.key);
    } else {
      labels[column.key] = trimmed;
    }
    setState(() => _editingHeaderKey = null);
    _emitView(widget.view!.copyWith(columnLabels: labels));
  }

  void _setCalculation(DsGridColumn column, DsAggregation aggregation) {
    final calculations =
        Map<String, DsAggregation>.of(widget.view!.calculations);
    if (aggregation == DsAggregation.none) {
      calculations.remove(column.key);
    } else {
      calculations[column.key] = aggregation;
    }
    _emitView(widget.view!.copyWith(calculations: calculations));
  }

  /// The width reserved at the trailing edge of the scrolling panes for the
  /// add-column affordance, so the header and body scroll extents stay equal.
  double get _trailingAddWidth =>
      _viewManaged && _hiddenColumns.isNotEmpty ? _addColumnWidth : 0;

  /// The width of the trailing row-actions column, or zero when the grid
  /// offers no row actions.
  double get _rowActionsWidth =>
      widget.rowActions == null ? 0 : _actionsColumnWidth;

  List<DsGridColumn> get _pinnedColumns =>
      _displayColumns.where((c) => c.frozen).toList(growable: false);

  List<DsGridColumn> get _scrollableColumns =>
      _displayColumns.where((c) => !c.frozen).toList(growable: false);

  /// The active precedence-ordered sorts. A set [DsDataGrid.view] is
  /// authoritative; otherwise the controlled [DsDataGrid.onSort] contract or
  /// the internal sort supplies at most one rule.
  List<DsGridSort> get _activeSorts {
    final view = widget.view;
    if (view != null) return view.effectiveSorts;
    final single = widget.onSort != null ? widget.sort : _internalSort;
    return [?single];
  }

  /// The primary sort, used where a single rule is enough.
  DsGridSort? get _activeSort =>
      _activeSorts.isEmpty ? null : _activeSorts.first;

  /// Emits a rewritten sort list, keeping the convenience [DsGridView.sort]
  /// in step with the primary rule.
  void _emitSorts(List<DsGridSort> sorts) {
    _emitView(widget.view!.copyWith(
      sorts: sorts,
      sort: sorts.isEmpty ? null : sorts.first,
    ));
  }

  double get _headerHeight => _rowHeight;

  DsGridColumn? _columnForKey(String key) {
    for (final column in widget.columns) {
      if (column.key == key) return column;
    }
    return null;
  }

  /// The rows in display order — reordered locally when the grid owns its
  /// sort. A view's sorts are applied here too, first rule first with each
  /// later rule breaking the ties of the ones before it.
  List<DsGridRow> get _displayRows {
    final sorts = _activeSorts;
    if (sorts.isEmpty) return widget.rows;
    if (widget.view == null && widget.onSort != null) return widget.rows;
    final ordered = List<DsGridRow>.of(widget.rows);
    ordered.sort((a, b) {
      for (final sort in sorts) {
        final column = _columnForKey(sort.columnKey);
        if (column == null) continue;
        final result = _compareValues(
          column,
          a.cells[sort.columnKey],
          b.cells[sort.columnKey],
        );
        if (result != 0) return sort.ascending ? result : -result;
      }
      return 0;
    });
    return ordered;
  }

  void _onHeaderTap(DsGridColumn column) {
    if (!column.sortable) return;
    if (widget.view != null) {
      // A read-only view (no onViewChanged) keeps its sorts fixed. A managed
      // header tap rewrites the primary rule and keeps the tie-breaks: an
      // untouched column becomes the new primary, the current primary cycles
      // ascending → descending → removed.
      if (widget.onViewChanged == null) return;
      final sorts = List<DsGridSort>.of(_activeSorts);
      final primary = sorts.isEmpty ? null : sorts.first;
      if (primary != null && primary.columnKey == column.key) {
        if (primary.ascending) {
          sorts[0] = DsGridSort(columnKey: column.key, ascending: false);
        } else {
          sorts.removeAt(0);
        }
      } else {
        sorts.removeWhere((s) => s.columnKey == column.key);
        sorts.insert(0, DsGridSort(columnKey: column.key));
      }
      _emitSorts(sorts);
      return;
    }
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

  // --- Editing --------------------------------------------------------------

  /// Whether editing is offered for [type]. Everything is editable except
  /// [DsCellType.progress], which is always read-only.
  bool _supportsEditing(DsCellType type) => type != DsCellType.progress;

  /// Whether a cell in [column] can be edited given the grid's master switch,
  /// the column opt-in and the cell type.
  /// The height of a data row and of the header, resolved from the explicit
  /// [DsDataGrid.rowHeight] when one is given and from [DsDataGrid.density]
  /// otherwise. Read through this everywhere, so the frozen and scrolling
  /// panes never disagree about a row's height.
  double get _rowHeight =>
      widget.rowHeight ?? widget.density.rowHeightFrom(DsTokens.of(context));

  /// Whether [column]'s cells offer inline editing.
  ///
  /// A column with a [DsGridColumn.cellBuilder] never does: the builder owns
  /// the whole cell, so wrapping it in a tap-to-edit affordance would swallow
  /// the pointer events its own controls need. This is the single gate for
  /// every edit entry point — the tap wrapper, Enter on a focused cell and
  /// paste — so a custom cell stays the builder's to drive.
  bool _isCellEditable(DsGridColumn column) =>
      widget.editable &&
      column.editable &&
      column.cellBuilder == null &&
      _supportsEditing(column.type);

  /// Whether the cell at [row]/[column] is currently showing an inline editor.
  bool _isEditingCell(DsGridRow row, DsGridColumn column) =>
      _editingRowId == row.id && _editingColumnKey == column.key;

  /// A short, screen-reader-friendly string for the current value of an
  /// editable cell, used as the `value` of its "Edit …" semantics button so the
  /// current value is announced on the control itself (not stranded in a
  /// separate child node). Returns null when the value is empty or is already
  /// conveyed another way (a checkbox uses `checked`).
  String? _editSemanticValue(DsGridColumn column, DsGridRow row) {
    final value = row.cells[column.key];
    switch (column.type) {
      case DsCellType.checkbox:
      case DsCellType.progress:
        return null;
      case DsCellType.text:
      case DsCellType.link:
      case DsCellType.user:
        final string = _asString(value);
        return (string == null || string.isEmpty) ? null : string;
      case DsCellType.number:
        final number = _asNum(value);
        return number == null ? null : _formatNumber(number);
      case DsCellType.currency:
        final number = _asNum(value);
        if (number == null) return null;
        final symbol = column.currencySymbol ?? r'$';
        return '$symbol${_formatNumber(number, decimals: 2)}';
      case DsCellType.date:
        final date = _asDate(value);
        return date == null ? null : _formatDate(date);
      case DsCellType.singleSelect:
      case DsCellType.status:
        final string = _asString(value);
        if (string == null || string.isEmpty) return null;
        return _optionFor(column, string)?.effectiveLabel ?? string;
      case DsCellType.multiSelect:
        final list = _asStringList(value);
        if (list == null || list.isEmpty) return null;
        return [
          for (final item in list) _optionFor(column, item)?.effectiveLabel ?? item,
        ].join(', ');
      case DsCellType.rating:
        final number = _asNum(value);
        return number == null ? null : '${number.round()} of 5';
    }
  }

  /// Finds the option in [column] whose value equals [value], or null.
  DsGridOption? _optionFor(DsGridColumn column, String value) {
    final options = column.options;
    if (options == null) return null;
    for (final option in options) {
      if (option.value == value) return option;
    }
    return null;
  }

  /// Reports a committed edit to the parent. The grid does not mutate its own
  /// rows; a controlled parent applies the change.
  void _emit(DsGridRow row, DsGridColumn column, Object? value) {
    widget.onCellChanged?.call(row.id, column.key, value);
  }

  /// Opens the inline text editor for the given cell.
  void _startInlineEdit(DsGridRow row, DsGridColumn column) {
    _dismissOptionsOverlay();
    setState(() {
      _editingRowId = row.id;
      _editingColumnKey = column.key;
    });
  }

  /// Clears the inline editor, but only if it is still showing the given cell —
  /// so a late commit from a torn-down editor cannot cancel a newer edit.
  void _cancelEditFor(String rowId, String columnKey) {
    if (_editingRowId == rowId && _editingColumnKey == columnKey) {
      setState(() {
        _editingRowId = null;
        _editingColumnKey = null;
      });
      // Hand keyboard control back to the cells so arrows keep working
      // after an edit commits or cancels.
      if (widget.enableCellNavigation && _focusRow != null) {
        _cellsFocusNode.requestFocus();
      }
    }
  }

  /// Removes and forgets any open select / multi-select overlay.
  void _dismissOptionsOverlay() {
    _optionsOverlay?.remove();
    _optionsOverlay = null;
  }

  /// Dispatches a tap on an editable cell to the right editor for its type.
  void _beginEdit(BuildContext context, DsGridColumn column, DsGridRow row) {
    // A pointer edit also moves the keyboard focus cell, so arrows continue
    // from where the user is working.
    final rowIndex = _navRowIndex[row.id];
    final colIndex = _navColIndex[column.key];
    if (rowIndex != null && colIndex != null) _focusCell(rowIndex, colIndex);
    switch (column.type) {
      case DsCellType.text:
      case DsCellType.number:
      case DsCellType.currency:
      case DsCellType.link:
      case DsCellType.user:
        _startInlineEdit(row, column);
      case DsCellType.date:
        _openDatePicker(context, column, row);
      case DsCellType.singleSelect:
      case DsCellType.status:
        _openSelectMenu(context, column, row, multi: false);
      case DsCellType.multiSelect:
        _openSelectMenu(context, column, row, multi: true);
      case DsCellType.checkbox:
        _emit(row, column, !(_asBool(row.cells[column.key]) ?? false));
      case DsCellType.rating:
      case DsCellType.progress:
        break;
    }
  }

  /// Commits an inline text edit, coercing per the column type and reverting on
  /// a failed number parse.
  void _commitInline(DsGridColumn column, DsGridRow row, String raw) {
    switch (column.type) {
      case DsCellType.number:
      case DsCellType.currency:
        final parsed = _parseEditableNumber(raw);
        if (parsed != null) _emit(row, column, parsed);
      case DsCellType.text:
      case DsCellType.link:
      case DsCellType.user:
        _emit(row, column, raw);
      default:
        break;
    }
    _cancelEditFor(row.id, column.key);
  }

  /// Opens the Material date picker for a [DsCellType.date] cell and commits the
  /// chosen day.
  Future<void> _openDatePicker(
    BuildContext context,
    DsGridColumn column,
    DsGridRow row,
  ) async {
    final current = _asDate(row.cells[column.key]) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(current.year - 100),
      lastDate: DateTime(current.year + 100, 12, 31),
    );
    // The picker is an async gap; the grid may have been disposed while it was
    // open, so don't push a late edit into a torn-down parent.
    if (!mounted) return;
    if (picked != null) _emit(row, column, picked);
  }

  /// Opens an anchored menu of [DsGridColumn.options] for a select or status
  /// cell. When [multi] is true the menu is a checkable multi-select that
  /// commits a `List<String>`; otherwise choosing a row commits its value.
  void _openSelectMenu(
    BuildContext context,
    DsGridColumn column,
    DsGridRow row, {
    required bool multi,
  }) {
    _dismissOptionsOverlay();
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (box == null || overlayBox == null) return;
    final tokens = DsTokens.of(context);
    final anchorOffset = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    final anchorSize = box.size;
    final overlaySize = overlayBox.size;
    final options = column.options ?? const <DsGridOption>[];

    late final OverlayEntry entry;
    Widget panel;
    if (multi) {
      final selected = _asStringList(row.cells[column.key])?.toSet() ??
          <String>{};
      panel = _MultiSelectOverlayPanel(
        tokens: tokens,
        options: options,
        initialSelected: selected,
        onCommit: (values) {
          _dismissOptionsOverlay();
          _emit(row, column, values);
        },
      );
    } else {
      final current = _asString(row.cells[column.key]);
      panel = _overlaySurface(
        tokens,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < options.length; i++)
              _optionRow(
                tokens,
                option: options[i],
                selected: options[i].value == current,
                multi: false,
                autofocus: options[i].value == current,
                onTap: () {
                  _dismissOptionsOverlay();
                  _emit(row, column, options[i].value);
                },
              ),
          ],
        ),
      );
    }

    entry = OverlayEntry(
      builder: (_) => _AnchoredOverlay(
        anchorOffset: anchorOffset,
        anchorSize: anchorSize,
        overlaySize: overlaySize,
        onDismiss: _dismissOptionsOverlay,
        child: panel,
      ),
    );
    _optionsOverlay = entry;
    overlay.insert(entry);
  }

  // --- Spreadsheet keyboarding ---------------------------------------------

  /// Rebuilds the navigable-cell caches for this frame: the rows in display
  /// order (honouring grouping's visible segments) and the index maps the key
  /// handler and highlight lookups use.
  void _syncNavCaches() {
    final rows = _displayRows;
    _navRows = widget.groupBy.isEmpty
        ? rows
        : [
            for (final segment in _visibleSegments(rows))
              if (segment.row != null) segment.row!,
          ];
    _navRowIndex = {
      for (var i = 0; i < _navRows.length; i++) _navRows[i].id: i,
    };
    final columns = [..._pinnedColumns, ..._scrollableColumns];
    _navColIndex = {
      for (var i = 0; i < columns.length; i++) columns[i].key: i,
    };
    // Clamp a stale focus after rows or columns changed under it.
    if (_focusRow != null && _navRows.isNotEmpty) {
      _focusRow = _focusRow!.clamp(0, _navRows.length - 1);
      _focusCol = _focusCol!.clamp(0, columns.length - 1);
    } else if (_navRows.isEmpty) {
      _focusRow = null;
      _focusCol = null;
      _anchorRow = null;
      _anchorCol = null;
    }
  }

  /// The display columns in navigable order (frozen first).
  List<DsGridColumn> get _navColumns =>
      [..._pinnedColumns, ..._scrollableColumns];

  bool _isCellFocused(DsGridRow row, DsGridColumn column) =>
      _focusRow != null &&
      _navRowIndex[row.id] == _focusRow &&
      _navColIndex[column.key] == _focusCol;

  bool _isCellInRange(DsGridRow row, DsGridColumn column) {
    if (_focusRow == null || _anchorRow == null) return false;
    final r = _navRowIndex[row.id];
    final c = _navColIndex[column.key];
    if (r == null || c == null) return false;
    final r1 = math.min(_focusRow!, _anchorRow!);
    final r2 = math.max(_focusRow!, _anchorRow!);
    final c1 = math.min(_focusCol!, _anchorCol!);
    final c2 = math.max(_focusCol!, _anchorCol!);
    return r >= r1 && r <= r2 && c >= c1 && c <= c2;
  }

  /// Sets the keyboard-focused cell, collapsing any range.
  void _focusCell(int row, int col) {
    setState(() {
      _focusRow = row;
      _focusCol = col;
      _anchorRow = null;
      _anchorCol = null;
    });
  }

  /// Scrolls vertically so the focused row's line is inside the viewport.
  void _ensureFocusVisible() {
    if (_focusRow == null || !_verticalController.hasClients) return;
    final row = _navRows[_focusRow!];
    int line = _focusRow!;
    if (widget.groupBy.isNotEmpty) {
      final segments = _visibleSegments(_displayRows);
      line = segments.indexWhere((s) => s.row?.id == row.id);
      if (line == -1) return;
    }
    final position = _verticalController.position;
    final top = line * _rowHeight;
    final bottom = top + _rowHeight;
    if (top < position.pixels) {
      _verticalController.jumpTo(
        top.toDouble().clamp(0, position.maxScrollExtent),
      );
    } else if (bottom > position.pixels + position.viewportDimension) {
      _verticalController.jumpTo(
        (bottom - position.viewportDimension)
            .clamp(0, position.maxScrollExtent),
      );
    }
  }

  KeyEventResult _onCellsKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    // Leave every key alone while an inline editor (or anything else inside
    // the grid) holds focus.
    if (FocusManager.instance.primaryFocus != _cellsFocusNode) {
      return KeyEventResult.ignored;
    }
    if (_navRows.isEmpty || _navColumns.isEmpty) return KeyEventResult.ignored;

    final pressed = HardwareKeyboard.instance;
    final bool shift = pressed.isShiftPressed;
    final bool primary = pressed.isControlPressed || pressed.isMetaPressed;
    final key = event.logicalKey;

    int dRow = 0;
    int dCol = 0;
    if (key == LogicalKeyboardKey.arrowUp) {
      dRow = -1;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      dRow = 1;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      dCol = -1;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      dCol = 1;
    } else if (primary && key == LogicalKeyboardKey.keyC) {
      _copyFocusOrRange();
      return KeyEventResult.handled;
    } else if (primary && key == LogicalKeyboardKey.keyV) {
      _pasteAtFocus();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.f2) {
      _editFocusedCell();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.escape) {
      if (_anchorRow != null) {
        setState(() {
          _anchorRow = null;
          _anchorCol = null;
        });
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    } else {
      return KeyEventResult.ignored;
    }

    setState(() {
      if (_focusRow == null) {
        _focusRow = 0;
        _focusCol = 0;
      } else {
        if (shift) {
          _anchorRow ??= _focusRow;
          _anchorCol ??= _focusCol;
        } else {
          _anchorRow = null;
          _anchorCol = null;
        }
        _focusRow =
            (_focusRow! + dRow).clamp(0, _navRows.length - 1);
        _focusCol =
            (_focusCol! + dCol).clamp(0, _navColumns.length - 1);
      }
    });
    _ensureFocusVisible();
    return KeyEventResult.handled;
  }

  /// Opens the focused cell's editor where the type edits inline (text,
  /// number, currency, link, user), or toggles a focused checkbox. The
  /// anchored editors (selects, dates) stay pointer-driven.
  void _editFocusedCell() {
    if (_focusRow == null) return;
    final row = _navRows[_focusRow!];
    final column = _navColumns[_focusCol!];
    if (!_isCellEditable(column)) return;
    switch (column.type) {
      case DsCellType.text:
      case DsCellType.number:
      case DsCellType.currency:
      case DsCellType.link:
      case DsCellType.user:
        _startInlineEdit(row, column);
      case DsCellType.checkbox:
        _emit(row, column, !(_asBool(row.cells[column.key]) ?? false));
      default:
        break;
    }
  }

  /// Copies the focused cell — or the rectangular range — to the clipboard
  /// as tab-separated text, one line per row.
  void _copyFocusOrRange() {
    if (_focusRow == null) return;
    final r1 = math.min(_focusRow!, _anchorRow ?? _focusRow!);
    final r2 = math.max(_focusRow!, _anchorRow ?? _focusRow!);
    final c1 = math.min(_focusCol!, _anchorCol ?? _focusCol!);
    final c2 = math.max(_focusCol!, _anchorCol ?? _focusCol!);
    final columns = _navColumns;
    final lines = <String>[
      for (var r = r1; r <= r2; r++)
        [
          for (var c = c1; c <= c2; c++)
            _clipboardCellText(columns[c], _navRows[r].cells[columns[c].key]),
        ].join('\t'),
    ];
    Clipboard.setData(ClipboardData(text: lines.join('\n')));
  }

  /// Pastes tab-separated clipboard text starting at the focused cell,
  /// writing only into editable cells whose type accepts the value, each
  /// through [DsDataGrid.onCellChanged].
  Future<void> _pasteAtFocus() async {
    if (_focusRow == null || widget.onCellChanged == null) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    final lines = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();
    final columns = _navColumns;
    for (var r = 0; r < lines.length; r++) {
      final targetRowIndex = _focusRow! + r;
      if (targetRowIndex >= _navRows.length) break;
      final cells = lines[r].split('\t');
      for (var c = 0; c < cells.length; c++) {
        final targetColIndex = _focusCol! + c;
        if (targetColIndex >= columns.length) break;
        final column = columns[targetColIndex];
        if (!_isCellEditable(column)) continue;
        final (bool ok, Object? value) = _coercePasted(column, cells[c]);
        if (!ok) continue;
        _emit(_navRows[targetRowIndex], column, value);
      }
    }
  }

  /// The plain clipboard text for a cell, spreadsheet-compatible: raw
  /// strings, ungrouped numbers, ISO dates, TRUE/FALSE checkboxes and
  /// comma-joined multi-select labels.
  String _clipboardCellText(DsGridColumn column, Object? value) {
    switch (column.type) {
      case DsCellType.text:
      case DsCellType.link:
      case DsCellType.user:
      case DsCellType.singleSelect:
      case DsCellType.status:
        return _asString(value) ?? '';
      case DsCellType.number:
      case DsCellType.currency:
      case DsCellType.rating:
      case DsCellType.progress:
        final number = _asNum(value);
        return number == null ? '' : _plainNumberText(number);
      case DsCellType.date:
        final date = _asDate(value);
        return date == null ? '' : _formatDate(date);
      case DsCellType.checkbox:
        final boolean = _asBool(value);
        return boolean == null ? '' : (boolean ? 'TRUE' : 'FALSE');
      case DsCellType.multiSelect:
        return _asStringList(value)?.join(', ') ?? '';
    }
  }

  /// Coerces pasted [raw] text for [column], returning whether the value is
  /// compatible and the value to write. Incompatible text is skipped rather
  /// than corrupting the cell.
  (bool, Object?) _coercePasted(DsGridColumn column, String raw) {
    final trimmed = raw.trim();
    switch (column.type) {
      case DsCellType.text:
      case DsCellType.link:
      case DsCellType.user:
        return (true, raw);
      case DsCellType.number:
      case DsCellType.currency:
        if (trimmed.isEmpty) return (true, null);
        final number = _parseEditableNumber(trimmed);
        return number == null ? (false, null) : (true, number);
      case DsCellType.rating:
        final number = num.tryParse(trimmed);
        return number == null
            ? (false, null)
            : (true, number.clamp(0, 5));
      case DsCellType.date:
        final date = DateTime.tryParse(trimmed);
        return date == null ? (false, null) : (true, date);
      case DsCellType.checkbox:
        final lowered = trimmed.toLowerCase();
        if (lowered == 'true' || lowered == '1' || lowered == 'yes') {
          return (true, true);
        }
        if (lowered == 'false' || lowered == '0' || lowered == 'no') {
          return (true, false);
        }
        return (false, null);
      case DsCellType.singleSelect:
      case DsCellType.status:
        final options = column.options;
        if (options == null) return (true, trimmed);
        for (final option in options) {
          if (option.value.toLowerCase() == trimmed.toLowerCase() ||
              option.effectiveLabel.toLowerCase() == trimmed.toLowerCase()) {
            return (true, option.value);
          }
        }
        return (false, null);
      case DsCellType.multiSelect:
        final parts = [
          for (final part in trimmed.split(','))
            if (part.trim().isNotEmpty) part.trim(),
        ];
        final options = column.options;
        if (options == null) return (true, parts);
        final resolved = <String>[];
        for (final part in parts) {
          var matched = part;
          for (final option in options) {
            if (option.value.toLowerCase() == part.toLowerCase() ||
                option.effectiveLabel.toLowerCase() == part.toLowerCase()) {
              matched = option.value;
              break;
            }
          }
          resolved.add(matched);
        }
        return (true, resolved);
      case DsCellType.progress:
        // Progress cells are never editable.
        return (false, null);
    }
  }

  // --- View management menus ------------------------------------------------

  /// Shows [panel] anchored beneath [context]'s render box, reusing the grid's
  /// single-overlay slot so at most one menu is ever open.
  void _openAnchoredPanel(BuildContext context, Widget panel) {
    _dismissOptionsOverlay();
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (box == null || overlayBox == null) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AnchoredOverlay(
        anchorOffset: box.localToGlobal(Offset.zero, ancestor: overlayBox),
        anchorSize: box.size,
        overlaySize: overlayBox.size,
        onDismiss: _dismissOptionsOverlay,
        child: panel,
      ),
    );
    _optionsOverlay = entry;
    overlay.insert(entry);
  }

  /// A single action row in a view-management menu.
  Widget _actionRow(
    DsTokens tokens, {
    required String label,
    IconData? icon,
    bool enabled = true,
    bool selected = false,
    required VoidCallback onTap,
  }) {
    final Color ink = enabled
        ? tokens.colorText
        : tokens.colorText.withValues(alpha: tokens.stateDisabledOpacity);
    return InkWell(
      onTap: enabled
          ? () {
              _dismissOptionsOverlay();
              onTap();
            }
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DsSpacing.md,
            vertical: DsSpacing.sm,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                DsIcon(
                  icon: icon,
                  size: DsIconSize.sm,
                  color: enabled
                      ? tokens.colorSecondaryText
                      : tokens.colorSecondaryText
                          .withValues(alpha: tokens.stateDisabledOpacity),
                ),
                const SizedBox(width: DsSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  style: tokens.bodyMd.toTextStyle(color: ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: DsSpacing.sm),
                DsIcon(
                  icon: DsIcons.check,
                  size: DsIconSize.sm,
                  color: tokens.formAccentColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// The per-column management menu behind the header's trigger: sort, move,
  /// relabel and hide.
  void _openHeaderMenu(BuildContext context, DsGridColumn column) {
    final tokens = DsTokens.of(context);
    final sortIndex =
        _activeSorts.indexWhere((s) => s.columnKey == column.key);
    final active = sortIndex == -1 ? null : _activeSorts[sortIndex];
    final index = _displayColumns.indexOf(column);

    // Makes this column the primary rule with [ascending], keeping the other
    // rules as tie-breaks.
    void sortPrimary({required bool ascending}) {
      final sorts = List<DsGridSort>.of(_activeSorts)
        ..removeWhere((s) => s.columnKey == column.key)
        ..insert(0, DsGridSort(columnKey: column.key, ascending: ascending));
      _emitSorts(sorts);
    }

    _openAnchoredPanel(
      context,
      _overlaySurface(
        tokens,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (column.sortable) ...[
              _actionRow(
                tokens,
                label: 'Sort ascending',
                icon: DsIcons.arrowUp,
                selected: active?.ascending == true,
                onTap: () => sortPrimary(ascending: true),
              ),
              _actionRow(
                tokens,
                label: 'Sort descending',
                icon: DsIcons.arrowDown,
                selected: active?.ascending == false,
                onTap: () => sortPrimary(ascending: false),
              ),
              if (active != null)
                _actionRow(
                  tokens,
                  label: 'Clear sort',
                  icon: DsIcons.close,
                  onTap: () => _emitSorts(
                    List<DsGridSort>.of(_activeSorts)
                      ..removeWhere((s) => s.columnKey == column.key),
                  ),
                ),
            ],
            _actionRow(
              tokens,
              label: 'Move left',
              icon: DsIcons.chevronLeft,
              enabled: index > 0,
              onTap: () => _moveColumn(column, -1),
            ),
            _actionRow(
              tokens,
              label: 'Move right',
              icon: DsIcons.chevronRight,
              enabled: index < _displayColumns.length - 1,
              onTap: () => _moveColumn(column, 1),
            ),
            _actionRow(
              tokens,
              label: 'Edit label',
              icon: DsIcons.edit,
              onTap: () => setState(() => _editingHeaderKey = column.key),
            ),
            _actionRow(
              tokens,
              label: 'Hide column',
              icon: DsIcons.visibilityOff,
              enabled: _visibleKeys.length > 1,
              onTap: () => _hideColumn(column),
            ),
          ],
        ),
      ),
    );
  }

  /// The add-column menu behind the trailing "+" affordance, listing every
  /// catalogue column the view currently hides.
  void _openAddColumnMenu(BuildContext context) {
    final tokens = DsTokens.of(context);
    _openAnchoredPanel(
      context,
      _overlaySurface(
        tokens,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final column in _hiddenColumns)
              _actionRow(
                tokens,
                label: column.title,
                icon: column.icon,
                onTap: () => _showColumn(column),
              ),
          ],
        ),
      ),
    );
  }

  /// The calculation picker behind a footer slot. Numeric aggregations are
  /// offered only for numeric column types; count applies to any column.
  void _openAggregationMenu(BuildContext context, DsGridColumn column) {
    final tokens = DsTokens.of(context);
    final current = widget.view!.calculations[column.key] ?? DsAggregation.none;
    final numeric = switch (column.type) {
      DsCellType.number ||
      DsCellType.currency ||
      DsCellType.rating ||
      DsCellType.progress =>
        true,
      _ => false,
    };
    final choices = <DsAggregation>[
      DsAggregation.none,
      DsAggregation.count,
      if (numeric) ...[
        DsAggregation.sum,
        DsAggregation.average,
        DsAggregation.min,
        DsAggregation.max,
      ],
    ];
    _openAnchoredPanel(
      context,
      _overlaySurface(
        tokens,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final aggregation in choices)
              _actionRow(
                tokens,
                label: aggregation == DsAggregation.none
                    ? 'None'
                    : _aggregationName(aggregation),
                selected: aggregation == current,
                onTap: () => _setCalculation(column, aggregation),
              ),
          ],
        ),
      ),
    );
  }

  /// The human name of an aggregation, as shown in footer slots and menus.
  String _aggregationName(DsAggregation aggregation) => switch (aggregation) {
        DsAggregation.none => '',
        DsAggregation.count => 'Count',
        DsAggregation.sum => 'Sum',
        DsAggregation.average => 'Average',
        DsAggregation.min => 'Min',
        DsAggregation.max => 'Max',
      };

  // --- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    _syncNavCaches();
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

        // Builds the grid body (table, cards or empty state) at a given height.
        // A null height means "size to content"; the fill sentinel
        // ([double.infinity]) means "fill the bounded space I am handed and
        // scroll". The fill sentinel lets a caption above a fixed-height grid
        // claim its own (possibly wrapped) height while the body takes exactly
        // what remains — no fragile estimate of the caption's height.
        Widget bodyFor(double? height) {
          if (widget.rows.isEmpty) return _buildEmpty(tokens, height);
          if (maxWidth < widget.compactBreakpoint) {
            return _buildCompact(tokens, height);
          }
          return _buildTable(tokens, maxWidth, height);
        }

        if (caption == null) return bodyFor(viewportHeight);

        final captionWidget = Padding(
          padding: const EdgeInsets.only(bottom: DsSpacing.sm),
          child: Semantics(
            container: true,
            header: true,
            label: caption,
            child: Text(
              caption,
              style: tokens.bodySm.toTextStyle(
                color: tokens.colorSecondaryText,
              ),
            ),
          ),
        );

        // Unbounded height: caption above a content-sized body.
        if (viewportHeight == null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [captionWidget, bodyFor(null)],
          );
        }

        // Bounded height: the caption takes its natural (possibly wrapped)
        // height and the body fills whatever remains.
        return SizedBox(
          height: viewportHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              captionWidget,
              Expanded(child: bodyFor(double.infinity)),
            ],
          ),
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
    // The fill sentinel: the empty frame stretches to fill the bounded slot it
    // is given (an [Expanded] under a caption).
    if (height == null || height == double.infinity) return framed;
    return SizedBox(height: math.max(0, height), child: framed);
  }

  // --- Compact (stacked cards) ---------------------------------------------

  Widget _buildCompact(DsTokens tokens, double? height) {
    final rows = _displayRows;
    final Widget list;
    if (widget.groupBy.isEmpty) {
      list = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: DsSpacing.sm),
            _buildCard(tokens, rows[i]),
          ],
        ],
      );
    } else {
      final segments = _visibleSegments(rows);
      list = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(height: DsSpacing.sm),
            if (segments[i].group != null)
              _groupHeaderCard(tokens, segments[i].group!)
            else
              _buildCard(tokens, segments[i].row!),
          ],
        ],
      );
    }
    // The compact counterpart of the calculations footer: a read-only summary
    // card beneath the stacked cards.
    final calculations = widget.view?.calculations ?? const {};
    final Widget listWithSummary;
    if (calculations.isEmpty) {
      listWithSummary = list;
    } else {
      final entries = <Widget>[];
      for (final column in _displayColumns) {
        final aggregation = calculations[column.key];
        if (aggregation == null || aggregation == DsAggregation.none) continue;
        final value = _aggregationLabel(column, aggregation, rows);
        if (value == null) continue;
        entries.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DsSpacing.xxs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _titleFor(column),
                    style: tokens.bodySm
                        .toTextStyle(color: tokens.colorSecondaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: DsSpacing.md),
                Text(
                  '${_aggregationName(aggregation)} $value',
                  style: tokens.labelSm.toTextStyle(color: tokens.colorText),
                ),
              ],
            ),
          ),
        );
      }
      listWithSummary = entries.isEmpty
          ? list
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                list,
                const SizedBox(height: DsSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: tokens.offsetBackgroundColor,
                    border: Border.all(color: tokens.colorBorder),
                    borderRadius:
                        BorderRadius.circular(tokens.formBorderRadius),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DsSpacing.md,
                    vertical: DsSpacing.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: entries,
                  ),
                ),
              ],
            );
    }

    if (height == null) return listWithSummary;
    final scrollable = Scrollbar(
      controller: _verticalController,
      child: SingleChildScrollView(
        controller: _verticalController,
        child: listWithSummary,
      ),
    );
    // The fill sentinel: scroll within whatever bounded height the parent
    // ([Expanded] under a caption) hands down, without a fixed box.
    if (height == double.infinity) return scrollable;
    return SizedBox(
      height: math.max(0, height),
      child: scrollable,
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
      for (final column in _displayColumns)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DsSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _titleFor(column),
                  style: tokens.bodySm.toTextStyle(
                    color: tokens.colorSecondaryText,
                  ),
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              Expanded(
                flex: 3,
                child: _cardValue(tokens, column, row),
              ),
            ],
          ),
        ),
    ];

    final cardActions = widget.rowActions?.call(row) ?? const <DsRowAction>[];
    if (cardActions.isNotEmpty) {
      fields.insert(
        0,
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: _rowActionsCell(tokens, row),
        ),
      );
    }

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
    // The fill sentinel: measure the bounded height the parent ([Expanded]
    // under a caption) actually hands down, so the header + scrolling body sum
    // to exactly that — never overflowing by a mis-estimated caption height.
    if (height == double.infinity) {
      return LayoutBuilder(
        builder: (context, constraints) => _buildTableSized(
          tokens,
          maxWidth,
          constraints.maxHeight.isFinite ? constraints.maxHeight : null,
        ),
      );
    }
    return _buildTableSized(tokens, maxWidth, height);
  }

  Widget _buildTableSized(DsTokens tokens, double maxWidth, double? height) {
    final rows = _displayRows;
    final pinnedColumns = _pinnedColumns;
    final scrollableColumns = _scrollableColumns;

    final double pinnedWidth = (widget.selectable ? _selectionColumnWidth : 0) +
        pinnedColumns.fold<double>(0, (sum, c) => sum + _columnWidth(c));
    final hasPinned = pinnedWidth > 0;
    final scrollContentWidth =
        scrollableColumns.fold<double>(0, (sum, c) => sum + _columnWidth(c));

    // With grouping active the body iterates group-header and data-row segments
    // rather than bare rows, so the content height counts every visible segment
    // (each one row-height tall) instead of just the rows.
    final grouped = widget.groupBy.isNotEmpty;
    final segments =
        grouped ? _visibleSegments(rows) : const <_GridSegment>[];
    final lineCount = grouped ? segments.length : rows.length;

    final contentHeight = lineCount * _rowHeight;
    final headerHeight = _headerHeight;
    // The calculations footer renders whenever a view carries calculations,
    // and always on a managed view so its add affordances are reachable.
    final hasFooter = widget.view != null &&
        (widget.view!.calculations.isNotEmpty || _viewManaged);
    final footerHeight = hasFooter ? _rowHeight + 1 : 0.0;
    final availableBody = height != null
        ? math.max(0.0, height - headerHeight - footerHeight - 1)
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

    final body = grouped
        ? _buildGroupedBody(
            tokens,
            segments,
            pinnedColumns,
            scrollableColumns,
            pinnedWidth,
            hasPinned,
            scrollContentWidth,
            contentHeight,
            bodyHeight,
          )
        : _buildBody(
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

    final table = SizedBox(
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
            children: [
              header,
              body,
              if (hasFooter)
                _buildFooter(
                  tokens,
                  rows,
                  pinnedColumns,
                  scrollableColumns,
                  pinnedWidth,
                  hasPinned,
                  scrollContentWidth,
                ),
            ],
          ),
        ),
      ),
    );

    if (!widget.enableCellNavigation) return table;
    // The table body joins the focus order; arrow keys and the clipboard
    // then operate on the focused cell. The handler acts only while this
    // node itself is the primary focus, so inline editors keep their keys.
    return Focus(
      focusNode: _cellsFocusNode,
      onKeyEvent: _onCellsKey,
      onFocusChange: (bool focused) {
        if (focused && _focusRow == null && _navRows.isNotEmpty) {
          _focusCell(0, 0);
        }
      },
      child: table,
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
                    final width = math.max(
                      scrollContentWidth + _trailingAddWidth + _rowActionsWidth,
                      constraints.maxWidth,
                    );
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
                            if (_trailingAddWidth > 0)
                              _addColumnCell(tokens),
                            if (_rowActionsWidth > 0)
                              SizedBox(
                                width: _actionsColumnWidth,
                                height: _headerHeight,
                              ),
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
              final width = math.max(
                scrollContentWidth + _trailingAddWidth + _rowActionsWidth,
                constraints.maxWidth,
              );
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
                              if (_rowActionsWidth > 0)
                                _rowActionsCell(tokens, row),
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

  // --- Grouped body ---------------------------------------------------------

  /// The grouped analogue of [_buildBody]. Both the frozen and scrolling panes
  /// iterate the *same* ordered [segments] — a mix of group-header bands and
  /// data-row segments, each exactly one [DsDataGrid.rowHeight] tall — so the
  /// two panes stay row-aligned exactly as they do without grouping. A header
  /// segment renders its chevron + label in the frozen pane and its aggregations
  /// in the scrolling pane; a collapsed group simply contributes no row
  /// segments, hiding its rows in both panes at once.
  Widget _buildGroupedBody(
    DsTokens tokens,
    List<_GridSegment> segments,
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
                for (final segment in segments)
                  if (segment.group != null)
                    _groupHeaderFrozen(tokens, segment.group!)
                  else
                    _rowSegment(
                      tokens,
                      segment.row!,
                      Row(
                        children: [
                          if (widget.selectable)
                            _selectionCell(tokens, segment.row!),
                          for (final column in pinnedColumns)
                            _dataCell(tokens, column, segment.row!),
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
              final width = math.max(
                scrollContentWidth + _trailingAddWidth + _rowActionsWidth,
                constraints.maxWidth,
              );
              return SingleChildScrollView(
                controller: _bodyHController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final segment in segments)
                        if (segment.group != null)
                          _groupHeaderScroll(
                            tokens,
                            segment.group!,
                            scrollableColumns,
                            showLabel: !hasPinned,
                          )
                        else
                          _rowSegment(
                            tokens,
                            segment.row!,
                            Row(
                              children: [
                                for (final column in scrollableColumns)
                                  _dataCell(tokens, column, segment.row!),
                                if (_rowActionsWidth > 0)
                                  _rowActionsCell(tokens, segment.row!),
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

  /// The frozen-pane part of a group header band: an offset-tinted strip, one
  /// row-height tall, carrying the disclosure chevron, the group label and the
  /// record count, indented by the group's depth. The whole strip is a
  /// keyboard-focusable semantics button that toggles the group.
  Widget _groupHeaderFrozen(DsTokens tokens, _GroupNode node) {
    final expanded = _isExpanded(node.path);
    final indent = DsSpacing.sm + node.depth * DsSpacing.lg;
    final band = Container(
      height: _rowHeight,
      decoration: BoxDecoration(
        color: tokens.offsetBackgroundColor,
        border: Border(bottom: BorderSide(color: tokens.colorBorder)),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: indent, right: DsSpacing.sm),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _groupLabelRow(tokens, node, expanded, flexible: true),
        ),
      ),
    );
    return _groupToggleButton(node, expanded, band, labelled: true);
  }

  /// The scrolling-pane part of a group header band: the per-column
  /// aggregations, aligned under the same [scrollableColumns] widths as the data
  /// cells so they line up with their columns and scroll with them. When there
  /// is no frozen pane ([showLabel] is true) the chevron + label is overlaid at
  /// the leading edge here instead, and this strip becomes the toggle button.
  Widget _groupHeaderScroll(
    DsTokens tokens,
    _GroupNode node,
    List<DsGridColumn> scrollableColumns, {
    required bool showLabel,
  }) {
    final expanded = _isExpanded(node.path);
    final aggRow = Row(
      children: [
        for (final column in scrollableColumns)
          _aggregationCell(tokens, column, node),
      ],
    );
    final Widget inner;
    if (showLabel) {
      final indent = DsSpacing.sm + node.depth * DsSpacing.lg;
      inner = Stack(
        children: [
          Positioned.fill(child: ExcludeSemantics(child: aggRow)),
          Positioned(
            left: indent,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _groupLabelRow(tokens, node, expanded, flexible: false),
            ),
          ),
        ],
      );
    } else {
      inner = aggRow;
    }
    final band = Container(
      height: _rowHeight,
      decoration: BoxDecoration(
        color: tokens.offsetBackgroundColor,
        border: Border(bottom: BorderSide(color: tokens.colorBorder)),
      ),
      child: inner,
    );
    return _groupToggleButton(node, expanded, band, labelled: showLabel);
  }

  /// Wraps a header [band] in the ink + tap affordance that toggles the group.
  /// When [labelled] the wrapper is the announced semantics button for the
  /// group; otherwise (the mirror strip in the other pane) its semantics are
  /// excluded so a group is announced exactly once.
  Widget _groupToggleButton(
    _GroupNode node,
    bool expanded,
    Widget band, {
    required bool labelled,
  }) {
    final interactive = Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: () => _toggleGroup(node.path), child: band),
    );
    if (labelled) {
      return Semantics(
        button: true,
        label: _groupSemanticsLabel(node, expanded),
        excludeSemantics: true,
        child: interactive,
      );
    }
    return ExcludeSemantics(child: interactive);
  }

  /// The chevron + label + count shown in a group header band. [flexible] lets
  /// the label shrink to the available width (used in the bounded frozen pane);
  /// otherwise it is capped so it can sit safely in an unbounded overlay.
  Widget _groupLabelRow(
    DsTokens tokens,
    _GroupNode node,
    bool expanded, {
    required bool flexible,
  }) {
    final label = Text(
      node.label,
      style: tokens.labelMd.toTextStyle(color: tokens.colorText),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DsIcon(
          icon: expanded ? DsIcons.expandMore : DsIcons.chevronRight,
          size: DsIconSize.sm,
          color: tokens.colorSecondaryText,
        ),
        const SizedBox(width: DsSpacing.xs),
        if (flexible)
          Flexible(child: label)
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: label,
          ),
        const SizedBox(width: DsSpacing.sm),
        Text(
          '· ${node.rows.length}',
          style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
        ),
      ],
    );
  }

  /// A single aggregation slot in a header band, sized to [column]'s width and
  /// aligned like its data cells so the summary lines up beneath the column.
  /// Renders nothing when the column has no aggregation (or no applicable
  /// value), keeping the slot's width so later columns stay aligned.
  Widget _aggregationCell(DsTokens tokens, DsGridColumn column, _GroupNode node) {
    final aggregation = widget.aggregations[column.key] ?? DsAggregation.none;
    final text = aggregation == DsAggregation.none
        ? null
        : _aggregationLabel(column, aggregation, node.rows);
    return SizedBox(
      width: _columnWidth(column),
      height: _rowHeight,
      child: text == null
          ? null
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: _cellPaddingX),
              child: Align(
                alignment: _alignmentOf(column.effectiveAlign),
                child: Text(
                  text,
                  style: tokens.labelSm.toTextStyle(color: tokens.colorText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
    );
  }

  /// The collapsible group header shown above each group's cards in the
  /// stacked-card layout: a bordered, offset-tinted card with a chevron, the
  /// label, the record count and — when expanded — a wrap of the group's
  /// aggregations. The whole card is a semantics button that toggles the group.
  Widget _groupHeaderCard(DsTokens tokens, _GroupNode node) {
    final expanded = _isExpanded(node.path);
    final indent = node.depth * DsSpacing.lg;
    final radius = BorderRadius.circular(tokens.formBorderRadius);

    final aggregations = <Widget>[];
    for (final column in _displayColumns) {
      final aggregation = widget.aggregations[column.key] ?? DsAggregation.none;
      if (aggregation == DsAggregation.none) continue;
      final text = _aggregationLabel(column, aggregation, node.rows);
      if (text == null) continue;
      aggregations.add(
        Text(
          '${_titleFor(column)}: $text',
          style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
        ),
      );
    }

    final content = Container(
      decoration: BoxDecoration(
        color: tokens.offsetBackgroundColor,
        border: Border.all(color: tokens.colorBorder),
        borderRadius: radius,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.md,
        vertical: DsSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DsIcon(
                icon: expanded ? DsIcons.expandMore : DsIcons.chevronRight,
                size: DsIconSize.sm,
                color: tokens.colorSecondaryText,
              ),
              const SizedBox(width: DsSpacing.xs),
              Expanded(
                child: Text(
                  node.label,
                  style: tokens.labelMd.toTextStyle(color: tokens.colorText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: DsSpacing.sm),
              Text(
                '· ${node.rows.length}',
                style:
                    tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
              ),
            ],
          ),
          if (expanded && aggregations.isNotEmpty) ...[
            const SizedBox(height: DsSpacing.xs),
            Wrap(
              spacing: DsSpacing.md,
              runSpacing: DsSpacing.xxs,
              children: aggregations,
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Semantics(
        button: true,
        label: _groupSemanticsLabel(node, expanded),
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: () => _toggleGroup(node.path), child: content),
        ),
      ),
    );
  }

  // --- Grouping model -------------------------------------------------------

  /// Whether the group at [path] is currently expanded, honouring any user
  /// toggle and otherwise falling back to [DsDataGrid.initiallyExpanded].
  bool _isExpanded(String path) =>
      _expansionOverrides[path] ?? widget.initiallyExpanded;

  /// Flips the expansion of the group at [path].
  void _toggleGroup(String path) {
    setState(() => _expansionOverrides[path] = !_isExpanded(path));
  }

  /// The announced label for a group header band, e.g.
  /// "Active group, 12 records, expanded".
  String _groupSemanticsLabel(_GroupNode node, bool expanded) =>
      '${node.label} group, ${node.rows.length} '
      '${node.rows.length == 1 ? 'record' : 'records'}, '
      '${expanded ? 'expanded' : 'collapsed'}';

  /// Builds the ordered, flattened list of segments to render for [rows]: each
  /// group contributes a header segment, then — when expanded — either its
  /// subgroups' segments or its own row segments.
  List<_GridSegment> _visibleSegments(List<DsGridRow> rows) {
    final out = <_GridSegment>[];
    _collectSegments(_groupLevel(rows, 0, ''), out);
    return out;
  }

  void _collectSegments(List<_GroupNode> nodes, List<_GridSegment> out) {
    for (final node in nodes) {
      out.add(_GridSegment.header(node));
      if (!_isExpanded(node.path)) continue;
      if (node.children.isEmpty) {
        for (final row in node.rows) {
          out.add(_GridSegment.row(row));
        }
      } else {
        _collectSegments(node.children, out);
      }
    }
  }

  /// Partitions [rows] by the [DsDataGrid.groupBy] key at [depth], preserving
  /// first-seen order, and recurses into the next key to build subgroups.
  List<_GroupNode> _groupLevel(
    List<DsGridRow> rows,
    int depth,
    String parentPath,
  ) {
    final key = widget.groupBy[depth];
    final column = _columnForKey(key);
    final order = <String>[];
    final buckets = <String, List<DsGridRow>>{};
    final raws = <String, Object?>{};
    for (final row in rows) {
      final raw = row.cells[key];
      final bucketKey = _groupBucketKey(raw);
      final existing = buckets[bucketKey];
      if (existing == null) {
        buckets[bucketKey] = <DsGridRow>[row];
        raws[bucketKey] = raw;
        order.add(bucketKey);
      } else {
        existing.add(row);
      }
    }
    final nodes = <_GroupNode>[];
    for (final bucketKey in order) {
      final path =
          parentPath.isEmpty ? bucketKey : '$parentPath $bucketKey';
      final groupRows = buckets[bucketKey]!;
      final children = depth + 1 < widget.groupBy.length
          ? _groupLevel(groupRows, depth + 1, path)
          : const <_GroupNode>[];
      nodes.add(_GroupNode(
        path: path,
        depth: depth,
        label: _groupLabel(column, raws[bucketKey]),
        rows: groupRows,
        children: children,
      ));
    }
    return nodes;
  }

  /// A stable partition key for a raw group value. A null or empty value shares
  /// one "Ungrouped" bucket; dates and lists get canonical string keys so equal
  /// values group together.
  String _groupBucketKey(Object? raw) {
    final string = _asString(raw);
    if (raw == null || (string != null && string.isEmpty)) {
      return ' ungrouped';
    }
    if (raw is DateTime) return 'date:${raw.toIso8601String()}';
    if (raw is List) {
      return 'list:${raw.map((e) => e?.toString() ?? '').join('')}';
    }
    return 'val:$raw';
  }

  /// The display label for a group, resolving select and status values through
  /// [DsGridColumn.options] and reading a null / empty value as "Ungrouped".
  String _groupLabel(DsGridColumn? column, Object? raw) {
    final string = _asString(raw);
    if (raw == null || (string != null && string.isEmpty)) return 'Ungrouped';
    if (column != null &&
        string != null &&
        (column.type == DsCellType.singleSelect ||
            column.type == DsCellType.status ||
            column.type == DsCellType.multiSelect)) {
      final option = _optionFor(column, string);
      if (option != null) return option.effectiveLabel;
    }
    return _groupValueText(column, raw);
  }

  /// A readable string for a group value, formatting dates, currency and numbers
  /// the way their cells render and falling back to the raw value's text.
  String _groupValueText(DsGridColumn? column, Object? raw) {
    final type = column?.type;
    if (type == DsCellType.date) {
      final date = _asDate(raw);
      if (date != null) return _formatDate(date);
    } else if (type == DsCellType.currency) {
      final number = _asNum(raw);
      if (number != null) {
        return '${column!.currencySymbol ?? r'$'}'
            '${_formatNumber(number, decimals: 2)}';
      }
    } else if (type == DsCellType.number) {
      final number = _asNum(raw);
      if (number != null) return _formatNumber(number);
    } else if (type == DsCellType.multiSelect) {
      final list = _asStringList(raw);
      if (list != null) {
        return [
          for (final item in list)
            _optionFor(column!, item)?.effectiveLabel ?? item,
        ].join(', ');
      }
    }
    final string = _asString(raw);
    if (string != null) return string;
    return raw?.toString() ?? '';
  }

  /// Computes an aggregation's display text over a group's [rows], or null when
  /// there is nothing to show (no aggregation, or no numeric value for the
  /// numeric aggregations).
  String? _aggregationLabel(
    DsGridColumn column,
    DsAggregation aggregation,
    List<DsGridRow> rows,
  ) {
    switch (aggregation) {
      case DsAggregation.none:
        return null;
      case DsAggregation.count:
        var count = 0;
        for (final row in rows) {
          if (row.cells[column.key] != null) count++;
        }
        return _formatNumber(count);
      case DsAggregation.sum:
      case DsAggregation.average:
      case DsAggregation.min:
      case DsAggregation.max:
        final values = <num>[];
        for (final row in rows) {
          final number = _asNum(row.cells[column.key]);
          if (number != null) values.add(number);
        }
        if (values.isEmpty) return null;
        final num result;
        if (aggregation == DsAggregation.sum) {
          result = values.reduce((a, b) => a + b);
        } else if (aggregation == DsAggregation.average) {
          result = values.reduce((a, b) => a + b) / values.length;
        } else if (aggregation == DsAggregation.min) {
          result = values.reduce(math.min);
        } else {
          result = values.reduce(math.max);
        }
        return _formatAggregationValue(column, aggregation, result);
    }
  }

  /// Formats a numeric aggregation [value] to match its column: currency keeps
  /// its symbol and two decimals, an average shows up to two decimals, and every
  /// other case uses the grid's grouped number formatting.
  String _formatAggregationValue(
    DsGridColumn column,
    DsAggregation aggregation,
    num value,
  ) {
    if (column.type == DsCellType.currency) {
      final symbol = column.currencySymbol ?? r'$';
      return '$symbol${_formatNumber(value, decimals: 2)}';
    }
    // A progress column stores a 0..1 fraction rendered as a percentage in its
    // cells; its aggregate must read the same way, not as a raw fraction.
    if (column.type == DsCellType.progress) {
      return '${(value.clamp(0, 1) * 100).round()}%';
    }
    if (aggregation == DsAggregation.average &&
        value != value.roundToDouble()) {
      return _formatNumber(value, decimals: 2);
    }
    return _formatNumber(value);
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
    final sortIndex =
        _activeSorts.indexWhere((s) => s.columnKey == column.key);
    final active = sortIndex == -1 ? null : _activeSorts[sortIndex];
    final index = _displayColumns.indexOf(column);
    final title = _titleFor(column);
    final managed = _viewManaged;

    // The inline header-label editor replaces the whole cell while active.
    if (managed && _editingHeaderKey == column.key) {
      return SizedBox(
        width: width,
        height: _headerHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _cellPaddingX,
            vertical: DsSpacing.xs,
          ),
          child: _CellTextEditor(
            key: ValueKey<String>('header ${column.key}'),
            tokens: tokens,
            dense: true,
            align: align,
            initialText: title,
            keyboardType: TextInputType.text,
            semanticsLabel: 'Edit label for ${column.title}',
            onCommit: (text) => _commitHeaderLabel(column, text),
            onCancel: () => setState(() => _editingHeaderKey = null),
          ),
        ),
      );
    }

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
            DsTextTransform.uppercase.apply(title),
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
            icon: active.ascending ? DsIcons.arrowUp : DsIcons.arrowDown,
            size: DsIconSize.xs,
            color: tokens.colorSecondaryText,
          ),
          // A tie-break rule shows its precedence beside the arrow.
          if (sortIndex > 0)
            Text(
              '${sortIndex + 1}',
              style: tokens.labelSm
                  .toTextStyle(color: tokens.colorSecondaryText),
            ),
        ],
      ],
    );

    final padded = Padding(
      // The managed header reserves trailing room for the column-menu
      // trigger so the title never sits beneath it.
      padding: EdgeInsetsDirectional.only(
        start: _cellPaddingX,
        end: managed ? _cellPaddingX + 20 : _cellPaddingX,
      ),
      child: row,
    );

    final sortState = active == null
        ? 'not sorted'
        : '${active.ascending ? 'sorted ascending' : 'sorted descending'}'
            '${_activeSorts.length > 1 ? ', sort ${sortIndex + 1} of ${_activeSorts.length}' : ''}';

    final Widget content = column.sortable
        ? Semantics(
            button: true,
            sortKey: OrdinalSortKey(index.toDouble()),
            label: '$title, $sortState',
            child: InkWell(onTap: () => _onHeaderTap(column), child: padded),
          )
        : Semantics(
            header: true,
            sortKey: OrdinalSortKey(index.toDouble()),
            label: title,
            child: padded,
          );

    final resizable = widget.resizableColumns && column.resizable;

    Widget cell = SizedBox(
      width: width,
      height: _headerHeight,
      child: Stack(
        children: [
          Positioned.fill(child: content),
          if (managed)
            PositionedDirectional(
              top: 0,
              bottom: 0,
              end: _resizeHandleWidth,
              child: Center(
                child: Semantics(
                  button: true,
                  label: 'Column options for $title',
                  child: Builder(
                    builder: (context) => InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => _openHeaderMenu(context, column),
                      child: Padding(
                        padding: const EdgeInsets.all(DsSpacing.xxs),
                        child: DsIcon(
                          icon: DsIcons.expandMore,
                          size: DsIconSize.xs,
                          color: tokens.colorSecondaryText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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

    if (!managed) return cell;

    // Long-press lifts the header for drag-to-reorder; the column menu's
    // move actions cover keyboard and assistive users.
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data != column.key,
      onAcceptWithDetails: (details) => _reorderColumn(details.data, column),
      builder: (context, candidates, rejected) => DecoratedBox(
        decoration: BoxDecoration(
          color: candidates.isNotEmpty
              ? tokens.brandTintColor
              : const Color(0x00000000),
        ),
        child: LongPressDraggable<String>(
          data: column.key,
          feedback: Material(
            color: const Color(0x00000000),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.formBackgroundColor,
                borderRadius: BorderRadius.circular(tokens.formBorderRadius),
                border: Border.all(color: tokens.colorBorder),
                boxShadow: tokens.shadowMedium,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DsSpacing.md,
                  vertical: DsSpacing.sm,
                ),
                child: Text(
                  DsTextTransform.uppercase.apply(title),
                  style: tokens.headingXs
                      .toTextStyle(color: tokens.colorSecondaryText),
                ),
              ),
            ),
          ),
          child: cell,
        ),
      ),
    );
  }

  /// The trailing "+" header cell that restores hidden columns.
  Widget _addColumnCell(DsTokens tokens) {
    return SizedBox(
      width: _addColumnWidth,
      height: _headerHeight,
      child: Semantics(
        button: true,
        label: 'Add column',
        child: Builder(
          builder: (context) => InkWell(
            onTap: () => _openAddColumnMenu(context),
            child: Center(
              child: DsIcon(
                icon: DsIcons.add,
                size: DsIconSize.sm,
                color: tokens.colorSecondaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The trailing per-row overflow menu. An empty action list leaves the slot
  /// blank so every row stays aligned; the trigger is a labelled, keyboard
  /// reachable button naming its row's actions.
  Widget _rowActionsCell(DsTokens tokens, DsGridRow row) {
    final actions = widget.rowActions?.call(row) ?? const <DsRowAction>[];
    if (actions.isEmpty) {
      return SizedBox(width: _actionsColumnWidth, height: _rowHeight);
    }
    return SizedBox(
      width: _actionsColumnWidth,
      height: _rowHeight,
      child: Center(
        child: DsMenu(
          items: <DsMenuItem>[
            for (final action in actions)
              DsMenuItem(
                label: action.label,
                icon: action.icon,
                destructive: action.destructive,
                onSelected: action.onSelected,
                enabled: action.onSelected != null,
              ),
          ],
          trigger: DsIcon(
            icon: DsIcons.moreHorizontal,
            size: DsIconSize.sm,
            color: tokens.colorSecondaryText,
            semanticLabel: 'Row actions',
          ),
        ),
      ),
    );
  }

  /// The calculations footer band: per-column aggregation slots aligned under
  /// the columns, mirroring the header's frozen/scrolling split. On a managed
  /// view every slot is a button opening the calculation picker.
  Widget _buildFooter(
    DsTokens tokens,
    List<DsGridRow> rows,
    List<DsGridColumn> pinnedColumns,
    List<DsGridColumn> scrollableColumns,
    double pinnedWidth,
    bool hasPinned,
    double scrollContentWidth,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.offsetBackgroundColor,
        border: Border(top: BorderSide(color: tokens.colorBorder)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          height: _rowHeight,
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
                        const SizedBox(width: _selectionColumnWidth),
                      for (final column in pinnedColumns)
                        _footerCell(tokens, column, rows),
                    ],
                  ),
                ),
              if (hasPinned) _seam(tokens),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = math.max(
                      scrollContentWidth + _trailingAddWidth + _rowActionsWidth,
                      constraints.maxWidth,
                    );
                    return SingleChildScrollView(
                      controller: _footerHController,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        width: width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final column in scrollableColumns)
                              _footerCell(tokens, column, rows),
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

  /// One slot in the calculations footer: the aggregation's name and value
  /// aligned like the column's cells, an add affordance when the managed slot
  /// is empty, or a blank spacer on a read-only view.
  Widget _footerCell(DsTokens tokens, DsGridColumn column, List<DsGridRow> rows) {
    final aggregation = widget.view?.calculations[column.key];
    final managed = _viewManaged;
    final title = _titleFor(column);

    final Widget content;
    final String? semanticsLabel;
    if (aggregation != null && aggregation != DsAggregation.none) {
      final value = _aggregationLabel(column, aggregation, rows) ?? '—';
      final name = _aggregationName(aggregation);
      semanticsLabel = '$name of $title: $value';
      content = Row(
        mainAxisAlignment: _mainAxisOf(column.effectiveAlign),
        children: [
          Flexible(
            child: Text(
              DsTextTransform.uppercase.apply(name),
              style:
                  tokens.headingXs.toTextStyle(color: tokens.colorSecondaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: DsSpacing.xs),
          Text(
            value,
            style: tokens.labelSm.toTextStyle(color: tokens.colorText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else if (managed) {
      semanticsLabel = 'Add calculation for $title';
      content = Align(
        alignment: _alignmentOf(column.effectiveAlign),
        child: DsIcon(
          icon: DsIcons.add,
          size: DsIconSize.xs,
          color: tokens.colorSecondaryText
              .withValues(alpha: tokens.stateDisabledIconOpacity),
        ),
      );
    } else {
      return SizedBox(width: _columnWidth(column), height: _rowHeight);
    }

    final cell = Padding(
      padding: EdgeInsets.symmetric(horizontal: _cellPaddingX),
      child: Center(child: content),
    );

    return SizedBox(
      width: _columnWidth(column),
      height: _rowHeight,
      child: managed
          ? Semantics(
              button: true,
              label: semanticsLabel,
              child: Builder(
                builder: (context) => InkWell(
                  onTap: () => _openAggregationMenu(context, column),
                  child: cell,
                ),
              ),
            )
          : Semantics(
              container: true,
              label: semanticsLabel,
              child: ExcludeSemantics(child: cell),
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
      height: _rowHeight,
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
          height: _rowHeight,
          child: Center(
            child: _GridCheck(value: selected, size: _checkboxSize),
          ),
        ),
      ),
    );
  }

  Widget _dataCell(DsTokens tokens, DsGridColumn column, DsGridRow row) {
    final align = column.effectiveAlign;
    final width = _columnWidth(column);

    // A cell being edited fills its padding with the inline text editor.
    if (_isEditingCell(row, column)) {
      return SizedBox(
        width: width,
        height: _rowHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _cellPaddingX,
            vertical: DsSpacing.xs,
          ),
          child: _inlineEditor(tokens, column, row, dense: true, align: align),
        ),
      );
    }

    final editable = _isCellEditable(column);

    // Editable ratings are interactive in place (per-star), so they carry no
    // whole-cell tap affordance.
    final Widget content = editable && column.type == DsCellType.rating
        ? _ratingRowInteractive(tokens, column, row, dense: true)
        : _cellContent(
            tokens,
            column,
            row,
            dense: true,
            align: align,
            tooltip: column.statusTooltip?.call(row),
          );

    final bool focused = _isCellFocused(row, column);
    final bool inRange = _anchorRow != null && _isCellInRange(row, column);

    Widget cell = SizedBox(
      width: width,
      height: _rowHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: inRange ? tokens.brandTintColor : null,
          border: focused
              ? Border.all(
                  color: tokens.formAccentColor,
                  width: tokens.focusRingWidth,
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _cellPaddingX),
          child: Align(alignment: _alignmentOf(align), child: content),
        ),
      ),
    );

    if (editable && column.type != DsCellType.rating) {
      cell = _wrapEditable(tokens, column, row, cell);
    }
    return cell;
  }

  // --- Cell renderers -------------------------------------------------------

  /// Builds the value shown in a stacked-card row, honouring edit state: the
  /// inline editor when editing, an interactive star row for an editable
  /// rating, or the read-only content wrapped in a tap-to-edit affordance.
  Widget _cardValue(DsTokens tokens, DsGridColumn column, DsGridRow row) {
    if (_isEditingCell(row, column)) {
      return _inlineEditor(
        tokens,
        column,
        row,
        dense: false,
        align: DsColumnAlign.end,
      );
    }
    final editable = _isCellEditable(column);
    if (editable && column.type == DsCellType.rating) {
      return Align(
        alignment: Alignment.centerRight,
        child: _ratingRowInteractive(tokens, column, row, dense: false),
      );
    }
    final display = Align(
      alignment: Alignment.centerRight,
      child: _cellContent(
        tokens,
        column,
        row,
        dense: false,
        align: DsColumnAlign.end,
        tooltip: column.statusTooltip?.call(row),
      ),
    );
    if (!editable) return display;
    return _wrapEditable(tokens, column, row, display);
  }

  /// Wraps a read-only cell [child] in a tap-to-edit affordance: an [InkWell]
  /// with a hover / pressed state and a semantics button labelled for the
  /// column, whose tap opens the appropriate editor for the cell type.
  Widget _wrapEditable(
    DsTokens tokens,
    DsGridColumn column,
    DsGridRow row,
    Widget child,
  ) {
    final bool? checked = column.type == DsCellType.checkbox
        ? (_asBool(row.cells[column.key]) ?? false)
        : null;
    // A checkbox conveys its value via `checked`; every other type announces
    // the current value through `value` so it is spoken on the control itself.
    final String? value =
        checked == null ? _editSemanticValue(column, row) : null;
    return Builder(
      builder: (context) => Semantics(
        button: true,
        checked: checked,
        label: 'Edit ${column.title}',
        value: value,
        // The visual content is excluded so its value is announced once (via
        // `value`), not duplicated by a nested badge/avatar node; the activate
        // action is wired here so the button works for screen readers too.
        onTap: () => _beginEdit(context, column, row),
        child: ExcludeSemantics(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => _beginEdit(context, column, row),
              borderRadius: BorderRadius.circular(tokens.formBorderRadius),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// The inline text editor used for the text, number, currency, link and user
  /// cell types. Numbers and currency values are edited as their raw number
  /// (no grouping or symbol).
  Widget _inlineEditor(
    DsTokens tokens,
    DsGridColumn column,
    DsGridRow row, {
    required bool dense,
    required DsColumnAlign align,
  }) {
    final value = row.cells[column.key];
    final String initial;
    final TextInputType keyboardType;
    if (column.type == DsCellType.number ||
        column.type == DsCellType.currency) {
      final number = _asNum(value);
      initial = number == null ? '' : _plainNumberText(number);
      keyboardType =
          const TextInputType.numberWithOptions(decimal: true, signed: true);
    } else {
      initial = _asString(value) ?? '';
      keyboardType = TextInputType.text;
    }
    return _CellTextEditor(
      key: ValueKey<String>('${row.id} ${column.key}'),
      tokens: tokens,
      dense: dense,
      align: align,
      initialText: initial,
      keyboardType: keyboardType,
      semanticsLabel: 'Edit ${column.title}',
      onCommit: (text) => _commitInline(column, row, text),
      onCancel: () => _cancelEditFor(row.id, column.key),
    );
  }

  /// An interactive five-star row for an editable [DsCellType.rating] cell.
  /// Tapping a star sets the rating to that many stars; tapping the current
  /// highest star clears it back by one, giving a way to reach zero.
  Widget _ratingRowInteractive(
    DsTokens tokens,
    DsGridColumn column,
    DsGridRow row, {
    required bool dense,
  }) {
    final current = (_asNum(row.cells[column.key]) ?? 0).clamp(0, 5).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Semantics(
            button: true,
            label: 'Set ${column.title} to ${i + 1}',
            child: InkWell(
              onTap: () => _emit(row, column, current == i + 1 ? i : i + 1),
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                child: DsIcon(
                  icon: i < current ? DsIcons.star : DsIcons.starOutline,
                  size: DsIconSize.sm,
                  color: i < current ? tokens.colorPrimary : tokens.colorBorder,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// A single row in a select / multi-select overlay menu. In [multi] mode a
  /// leading checkbox glyph shows the staged state; otherwise a trailing check
  /// marks the current value.
  Widget _optionRow(
    DsTokens tokens, {
    required DsGridOption option,
    required bool selected,
    required bool multi,
    required bool autofocus,
    required VoidCallback onTap,
  }) {
    final swatch = _optionSwatch(tokens, option);
    return InkWell(
      onTap: onTap,
      autofocus: autofocus,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DsSpacing.md,
            vertical: DsSpacing.sm,
          ),
          child: Row(
            children: [
              if (multi) ...[
                _GridCheck(value: selected, size: _checkboxSize),
                const SizedBox(width: DsSpacing.sm),
              ] else if (swatch != null) ...[
                _swatchDot(swatch),
                const SizedBox(width: DsSpacing.sm),
              ],
              Expanded(
                child: Text(
                  option.effectiveLabel,
                  style: tokens.bodyMd.toTextStyle(color: tokens.colorText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!multi && selected) ...[
                const SizedBox(width: DsSpacing.sm),
                DsIcon(
                  icon: DsIcons.check,
                  size: DsIconSize.sm,
                  color: tokens.formAccentColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Renders a single select / status / multi-select [value] as a badge,
  /// resolving its label and colour through [DsGridColumn.options] when a
  /// matching option exists and falling back to [fallbackVariant] otherwise.
  Widget _optionBadge(
    DsTokens tokens,
    DsGridColumn column,
    String value, {
    required DsBadgeVariant fallbackVariant,
  }) {
    final option = _optionFor(column, value);
    final label = option?.effectiveLabel ?? value;
    final color = option?.color;
    if (color != null) return _colorBadge(tokens, label, color);
    return DsBadge(label: label, variant: option?.variant ?? fallbackVariant);
  }

  Widget _cellContent(
    DsTokens tokens,
    DsGridColumn column,
    DsGridRow row, {
    required bool dense,
    required DsColumnAlign align,
    String? tooltip,
  }) {
    final Object? value = row.cells[column.key];
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

    final cellBuilder = column.cellBuilder;
    if (cellBuilder != null) {
      final built = cellBuilder(context, value, row);
      // The dense (table) layout clips overflow rather than letting a tall or
      // wide custom cell break row alignment. The scroll view is inert, so it
      // does not steal drags from a control inside the cell.
      return dense ? _guarded(built) : built;
    }

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
        if (string == null || string.isEmpty) return emDash;
        final badge = _optionBadge(
          tokens,
          column,
          string,
          fallbackVariant: _variantForStatus(string),
        );
        final tip = tooltip;
        if (tip == null || tip.isEmpty) return badge;
        // The reason behind the state is never pointer-only: the tooltip
        // text also joins the cell's announced label.
        return Tooltip(
          message: tip,
          child: Semantics(
            label: '$string, $tip',
            excludeSemantics: true,
            child: badge,
          ),
        );
      case DsCellType.multiSelect:
        final list = _asStringList(value);
        if (list == null || list.isEmpty) return emDash;
        if (!dense) {
          return Wrap(
            spacing: DsSpacing.xs,
            runSpacing: DsSpacing.xs,
            alignment:
                align == DsColumnAlign.end ? WrapAlignment.end : WrapAlignment.start,
            children: [
              for (final item in list)
                _optionBadge(
                  tokens,
                  column,
                  item,
                  fallbackVariant: DsBadgeVariant.neutral,
                ),
            ],
          );
        }
        return _guarded(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < list.length; i++) ...[
                if (i > 0) const SizedBox(width: DsSpacing.xs),
                _optionBadge(
                  tokens,
                  column,
                  list[i],
                  fallbackVariant: DsBadgeVariant.neutral,
                ),
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
              icon: i < filled ? DsIcons.star : DsIcons.starOutline,
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

// --- Grouping model ---------------------------------------------------------

/// One node in the grid's group tree: a group (or subgroup) at a given [depth],
/// its resolved display [label], the [rows] it contains (recursively) and its
/// [children] subgroups (empty at the innermost grouping level).
///
/// [path] is a stable, unique key identifying this group within the tree; the
/// grid uses it to remember collapse state across rebuilds.
@immutable
class _GroupNode {
  const _GroupNode({
    required this.path,
    required this.depth,
    required this.label,
    required this.rows,
    required this.children,
  });

  final String path;
  final int depth;
  final String label;
  final List<DsGridRow> rows;
  final List<_GroupNode> children;
}

/// A single item in the flattened render sequence of a grouped body: either a
/// group header band ([group] set) or a data row ([row] set). Exactly one of the
/// two is non-null, which lets both the frozen and scrolling panes walk the same
/// ordered list and stay row-aligned.
@immutable
class _GridSegment {
  const _GridSegment.header(_GroupNode this.group) : row = null;
  const _GridSegment.row(DsGridRow this.row) : group = null;

  final _GroupNode? group;
  final DsGridRow? row;
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

/// Formats [value] as a plain, ungrouped string suitable for inline editing: an
/// integer keeps no decimals and a whole double drops its trailing `.0`.
String _plainNumberText(num value) {
  if (value is int) return value.toString();
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toString();
}

/// Parses editable numeric input, tolerating grouping commas and surrounding
/// whitespace. Returns null (a revert) when the field is empty or unparseable.
num? _parseEditableNumber(String raw) {
  final cleaned = raw.trim().replaceAll(',', '');
  if (cleaned.isEmpty) return null;
  return num.tryParse(cleaned);
}

/// The swatch colour for [option] in a menu row: its explicit colour, else a
/// representative colour derived from its badge variant, else null.
Color? _optionSwatch(DsTokens tokens, DsGridOption option) {
  if (option.color != null) return option.color;
  return switch (option.variant) {
    DsBadgeVariant.success => tokens.badgeSuccessColorText,
    DsBadgeVariant.warning => tokens.badgeWarningColorText,
    DsBadgeVariant.danger => tokens.badgeDangerColorText,
    DsBadgeVariant.info => tokens.badgeInfoColorText,
    DsBadgeVariant.neutral => tokens.badgeNeutralColorText,
    null => null,
  };
}

/// A small round colour swatch used in option menus and colour badges.
Widget _swatchDot(Color color) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

/// A badge for a select / status value that carries an explicit swatch [color],
/// drawn as a tinted pill with a leading dot rather than one of the shared
/// [DsBadge] variants.
Widget _colorBadge(DsTokens tokens, String label, Color color) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(tokens.badgeBorderRadius),
      border: Border.all(color: color.withValues(alpha: 0.5)),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.badgePaddingX,
        vertical: tokens.badgePaddingY,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _swatchDot(color),
          SizedBox(width: tokens.badgePaddingX),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: tokens.colorText,
                fontSize: tokens.badgeLabelFontSize,
                fontWeight: tokens.badgeLabelFontWeight,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

/// The themed floating surface shared by the select and multi-select menus,
/// mirroring [DsMenu]'s panel: a form-background fill, a 1px border, the overlay
/// corner radius and a medium drop shadow.
Widget _overlaySurface(DsTokens tokens, Widget child) {
  final radius = BorderRadius.circular(tokens.overlayBorderRadius);
  return Material(
    type: MaterialType.transparency,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        borderRadius: radius,
        border: Border.all(color: tokens.colorBorder),
        boxShadow: DsElevation.medium,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DsSpacing.xs),
            child: child,
          ),
        ),
      ),
    ),
  );
}

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
          ? const Icon(DsIcons.check, size: DsIconSize.xs, color: Colors.white)
          : indeterminate
              ? const Icon(
                  DsIcons.remove,
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

/// The inline text field shown while editing a text, number, currency, link or
/// user cell.
///
/// It autofocuses and traps keyboard focus, commits on Enter or when focus is
/// lost while it is still mounted, and cancels on Escape. A single guard makes
/// sure a value is committed or cancelled exactly once, and the focus listener
/// is removed before disposal so tearing the editor down cannot fire a stray
/// commit.
class _CellTextEditor extends StatefulWidget {
  const _CellTextEditor({
    super.key,
    required this.tokens,
    required this.dense,
    required this.align,
    required this.initialText,
    required this.keyboardType,
    required this.semanticsLabel,
    required this.onCommit,
    required this.onCancel,
  });

  final DsTokens tokens;
  final bool dense;
  final DsColumnAlign align;
  final String initialText;
  final TextInputType keyboardType;
  final String semanticsLabel;
  final ValueChanged<String> onCommit;
  final VoidCallback onCancel;

  @override
  State<_CellTextEditor> createState() => _CellTextEditorState();
}

class _CellTextEditorState extends State<_CellTextEditor> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);
  final FocusNode _focusNode = FocusNode();
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    // Remove the listener first so tearing the editor down (for example when
    // another cell begins editing) does not fire a stray commit.
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _commit() {
    if (_handled) return;
    _handled = true;
    widget.onCommit(_controller.text);
  }

  void _cancel() {
    if (_handled) return;
    _handled = true;
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final radius = BorderRadius.circular(tokens.formBorderRadius);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: tokens.colorBorder),
    );
    return Semantics(
      label: widget.semanticsLabel,
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): _cancel,
        },
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          keyboardType: widget.keyboardType,
          textAlign: _textAlignOf(widget.align),
          textAlignVertical: TextAlignVertical.center,
          cursorColor: tokens.formAccentColor,
          style: (widget.dense ? tokens.bodySm : tokens.bodyMd)
              .toTextStyle(color: tokens.colorText),
          onSubmitted: (_) => _commit(),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: tokens.formBackgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DsSpacing.sm,
              vertical: DsSpacing.xs,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: tokens.formHighlightColorBorder),
            ),
          ),
        ),
      ),
    );
  }
}

/// The full-screen layer that hosts an open select / multi-select menu: a
/// transparent barrier that dismisses on an outside tap, plus the [child] panel
/// positioned just beneath the tapped cell and clamped within the overlay.
/// Escape dismisses the menu and taps inside the panel are absorbed.
class _AnchoredOverlay extends StatelessWidget {
  const _AnchoredOverlay({
    required this.anchorOffset,
    required this.anchorSize,
    required this.overlaySize,
    required this.onDismiss,
    required this.child,
  });

  final Offset anchorOffset;
  final Size anchorSize;
  final Size overlaySize;
  final VoidCallback onDismiss;
  final Widget child;

  static const double _margin = DsSpacing.sm;
  static const double _maxWidth = 320;

  @override
  Widget build(BuildContext context) {
    final double top = anchorOffset.dy + anchorSize.height + DsSpacing.xxs;
    final double maxLeft =
        math.max(_margin, overlaySize.width - _maxWidth - _margin);
    final double left = anchorOffset.dx.clamp(_margin, maxLeft);
    final double maxHeight = math.max(120.0, overlaySize.height - top - _margin);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        Positioned(
          left: left,
          top: top.clamp(
            _margin,
            math.max(_margin, overlaySize.height - _margin),
          ),
          child: CallbackShortcuts(
            bindings: <ShortcutActivator, VoidCallback>{
              const SingleActivator(LogicalKeyboardKey.escape): onDismiss,
            },
            child: FocusScope(
              child: GestureDetector(
                // Absorb taps on the panel so they never reach the barrier.
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: math.min(anchorSize.width, _maxWidth),
                    maxWidth: _maxWidth,
                    maxHeight: maxHeight,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The checkable menu shown while editing a [DsCellType.multiSelect] cell.
///
/// The selection is staged locally so toggling options does not commit until
/// "Done" is chosen; Escape or an outside tap cancels via the enclosing
/// [_AnchoredOverlay].
class _MultiSelectOverlayPanel extends StatefulWidget {
  const _MultiSelectOverlayPanel({
    required this.tokens,
    required this.options,
    required this.initialSelected,
    required this.onCommit,
  });

  final DsTokens tokens;
  final List<DsGridOption> options;
  final Set<String> initialSelected;
  final ValueChanged<List<String>> onCommit;

  @override
  State<_MultiSelectOverlayPanel> createState() =>
      _MultiSelectOverlayPanelState();
}

class _MultiSelectOverlayPanelState extends State<_MultiSelectOverlayPanel> {
  late final Set<String> _selected = <String>{...widget.initialSelected};

  void _toggle(String value) {
    setState(() {
      if (!_selected.add(value)) _selected.remove(value);
    });
  }

  List<String> _ordered() {
    final known = {for (final option in widget.options) option.value};
    return [
      // Declared options first, in their display order…
      for (final option in widget.options)
        if (_selected.contains(option.value)) option.value,
      // …then any staged value not in the option set, preserved rather than
      // silently dropped (e.g. a legacy tag the column no longer declares).
      for (final value in _selected)
        if (!known.contains(value)) value,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    return _overlaySurface(
      tokens,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < widget.options.length; i++)
            _row(tokens, widget.options[i], autofocus: i == 0),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: tokens.colorBorder)),
            ),
            child: InkWell(
              onTap: () => widget.onCommit(_ordered()),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Center(
                  child: Text(
                    'Done',
                    style: tokens.labelMd.toTextStyle(
                      color: tokens.actionPrimaryColorText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(DsTokens tokens, DsGridOption option, {required bool autofocus}) {
    final selected = _selected.contains(option.value);
    return InkWell(
      onTap: () => _toggle(option.value),
      autofocus: autofocus,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DsSpacing.md,
            vertical: DsSpacing.sm,
          ),
          child: Row(
            children: [
              _GridCheck(
                value: selected,
                size: _DsDataGridState._checkboxSize,
              ),
              const SizedBox(width: DsSpacing.sm),
              Expanded(
                child: Text(
                  option.effectiveLabel,
                  style: tokens.bodyMd.toTextStyle(color: tokens.colorText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
