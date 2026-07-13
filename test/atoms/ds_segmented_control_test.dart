import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Dir { asc, desc }

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 400,
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? DsTheme.light(),
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  const segments = <DsSegment<_Dir>>[
    DsSegment(value: _Dir.asc, label: 'Asc'),
    DsSegment(value: _Dir.desc, label: 'Desc'),
  ];

  testWidgets('renders every segment label', (tester) async {
    await _pump(
      tester,
      DsSegmentedControl<_Dir>(
        segments: segments,
        value: _Dir.asc,
        onChanged: (_) {},
      ),
    );
    expect(find.text('Asc'), findsOneWidget);
    expect(find.text('Desc'), findsOneWidget);
  });

  testWidgets('tapping a segment reports its value', (tester) async {
    _Dir? picked;
    await _pump(
      tester,
      DsSegmentedControl<_Dir>(
        segments: segments,
        value: _Dir.asc,
        onChanged: (v) => picked = v,
      ),
    );
    await tester.tap(find.text('Desc'));
    expect(picked, _Dir.desc);
  });

  testWidgets('exposes the selected state to assistive technology', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      DsSegmentedControl<_Dir>(
        segments: segments,
        value: _Dir.asc,
        onChanged: (_) {},
      ),
    );
    expect(tester.getSemantics(find.bySemanticsLabel('Asc')),
        isSemantics(isSelected: true, isButton: true));
    expect(tester.getSemantics(find.bySemanticsLabel('Desc')),
        isSemantics(isSelected: false));
    handle.dispose();
  });

  testWidgets('a null onChanged disables it and drops it from the focus order', (tester) async {
    await _pump(
      tester,
      DsSegmentedControl<_Dir>(
        segments: segments,
        value: _Dir.asc,
        onChanged: null,
      ),
    );
    // The control renders but is inert: its subtree is wrapped in an
    // IgnorePointer so no segment responds.
    final ignore = tester.widget<IgnorePointer>(
      find.descendant(
        of: find.byType(DsSegmentedControl<_Dir>),
        matching: find.byType(IgnorePointer),
      ),
    );
    expect(ignore.ignoring, isTrue);
    expect(find.text('Asc'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an icon-only segment carries a semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      DsSegmentedControl<_Dir>(
        segments: const [
          DsSegment(value: _Dir.asc, icon: DsIcons.arrowUp, semanticLabel: 'Ascending'),
          DsSegment(value: _Dir.desc, icon: DsIcons.arrowDown, semanticLabel: 'Descending'),
        ],
        value: _Dir.asc,
        onChanged: (_) {},
      ),
    );
    expect(find.bySemanticsLabel('Ascending'), findsOneWidget);
    expect(find.bySemanticsLabel('Descending'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('no overflow at 320dp and at a wide width', (tester) async {
    for (final w in [320.0, 1200.0]) {
      await _pump(
        tester,
        DsSegmentedControl<_Dir>(segments: segments, value: _Dir.asc, onChanged: (_) {}),
        width: w,
      );
      expect(tester.takeException(), isNull, reason: 'overflowed at ${w}dp');
    }
  });

  testWidgets('renders under a skin without error', (tester) async {
    await _pump(
      tester,
      DsSegmentedControl<_Dir>(segments: segments, value: _Dir.desc, onChanged: (_) {}),
      theme: DsTheme.light(tokens: DsSkins.engenLight()),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Desc'), findsOneWidget);
  });
}
