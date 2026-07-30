# Icon badge

An icon badge is a small tinted circle holding a single icon: a tick beside a finished step, a warning mark on a task that needs attention, a lock ahead of a security row. `DsIconBadge` colours the circle and the glyph from a named tone, each mapping onto an existing token pair, so the mark re-skins with the active theme.

The badge is decorative by default and hidden from assistive technology, on the expectation that the neighbouring label carries the meaning. When the mark stands alone, pass a semantic label so it is announced. The tones are primary, success, warning, danger and neutral; explicit colour overrides exist for the rare pairing the tones do not cover.

The mark is a circle by default, which reads as a status: a step's tick, a warning dot beside a row. Pass `DsIconBadgeShape.rounded` for the rounded square that reads as a launcher tile instead, which is what a shortcut a thumb aims at wants. The rounded mark takes the theme's `radiusControl`, so a skin that softens or sharpens its controls carries the mark with them.

## Guidelines

**Do**

- Pick the tone that matches the state: success for done, danger for failed.
- Let the neighbouring label carry the meaning and keep the mark decorative.
- Give a standalone mark a semantic label so it is announced.

**Don't**

- Don't use it as a button; it has no tap handling and no 48dp target.
- Don't override the tone colours when a preset fits.
- Don't crowd one row with marks in several tones at once.

## Example

```dart
const DsIconBadge(
  icon: DsIcons.check,
  tone: DsIconBadgeTone.success,
  semanticLabel: 'Completed',
);
```

## See also

- [Communicating state](communicating-state.md)
- [Progress stepping](progress-stepping.md)
- [Setup guide](setup-guide.md)
