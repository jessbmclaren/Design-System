# Wordmark

`DsWordmark` sets a product name as two-tone text: a `primary` part in a lighter weight followed by an optional `accent` part in a heavier weight, for example "acme" then "id". The family and colour come from the active theme, so the mark re-skins alongside the rest of the system; the two weights are fixed. The name itself is content rather than a token, so you pass the parts in. Screen readers read the whole mark as one name.

## Guidelines

**Do**

- Pass the product name as content, and keep one source for it so a rebrand updates every mark at once.
- Use `accent` to give the second part of the name a heavier weight when the brand splits into two tones.
- Set `fontSize` to suit the slot, for example a larger mark on a marketing header and a smaller one in an app bar.
- Let the mark take its colour from the theme, and set `color` only when it must sit on a fixed background.

**Don't**

- Don't rebuild the wordmark as an image or a hardcoded style; the component keeps it in step with the theme.
- Don't split a one-word brand into `primary` and `accent` where the two tones carry no meaning.
- Don't restyle the family or weights by hand; they belong to the type ramp.
- Don't place the mark on a background that fails the AA contrast check against its colour.

## Example

```dart
Row(
  children: const [
    // Two-tone: a lighter primary and a heavier accent.
    DsWordmark(primary: 'acme', accent: 'id'),
    SizedBox(width: 32),
    // Single tone, larger, for a marketing header.
    DsWordmark(primary: 'acme', fontSize: 28),
  ],
);
```

## See also

- [Design tokens](design-tokens.md)
