import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_chart_palette.dart';

/// A single proportional slice of a [DsMeterChart].
///
/// A segment contributes its [value] to the whole; its share of the bar is
/// `value / total`. Give it a descriptive [label] for the legend and semantics.
/// Leave [color] null to draw from the validated categorical chart palette
/// (recommended, so the whole meter stays on-system); pass an explicit [color]
/// only when a fixed brand or status mapping is required.
@immutable
class DsMeterSegment {
  /// Creates a meter segment.
  const DsMeterSegment({required this.label, required this.value, this.color});

  /// The human-readable name of this segment, shown in the legend and read out
  /// by assistive technology.
  final String label;

  /// The magnitude of this segment. Its width is `value / total` of the bar.
  /// Negative values are treated as zero.
  final double value;

  /// An optional explicit colour. When null, the segment takes its colour from
  /// [DsChartPalette.colorAt] using its position in the list.
  final Color? color;
}

/// A horizontal meter: a whole divided into proportional, coloured segments.
///
/// [DsMeterChart] renders one rounded-end horizontal bar split into
/// [segments], each sized by its share of the total. It is the right form for
/// a part-to-whole breakdown that fits on a single line (a budget split,
/// storage usage by type or traffic by channel), where a full stacked bar
/// chart would be overkill.
///
/// Colour, type and spacing come entirely from the design system. Each segment
/// is drawn in [DsMeterSegment.color] or, when that is null, the validated
/// categorical palette via [DsChartPalette.colorAt] for the active
/// [Brightness]. A 2px surface-colour gap separates adjacent segments and the
/// outer ends are rounded. The optional [title] uses the `headingSm` token and
/// the legend text uses `colorText` (labels) and `colorSecondaryText`
/// (values/percentages); no series colour is ever used for text.
///
/// Responsiveness: the bar always fills the available width and the legend
/// wraps onto multiple lines on narrow layouts, so the widget never overflows
/// down to a 320dp-wide viewport.
///
/// Accessibility: the whole widget is wrapped in a [Semantics] node whose label
/// summarises the segment count and total, and each legend entry exposes its
/// own label, value and percentage so a caller could also render a table.
///
/// The widget starts no timers or animations; it renders a stable still frame
/// from the data passed in, which is safe to capture in a screenshot.
///
/// ```dart
/// DsMeterChart(
///   title: 'Storage used',
///   segments: const [
///     DsMeterSegment(label: 'Photos', value: 45),
///     DsMeterSegment(label: 'Video', value: 30),
///     DsMeterSegment(label: 'Docs', value: 15),
///     DsMeterSegment(label: 'Other', value: 10),
///   ],
/// )
/// ```
class DsMeterChart extends StatelessWidget {
  /// Creates a horizontal proportional meter.
  const DsMeterChart({
    super.key,
    required this.segments,
    this.title,
    this.showLegend = true,
    this.barHeight = 14,
  });

  /// The proportional slices of the meter, drawn left-to-right in order.
  final List<DsMeterSegment> segments;

  /// An optional heading shown above the bar, styled as `headingSm`.
  final String? title;

  /// Whether to show the legend below the bar. Defaults to true.
  final bool showLegend;

  /// The thickness of the bar in logical pixels. Defaults to 14.
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    // Resolve each segment's effective colour and clamp negative values.
    final values = <double>[
      for (final s in segments) s.value < 0 ? 0 : s.value,
    ];
    final total = values.fold<double>(0, (sum, v) => sum + v);
    final colors = <Color>[
      for (var i = 0; i < segments.length; i++)
        segments[i].color ?? tokens.chartColorAt(i),
    ];

    final semanticsLabel = _buildSemanticsLabel(values, total);

