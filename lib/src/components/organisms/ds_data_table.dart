import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_typography.dart';

/// A column definition for a [DsDataTable].
///
/// Describes the header [label] and whether the column holds [numeric] values.
/// Numeric columns are right-aligned in the wide table layout so that figures
/// line up on their trailing digit.
@immutable
class DsColumn {
  /// Creates a column with the given header [label].
  const DsColumn({required this.label, this.numeric = false});

  /// The header label shown at the top of the column.
  final String label;

  /// Whether the column holds numeric values. Numeric columns are
  /// right-aligned in the wide layout.
  final bool numeric;
}

/// A single row of data for a [DsDataTable].
///
/// [cells] must contain one string per column, in column order. Provide
/// [onTap] to make the row interactive, and set [selected] to highlight it.
@immutable
class DsDataRow {
  /// Creates a row from its [cells].
  const DsDataRow({required this.cells, this.onTap, this.selected = false});

  /// The cell values, one per column, in column order.
  final List<String> cells;

  /// Called when the row is tapped. A null callback makes the row
  /// non-interactive.
  final VoidCallback? onTap;

  /// Whether the row is highlighted as selected.
  final bool selected;
}

/// A responsive Design System data table.
///
/// [DsDataTable] adapts its layout to the available width, measured with a
/// [LayoutBuilder] (falling back to [MediaQuery] when the incoming constraints
/// are unbounded):
///
/// * **Compact** (width below [compactBreakpoint], e.g. a 320dp phone): each
///   row is rendered as a bordered "key: value" card, one cell per line with
///   the column label beside its value. This never overflows on narrow
///   screens.
/// * **Wide** (width at or above [compactBreakpoint]): a true tabular layout
///   with a header row, per-row dividers and right-aligned numeric columns.
///   The table fills the available width but scrolls horizontally when the
///   columns need more room than is available.
///
/// Use it wherever tabular data must remain readable from small phones through
/// to large desktop windows. Each [DsDataRow] may define its own `onTap` and
/// `selected` state. This widget renders statically. It runs no timers or
/// animations, so it is safe to capture in screenshots.
///
/// ## This or `DsDataGrid`?
///
/// The two are not variants of one another; they answer different questions.
///
/// [DsDataTable] **displays** a handful of rows that are already formatted.
/// Cells are plain strings, there is nothing to configure, and it is the right
/// answer for a summary block inside a larger page — a few line items under a
/// filter bar, an invoice breakdown, a comparison.
///
/// `DsDataGrid` is for **working through** records: typed cells that sort and
/// align by convention, frozen columns, selection, grouping, inline editing,
/// keyboard navigation and a calculations footer. Reach for it the moment the
/// table is the task rather than an illustration of it.
///
/// Moving between them is a rewrite of the data, not of the layout: strings
/// become a `Map` keyed by column, and each column declares a `DsCellType`.
///
/// Every [DsDataRow.cells] list is assumed to have the same length as
/// [columns].
class DsDataTable extends StatelessWidget {
  /// Creates a responsive data table.
  const DsDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.compactBreakpoint = 600,
  });

  /// The column definitions, in display order.
  final List<DsColumn> columns;

  /// The rows of data to display.
  final List<DsDataRow> rows;

  /// The width, in logical pixels, below which the compact card layout is used
  /// instead of the wide tabular layout.
  final double compactBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        if (maxWidth < compactBreakpoint) {
          return _buildCompact(context);
        }
        return _buildWide(context, maxWidth);
      },
    );
  }

  // Compact layout: one bordered card per row.
  Widget _buildCompact(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: tokens.spacingUnit),
          _CompactCard(columns: columns, row: rows[i], tokens: tokens),
        ],
      ],
    );
  }

  // Wide layout: a table whose flex columns fill the available width.
  //
  // Columns are laid out with [Expanded], so they always fit the width the
  // parent gives us. No horizontal scrolling is needed, and wrapping the
  // stretch column in an unbounded viewport would force an infinite width.
  Widget _buildWide(BuildContext context, double maxWidth) {
    final tokens = DsTokens.of(context);
    final borderSide = BorderSide(color: tokens.colorBorder);

    return SizedBox(
      width: maxWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row.
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: borderSide),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.tableRowPaddingY),
              child: Row(
                children: [
                  for (final column in columns)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.spacingUnit * 1.5,
                        ),
                        child: Text(
                          DsTextTransform.uppercase.apply(column.label),
                          textAlign: column.numeric
                              ? TextAlign.right
                              : TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: tokens.headingXs.toTextStyle(
                            color: tokens.colorSecondaryText,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Data rows.
          for (final row in rows)
            _WideRow(
              columns: columns,
              row: row,
              tokens: tokens,
              borderSide: borderSide,
            ),
        ],
      ),
    );
  }
}

/// A single data row in the wide tabular layout.
class _WideRow extends StatelessWidget {
  const _WideRow({
    required this.columns,
    required this.row,
    required this.tokens,
    required this.borderSide,
  });

  final List<DsColumn> columns;
  final DsDataRow row;
  final DsTokens tokens;
  final BorderSide borderSide;

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: row.selected ? tokens.offsetBackgroundColor : null,
        border: Border(bottom: borderSide),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.tableRowPaddingY),
        child: Row(
          children: [
            for (var i = 0; i < columns.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacingUnit * 1.5,
                  ),
                  child: Text(
                    row.cells[i],
                    textAlign:
                        columns[i].numeric ? TextAlign.right : TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: tokens.bodySm.toTextStyle(
                      color: tokens.colorText,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (row.onTap == null) {
      return content;
    }
    return InkWell(
      onTap: row.onTap,
      child: content,
    );
  }
}

/// A single row rendered as a bordered card in the compact layout.
class _CompactCard extends StatelessWidget {
  const _CompactCard({
    required this.columns,
    required this.row,
    required this.tokens,
  });

  final List<DsColumn> columns;
  final DsDataRow row;
  final DsTokens tokens;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(tokens.formBorderRadius);
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: row.selected ? tokens.offsetBackgroundColor : null,
        border: Border.all(color: tokens.colorBorder),
        borderRadius: radius,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacingUnit * 1.5,
          vertical: tokens.spacingUnit,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < columns.length; i++) ...[
              if (i > 0) SizedBox(height: tokens.spacingUnit / 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      columns[i].label,
                      overflow: TextOverflow.ellipsis,
                      style: tokens.bodySm.toTextStyle(
                        color: tokens.colorSecondaryText,
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.spacingUnit),
                  Expanded(
                    child: Text(
                      row.cells[i],
                      textAlign: TextAlign.right,
                      style: tokens.bodySm.toTextStyle(
                        color: tokens.colorText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    if (row.onTap == null) {
      return content;
    }
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: row.onTap,
        child: content,
      ),
    );
  }
}
