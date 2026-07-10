// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Charts → Line chart.
final PatternPage lineChartPage = PatternPage(
  id: 'line-chart',
  group: DocGroup.charts,
  navTitle: 'Line chart',
  title: 'Line chart',
  description:
      'A line chart traces one or more metrics as they change over an ordered '
      'axis (days, weeks or releases) so trend, momentum and the gap between '
      'series are easy to read. Every `DsLineSeries` you pass shares a '
      'single y-axis, which keeps the lines directly comparable and rules out '
      'the misleading dual-axis pairing. Series take their colour from the '
      'validated `DsChartPalette` categorical order by position, so identity '
      'stays stable across a product and never collides with a status hue; a '
      'legend appears automatically once there are two or more lines. The chart '
      'fills its parent\'s width, renders as a single static frame, thins '
      'x-labels rather than overflowing and ships a spoken summary so the '
      'trend is available to assistive technology as well as the eye.',
  hasLiveDemo: true,
  dos: const [
    'Plot metrics that share a unit and a comparable magnitude on the one axis '
        'so the shared y-scale reads honestly.',
    'Pass series in a stable order and let the palette assign colour by '
        'position, so a metric keeps the same hue everywhere it appears.',
    'Give every series a clear `name`; it drives the legend and the spoken '
        'summary for assistive technology.',
    'Provide `xLabels` in x order for time axes; the chart thins them to fit '
        'on narrow widths instead of overflowing.',
    'Set a `title` that names the metric, especially for a single-series chart '
        'where no legend is drawn.',
    'Keep points sparse (roughly a dozen or fewer) when you want readable, '
        'tappable point markers on each line.',
  ],
  donts: const [
    'Do not force two different units onto the chart expecting a second axis. '
        'It is single-axis by design; split them into two charts instead.',
    'Do not hand-pick a series `color` to signal state; status belongs to the '
        'badge tokens, never a categorical line hue.',
    'Do not crowd the chart with many long-running series; past a handful of '
        'lines, trends blur and the legend dominates.',
    'Do not rely on colour alone to tell series apart. Keep the legend and '
        'series names meaningful.',
  ],
  code: '''
DsLineChart(
  title: 'Weekly active users',
  xLabels: const ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'],
  series: const [
    DsLineSeries(name: 'Web', values: [1200, 1320, 1280, 1450, 1600, 1720]),
    DsLineSeries(name: 'Mobile', values: [900, 960, 1040, 1000, 1180, 1290]),
    DsLineSeries(name: 'API', values: [320, 360, 410, 480, 520, 610]),
  ],
)
''',
  shots: const [
    Shot(pageId: 'line-chart', size: ShotSize.desktop),
    Shot(pageId: 'line-chart', size: ShotSize.phone),
  ],
  related: const ['bar-chart', 'sparkline'],
);
