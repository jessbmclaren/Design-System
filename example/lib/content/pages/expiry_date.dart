// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Display → Expiry date.
final PatternPage expiryDatePage = PatternPage(
  id: 'expiry-date',
  group: DocGroup.display,
  navTitle: 'Expiry date',
  title: 'Expiry date',
  description:
      '`DsExpiryDate` pairs an absolute calendar date ("7 Jan 2027") with a '
      'relative hint ("in 6 months") that turns urgent as the date approaches. '
      'Once the date falls within `urgentWithin` — or has passed — the hint '
      'switches to the danger colour and reads "expired 3 days ago", so an '
      'expiring licence, permit or document flags itself without anyone doing '
      'the mental arithmetic. Reach for it wherever a deadline needs to read '
      'at a glance: a licence column in a roster, a compliance card, a record '
      'panel. The hint is computed against `now`, which defaults to the wall '
      'clock.',
  hasLiveDemo: true,
  dos: const [
    'Always pass a fixed `now` in tests, demos and screenshots so the relative '
        'hint renders deterministically instead of drifting with the wall clock.',
    'Set `dense: true` inside table cells so the compact type sits within a '
        'standard row height.',
    'Tune `urgentWithin` to the window in which your process can still act on '
        'the expiry; the default is 90 days.',
    'Let the hint text carry the urgency — it does so in words as well as '
        'colour, which is what keeps the state accessible.',
  ],
  donts: const [
    "Don't format the date yourself; `DsExpiryDate.formatDate` keeps the "
        'day-first "7 Jan 2027" format consistent across the system.',
    "Don't use it for dates that are not deadlines (a created-at timestamp "
        'has nothing to count down to).',
    "Don't hide the component once a date has passed; the \"expired … ago\" "
        'reading is exactly the moment it earns its place.',
  ],
  code: '''
DsExpiryDate(
  date: DateTime(2027, 1, 7),
  now: DateTime(2026, 7, 22), // fixed clock → deterministic tests
)

DsExpiryDate(
  date: DateTime(2026, 8, 30),
  now: DateTime(2026, 7, 22),
  urgentWithin: const Duration(days: 90),
  dense: true, // compact type for table cells
)
''',
  related: const ['date-field', 'roster-view', 'data-grid'],
);
