# Status bar

A status bar closes the chrome frame along the bottom edge: a slim, hairline-topped strip carrying a quiet label on one side and ambient widgets on the other. Use `DsStatusBar` for footer chrome such as an environment name, a developers strip or quick links, and keep primary actions out of it; anything the user must do belongs in the content or the top bar. The app shell takes one through its `statusBar` slot.

The bar reads its fill, hairline and type from the theme tokens. Set `transparent` to drop the fill and hairline when it sits over a decorated backdrop and only its content should show. Purely decorative trailing runs should be excluded from semantics by the caller so screen readers skip them.

## Guidelines

**Do**

- Keep the copy ambient: an environment, a version, a channel.
- Use the leading glyph to give the strip a quiet identity.
- Set `transparent` when the bar overlays a decorated surface.

**Don't**

- Don't put primary actions in the status bar.
- Don't let the label wrap; it ellipsizes to keep the strip slim.
- Don't stack status bars; one strip closes the frame.

## Example

```dart
DsStatusBar(
  icon: DsIcons.terminal,
  label: 'Developers',
  trailing: [Text('v1.0')],
);
```

## See also

- [App shell](app-shell.md)
- [Full-page layouts](full-page-layouts.md)
