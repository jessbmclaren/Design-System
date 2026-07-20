# Keyboard hints

A keyboard hint is the small keycap beside an action that teaches its shortcut in place, so a user learns it while doing the thing rather than from a help page. `DsKeyHint` renders one or more caps; a button takes them directly through its `keyHint` parameter.

The hint is decorative to assistive technology by default, because the control beside it already carries the action and its name: a screen reader that announced the keycap too would say the action twice. Pass a `semanticLabel` only when the hint stands alone, such as in a shortcut reference table.

Teach only shortcuts the product actually binds, and write the keys as the platform shows them. A hint that lies is worse than no hint.

## Guidelines

**Do**

- Put the hint on the action it triggers, not in a legend elsewhere.
- List keys in press order, such as the modifier then the key.
- Keep hints to the few shortcuts worth learning.

**Don't**

- Don't show a hint for a shortcut the screen does not bind.
- Don't give the hint its own accessible name beside a labelled control.
- Don't rely on the hint alone to explain an action; the label does that.

## Example

```dart
DsButton(
  label: 'New record',
  onPressed: createRecord,
  keyHint: const ['N'],
);

// Standing alone, in a shortcut reference:
const DsKeyHint(keys: ['⌘', '↵'], semanticLabel: 'Command Enter');
```

## See also

- [Action buttons](action-buttons.md)
- [Dialog and sheet](dialog.md)
