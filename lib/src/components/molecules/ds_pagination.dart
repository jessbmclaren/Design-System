import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';
import 'ds_select.dart';

/// A table footer that reports the visible range and moves between pages.
///
/// Controlled: the caller owns [page] (1-based) and applies [onPageChanged] /
/// [onPageSizeChanged] to its own state. Prev and Next disable themselves at
/// the edges, and the whole control collapses gracefully at narrow widths by
/// wrapping — the range label, the pager and the page-size select each stay on
/// their own line when they no longer fit side by side.
///
/// When [totalItems] and [pageSize] are provided the leading label reads
/// '1–25 of 103'; otherwise it falls back to 'Page 2 of 5'.
class DsPagination extends StatelessWidget {
  /// Creates a pagination control.
  ///
  /// [page] is 1-based and must be within 1..[pageCount]. [pageCount] must be
  /// at least 1. A null [onPageChanged] disables both pager buttons.
  const DsPagination({
    super.key,
    required this.page,
    required this.pageCount,
    this.onPageChanged,
    this.totalItems,
    this.pageSize,
    this.pageSizeOptions = const [10, 25, 50, 100],
    this.onPageSizeChanged,
  })  : assert(pageCount >= 1, 'pageCount must be at least 1'),
        assert(
          page >= 1 && page <= pageCount,
          'page must be within 1..pageCount',
        );

  /// The current page, 1-based.
  final int page;

  /// How many pages there are in total. At least 1.
  final int pageCount;

  /// Called with the new page when Prev or Next is pressed. Null disables the
  /// pager.
  final ValueChanged<int>? onPageChanged;

  /// The total number of items across all pages, used for the range label.
  final int? totalItems;

  /// How many items each page holds, used for the range label and the
  /// page-size select.
  final int? pageSize;

  /// The choices offered by the page-size select.
  final List<int> pageSizeOptions;

  /// Called with the new page size. When null (or [pageSize] is null) the
  /// page-size select is not shown.
  final ValueChanged<int>? onPageSizeChanged;

  String _rangeLabel() {
    final total = totalItems;
    final size = pageSize;
    if (total != null && size != null) {
      if (total == 0) return '0 of 0';
      final start = (page - 1) * size + 1;
      final end = (page * size) < total ? page * size : total;
      return '$start–$end of $total';
    }
    return 'Page $page of $pageCount';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final canGoBack = onPageChanged != null && page > 1;
    final canGoForward = onPageChanged != null && page < pageCount;

    // A Wrap rather than a Row so the pager can break across lines instead of
    // overflowing when a narrow phone (or large text) leaves it short of room.
    final pager = Wrap(
      spacing: DsSpacing.sm,
      runSpacing: DsSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DsButton(
          label: 'Prev',
          icon: DsIcons.arrowBack,
          variant: DsButtonVariant.tertiary,
          onPressed: canGoBack ? () => onPageChanged!(page - 1) : null,
        ),
        Semantics(
          label: 'Page $page of $pageCount',
          container: true,
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DsSpacing.md,
                vertical: DsSpacing.xs,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: tokens.colorBorder),
                borderRadius: BorderRadius.circular(tokens.borderRadius),
              ),
              child: Text(
                '$page',
                style: tokens.labelMd.toTextStyle(color: tokens.colorText),
              ),
            ),
          ),
        ),
        DsButton(
          label: 'Next',
          trailingIcon: DsIcons.arrowForward,
          variant: DsButtonVariant.tertiary,
          onPressed: canGoForward ? () => onPageChanged!(page + 1) : null,
        ),
      ],
    );

    final showSizeSelect = pageSize != null && onPageSizeChanged != null;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DsSpacing.lg,
      runSpacing: DsSpacing.sm,
      children: [
        Text(
          _rangeLabel(),
          style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
        ),
        pager,
        if (showSizeSelect)
          SizedBox(
            width: 132,
            child: DsSelect<int>(
              value: pageSize,
              options: [
                for (final size in pageSizeOptions)
                  DsSelectOption(value: size, label: '$size / page'),
              ],
              onChanged: (size) {
                if (size != null) onPageSizeChanged!(size);
              },
            ),
          ),
      ],
    );
  }
}
