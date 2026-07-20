# Dialog and sheet

A dialog holds a decision that must be answered before the page continues. `DsDialog` centres any body on a themed surface over a dimmed barrier, capped at a readable width, with its actions along the bottom edge. `DsModalSheet` is the thumb-zone counterpart: the same content on a top-rounded surface rising from the bottom edge, with a grab handle and an optional pinned action row. Both are presented by a static `show` and return the value they are popped with.

The same decision reads as a centred dialog on a desktop and a sheet in the thumb zone on a phone. `showDsDialogOrSheet` makes that switch for you at the medium breakpoint, so a screen does not re-write the rule each time. Both surfaces close before running a chosen action, so a navigation that rebuilds the tree never races the closing barrier, and both dismiss on the barrier or Escape.

For a flat list of choices reach for `DsMenu` or `DsMenuSheet` instead: those present options, while these carry arbitrary content.

## Guidelines

**Do**

- Reach for `showDsDialogOrSheet` when the same decision serves phone and desktop.
- Name the decision in the title and put the consequence in the body.
- Pop with a value so the caller learns what the user chose.
- Mark an irreversible action with the danger button variant.

**Don't**

- Don't use a dialog for a whole task; that is what the task view is for.
- Don't stack a dialog over a sheet; one modal layer at a time.
- Don't hide the only way forward behind a dismissible barrier.

## Example

```dart
Future<void> confirmDelete(BuildContext context) async {
  final confirmed = await showDsDialogOrSheet<bool>(
    context,
    title: 'Delete group?',
    body: const Text('Vehicles in this group return to Unassigned.'),
    actions: [
      DsButton(
        label: 'Cancel',
        variant: DsButtonVariant.secondary,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      DsButton(
        label: 'Delete',
        variant: DsButtonVariant.danger,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
  if (confirmed ?? false) deleteGroup();
}
```

## See also

- [Menu](menu.md)
- [Menu sheet](menu-sheet.md)
- [Takeover](takeover.md)
- [Focus view](focus-view.md)
