import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Meter chart page.
///
/// Renders a `DsMeterChart` breaking one storage total into four labelled,
/// palette-coloured segments and lets the viewer toggle the legend beneath the
/// bar. The chart draws a stable frame (no timers or animation), so it is safe
/// to screenshot and reflows without overflow down to a 320dp width.
class MeterChartDemo extends StatefulWidget {
  const MeterChartDemo({super.key});

  @override
  State<MeterChartDemo> createState() => _MeterChartDemoState();
}

class _MeterChartDemoState extends State<MeterChartDemo> {
  bool _showLegend = true;

  static const List<DsMeterSegment> _segments = [
    DsMeterSegment(label: 'Photos', value: 45),
    DsMeterSegment(label: 'Video', value: 30),
    DsMeterSegment(label: 'Documents', value: 15),
    DsMeterSegment(label: 'Other', value: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsMeterChart(
          title: 'Storage used',
          segments: _segments,
          showLegend: _showLegend,
        ),
        const SizedBox(height: 20),
        DsSwitch(
          value: _showLegend,
          label: 'Show legend',
          onChanged: (next) => setState(() => _showLegend = next),
        ),
      ],
    );
  }
}
