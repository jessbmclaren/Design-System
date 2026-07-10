// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Feedback → Progress bar.
final PatternPage progressBarPage = PatternPage(
  id: 'progress-bar',
  group: DocGroup.feedback,
  navTitle: 'Progress bar',
  title: 'Progress bar',
  description:
      '`DsProgressBar` is a thin, rounded bar that shows how much of a '
      'bounded task is complete. Pass a `value` from 0 to 1; the track and '
      'fill colours come from the theme, so the bar re-skins with the active '
      'brand. Set `animate: true` to ease the fill towards a changed value, '
      'and it settles on a still frame when the user has asked for reduced '
      'motion. For an open-ended wait with no measurable fraction, show '
      '`DsSpinner` instead.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Assistive technology announces the bar as a percentage. Give it a '
      '`semanticLabel` naming what is progressing when the bar stands alone, '
      'or set `excludeSemantics: true` when neighbouring text already states '
      'the progress (a "3 of 6" count, say) so it is not read out twice.',
    ),
  ],
  dos: const [
    'Derive the value from real progress, such as completed steps over total steps.',
    'Set animate: true when the value moves while the bar is on screen, so a change reads as progress rather than a jump.',
    'Name the work with semanticLabel when no nearby text does.',
    'Keep the default static fill for screenshots and goldens; it is deterministic.',
  ],
  donts: const [
    'Don\'t use it for an unbounded wait; that is DsSpinner\'s job.',
    'Don\'t pair it with a count or percentage derived from different state; the two must never disagree.',
    'Don\'t stack bars to compare quantities; that is a chart, use DsBarChart.',
    'Don\'t announce both the bar and a visible count; exclude one from semantics.',
  ],
  code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('\$done of \$total tasks complete'),
    const SizedBox(height: 8),
    DsProgressBar(
      value: done / total,
      animate: true,
      // The count above already states the progress.
      excludeSemantics: true,
    ),
  ],
);
''',
  shots: const [
    Shot(pageId: 'progress-bar', size: ShotSize.desktop),
    Shot(pageId: 'progress-bar', size: ShotSize.phone),
  ],
  related: const ['setup-guide', 'progress-stepping', 'loading'],
);
