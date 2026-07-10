// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Feedback → Animated ellipsis.
final PatternPage animatedEllipsisPage = PatternPage(
  id: 'animated-ellipsis',
  group: DocGroup.feedback,
  navTitle: 'Animated ellipsis',
  title: 'Animated ellipsis',
  description:
      'An animated ellipsis trails waiting copy such as "Preparing your '
      'workspace", cycling from no dots up to three and back while work is '
      'in progress. `DsAnimatedEllipsis` reserves the width of the full '
      'ellipsis up front, so the sentence it follows never shifts as dots '
      'come and go.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'Under reduced motion the dots do not cycle: the widget renders a '
      'static full ellipsis instead, so the copy still reads as ongoing. '
      'The dots change several times a second, so by default they are '
      'excluded from semantics and the sentence they trail carries the '
      'meaning. Announce progress through that text or a live region around '
      'it, never through the dots.',
    ),
  ],
  dos: const [
    'Attach it to a sentence that names what is happening.',
    'Announce progress through the surrounding text, not the dots.',
    'Swap to a progress bar once the wait becomes measurable.',
  ],
  donts: const [
    'Don\'t show it without any copy; three bare dots explain nothing.',
    'Don\'t pair it with a spinner on the same line.',
    'Don\'t leave it running after the work has finished.',
  ],
  code: '''
Text.rich(
  TextSpan(
    children: [
      const TextSpan(text: 'Preparing your workspace'),
      WidgetSpan(child: DsAnimatedEllipsis()),
    ],
  ),
);
''',
  related: ['loading', 'waiting-screens'],
);
