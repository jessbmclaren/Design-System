import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_chart_palette.dart';

/// A single named line in a [DsLineChart].
///
/// Every series shares the chart's single y-axis, so [values] are plotted on
/// the same magnitude scale as its siblings. The i-th entry in [values] lines
/// up with the i-th x position (and, when supplied, the i-th `xLabels` label).
///
/// Provide [color] only to override the palette; leaving it null lets the chart
/// assign a stable categorical colour from [DsChartPalette] by the series'
/// position, which keeps identity consistent across a product.
@immutable
class DsLineSeries {
  /// Creates a line series named [name] plotting [values].
  const DsLineSeries({
    required this.name,
    required this.values,
    this.color,
  });

  /// The human-readable series name, shown in the legend and read to
  /// assistive technology.
  final String name;

  /// The magnitude of each point, in x order. May differ in length from other
  /// series; missing trailing points are not drawn.
  final List<double> values;

  /// An optional explicit line colour. When null the chart draws a stable
  /// categorical colour from [DsChartPalette.colorAt] for the series' index.
  final Color? color;
}

/// A multi-series line chart rendered with [CustomPaint].
///
/// The chart shares **one** y-axis across every series (never dual-axis), so
/// lines are directly comparable. Lines are 2px; when there are only a
/// handful of points per series, filled point markers (>= 8px) are drawn to
/// make individual readings tappable-looking and legible.
///
/// Colour, type and spacing all come from the Design System tokens:
///
/// * Titles, axis labels and legend text wear the theme **text** tokens
///   ([DsTokens.colorText] / [DsTokens.colorSecondaryText]), never a series
///   colour.
/// * Grid lines and axes are recessive: [DsTokens.colorBorder] at low alpha.
/// * Line colours come from the validated [DsChartPalette] categorical order,
///   so identity is stable and status hues are never reused.
///
/// The widget is responsive: it fills its parent's width, adopts a sensible
/// default [height] and uses a [LayoutBuilder] to thin x-axis labels on narrow
/// widths rather than overflow. It lays out cleanly from a 320dp phone to a
/// wide desktop. Rendering is a single static frame (no timers, no animation),
/// so it is safe for screenshots and honours reduced-motion preferences.
///
/// For two or more series a legend is always present so identity is never
/// conveyed by colour alone; a single series needs no legend because the
/// [title] names it.
///
/// ```dart
/// DsLineChart(
///   title: 'Weekly active users',
///   xLabels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
///   series: const [
///     DsLineSeries(name: 'Web', values: [120, 132, 128, 145, 160]),
///     DsLineSeries(name: 'Mobile', values: [90, 96, 104, 100, 118]),
///   ],
/// )
/// ```
class DsLineChart extends StatelessWidget {
  /// Creates a line chart for [series].
  const DsLineChart({
    super.key,
    required this.series,
    this.xLabels,
    this.title,
    this.height = 260,
  });

  /// The series to plot. One line is drawn per entry, in list order, which also
  /// fixes each series' categorical palette colour.
  final List<DsLineSeries> series;

  /// Optional labels for the x positions, in index order. Labels are thinned on
  /// narrow widths so they never overflow.
  final List<String>? xLabels;

  /// An optional title rendered above the plot in the primary text colour.
  final String? title;

  /// The height of the plot area in logical pixels. Width always fills the
  /// parent. Defaults to 260.
  final double height;

  /// The greatest number of points held by any series.
  int get _pointCount =>
      series.fold(0, (m, s) => math.max(m, s.values.length));

  /// A flat view of every finite value across all series.
  Iterable<double> get _allValues =>
      series.expand((s) => s.values).where((v) => v.isFinite);

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final brightness = Theme.of(context).brightness;

    // Resolve a concrete colour for every series once, so the painter and the
    // legend agree exactly.
    final colors = <Color>[
      for (var i = 0; i < series.length; i++)
        series[i].color ?? DsChartPalette.colorAt(i, brightness),
    ];

    final hasData = _allValues.isNotEmpty;
    final ticks = hasData
        ? _niceTicks(
            _allValues.reduce(math.min),
            _allValues.reduce(math.max),
          )
        : const _TickScale(min: 0, max: 1, values: [0, 1]);

