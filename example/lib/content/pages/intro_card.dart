// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Patterns → Intro card.
final PatternPage introCardPage = PatternPage(
  id: 'intro-card',
  group: DocGroup.patterns,
  navTitle: 'Intro card',
  title: 'Intro card',
  description:
      'An intro card introduces something the user has not met: a feature, a '
      'tour\'s opening frame, a welcome. The eyebrow says what kind of thing '
      'this is, the title says what it is, the body says why it matters, and '
      'the actions offer the way forward and the way past.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      '`DsIntroCard` is content-shaped rather than flow-shaped: it holds no '
      'steps and no state, so the same card works inside a takeover, a '
      'dialog or a page. Pair it with `DsTakeover` for the full-screen '
      'moment, and give it an `onClose` whenever the introduction can be '
      'declined.',
    ),
  ],
  dos: const [
    'Say what the thing does for the user, not what the release contains.',
    'Offer a way past whenever the introduction is not required.',
    'Keep the body to a sentence or two; a card is not documentation.',
  ],
  donts: const [
    'Don\'t use it for a multi-step flow; the wizard and task view do that.',
    'Don\'t show it again once dismissed unless something genuinely changed.',
    'Don\'t leave a card with no way out on a screen the user must pass.',
  ],
  code: '''
DsTakeover(
  background: dashboard,
  child: DsIntroCard(
    eyebrow: 'New',
    title: 'Track spend as it happens',
    body: const Text('Every transaction lands here within a minute.'),
    primaryAction: DsButton(label: 'Show me', onPressed: startTour),
    secondaryAction: DsButton(
      label: 'Not now',
      variant: DsButtonVariant.tertiary,
      onPressed: dismiss,
    ),
    onClose: dismiss,
  ),
);
''',
  related: const ['takeover', 'tour-card', 'spotlight'],
);