    final children = <Widget>[
      if (title != null && title!.isNotEmpty) ...[
        Text(title!, style: tokens.headingSm.toTextStyle(color: tokens.colorText)),
        const SizedBox(height: 12),
      ],
      SizedBox(
        height: barHeight,
        width: double.infinity,
        child: CustomPaint(
          painter: _MeterBarPainter(
            values: values,
            colors: colors,
            total: total,
            barHeight: barHeight,
            gap: 2,
            surface: tokens.colorBackground,
            emptyTrack: tokens.colorBorder.withValues(alpha: 0.4),
          ),
        ),
      ),
      if (showLegend && segments.isNotEmpty) ...[
        const SizedBox(height: 14),
        _Legend(
          segments: segments,
          values: values,
          colors: colors,
          total: total,
          tokens: tokens,
        ),
      ],
    ];

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  String _buildSemanticsLabel(List<double> values, double total) {
    final count = segments.length;
    final titlePart = (title != null && title!.isNotEmpty) ? '$title. ' : '';
    final buffer = StringBuffer(
      '${titlePart}Meter chart, $count '
      '${count == 1 ? 'segment' : 'segments'}, total ${_fmt(total)}. ',
    );
    for (var i = 0; i < segments.length; i++) {
      final pct = total > 0 ? (values[i] / total) * 100 : 0.0;
      buffer.write(
        '${segments[i].label}: ${_fmt(values[i])} '
        '(${pct.toStringAsFixed(0)}%). ',
      );
    }
    return buffer.toString().trim();
  }
}

/// Formats a number without a trailing `.0` for whole values.
String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(1);
}

/// Paints the segmented, rounded-end meter bar with surface-colour gaps.
class _MeterBarPainter extends CustomPainter {
  const _MeterBarPainter({
    required this.values,
    required this.colors,
    required this.total,
    required this.barHeight,
    required this.gap,
    required this.surface,
    required this.emptyTrack,
  });

  final List<double> values;
  final List<Color> colors;
  final double total;
  final double barHeight;
  final double gap;
  final Color surface;
  final Color emptyTrack;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(barHeight / 2 < 4 ? barHeight / 2 : 4);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Empty / zero-total track: a recessive rounded pill.
    if (total <= 0 || values.isEmpty) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(fullRect, radius),
        Paint()..color = emptyTrack,
      );
      return;
    }

    // Clip everything to the outer rounded-pill shape so segment ends inherit
    // the rounded outer corners while interior joins stay square.
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(fullRect, radius));

    // Fill the pill with the surface colour first so the 2px inter-segment
    // gaps read as clean surface-coloured dividers.
    canvas.drawRect(fullRect, Paint()..color = surface);

    var x = 0.0;
    final count = values.length;
    for (var i = 0; i < count; i++) {
      final w = (values[i] / total) * size.width;
      if (w <= 0) continue;
      // Trailing edge gap: shrink every segment except the last by `gap`,
      // painting the surface colour through the gap for a crisp divider.
      final isLast = i == _lastNonZeroIndex();
      final segWidth = isLast ? size.width - x : w - gap;
      final rect = Rect.fromLTWH(x, 0, segWidth < 0 ? 0 : segWidth, size.height);
      canvas.drawRect(rect, Paint()..color = colors[i]);
      x += w;
    }

    canvas.restore();
  }

  int _lastNonZeroIndex() {
    for (var i = values.length - 1; i >= 0; i--) {
      if (values[i] > 0) return i;
    }
    return values.length - 1;
  }

  @override
  bool shouldRepaint(_MeterBarPainter old) =>
      old.values != values ||
      old.colors != colors ||
      old.total != total ||
      old.barHeight != barHeight ||
      old.gap != gap ||
      old.surface != surface ||
      old.emptyTrack != emptyTrack;
}

/// The wrapping legend beneath the bar.
class _Legend extends StatelessWidget {
  const _Legend({
    required this.segments,
    required this.values,
    required this.colors,
    required this.total,
    required this.tokens,
  });

  final List<DsMeterSegment> segments;
  final List<double> values;
  final List<Color> colors;
  final double total;
  final DsTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (var i = 0; i < segments.length; i++)
          _LegendItem(
            label: segments[i].label,
            value: values[i],
            color: colors[i],
            total: total,
            tokens: tokens,
          ),
      ],
    );
  }
}

/// A single swatch + label + value/percentage row in the legend.
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.value,
    required this.color,
    required this.total,
    required this.tokens,
  });

  final String label;
  final double value;
  final Color color;
  final double total;
  final DsTokens tokens;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (value / total) * 100 : 0.0;
    final valueText = '${_fmt(value)} (${pct.toStringAsFixed(0)}%)';

    return Semantics(
      label: '$label, $valueText',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            // Flexible so a long label (or a large text scale) ellipsizes
            // instead of pushing the legend row past its bounds.
            Flexible(
              child: Text(
                label,
                style: tokens.labelMd.toTextStyle(color: tokens.colorText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              valueText,
              style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
