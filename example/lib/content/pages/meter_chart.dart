// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Charts → Meter chart.
final PatternPage meterChartPage = PatternPage(
  id: 'meter-chart',
  group: DocGroup.charts,
  navTitle: 'Meter chart',
  title: 'Meter chart',
  description:
      'A `DsMeterChart` divides a single whole into proportional, labelled '
      'segments laid out along one rounded horizontal bar. It is the most '
      'compact way to show a part-to-whole breakdown: a budget split, storage '
      'by file type or traffic by channel. Each `DsMeterSegment` contributes '
      'its `value` and takes a width of `value / total`, so the segments '
      'always sum to the full bar and the eye compares shares directly. Colour '
      'comes from the design system, not the caller: leave '
      '`DsMeterSegment.color` null and each segment draws its hue in order from '
      'the validated categorical palette, with a 2px surface-coloured gap '
      'between neighbours and rounded outer ends. The optional `title` labels '
      'the whole, and the wrapping legend beneath prints each segment\'s name, '
      'value and percentage. Text always uses on-system foreground colours, '
      'never a series hue. It is responsive by construction: the bar fills its '
      'parent\'s width and the legend reflows onto multiple lines down to a '
      '320dp phone. It renders a still frame with no timers or animation and '
      'exposes the segment count, total and every share to assistive '
      'technology.',
  hasLiveDemo: true,
  dos: const [
    'Use it for a single whole split into a handful of parts: the segments are proportional shares of one total, not independent measures.',
    'Keep the segment count small (three to six) and each `label` short so both the bar and its legend stay legible.',
    'Set a `title` that names the whole being divided, such as "Storage used" or "Budget allocation".',
    'Let the palette colour the segments in order so the meter stays on-system and the legend swatches match the bar.',
    'Order segments meaningfully (by magnitude or by a natural sequence) since they read left-to-right in list order.',
    'Reserve an explicit `DsMeterSegment.color` for a fixed status or brand mapping, and apply it consistently across every segment.',
  ],
  donts: const [
    'Don\'t use it to compare independent categories that don\'t sum to a meaningful whole; use a `DsBarChart` instead.',
    'Don\'t plot a trend over time on it; a `DsLineChart` shows change far more faithfully.',
    'Don\'t pass negative values expecting a reversed segment. Values at or below zero are clamped to zero and draw nothing.',
    'Don\'t colour segments by hand just to decorate them; mixing arbitrary hues breaks the palette and the legend mapping.',
  ],
  code: '''
DsMeterChart(
  title: 'Storage used',
  segments: const [
    DsMeterSegment(label: 'Photos', value: 45),
    DsMeterSegment(label: 'Video', value: 30),
    DsMeterSegment(label: 'Documents', value: 15),
    DsMeterSegment(label: 'Other', value: 10),
  ],
);
''',
  shots: const [
    Shot(pageId: 'meter-chart', size: ShotSize.desktop),
    Shot(pageId: 'meter-chart', size: ShotSize.phone),
  ],
  related: const ['bar-chart', 'line-chart'],
);
