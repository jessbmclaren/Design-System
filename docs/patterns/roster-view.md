# Roster view

`DsRosterView` is a full roster-management surface: a `DsPageHeader` with the caller's actions, a toolbar of `DsRosterSegment` filters and search, a `DsDataGrid` over the caller's columns and rows, a pagination slot beneath the grid and a footer slot for guidance such as a `DsImportGuide` or `DsStatusLegend`. It stays controlled throughout — filtering, searching, sorting, selection and paging all live with the caller, which passes rows that arrive already filtered, sorted and paged. When `detail` is set (typically a `DsRecordPanel` for the focused record) it docks to the trailing edge on expanded windows and becomes a takeover on compact and medium ones. Reach for it whenever a screen manages a collection of records: drivers, vehicles, customers, sites.

The grid needs bounded height, so the roster gives it `tableHeight` and the whole organism can sit inside any scrolling page. Segments carry an optional count ("Needs attention · 2") so the toolbar doubles as a health summary of the roster, and because a row's cells and a `DsRecordPanel`'s values share the same `DsGridColumn` definitions, tapping a row opens straight into a detail panel with no translation layer.

## Guidelines

**Do**

- Hand the view rows that are already filtered, sorted and paged; the roster arranges the screen while your state prepares the data.
- Reuse the same `DsGridColumn` list for the grid and the `DsRecordPanel` detail, so a tapped row opens without a mapping layer.
- Give each segment a count so the filter bar doubles as a health summary of the collection.
- Clear `detail` from your own state when the panel closes — close affordances belong to the detail widget itself.

**Don't**

- Don't let the roster own filter, search or sort state; it is controlled end to end, and your callbacks apply every change.
- Don't wrap the grid in your own unbounded scroll area; tune `tableHeight` instead and let the page scroll around the organism.
- Don't build a second detail layout for small windows — the roster already swaps the docked panel for a takeover below the expanded breakpoint.

## Example

```dart
DsRosterView(
  title: 'Drivers',
  subtitle: 'The drivers operating your vehicles.',
  countLabel: '12 drivers',
  segments: const [
    DsRosterSegment(value: 'all', label: 'All drivers', count: 12),
    DsRosterSegment(value: 'ready', label: 'Ready', count: 10),
    DsRosterSegment(value: 'attention', label: 'Needs attention', count: 2),
  ],
  segmentValue: segment,
  onSegmentChanged: (next) => setState(() => segment = next),
  onSearchChanged: (query) => setState(() => search = query),
  columns: columns,
  rows: visibleRows, // already filtered, sorted and paged by you
  selectable: true,
  selectedRowIds: selected,
  onSelectionChanged: (next) => setState(() => selected = next),
  sort: sort,
  onSort: (next) => setState(() => sort = next),
  pagination: DsPagination(
    page: 1,
    pageCount: 1,
    totalItems: 12,
    pageSize: 25,
    onPageChanged: (next) {},
  ),
  detail: openDriver == null
      ? null
      : DsRecordPanel(
          columns: columns, // the grid's own columns, reused
          values: openDriver!,
          onChanged: (next) => setState(() => openDriver = next),
          onClose: () => setState(() => openDriver = null),
        ),
)
```

## See also

- [Data grid](data-grid.md)
- [Record panel](record-panel.md)
- [Pagination](pagination.md)
- [Status legend](status-legend.md)
- [Import guide](import-guide.md)
