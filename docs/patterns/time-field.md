# Time field

A time field collects the hour a thing happens, as the date field collects the day: a window opens, a report runs, a shift starts. `DsTimeField` opens the platform time picker and is controlled, holding no time of its own.

The control mirrors the date field exactly, so the two sit together in a form without a seam: the same fill, border, caption and tap target, and the whole control opens the picker rather than only its glyph. There is nothing to type, so a stored time is always a real time.

The value is formatted through the platform localisations, so it follows the user's locale and their 12- or 24-hour preference rather than a pattern chosen by the system.

## Guidelines

**Do**

- Pair it with a date field when a moment needs both halves.
- Use the helper text for the rule, such as the hours a window may cover.
- Keep the stored value as a time of day; formatting belongs to display.

**Don't**

- Don't format the time yourself; the locale already decides.
- Don't use a text field for a time; typed times are half-valid at best.

## Example

```dart
DsTimeField(
  label: 'Opens at',
  value: opensAt,
  helperText: 'Deliveries can only be booked inside opening hours.',
  onChanged: (time) => setState(() => opensAt = time),
);
```

## See also

- [Date field](date-field.md)
- [Text fields](text-fields.md)
- [Form field group](form-field-group.md)
