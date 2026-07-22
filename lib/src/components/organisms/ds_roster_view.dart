import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_segmented_control.dart';
import '../molecules/ds_page_header.dart';
import '../molecules/ds_search_field.dart';
import 'ds_data_grid.dart';

/// A quick status filter shown in a [DsRosterView] toolbar.
///
/// Segments carry an optional [count] ('Needs attention · 2') so the toolbar
/// doubles as a health summary of the roster.
@immutable
class DsRosterSegment {
  /// Creates a filter segment.
  const DsRosterSegment({required this.value, required this.label, this.count});

  /// The stable identifier reported through [DsRosterView.onSegmentChanged].
  final String value;

  /// The segment's visible name, e.g. 'All drivers'.
  final String label;

  /// An optional record count appended to the label.
  final int? count;
}

/// A full roster-management surface: header, filters, search, data grid,
/// pagination and guidance, with room for a detail panel alongside.
///
/// This organism arranges the parts of a records screen — a [DsPageHeader]
/// with the caller's [headerActions], a toolbar of segment filters and search,
/// a [DsDataGrid] over [columns] and [rows], a [pagination] slot beneath the
/// grid and a [footer] slot for guidance such as a [DsImportGuide] or
/// [DsStatusLegend]. It stays controlled throughout: filtering, searching,
/// sorting, selection and paging all live with the caller, which passes the
/// already-prepared rows.
///
/// When [detail] is set (typically a [DsRecordPanel] for the focused record)
/// it docks to the trailing edge on expanded windows. On compact and medium
/// windows it replaces the roster as a takeover until the caller clears it —
/// close affordances belong to the detail widget itself.
///
/// The grid needs bounded height, so the roster gives it [tableHeight] and the
/// whole organism can sit inside any scrolling page.
class DsRosterView extends StatelessWidget {
  /// Creates a roster view.
  const DsRosterView({
    super.key,
    required this.title,
    this.subtitle,
    this.headerActions = const [],
    this.countLabel,
    this.segments = const [],
    this.segmentValue,
    this.onSegmentChanged,
    this.searchHint = 'Search…',
    this.searchController,
    this.onSearchChanged,
    this.toolbarActions = const [],
    required this.columns,
    required this.rows,
    this.selectable = false,
    this.selectedRowIds,
    this.onSelectionChanged,
    this.sort,
    this.onSort,
    this.emptyState,
    this.pagination,
    this.footer,
    this.detail,
    this.detailWidth = 380,
    this.tableHeight = 480,
  });

  /// The page title, e.g. 'Drivers'.
  final String title;

  /// The sentence under the title describing the collection.
  final String? subtitle;

  /// Actions docked to the header's trailing edge — an add button, an import
  /// menu, an overflow menu.
  final List<Widget> headerActions;

  /// A bold record count leading the toolbar, e.g. '12 drivers'.
  final String? countLabel;

  /// Quick filters over the roster. Hidden when empty.
  final List<DsRosterSegment> segments;

  /// The selected segment's [DsRosterSegment.value]. Must match one of
  /// [segments] when they are provided.
  final String? segmentValue;

  /// Called with the picked segment value. Null disables the segments.
  final ValueChanged<String>? onSegmentChanged;

  /// Placeholder text for the search field.
  final String searchHint;

  /// Optional controller for the search field, when the caller needs to set
  /// or clear the query programmatically.
  final TextEditingController? searchController;

  /// Called as the search query changes. Null hides the search field.
  final ValueChanged<String>? onSearchChanged;

  /// Trailing toolbar controls — filter, group, sort, field pickers.
  final List<Widget> toolbarActions;

  /// The grid's column definitions.
  final List<DsGridColumn> columns;

  /// The rows to display, already filtered, sorted and paged by the caller.
  final List<DsGridRow> rows;

  /// Whether rows can be selected with checkboxes.
  final bool selectable;

  /// The selected row ids, when [selectable].
  final Set<String>? selectedRowIds;

  /// Called with the new selection, when [selectable].
  final ValueChanged<Set<String>>? onSelectionChanged;

  /// The current sort, owned by the caller.
  final DsGridSort? sort;

  /// Called when a sortable header is tapped.
  final ValueChanged<DsGridSort?>? onSort;

  /// Shown inside the grid area when [rows] is empty.
  final Widget? emptyState;

  /// The pager under the grid, typically a [DsPagination].
  final Widget? pagination;

  /// Guidance under the table, typically a row of [DsImportGuide],
  /// [DsStatusLegend] and related help.
  final Widget? footer;

  /// The focused record's panel. Docked alongside on expanded windows,
  /// a takeover on smaller ones.
  final Widget? detail;

  /// The docked [detail] panel's width on expanded windows.
  final double detailWidth;

  /// The bounded height given to the grid (and the docked detail panel).
  final double tableHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final expanded =
            DsBreakpoints.windowSizeFor(width) >= DsWindowSize.expanded;

        if (detail != null && !expanded) {
          // Small windows cannot hold the roster and a panel side by side, so
          // the open record takes over until the caller clears [detail].
          return SizedBox(height: tableHeight, child: detail);
        }

        final roster = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DsPageHeader(
              title: title,
              subtitle: subtitle,
              actions: headerActions,
            ),
            const SizedBox(height: DsSpacing.lg),
            _toolbar(tokens, width),
            const SizedBox(height: DsSpacing.lg),
            SizedBox(
              height: tableHeight,
              child: DsDataGrid(
                columns: columns,
                rows: rows,
                selectable: selectable,
                selectedRowIds: selectedRowIds,
                onSelectionChanged: onSelectionChanged,
                sort: sort,
                onSort: onSort,
                emptyState: emptyState,
              ),
            ),
            if (pagination != null) ...[
              const SizedBox(height: DsSpacing.md),
              pagination!,
            ],
            if (footer != null) ...[
              const SizedBox(height: DsSpacing.xl),
              Divider(height: 1, thickness: 1, color: tokens.colorBorderSubtle),
              const SizedBox(height: DsSpacing.xl),
              footer!,
            ],
          ],
        );

        if (detail == null) return roster;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: roster),
            const SizedBox(width: DsSpacing.lg),
            SizedBox(width: detailWidth, height: tableHeight, child: detail),
          ],
        );
      },
    );
  }

  Widget _toolbar(DsTokens tokens, double width) {
    final compact = width < DsBreakpoints.medium;
    final searchField = onSearchChanged == null
        ? null
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? width : 320),
            child: DsSearchField(
              hintText: searchHint,
              controller: searchController,
              onChanged: onSearchChanged,
            ),
          );

    return Wrap(
      spacing: DsSpacing.lg,
      runSpacing: DsSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (countLabel != null)
          Text(
            countLabel!,
            style: tokens.labelMd
                .toTextStyle(color: tokens.colorText)
                .copyWith(fontWeight: tokens.strongLabelFontWeight),
          ),
        if (segments.length >= 2)
          // The segment track lays out as a row, so at very narrow widths it
          // pans rather than overflowing.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DsSegmentedControl<String>(
              segments: [
                for (final segment in segments)
                  DsSegment(
                    value: segment.value,
                    label: segment.count == null
                        ? segment.label
                        : '${segment.label}  ${segment.count}',
                  ),
              ],
              value: segmentValue ?? segments.first.value,
              onChanged: onSegmentChanged,
            ),
          ),
        ?searchField,
        if (toolbarActions.isNotEmpty)
          Wrap(
            spacing: DsSpacing.sm,
            runSpacing: DsSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: toolbarActions,
          ),
      ],
    );
  }
}
