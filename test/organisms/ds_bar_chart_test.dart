import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const sampleData = [
    DsBarDatum(label: 'Mon', value: 120),
    DsBarDatum(label: 'Tue', value: 200),
    DsBarDatum(label: 'Wed', value: 150),
  ];

  testWidgets('renders its title and paints the chart', (tester) async {
    await pumpDs(
      tester,
      const DsBarChart(title: 'Weekly active users', data: sampleData),
    );

    expect(find.text('Weekly active users'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('summarises the series for assistive tech', (tester) async {
    await pumpDs(
      tester,
      const DsBarChart(title: 'Weekly active users', data: sampleData),
    );

    final semantics = tester.getSemantics(find.byType(DsBarChart));
    expect(semantics.label, contains('Weekly active users'));
    expect(semantics.label, contains('3 categories'));
    expect(semantics.label, contains('Mon: 120'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders nothing but a stable frame when data is empty',
      (tester) async {
    await pumpDs(tester, const DsBarChart(data: []));

    expect(find.byType(DsBarChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omits value labels title when title is null', (tester) async {
    await pumpDs(
      tester,
      const DsBarChart(data: sampleData, showValueLabels: false),
    );

    // No title supplied, so no heading Text should render.
    expect(find.text('Weekly active users'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders at a 320dp phone without overflow', (tester) async {
    await pumpDs(
      tester,
      const DsBarChart(title: 'Revenue', data: sampleData),
      surfaceSize: const Size(320, 900),
    );
    await tester.pump();

    expect(find.byType(DsBarChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders at a 1200dp desktop without overflow', (tester) async {
    await pumpDs(
      tester,
      const DsBarChart(title: 'Revenue', data: sampleData),
      surfaceSize: const Size(1200, 900),
    );
    await tester.pump();

    expect(find.byType(DsBarChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
