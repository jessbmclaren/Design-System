# Task view

A task view gives one job its own page: enter, do the job, leave. `DsTaskView` is the frame between the page scaffold, which has no pinned actions, and the onboarding wizard, which leads with a stepper. It carries a bordered header with a back affordance, the title and an optional subtitle, an optional banner beneath it, the body centred in a readable column, and the actions pinned along the bottom edge where a thumb reaches them.

The header grows with the user's text scale rather than clipping, the body is capped at `maxBodyWidth` and scrolls unless the body owns its own scrolling, and the footer is `DsFooterActions`: the actions sit in a row on a wide page and stack full-width, primary first, on a narrow one. The pinned footer respects the safe area and the keyboard inset, so a focused field is never hidden beneath it.

## Guidelines

**Do**

- Give the page one job and name it in the title.
- Use the subtitle for context such as a step counter.
- Pass `DsIcons.close` as the back glyph when the task dismisses rather than returns.
- Set `scrollable: false` when the body is itself a list or a grid.

**Don't**

- Don't stack several jobs on one task view; give each its own page.
- Don't put the primary action in the body; the footer is where it lives.
- Don't nest a task view inside another scrolling page.

## Example

```dart
DsTaskView(
  title: 'Add a vehicle',
  subtitle: 'Step 2 of 3',
  onBack: () => Navigator.of(context).maybePop(),
  banner: const DsBanner(
    variant: DsBannerVariant.info,
    title: 'Draft saved a moment ago',
  ),
  body: const VehicleForm(),
  primaryLabel: 'Save vehicle',
  onPrimary: saveVehicle,
  secondaryLabel: 'Save draft',
  onSecondary: saveDraft,
);
```

## See also

- [Full-page layouts](full-page-layouts.md)
- [Footer actions](footer-actions.md)
- [App shell](app-shell.md)
