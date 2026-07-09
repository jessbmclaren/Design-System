import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Bar chart page.
///
/// Renders a single-series `DsBarChart` of weekly active users and lets the
/// viewer toggle the numeric value labels above each bar. The chart draws a
/// stable still frame — no timers or animation — so it is safe to screenshot,
/// and it reflows without overflow down to a 320dp width.
class BarChartDemo extends StatefulWidget {
  const BarChartDemo({super.key});

  @override
  State<BarChartDemo> createState() => _BarChartDemoState();
}

class _BarChartDemoState extends State<BarChartDemo> {
  bool _showValueLabels = true;

  static const List<DsBarDatum> _data = [
    DsBarDatum(label: 'Mon', value: 1240),
    DsBarDatum(label: 'Tue', value: 1980),
    DsBarDatum(label: 'Wed', value: 1720),
    DsBarDatum(label: 'Thu', value: 2100),
    DsBarDatum(label: 'Fri', value: 2460),
    DsBarDatum(label: 'Sat', value: 1310),
    DsBarDatum(label: 'Sun', value: 980),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsBarChart(
          title: 'Weekly active users',
          data: _data,
          height: 220,
          showValueLabels: _showValueLabels,
        ),
        const SizedBox(height: 20),
        DsSwitch(
          value: _showValueLabels,
          label: 'Show value labels',
          onChanged: (next) => setState(() => _showValueLabels = next),
        ),
      ],
    );
  }
}
