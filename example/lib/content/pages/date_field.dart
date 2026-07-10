// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Forms → Date field.
final PatternPage dateFieldPage = PatternPage(
  id: 'date-field',
  group: DocGroup.inputs,
  navTitle: 'Date field',
  title: 'Date field',
  description:
      'The date field collects a single calendar date without the ambiguity of '
      'free-form typing. `DsDateField` presents a read-only, text-field-shaped '
      'control (persistent label, filled surface, trailing calendar glyph) '
      'that shows the selected date as `yyyy-MM-dd` or a placeholder hint while '
      'empty. Tapping opens the platform date picker, themed to inherit the '
      'design system, bounded by `firstDate` and `lastDate`; the confirmed date '
      'is returned through `onChanged`. Because entry is picker-only the value '
      'is always a valid `DateTime`, so `helperText` and `errorText` carry '
      'guidance and validation exactly as they do on the text field.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Constrain the calendar to the dates that make sense: set `firstDate` and '
      '`lastDate` so a due date cannot land in the past or a birthday in the '
      'future. Keep the `label` visible and let `hintText` show the expected '
      'shape rather than repeat the label. Use `helperText` to explain a '
      'constraint before the user acts, and swap to `errorText` only after a '
      'selection has been made and found invalid. The two never appear '
      'together. Passing a `null` `onChanged`, or `enabled: false`, dims the '
      'control and blocks the picker.',
    ),
  ],
  dos: const [
    'Bound the picker with firstDate and lastDate so only valid dates can be chosen.',
    'Keep a visible label so the field\'s purpose survives once a date is filled in.',
    'Use hintText to show the expected value and helperText to explain any constraint.',
    'Reserve errorText for validation after a selection, never alongside helperText.',
    'Disable the field with enabled: false (or a null onChanged) when a date cannot yet be picked.',
  ],
  donts: const [
    "Don't ask people to type dates free-form when a bounded calendar removes the guesswork.",
    "Don't rely on the hint as the label. It vanishes the moment a date is selected.",
    "Don't show an error before the user has picked anything.",
    "Don't leave firstDate and lastDate unset for domain dates that have a natural range.",
  ],
  code: '''
DsDateField(
  label: 'Start date',
  value: _startDate,
  hintText: 'Select a date',
  helperText: 'Billing begins on this date.',
  firstDate: DateTime(2024),
  lastDate: DateTime(2027),
  onChanged: (date) => setState(() => _startDate = date),
)
''',
  shots: const [
    Shot(pageId: 'date-field', size: ShotSize.desktop),
    Shot(pageId: 'date-field', size: ShotSize.phone),
  ],
  related: const ['text-fields', 'select'],
);
