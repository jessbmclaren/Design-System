// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Display → Summary section.
final PatternPage summarySectionPage = PatternPage(
  id: 'summary-section',
  group: DocGroup.display,
  navTitle: 'Summary section',
  title: 'Summary section',
  description:
      'A summary section reads back what the user entered, with a way to go '
      'change it. It is the shape a review step takes before a flow commits: '
      'the title names the step, the edit link returns to it, and the body '
      'holds the values.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'Keeping the edit affordance beside the title, rather than after the '
      'values, means a user scanning a review always finds the way back in '
      'the same place. The link announces what it edits, so a screen reader '
      'moving between sections never meets a row of identical Edit links.',
    ),
  ],
  dos: const [
    'Name the section exactly as the step that collected it.',
    'Return the user to that step, with their answers still in place.',
    'Drop the edit link for anything that cannot be changed from here.',
  ],
  donts: const [
    'Don\'t re-collect values in the summary; it reads back, it does not ask.',
    'Don\'t hide a value the user gave; a review that omits things is not a review.',
  ],
  code: '''
DsSummarySection(
  title: 'Business details',
  onEdit: () => goToStep(1),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text('Northwind Traders'),
      Text('Registered 2019'),
    ],
  ),
);
''',
  related: const ['business-verification', 'onboarding-wizard', 'lists'],
);
