import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../tokens/ds_chart_palette.dart';

/// A tiny inline line chart with no axes, labels or gridlines.
///
/// [DsSparkline] renders a compact trend line — a "sparkline" — sized to sit
/// inline with text or inside a dense table cell. The [values] are normalised
/// to fit the given [width] and [height] box, drawn as a 2px polyline, with an
/// optional soft fill beneath the line and an end dot marking the last point.
///
/// The line colour defaults to the first entry of the validated
/// [DsChartPalette] categorical order for the active [Brightness]; supply
/// [color] to override it (for example to echo a value's status elsewhere in
/// the UI). No number labels or axes are drawn — a sparkline communicates shape,
/// not precise values.
///
/// The widget is screenshot-safe: it renders a single stable frame from the
/// data passed in, with no timers or animation. Zero- and one-point inputs are
/// handled gracefully (nothing, or a single centred dot). The chart fills the
/// provided [width]/[height] and never overflows.
///
/// ```dart
/// DsSparkline(values: [3, 5, 2, 8, 6, 9, 7])
/// ```
class DsSparkline extends StatelessWidget {
  /// Creates an inline sparkline for [values].
  const DsSparkline({
    super.key,
    required this.values,
    this.color,
    this.width = 96,
    this.height = 28,
    this.filled = false,
    this.showEndDot = true,
  });

  /// The ordered data points, plotted left → right and normalised to the box.
  ///
  /// A flat series (all equal) draws along the vertical centre. An empty list
  /// draws nothing; a single value draws a centred end dot only.
  final List<double> values;

  /// The line (and fill) colour.
  ///
  /// Defaults to `DsChartPalette.colorAt(0, brightness)` for the active theme
  /// brightness. Pass a value to override, e.g. a status hue used elsewhere.
  final Color? color;

  /// The width of the sparkline box. The plot fills this width.
  final double width;

  /// The height of the sparkline box. The plot fills this height.
  final double height;

  /// Whether to paint a soft translucent fill beneath the line.
  final bool filled;

  /// Whether to draw a dot (>= 6px) at the last data point.
  final bool showEndDot;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final lineColor = color ?? DsChartPalette.colorAt(0, brightness);

    return Semantics(
      label: 'Sparkline',
      container: true,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          size: Size(width, height),
          painter: _SparklinePainter(
            values: values,
            color: lineColor,
            filled: filled,
            showEndDot: showEndDot,
          ),
        ),
      ),
    );
  }
}

/// Paints the [DsSparkline] polyline, optional fill and end dot.
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.values,
    required this.color,
    required this.filled,
    required this.showEndDot,
  });

  final List<double> values;
  final Color color;
  final bool filled;
  final bool showEndDot;

  /// Padding kept clear inside the box so the 2px stroke and end dot never clip.
  static const double _inset = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;

    final left = _inset;
    final right = size.width - _inset;
    final top = _inset;
    final bottom = size.height - _inset;
    final plotWidth = (right - left).clamp(0.0, double.infinity);
    final plotHeight = (bottom - top).clamp(0.0, double.infinity);

    // Single point: draw a centred dot only.
    if (values.length == 1) {
      if (showEndDot) {
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          3,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill
            ..isAntiAlias = true,
        );
      }
      return;
    }

    var minV = values.first;
    var maxV = values.first;
    for (final v in values) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    final range = maxV - minV;

    double x(int i) => left + (plotWidth * i) / (values.length - 1);
    double y(double v) {
      if (range == 0) return top + plotHeight / 2;
      // Higher values sit higher on screen (smaller y).
      final t = (v - minV) / range;
      return bottom - plotHeight * t;
    }

    final points = <Offset>[
      for (var i = 0; i < values.length; i++) Offset(x(i), y(values[i])),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    if (filled) {
      final fillPath = Path.from(path)
        ..lineTo(points.last.dx, bottom)
        ..lineTo(points.first.dx, bottom)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..color = color.withValues(alpha: 0.14)
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );

    if (showEndDot) {
      canvas.drawCircle(
        points.last,
        3,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        oldDelegate.color != color ||
        oldDelegate.filled != filled ||
        oldDelegate.showEndDot != showEndDot;
  }
}
