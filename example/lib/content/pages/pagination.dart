// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Data → Pagination.
final PatternPage paginationPage = PatternPage(
  id: 'pagination',
  group: DocGroup.data,
  navTitle: 'Pagination',
  title: 'Pagination',
  description:
      '`DsPagination` is the table footer that reports the visible range '
      '("1–25 of 103") and moves between pages with Prev / Next and an '
      'optional page-size select. It is fully controlled: the caller owns the '
      '1-based `page` and applies `onPageChanged` / `onPageSizeChanged` to its '
      'own state, then re-slices the rows it hands the grid. Prev and Next '
      'disable themselves at the edges, and at narrow widths the range label, '
      'the pager and the page-size select each wrap onto their own line '
      'instead of overflowing. Reach for it beneath any `DsDataGrid` or '
      '`DsRosterView` whose collection is too large to show at once.',
  hasLiveDemo: true,
  dos: const [
    'Own the page state: apply the new page from `onPageChanged` and slice '
        'the rows yourself — the control never mutates anything.',
    'Provide `totalItems` and `pageSize` so the leading label reads '
        '"1–25 of 103" rather than falling back to "Page 1 of 5".',
    'Reset to page 1 whenever the page size or an upstream filter changes, so '
        'the visible range never points past the data.',
    'Place it directly beneath the grid it pages, where the range label reads '
        'as a caption for the rows above it.',
  ],
  donts: const [
    "Don't hide Prev or Next at the edges; the control already disables them "
        'and keeps the layout stable.',
    "Don't compose your own range label above the grid; the pagination row is "
        'the single source of "where am I" truth.',
    "Don't show the page-size select when the caller cannot honour it — omit "
        '`onPageSizeChanged` and it disappears.',
  ],
  code: '''
DsPagination(
  page: page, // 1-based, owned by you
  pageCount: (totalItems / pageSize).ceil(),
  totalItems: totalItems,
  pageSize: pageSize,
  onPageChanged: (next) => setState(() => page = next),
  onPageSizeChanged: (size) => setState(() {
    pageSize = size;
    page = 1; // never point past the data
  }),
)
''',
  related: const ['data-grid', 'roster-view', 'filtering-sorting'],
);
