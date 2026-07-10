import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Sparkline page.
///
/// Renders `DsSparkline` in the contexts it is built for: as an inline trend on
/// a stack of KPI rows (one filled headline metric, one status-coloured metric)
/// and as compact plots inside dense table-style cells. Every sparkline is
/// paired with the real value it trends, since the plot conveys shape, not
/// magnitude. Static and screenshot-safe: no timers or animation.
class SparklineDemo extends StatelessWidget {
  const SparklineDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final Brightness brightness = Theme.of(context).brightness;

    final TextStyle labelStyle = TextStyle(
      fontFamily: tokens.fontFamily,
      fontSize: tokens.fontSizeBase,
      color: tokens.colorText,
    );
    final TextStyle valueStyle = TextStyle(
      fontFamily: tokens.fontFamily,
      fontSize: tokens.fontSizeBase + 6,
      fontWeight: FontWeight.w600,
      color: tokens.colorText,
    );
    final TextStyle mutedStyle = TextStyle(
      fontFamily: tokens.fontFamily,
      fontSize: tokens.fontSizeBase - 3,
      color: tokens.colorSecondaryText,
    );

    // A KPI row: label + big value on the left, trend sparkline on the right.
    Widget kpi({
      required String label,
      required String value,
      required List<double> series,
      required Color color,
      bool filled = false,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: mutedStyle),
                  const SizedBox(height: 2),
                  Text(value, style: valueStyle),
                ],
              ),
            ),
            const SizedBox(width: 12),
            DsSparkline(
              values: series,
              color: color,
              filled: filled,
              width: 92,
              height: 32,
            ),
          ],
        ),
      );
    }

    // A dense table-style row: label, trailing value, compact status sparkline.
    Widget cell({
      required String label,
      required String value,
      required List<double> series,
      required Color color,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(label, style: labelStyle)),
            const SizedBox(width: 10),
            DsSparkline(
              values: series,
              color: color,
              width: 64,
              height: 22,
            ),
            const SizedBox(width: 12),
            Text(value, style: labelStyle),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Headline metric: filled area, brand hue, trending up.
        kpi(
          label: 'Monthly active users',
          value: '14.1k',
          series: const [820, 932, 901, 1090, 1230, 1180, 1410],
          color: DsChartPalette.colorAt(0, brightness),
          filled: true,
        ),
        const DsDivider(),
        // Revenue: positive status hue.
        kpi(
          label: 'Net revenue',
          value: '\$92,480',
          series: const [61, 64, 63, 70, 74, 79, 92],
          color: DsChartPalette.divergingPositive,
        ),
        const SizedBox(height: 18),
        Text('Support metrics', style: mutedStyle),
        const SizedBox(height: 6),
        // Dense cells: status-coloured trends beside their real values.
        cell(
          label: 'Avg. response time',
          value: '2.9 h',
          series: const [4.8, 4.5, 4.9, 4.1, 3.6, 3.2, 2.9],
          color: DsChartPalette.divergingPositive,
        ),
        const DsDivider(),
        cell(
          label: 'Escalations',
          value: '38',
          series: const [12, 15, 14, 21, 26, 31, 38],
          color: DsChartPalette.divergingNegative,
        ),
        const DsDivider(),
        cell(
          label: 'CSAT',
          value: '94%',
          series: const [91, 92, 90, 93, 92, 94, 94],
          color: DsChartPalette.colorAt(2, brightness),
        ),
      ],
    );
  }
}
