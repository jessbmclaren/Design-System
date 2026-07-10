// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Layout → Fade slide in.
final PatternPage fadeSlideInPage = PatternPage(
  id: 'fade-slide-in',
  group: DocGroup.layout,
  navTitle: 'Fade slide in',
  title: 'Fade slide in',
  description:
      'A fade slide in wraps content arriving on screen for the first time: '
      'the child fades in while sliding up a few pixels, then never replays. '
      '`DsFadeSlideIn` runs on the motion scale and collapses to the settled '
      'frame under reduced motion, delay included.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'Give several siblings an increasing delay, most simply from '
      '`DsMotion.stagger`, so a group reveals a beat apart instead of all at '
      'once. The child\'s semantics are exposed from the moment it mounts, '
      'so assistive technology reads the content without waiting on the '
      'choreography.',
    ),
  ],
  dos: const [
    'Wrap whole blocks, such as a card or a step, rather than single words.',
    'Stagger siblings with `DsMotion.stagger` so the reveal reads in order.',
    'Trust the defaults; the duration and curve come from the motion scale.',
  ],
  donts: const [
    'Don\'t animate content that is already on screen when it merely '
        'updates.',
    'Don\'t chain long delays; the page should settle within half a second.',
    'Don\'t hide meaning behind the entrance; screen readers get the content '
        'immediately.',
  ],
  code: '''
DsFadeSlideIn(
  delay: DsMotion.stagger(context, index),
  child: card,
);
''',
  related: ['motion', 'box'],
);
