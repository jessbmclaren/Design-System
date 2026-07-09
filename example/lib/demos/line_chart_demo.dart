import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Line chart page: three product metrics tracked over six
/// weeks on one shared axis, with the automatic legend and thinned x-labels.
class LineChartDemo extends StatelessWidget {
  const LineChartDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const DsLineChart(
      title: 'Weekly active users',
      xLabels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'],
      series: [
        DsLineSeries(
          name: 'Web',
          values: [1200, 1320, 1280, 1450, 1600, 1720],
        ),
        DsLineSeries(
          name: 'Mobile',
          values: [900, 960, 1040, 1000, 1180, 1290],
        ),
        DsLineSeries(
          name: 'API',
          values: [320, 360, 410, 480, 520, 610],
        ),
      ],
    );
  }
}
