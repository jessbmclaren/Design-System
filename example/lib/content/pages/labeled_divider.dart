// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Display → Labelled divider.
final PatternPage labeledDividerPage = PatternPage(
  id: 'labeled-divider',
  group: DocGroup.display,
  navTitle: 'Labelled divider',
  title: 'Labelled divider',
  description:
      '`DsLabeledDivider` draws a horizontal rule with a short label in the '
      'middle, a `DsDivider` running to each side. Use it to split a form or '
      'list into named sections without the weight of a heading, for example an '
      '"Or sign in with" separator above a set of alternative actions. The '
      'label sits in the secondary text colour and ellipsizes rather than '
      'overflowing when space runs short.',
  hasLiveDemo: false,
  dos: const [
    'Use it to separate two groups of controls that need a short caption between them.',
    'Keep the label to a few words, for example "Or" or "Or continue with".',
    'Reserve a plain `DsDivider` for the cases where the sections need no caption.',
    'Put it between sections of equal weight, so neither side reads as a heading for the other.',
  ],
  donts: const [
    'Don\'t use it as a page or section heading; a real heading carries the structure.',
    'Don\'t write a label so long it ellipsizes away its meaning.',
    'Don\'t stack several labelled dividers close together; the rules start to compete with the content.',
    'Don\'t put a full sentence in the label; it is a caption, not body text.',
  ],
  code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: const [
    // ... email and password fields ...
    DsLabeledDivider(label: 'Or sign in with'),
    SizedBox(height: 16),
    // ... a row of alternative sign-in buttons ...
  ],
);
''',
  related: const ['divider'],
);
