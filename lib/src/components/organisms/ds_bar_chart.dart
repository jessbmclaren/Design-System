import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_chart_palette.dart';

/// A single category in a [DsBarChart].
///
/// A datum pairs a human-readable [label] with its [value]. Supply an explicit
/// [color] only to override the chart's single series hue for one bar (for
/// example to highlight a total); leave it null to let the chart colour every
/// bar with the design system's data-visualization palette.
@immutable
class DsBarDatum {
  /// Creates a bar chart datum.
  const DsBarDatum({
    required this.label,
    required this.value,
    this.color,
  });

  /// The category name, shown on the x-axis beneath the bar.
  final String label;

  /// The magnitude of the bar. Values at or below zero draw as an empty slot;
  /// this is a magnitude chart anchored to a zero baseline.
  final double value;

  /// An optional per-datum override for the bar's fill colour.
  ///
  /// When null the bar uses the first entry of the design system chart palette
  /// for the active [Brightness]. Prefer leaving this null so the chart reads
  /// as one coherent series.
  final Color? color;
}

/// A single-series vertical bar chart rendered with [CustomPaint].
///
/// [DsBarChart] plots one series of categorical magnitudes as thin, baseline
/// anchored bars with lightly rounded tops. Because it shows a single series it
/// carries no legend — the [title] names what is being measured — and every bar
/// shares one hue drawn from [DsChartPalette]. Individual bars may override that
/// hue via [DsBarDatum.color].
///
/// Everything that is text (the [title], value labels and x-axis labels) is
/// coloured from the theme's text tokens, never from a series colour, and the
/// gridlines and baseline are recessive ([DsTokens.colorBorder] at low alpha).
/// All colours and type styles come from [DsTokens.of], so the chart re-themes
/// with the surrounding application and works for any white-label brand.
///
/// Responsiveness: the chart fills its parent's width and stands [height]
/// logical pixels tall. It uses a [LayoutBuilder] so that on narrow viewports it
/// thins the x-axis labels (showing every Nth label) and ellipsizes each to its
/// slot, and drops value labels that no longer fit. It never overflows, down to
/// a 320dp-wide phone.
///
/// Accessibility: the whole chart is wrapped in a [Semantics] node whose label
/// summarises the series (category count, maximum and every label/value pair) so
/// a screen reader conveys the data and a caller has enough to render an
/// equivalent table.
///
/// The widget starts no timers and runs no animation, so it renders a stable
/// still frame that is safe to capture in a screenshot.
///
/// ```dart
/// DsBarChart(
///   title: 'Weekly active users',
///   data: const [
///     DsBarDatum(label: 'Mon', value: 120),
///     DsBarDatum(label: 'Tue', value: 200),
///     DsBarDatum(label: 'Wed', value: 150),
///   ],
/// )
/// ```
class DsBarChart extends StatelessWidget {
  /// Creates a single-series vertical bar chart.
  const DsBarChart({
    super.key,
    required this.data,
    this.title,
    this.height = 240,
    this.showValueLabels = true,
  });

  /// The bars to plot, drawn left to right in the given order.
  final List<DsBarDatum> data;

  /// An optional heading rendered above the plot. Since a single-series chart
  /// has no legend, the title is what names the series.
  final String? title;

  /// The height in logical pixels of the plot area (excluding the [title]).
  final double height;

  /// Whether to draw the numeric value above each bar.
  ///
  /// Labels are still selective: any that would not fit above their bar are
  /// omitted so numbers never crowd or overflow.
  final bool showValueLabels;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final brightness = Theme.of(context).brightness;
    final defaultBarColor = DsChartPalette.colorAt(0, brightness);