    final titleStyle = tokens.headingSm.toTextStyle(color: tokens.colorText);
    // The painter uses TextPainter, which does not inherit the theme font;
    // stamp the resolved family onto the axis label style.
    final themed = Theme.of(context).textTheme.bodyMedium;
    final axisStyle = tokens.bodySm
        .toTextStyle(color: tokens.colorSecondaryText)
        .copyWith(
          fontFamily: themed?.fontFamily,
          fontFamilyFallback: themed?.fontFamilyFallback,
        );

    final chart = LayoutBuilder(
      builder: (context, constraints) {
        final plot = CustomPaint(
          isComplex: true,
          painter: _LineChartPainter(
            series: series,
            colors: colors,
            xLabels: xLabels,
            ticks: ticks,
            pointCount: _pointCount,
            axisStyle: axisStyle,
            gridColor: tokens.colorBorder.withValues(alpha: 0.4),
            axisColor: tokens.colorBorder.withValues(alpha: 0.4),
            markerColor: tokens.colorBackground,
            spacingUnit: tokens.spacingUnit,
          ),
          child: const SizedBox.expand(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(title!, style: titleStyle),
              SizedBox(height: tokens.spacingUnit),
            ],
            if (series.length >= 2) ...[
              _Legend(
                series: series,
                colors: colors,
                labelStyle: tokens.bodySm
                    .toTextStyle(color: tokens.colorSecondaryText),
              ),
              SizedBox(height: tokens.spacingUnit * 1.5),
            ],
            SizedBox(
              height: height,
              width: double.infinity,
              child: hasData
                  ? plot
                  : _EmptyPlot(
                      style: axisStyle,
                      color: tokens.colorBorder.withValues(alpha: 0.4),
                    ),
            ),
          ],
        );
      },
    );

    return Semantics(
      container: true,
      label: _semanticLabel(),
      child: chart,
    );
  }

  /// Builds a spoken summary of the chart so assistive technology conveys the
  /// same information the visuals do, and a caller could render a table.
  String _semanticLabel() {
    if (_allValues.isEmpty) {
      return 'Line chart, no data.';
    }
    final min = _allValues.reduce(math.min);
    final max = _allValues.reduce(math.max);
    final head = title == null ? 'Line chart' : 'Line chart titled $title';
    final seriesPart = series.length == 1
        ? '1 series (${series.first.name})'
        : '${series.length} series (${series.map((s) => s.name).join(', ')})';
    return '$head, $seriesPart, $_pointCount points each, '
        'values from ${_formatNumber(min)} to ${_formatNumber(max)}.';
  }
}

/// The horizontal swatch-and-name legend shown for multi-series charts.
class _Legend extends StatelessWidget {
  const _Legend({
    required this.series,
    required this.colors,
    required this.labelStyle,
  });

  final List<DsLineSeries> series;
  final List<Color> colors;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Wrap(
      spacing: tokens.spacingUnit * 2,
      runSpacing: tokens.spacingUnit / 2,
      children: [
        for (var i = 0; i < series.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // A short line-like swatch: identity is shape + colour + label.
              Container(
                width: 14,
                height: 4,
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: tokens.spacingUnit),
              Text(series[i].name, style: labelStyle),
            ],
          ),
      ],
    );
  }
}

/// The placeholder drawn when there is nothing to plot.
class _EmptyPlot extends StatelessWidget {
  const _EmptyPlot({required this.style, required this.color});

  final TextStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: color), left: BorderSide(color: color)),
      ),
      child: Center(child: Text('No data', style: style)),
    );
  }
}

/// Immutable description of a "nice" y-axis scale: rounded [min]/[max] bounds
/// and the tick [values] to label between them.
@immutable
class _TickScale {
  const _TickScale({
    required this.min,
    required this.max,
    required this.values,
  });

  final double min;
  final double max;
  final List<double> values;

  double get span => math.max(max - min, 1e-9);
}

