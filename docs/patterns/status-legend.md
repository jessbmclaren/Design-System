# Status legend

`DsStatusLegend` is a key that explains what each status badge in a table means. Statuses carry meaning by colour and word ("Ready", "Needs attention"), and a legend keeps that meaning discoverable instead of tribal: each `DsStatusLegendEntry` renders its badge beside a plain-language description, with the badges aligned in a scannable rail and the descriptions free to wrap. Reach for it wherever a data surface introduces status vocabulary a newcomer could not guess — a roster footer, an onboarding aside, a report header.

## Guidelines

**Do**

- Use the exact labels and badge variants the table itself renders, so the key and the cells stay in lockstep.
- Write each description as one short, plain-language sentence about what the status means for the person reading it.
- Keep the legend near the data it explains — a footer under the grid, not a help-centre article three clicks away.

**Don't**

- Don't restate the label as its own description ("Ready — the driver is ready"); say what the status implies and what to do about it.
- Don't use the legend as a filter; it is explanatory, and segments or filter controls do the narrowing.
- Don't document statuses the surface never shows; a legend mirrors the live vocabulary, not the full state machine.

## Example

```dart
DsStatusLegend(
  title: 'Statuses explained',
  entries: const [
    DsStatusLegendEntry(
      label: 'Ready',
      description: 'Fully compliant and available to take trips.',
      variant: DsBadgeVariant.success,
    ),
    DsStatusLegendEntry(
      label: 'Needs attention',
      description: 'A document is missing or about to expire.',
      variant: DsBadgeVariant.warning,
    ),
    DsStatusLegendEntry(
      label: 'Deactivated',
      description: 'Removed from the roster and cannot be assigned.',
      variant: DsBadgeVariant.danger,
    ),
  ],
)
```

## See also

- [Roster view](roster-view.md)
- [Communicating state](communicating-state.md)
- [Data grid](data-grid.md)
