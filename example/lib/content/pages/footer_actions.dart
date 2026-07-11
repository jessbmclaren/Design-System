// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Actions → Footer actions.
final PatternPage footerActionsPage = PatternPage(
  id: 'footer-actions',
  group: DocGroup.actions,
  navTitle: 'Footer actions',
  title: 'Footer actions',
  description:
      'A `DsFooterActions` is the action cluster that closes a wizard step or '
      'an onboarding screen: a primary continue action, an optional quiet '
      'Back action, an optional caption such as "Step 2 of 4" and an '
      'optional low-emphasis action beneath, typically "Save and finish '
      'later". Every button is a `DsButton`, so the cluster inherits its '
      'theming, touch targets and pending spinner. Gate progress by passing '
      'a null `onPrimary` and set `primaryPending` while the step saves.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'The cluster measures its own width with a `LayoutBuilder`, not the '
      'window, so it adapts inside a narrow card as readily as on a full '
      'page. At `minRowWidth` (480dp by default) and wider the actions sit '
      'in a single row with the primary action last, on the trailing edge, '
      'and the `leading` caption pinned to the start. Below the threshold '
      'the cluster stacks with every button full-width and the primary '
      'action first, the standard mobile ordering. The tertiary action '
      'renders centred beneath the cluster in both layouts. A parent that '
      'has already made the layout decision can force a mode by passing '
      '`0` (always a row) or `double.infinity` (always stacked); '
      '`DsOnboardingWizard` builds its footer this way.',
    ),
  ],
  dos: const [
    'Give the primary action a verb that names the outcome, such as '
        '"Continue" or "Create account".',
    'Gate progress with a null onPrimary while the step is incomplete, so '
        'the user cannot submit early.',
    'Set primaryPending while the action is in flight to show a spinner and '
        'block a double submit.',
    'Keep the tertiary slot for one genuine escape hatch, such as "Save and '
        'finish later".',
    'Let the cluster measure its own width rather than branching on the '
        'window size.',
  ],
  donts: const [
    'Do not add a second primary action; one continue action per footer.',
    'Do not promote the back action; it stays a quiet tertiary or secondary '
        'button.',
    'Do not use the leading slot for another button; it is for a caption or '
        'a short note.',
    'Do not hand-roll a footer from raw buttons when this cluster fits; the '
        'ordering and stacking rules stay consistent when shared.',
  ],
  code: '''
DsFooterActions(
  backLabel: 'Back',
  onBack: () => setState(() => _step -= 1),
  primaryLabel: 'Continue',
  primaryTrailingIcon: DsIcons.arrowForward,
  onPrimary: _formComplete ? _continue : null,
  primaryPending: _saving,
  tertiaryLabel: 'Save and finish later',
  onTertiary: _saveDraft,
)
''',
  related: ['action-buttons', 'button-group', 'onboarding-wizard'],
);