    // TextPainter (unlike Text) does not inherit the theme font, so resolve
    // the family from the theme and stamp it onto the painted label styles.
    final themed = Theme.of(context).textTheme.bodyMedium;
    TextStyle painted(TextStyle s) => s.copyWith(
          fontFamily: themed?.fontFamily,
          fontFamilyFallback: themed?.fontFamilyFallback,
        );
    final labelStyle =
        painted(tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText));
    final valueStyle = painted(tokens.bodySm.toTextStyle(color: tokens.colorText));

    final semanticsLabel = _semanticsLabel();

    final chart = SizedBox(
      height: height,
      width: double.infinity,
      child: data.isEmpty
          ? const SizedBox.shrink()
          : LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, height),
                  isComplex: true,
                  painter: _DsBarChartPainter(
                    data: data,
                    defaultBarColor: defaultBarColor,
                    gridColor: tokens.colorBorder.withValues(alpha: 0.4),
                    surfaceColor: tokens.colorBackground,
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                    showValueLabels: showValueLabels,
                  ),
                );
              },
            ),
    );

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            Text(
              title!,
              style: tokens.headingSm.toTextStyle(color: tokens.colorText),
            ),
            const SizedBox(height: 12),
          ],
          chart,
        ],
      ),
    );
  }

  /// Builds a descriptive summary of the whole series for assistive tech.
  String _semanticsLabel() {
    if (data.isEmpty) {
      return title == null
          ? 'Bar chart, no data'
          : 'Bar chart, $title, no data';
    }
    final maxValue = data.map((d) => d.value).reduce(math.max);
    final pairs =
        data.map((d) => '${d.label}: ${_formatValue(d.value)}').join(', ');
    final named = title == null ? '' : '$title. ';
    final count = data.length == 1 ? '1 category' : '${data.length} categories';
    return 'Bar chart. $named$count. '
        'Maximum ${_formatValue(maxValue)}. $pairs.';
  }
}

/// Formats a magnitude compactly: integers plainly, thousands as `k`, millions
/// as `M`, and otherwise to one decimal place.
String _formatValue(double v) {
  final abs = v.abs();
  if (abs >= 1000000) {
    final scaled = v / 1000000;
    return '${scaled.toStringAsFixed(abs % 1000000 == 0 ? 0 : 1)}M';
  }
  if (abs >= 1000) {
    final scaled = v / 1000;
    return '${scaled.toStringAsFixed(abs % 1000 == 0 ? 0 : 1)}k';
  }
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(1);
}

/// Rounds [rawMax] up to a visually tidy axis maximum (1, 2, 2.5, 5 or 10 times
/// a power of ten) so gridlines land on sensible values.
double _niceMax(double rawMax) {
  if (rawMax <= 0) return 1;
  final exponent = (math.log(rawMax) / math.ln10).floor();
  final magnitude = math.pow(10, exponent).toDouble();
  final fraction = rawMax / magnitude;
  final double niceFraction;
  if (fraction <= 1) {
    niceFraction = 1;
  } else if (fraction <= 2) {
    niceFraction = 2;
  } else if (fraction <= 2.5) {
    niceFraction = 2.5;
  } else if (fraction <= 5) {
    niceFraction = 5;
  } else {
    niceFraction = 10;
  }
  return niceFraction * magnitude;
}

/// Paints the gridlines, baseline, bars and labels for a [DsBarChart].
class _DsBarChartPainter extends CustomPainter {
  _DsBarChartPainter({
    required this.data,
    required this.defaultBarColor,
    required this.gridColor,
    required this.surfaceColor,
    required this.labelStyle,
    required this.valueStyle,
    required this.showValueLabels,
  });

  final List<DsBarDatum> data;
  final Color defaultBarColor;
  final Color gridColor;
  final Color surfaceColor;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final bool showValueLabels;

  /// Number of horizontal gridline divisions above the baseline.
  static const int _divisions = 4;

  /// Corner radius of a bar's top edge.
  static const double _barRadius = 4;

  /// Largest a single bar is allowed to grow on wide layouts.
  static const double _maxBarWidth = 48;

  /// Minimum surface-colour gap enforced between neighbouring bars.
  static const double _minGap = 2;

  /// Vertical breathing room between text and the mark it annotates.
  static const double _textGap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final rawMax = data.map((d) => d.value).fold<double>(0, math.max);
    final niceMax = _niceMax(rawMax);

