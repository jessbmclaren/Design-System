## Unreleased

### Breaking

* `DsGridCellBuilder` now receives the row alongside the value:
  `(BuildContext, Object?, DsGridRow)`. A custom cell can therefore be
  interactive and still report *which* record it acted on. Migration: add the
  third parameter to each builder; ignore it if unused.
* A `DsGridColumn` with a `cellBuilder` no longer offers inline editing. The
  builder owns the whole cell, so a tap-to-edit wrapper would swallow the
  pointer events its own controls need. Set one or the other, not both.
* `DsDataGrid.rowHeight` is now `double?` and defaults to null, taking its
  value from the new `density`. Passing an explicit height still overrides it,
  and the default height is unchanged at 44dp.

### Added

* `DsCheckList` — a scrollable column of checkbox rows with an optional action
  row, the body shared by every "pick several from a set" surface.
* `DsCheckMenu` — that list behind a trigger, staying open while options are
  ticked. Locked options (`enabled: false`) are skipped by select-all, which is
  how a caller guarantees a selection can never empty.
* `DsGridDensity` (comfortable / cosy / compact) with the heights behind it as
  tokens, so a skin restyles every table's density at once.
* `DsTokens.checkboxSize`, read by both the `DsCheckbox` atom and every
  checkbox the data grid draws, so the two cannot drift.
* `DsRosterView` now forwards `density`, `view` and `onViewChanged` to its
  grid, so a density or column control in its toolbar actually reaches it.
* `DsIcons.densityComfortable` / `densityCosy` / `densityCompact`.
* Docs pages: Table workbench, Check list, Check menu, and Data table — which
  was public, used and tested but had never been documented.

### Fixed

* The data grid's calculations footer no longer overflows a narrow column: a
  wide total such as `SUM $1,284,900.00` now ellipsizes instead.
* The data grid's overlay surface read its shadow from the `DsElevation`
  primitive rather than `DsTokens.shadowMedium`, so a skin could not restyle
  it — and the column picker and the multi-select editor could render with
  different shadows.
* A `DsMenu` trigger announced its label and its expanded state as two separate
  semantics nodes instead of one control.

## 0.0.1

* TODO: Describe initial release.
