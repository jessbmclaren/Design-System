import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const twoSeries = <DsLineSeries>[
    DsLineSeries(name: 'Web', values: [120, 132, 128, 145, 160]),
    DsLineSeries(name: 'Mobile', values: [90, 96, 104, 100, 118]),
  ];

  testWidgets('renders title and legend names for a multi-series chart',
      (tester) async {
    await pumpDs(
      tester,
      const DsLineChart(
        title: 'Weekly active users',
        xLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        series: twoSeries,
      ),
    );

    expect(find.text('Weekly active users'), findsOneWidget);
    expect(find.text('Web'), findsOneWidget);
    expect(find.text('Mobile'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('omits the legend for a single series', (tester) async {
    await pumpDs(
      tester,
      const DsLineChart(
        title: 'Signups',
        series: [DsLineSeries(name: 'Signups', values: [1, 2, 3, 4])],
      ),
    );

    // Single series relies on the title for identity, so no legend swatch label.
    expect(find.text('Signups'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an empty placeholder when there is no data',
      (tester) async {
    await pumpDs(
      tester,
      const DsLineChart(
        title: 'Empty',
        series: [DsLineSeries(name: 'Nothing', values: [])],
      ),
    );

    expect(find.text('No data'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes a semantic summary describing the chart',
      (tester) async {
    await pumpDs(
      tester,
      const DsLineChart(
        title: 'Weekly active users',
        series: twoSeries,
      ),
    );

    expect(
      find.bySemanticsLabel(RegExp('Line chart titled Weekly active users')),
      findsOneWidget,
    );
  });

  testWidgets('renders without overflow on a small phone', (tester) async {
    await pumpDs(
      tester,
      const DsLineChart(
        title: 'Weekly active users',
        xLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        series: twoSeries,
      ),
      surfaceSize: const Size(320, 900),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('renders without overflow on a large desktop', (tester) async {
    await pumpDs(
      tester,
      const DsLineChart(
        title: 'Weekly active users',
        xLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        series: twoSeries,
      ),
      surfaceSize: const Size(1200, 900),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
