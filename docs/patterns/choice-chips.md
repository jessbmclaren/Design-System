# Choice chips

A choice chip is a small selectable pill, and a chip group is a set of them. Reach for them where a handful of short choices read better inline than as a column of checkboxes: days of the week, capabilities, tags. `DsChoiceChip` is the interactive counterpart to the static `DsChip`.

A selected chip carries the brand tint, the brand ink and a leading check, so the state survives a colour-blind reading rather than resting on hue. Each chip is a checkbox to assistive technology, reporting its state and activating on Enter and Space, and its target meets the accessible minimum while the pill stays visually compact.

`DsChipGroup` reports the whole selection on every toggle, as a new set rather than the one it was handed, so a caller comparing values always sees the change. An `errorText` renders beneath the chips for a group that must not be left empty.

## Guidelines

**Do**

- Use a group for a handful of options; a select handles a long list better.
- Keep labels to a word or two so the row keeps its rhythm.
- Give a chip `onRemoved` when it represents something the user added.

**Don't**

- Don't use chips for one exclusive choice; that is a segmented control or radio set.
- Don't mutate the set you were given; apply the one the group reports.
- Don't rely on the tint alone to show selection; the check is part of the contract.

## Example

```dart
DsChipGroup<String>(
  options: const [
    DsChipOption(value: 'mon', label: 'Monday'),
    DsChipOption(value: 'tue', label: 'Tuesday'),
    DsChipOption(value: 'wed', label: 'Wednesday'),
  ],
  selected: days,
  onChanged: (next) => setState(() => days = next),
  errorText: days.isEmpty ? 'Choose at least one day' : null,
);
```

## See also

- [Selection controls](selection-controls.md)
- [Segmented control](segmented-control.md)
- [Filter controls](filter-controls.md)
