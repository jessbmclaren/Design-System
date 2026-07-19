# Table views

A table view is a saved way of looking at the same records: which columns show, in what order, under what labels, sorted how, with which column-bottom calculations. `DsGridView` captures that configuration as plain data the caller owns. Pass one to `DsDataGrid.view` and the grid renders it; add `onViewChanged` and the grid grows its management surface, so users shape the view directly in the table and every change comes back to you as a new value to store.

With `onViewChanged` set, each header gains a column menu (sort ascending or descending, move, edit label, hide), headers reorder by long-press drag with the menu's move actions covering keyboard and assistive users, a trailing add-column affordance restores hidden columns and a footer band holds the calculations: count for any column, sum, average, min and max for numeric ones. Relabelling is display-only; the underlying column and its data key never change.

Sorting is precedence-ordered: `sorts` holds the rules first rule first, and each later rule breaks the ties of the ones before it. A header tap rewrites the primary rule and keeps the tie-breaks, while tie-break columns show their precedence beside the arrow. Edit the whole list with `DsSortBuilder`, or drop a `DsSortPill` into the toolbar above the grid: it reads `Sorted by Amount +1` and opens the builder in place.

The grid never stores a view itself. Persisting views, naming them and switching between them belongs to the application: hold a list of `DsGridView` values, show the active one, and compose a switcher from `DsTabs` or `DsMenu`. Passing a view without `onViewChanged` renders it read-only, which is how a shared or locked view ships.

## Guidelines

**Do**

- Store the emitted view and pass it straight back; the grid renders only what you give it.
- Give saved views meaningful names in your switcher, such as `Overdue accounts`.
- Use display relabels for context, such as shortening `Organisation legal name` to `Organisation`.
- Ship locked or shared views by passing the view without `onViewChanged`.

**Don't**

- Don't mutate a view in place; emit and store new values so equality and undo stay trivial.
- Don't hide every column; the grid refuses to hide the last one.
- Don't use relabels to change meaning; they restyle the header, not the data.

## Example

```dart
DsDataGrid(
  columns: columns,
  rows: rows,
  view: activeView,
  onViewChanged: (next) => setState(() => activeView = next),
);

// A saved view is plain data:
const overdue = DsGridView(
  visibleColumns: ['driver', 'amount', 'status'],
  columnLabels: {'driver': 'Account holder'},
  sorts: [
    DsGridSort(columnKey: 'amount', ascending: false),
    DsGridSort(columnKey: 'driver'),
  ],
  calculations: {'amount': DsAggregation.sum},
);

// The toolbar pill above the grid:
DsSortPill(
  columns: columns,
  sorts: activeView.sorts,
  onChanged: (next) => setState(() => activeView =
      activeView.copyWith(sorts: next, sort: next.isEmpty ? null : next.first)),
);
```

## See also

- [Data grid](data-grid.md)
- [Cell types & editing](cell-types.md)
- [Grouping](grouping.md)
- [Filtering & sorting](filtering-sorting.md)