/// Paints the grid, axes, labels, lines and markers of a [DsLineChart].
class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.colors,
    required this.xLabels,
    required this.ticks,
    required this.pointCount,
    required this.axisStyle,
    required this.gridColor,
    required this.axisColor,
    required this.markerColor,
    required this.spacingUnit,
  });

  final List<DsLineSeries> series;
  final List<Color> colors;
  final List<String>? xLabels;
  final _TickScale ticks;
  final int pointCount;
  final TextStyle axisStyle;
  final Color gridColor;
  final Color axisColor;
  final Color markerColor;

  /// The theme's base spacing unit, driving the label gutters and padding.
  final double spacingUnit;

  @override
  void paint(Canvas canvas, Size size) {
    if (pointCount == 0) return;

    // ---- Measure the gutters the labels need -----------------------------
    final yLabelPainters = [
      for (final v in ticks.values) _layout(_formatNumber(v)),
    ];
    final leftPad = yLabelPainters.fold<double>(0, (m, p) => math.max(m, p.width)) +
        spacingUnit;

    final hasXLabels = xLabels != null && xLabels!.isNotEmpty;
    final bottomPad = hasXLabels
        ? _layout('X').height + spacingUnit
        : spacingUnit / 2;
    // Headroom so the top gridline label breathes.
    final topPad = spacingUnit;
    // Room for the final point's marker/label.
    final rightPad = spacingUnit * 1.5;

    final plot = Rect.fromLTRB(
      leftPad,
      topPad,
      math.max(leftPad + 1, size.width - rightPad),
      math.max(topPad + 1, size.height - bottomPad),
    );

    // ---- Horizontal gridlines + y labels ---------------------------------
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < ticks.values.length; i++) {
      final y = _yFor(ticks.values[i], plot);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      final tp = yLabelPainters[i];
      tp.paint(
        canvas,
        Offset(plot.left - spacingUnit - tp.width, y - tp.height / 2),
      );
    }

    // ---- Axes (left + baseline), a touch stronger than the interior grid --
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    canvas.drawLine(plot.bottomLeft, plot.bottomRight, axisPaint);
    canvas.drawLine(plot.topLeft, plot.bottomLeft, axisPaint);

    // ---- X labels, thinned to fit ----------------------------------------
    if (hasXLabels) {
      _paintXLabels(canvas, plot);
    }

    // ---- Series lines + markers ------------------------------------------
    // Markers only when points are sparse, so they never crowd the line.
    final showMarkers = pointCount <= 12;
    canvas.save();
    canvas.clipRect(plot.inflate(6));
    for (var s = 0; s < series.length; s++) {
      _paintSeries(canvas, plot, series[s], colors[s], showMarkers);
    }
    canvas.restore();
  }

  void _paintSeries(
    Canvas canvas,
    Rect plot,
    DsLineSeries s,
    Color color,
    bool showMarkers,
  ) {
    final points = <Offset>[];
    for (var i = 0; i < s.values.length; i++) {
      final v = s.values[i];
      if (!v.isFinite) continue;
      points.add(Offset(_xFor(i, plot), _yFor(v, plot)));
    }
    if (points.isEmpty) return;

    if (points.length > 1) {
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    if (showMarkers || points.length == 1) {
      // A surface-colour ring separates the marker fill from the line beneath,
      // giving the 2px gap the mark specs call for.
      final ringPaint = Paint()..color = markerColor;
      final fillPaint = Paint()..color = color;
      for (final p in points) {
        canvas.drawCircle(p, 5, ringPaint); // 10px halo
        canvas.drawCircle(p, 4, fillPaint); // >= 8px mark
      }
    }
  }

  void _paintXLabels(Canvas canvas, Rect plot) {
    final labels = xLabels!;
    final count = math.min(labels.length, pointCount);
    if (count == 0) return;

    // Widest label decides how many can sit side by side.
    var maxLabelW = 0.0;
    final painters = <TextPainter>[];
    for (var i = 0; i < count; i++) {
      final tp = _layout(labels[i]);
      painters.add(tp);
      maxLabelW = math.max(maxLabelW, tp.width);
    }

    final slot = pointCount > 1
        ? plot.width / (pointCount - 1)
        : plot.width;
    final stride = math.max(
      1,
      ((maxLabelW + spacingUnit) / math.max(slot, 1)).ceil(),
    );

    final y = plot.bottom + spacingUnit / 2;
    for (var i = 0; i < count; i++) {
      // Always keep the first and last; thin the interior on the stride.
      final keep = i % stride == 0 || i == count - 1;
      if (!keep) continue;
      final tp = painters[i];
      final rawDx = _xFor(i, plot) - tp.width / 2;
      final maxDx = math.max(0.0, plot.right - tp.width);
      final dx = math.min(math.max(rawDx, 0.0), maxDx);
      tp.paint(canvas, Offset(dx, y));
    }
  }

  double _xFor(int index, Rect plot) {
    if (pointCount <= 1) return plot.center.dx;
    return plot.left + plot.width * (index / (pointCount - 1));
  }

  double _yFor(double value, Rect plot) {
    final t = (value - ticks.min) / ticks.span;
    return plot.bottom - t * plot.height;
  }

  TextPainter _layout(String text) {
    return TextPainter(
      text: TextSpan(text: text, style: axisStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) {
    return old.series != series ||
        old.colors != colors ||
        old.xLabels != xLabels ||
        old.ticks != ticks ||
        old.pointCount != pointCount ||
        old.axisStyle != axisStyle ||
        old.gridColor != gridColor ||
        old.axisColor != axisColor ||
        old.markerColor != markerColor ||
        old.spacingUnit != spacingUnit;
  }
}

/// Computes a rounded ("nice") axis scale spanning [dataMin]..[dataMax] with
/// roughly [maxTicks] evenly spaced, human-friendly tick values.
_TickScale _niceTicks(double dataMin, double dataMax, {int maxTicks = 5}) {
  var lo = dataMin;
  var hi = dataMax;
  if (lo == hi) {
    // A flat series still needs a band to draw within.
    final pad = lo == 0 ? 1.0 : lo.abs() * 0.5;
    lo -= pad;
    hi += pad;
  }
  // Prefer anchoring to zero when the data sits close to it, so magnitude reads
  // honestly rather than exaggerating a small range.
  if (lo > 0 && lo <= hi * 0.35) lo = 0;
  if (hi < 0 && hi >= lo * 0.35) hi = 0;

  final range = _niceNum(hi - lo, round: false);
  final step = _niceNum(range / (maxTicks - 1), round: true);
  final niceMin = (lo / step).floor() * step;
  final niceMax = (hi / step).ceil() * step;

  final values = <double>[];
  for (var v = niceMin; v <= niceMax + step * 0.5; v += step) {
    // Snap away floating-point dust so labels read cleanly.
    values.add((v / step).round() * step);
  }
  return _TickScale(min: niceMin, max: niceMax, values: values);
}

/// Rounds [range] to a 1/2/5 x 10^n "nice" number.
double _niceNum(double range, {required bool round}) {
  if (range <= 0) return 1;
  final exponent = (math.log(range) / math.ln10).floor();
  final fraction = range / math.pow(10, exponent);
  final double niceFraction;
  if (round) {
    if (fraction < 1.5) {
      niceFraction = 1;
    } else if (fraction < 3) {
      niceFraction = 2;
    } else if (fraction < 7) {
      niceFraction = 5;
    } else {
      niceFraction = 10;
    }
  } else {
    if (fraction <= 1) {
      niceFraction = 1;
    } else if (fraction <= 2) {
      niceFraction = 2;
    } else if (fraction <= 5) {
      niceFraction = 5;
    } else {
      niceFraction = 10;
    }
  }
  return niceFraction * math.pow(10, exponent);
}

/// Formats [value] compactly for axis ticks and summaries: thousands as `k`,
/// millions as `M` and integers without a trailing `.0`.
String _formatNumber(double value) {
  if (!value.isFinite) return '';
  final abs = value.abs();
  if (abs >= 1e6) return '${_trim(value / 1e6)}M';
  if (abs >= 1e3) return '${_trim(value / 1e3)}k';
  return _trim(value);
}

/// Trims a double to at most one decimal place, dropping a trailing `.0`.
String _trim(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}