    // Reserve vertical space for x-axis labels (bottom) and value labels (top).
    final sampleLabel = _layoutText('Ag', labelStyle);
    final xLabelSpace = sampleLabel.height + _textGap;
    final valueSpace = showValueLabels ? sampleLabel.height + _textGap : _textGap;

    final plotTop = valueSpace;
    final plotBottom = size.height - xLabelSpace;
    final plotHeight = plotBottom - plotTop;
    if (plotHeight <= 0) return;
    final plotWidth = size.width;

    _paintGrid(canvas, plotTop, plotBottom, plotWidth);

    final slot = plotWidth / data.length;
    final barWidth = math
        .min(math.min(slot * 0.62, _maxBarWidth), slot - _minGap)
        .clamp(1.0, slot)
        .toDouble();

    // Determine an x-label stride so labels never overlap or overflow.
    var widestLabel = 0.0;
    for (final d in data) {
      widestLabel = math.max(widestLabel, _layoutText(d.label, labelStyle).width);
    }
    final stride = math.max(1, ((widestLabel + 6) / slot).ceil());

    for (var i = 0; i < data.length; i++) {
      final datum = data[i];
      final slotCenter = slot * i + slot / 2;
      final value = datum.value.clamp(0.0, double.infinity);
      final barHeight = niceMax <= 0 ? 0.0 : (value / niceMax) * plotHeight;
      final barTop = plotBottom - barHeight;
      final left = slotCenter - barWidth / 2;
      final rect = Rect.fromLTRB(left, barTop, left + barWidth, plotBottom);

      if (barHeight > 0) {
        final rrect = RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(_barRadius),
          topRight: const Radius.circular(_barRadius),
        );
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = datum.color ?? defaultBarColor
            ..isAntiAlias = true,
        );
      }

      // Value label above the bar — only when enabled and it fits the slot.
      if (showValueLabels) {
        final text = _layoutText(_formatValue(datum.value), valueStyle);
        final fitsWidth = text.width <= slot - 2;
        final fitsHeight = barTop >= valueSpace;
        if (barHeight > 0 && fitsWidth && fitsHeight) {
          final tx = (slotCenter - text.width / 2)
              .clamp(0.0, plotWidth - text.width)
              .toDouble();
          text.paint(canvas, Offset(tx, barTop - text.height - _textGap));
        }
      }

      // X-axis label beneath the bar — thinned by [stride] and ellipsized.
      if (i % stride == 0) {
        final maxWidth = math.min(slot * stride - 4, plotWidth);
        final text = _layoutText(
          datum.label,
          labelStyle,
          maxWidth: maxWidth,
          ellipsis: true,
        );
        final tx = (slotCenter - text.width / 2)
            .clamp(0.0, plotWidth - text.width)
            .toDouble();
        text.paint(canvas, Offset(tx, plotBottom + _textGap));
      }
    }
  }

  void _paintGrid(Canvas canvas, double top, double bottom, double width) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..isAntiAlias = false;
    // Interior gridlines (above the baseline).
    for (var i = 1; i <= _divisions; i++) {
      final y = bottom - (bottom - top) * (i / _divisions);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }
    // Baseline — the axis, drawn a touch stronger.
    canvas.drawLine(
      Offset(0, bottom),
      Offset(width, bottom),
      Paint()
        ..color = gridColor
        ..strokeWidth = 1.25
        ..isAntiAlias = false,
    );
  }

  TextPainter _layoutText(
    String text,
    TextStyle style, {
    double? maxWidth,
    bool ellipsis = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: ellipsis ? '…' : null,
    );
    painter.layout(maxWidth: maxWidth ?? double.infinity);
    return painter;
  }

  @override
  bool shouldRepaint(_DsBarChartPainter old) {
    return old.data != data ||
        old.defaultBarColor != defaultBarColor ||
        old.gridColor != gridColor ||
        old.surfaceColor != surfaceColor ||
        old.labelStyle != labelStyle ||
        old.valueStyle != valueStyle ||
        old.showValueLabels != showValueLabels;
  }
}
