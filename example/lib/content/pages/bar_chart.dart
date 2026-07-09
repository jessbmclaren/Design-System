// Pure Dart — NO Flutter imports.
import '../pattern_page_content.dart';

/// Charts → Bar chart.
final PatternPage barChartPage = PatternPage(
  id: 'bar-chart',
  group: DocGroup.charts,
  navTitle: 'BarChart',
  title: 'Bar chart',
  description:
      'A `DsBarChart` compares a single series of categories as vertical, '
      'baseline-anchored bars, making it the clearest way to answer "which is '
      'biggest?" across a handful of named values. Because it shows one series '
      'it carries no legend — the `title` names what is measured and every bar '
      'shares one hue from the data-visualization palette, so the eye reads '
      'length, not colour. Each `DsBarDatum` pairs a `label` with a `value` '
      'anchored to zero; the chart rounds up to a tidy axis maximum, draws '
      'recessive gridlines, and prints a compact value above each bar. It is '
      'responsive by construction: it fills its parent\'s width, thins and '
      'ellipsizes x-axis labels on narrow viewports, and drops any value label '
      'that no longer fits rather than overflow — down to a 320dp phone. It '
      'renders a still frame with no timers or animation and exposes the full '
      'series to screen readers as a summary of every label and value.',
  hasLiveDemo: true,
  dos: const [
    'Compare categories on one shared, zero-based baseline so bar lengths are honestly proportional.',
    'Set a `title` to name the series — it stands in for the legend a single-series chart omits.',
    'Keep the category count small and each `label` short so every bar and its label stay legible.',
    'Let the palette colour the whole series; reserve `DsBarDatum.color` for highlighting one bar, like a total.',
    'Order bars meaningfully — by magnitude, or by a natural sequence such as day or month.',
    'Turn off `showValueLabels` when the exact figures matter less than the shape of the comparison.',
  ],
  donts: const [
    'Don\'t give bars different colours to decorate them — varied hues imply a categorical meaning that isn\'t there.',
    'Don\'t plot more than one series here; reach for a grouped chart or a line chart instead.',
    'Don\'t use a bar chart for a continuous trend over time — a `DsLineChart` shows change more faithfully.',
    'Don\'t pass negative values expecting downward bars; values at or below zero draw as an empty slot.',
  ],
  code: '''
DsBarChart(
  title: 'Weekly active users',
  data: const [
    DsBarDatum(label: 'Mon', value: 1240),
    DsBarDatum(label: 'Tue', value: 1980),
    DsBarDatum(label: 'Wed', value: 1720),
    DsBarDatum(label: 'Thu', value: 2100),
    DsBarDatum(label: 'Fri', value: 2460),
    DsBarDatum(label: 'Sat', value: 1310),
    DsBarDatum(label: 'Sun', value: 980),
  ],
  showValueLabels: true,
);
''',
  shots: const [
    Shot(pageId: 'bar-chart', size: ShotSize.desktop),
    Shot(pageId: 'bar-chart', size: ShotSize.phone),
  ],
  related: const ['line-chart', 'meter-chart'],
);
