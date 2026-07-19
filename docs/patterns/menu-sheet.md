# Menu sheet

A menu sheet presents choices as a modal bottom sheet, where they are easiest to reach one-handed. `DsMenuSheet` is the thumb-zone counterpart to the anchored menu: the same rows of icon, label and callback, slid up from the bottom edge behind a grab handle. Use it on compact widths where a popover would be cramped or land under a thumb, for example for the navigation destinations behind the app shell's menu trigger. Present it with `DsMenuSheet.show`, which styles the sheet, its corners and its barrier from the active theme.

Mark the current choice with `selected` and it renders on the brand tint with its state announced to assistive technology. Choosing a row closes the sheet first and then runs the row's callback, so a navigation that rebuilds the tree never races the closing sheet. Each row is at least 48dp tall and keyboard-focusable, and the sheet scrolls when the destinations outgrow the viewport.

## Guidelines

**Do**

- Reach for the sheet below the medium breakpoint and an anchored `DsMenu` above it.
- Mark the current destination with `selected` so the user can see where they are.
- Keep rows to a single line; long labels ellipsize.
- Mark irreversible choices with `destructive` so they render in the danger colour.

**Don't**

- Don't nest a sheet inside another modal surface.
- Don't use the sheet for more than one level of choices; it is a flat list.
- Don't put forms or free text into a menu sheet; it presents choices.

## Example

```dart
DsMenuSheet.show(
  context,
  items: [
    DsMenuSheetItem(
      label: 'Home',
      icon: DsIcons.home,
      selected: true,
      onSelected: goHome,
    ),
    DsMenuSheetItem(
      label: 'Statements',
      icon: DsIcons.fileText,
      onSelected: goStatements,
    ),
  ],
);
```

## See also

- [Menu](menu.md)
- [App shell](app-shell.md)
