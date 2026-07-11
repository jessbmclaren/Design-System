// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Feedback → Verification rail.
final PatternPage verificationRailPage = PatternPage(
  id: 'verification-rail',
  group: DocGroup.feedback,
  navTitle: 'Verification rail',
  title: 'Verification rail',
  description:
      'A verification rail shows where the user is inside a sectioned flow, '
      'such as a business-verification takeover: the sections run top to '
      'bottom, each with a circular marker and a label. `DsVerificationRail` '
      'marks a done section with a check, numbers the active and upcoming '
      'ones and expands the active section\'s optional sub-steps into a '
      'dotted list. The caller owns every section\'s state and updates it as '
      'the flow advances; with an `onSectionSelected` callback, done sections '
      'become tappable so the user can jump back.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'The rail watches its own width and swaps to a compact horizontal '
      'summary when it drops below the breakpoint: the section markers in a '
      'row with the active section\'s label alongside. The compact form is '
      'informational only, so keep Back and Continue actions in the flow '
      'itself on small screens. Each section announces its label, position '
      'and state to assistive technology.',
    ),
  ],
  dos: const [
    'Keep the rail to a handful of sections with short labels; it is a map, '
        'not a table of contents.',
    'Mirror real screens: every section and sub-step should correspond to a '
        'step the user will actually see.',
    'Let users jump back to done sections through `onSectionSelected` so '
        'revisiting an answer never means starting over.',
    'Update the section states from the flow\'s own source of truth; the '
        'rail renders state, it does not own it.',
  ],
  donts: const [
    'Don\'t make active or upcoming sections tappable; skipping ahead '
        'bypasses the flow\'s gating.',
    'Don\'t show sub-steps on every section at once; only the active '
        'section expands, keeping the rail scannable.',
    'Don\'t use the rail for a short linear wizard; the progress stepper '
        'already covers that.',
  ],
  code: '''
DsVerificationRail(
  sections: const [
    DsVerificationSection(
      label: 'Business',
      state: DsVerificationSectionState.done,
    ),
    DsVerificationSection(
      label: 'Identity',
      state: DsVerificationSectionState.active,
      subSteps: ['Your details', 'Your document'],
    ),
    DsVerificationSection(label: 'Review'),
  ],
  activeSubStep: 0,
  onSectionSelected: (index) => _jumpTo(index),
);
''',
  related: ['progress-stepping', 'business-verification', 'onboarding-wizard'],
);
