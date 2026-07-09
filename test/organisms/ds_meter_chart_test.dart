import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

import '../helpers.dart';

void main() {
  const segments = <DsMeterSegment>[
    DsMeterSegment(label: 'Photos', value: 45),
    DsMeterSegment(label: 'Video', value: 30),
    DsMeterSegment(label: 'Docs', value: 15),
    DsMeterSegment(label: 'Other', value: 10),
  ];

  testWidgets('renders title, legend labels and percentages', (tester) async {
    await pumpDs(
      tester,
      const DsMeterChart(title: 'Storage used', segments: segments),
    );

    expect(find.text('Storage used'), findsOneWidget);
    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('Video'), findsOneWidget);
    expect(find.text('Docs'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    // 45 of 100 -> 45%.
    expect(find.text('45 (45%)'), findsOneWidget);
    expect(find.text('30 (30%)'), findsOneWidget);
  });

  testWidgets('paints the meter bar via CustomPaint without exception',
      (tester) async {
    await pumpDs(tester, const DsMeterChart(segments: segments));

    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides legend when showLegend is false', (tester) async {
    await pumpDs(
      tester,
      const DsMeterChart(segments: segments, showLegend: false),
    );

    expect(find.text('Photos'), findsNothing);
    expect(find.text('45 (45%)'), findsNothing);
    // Bar still renders.
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('renders an empty-track bar with no segments', (tester) async {
    await pumpDs(
      tester,
      const DsMeterChart(title: 'Empty', segments: <DsMeterSegment>[]),
    );

    expect(find.text('Empty'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow at 320x900 (small phone)', (tester) async {
    await pumpDs(
      tester,
      const DsMeterChart(title: 'Storage used', segments: segments),
      surfaceSize: const Size(320, 900),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow at 1200x900 (large desktop)', (tester) async {
    await pumpDs(
      tester,
      const DsMeterChart(title: 'Storage used', segments: segments),
      surfaceSize: const Size(1200, 900),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
