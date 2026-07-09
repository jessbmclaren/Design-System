import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsTabs', () {
    const tabs = [
      DsTab(label: 'Overview'),
      DsTab(label: 'Activity', icon: Icons.timeline),
      DsTab(label: 'Settings'),
    ];

    testWidgets('renders all tab labels', (tester) async {
      await pumpDs(
        tester,
        DsTabs(tabs: tabs, selectedIndex: 0, onChanged: (_) {}),
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.timeline), findsOneWidget);
    });

    testWidgets('tapping a tab calls onChanged with its index', (tester) async {
      int? tapped;
      await pumpDs(
        tester,
        DsTabs(
          tabs: tabs,
          selectedIndex: 0,
          onChanged: (index) => tapped = index,
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(tapped, 2);
    });

    testWidgets('selectedIndex is reflected in the active tab styling',
        (tester) async {
      await pumpDs(
        tester,
        DsTabs(tabs: tabs, selectedIndex: 1, onChanged: (_) {}),
      );

      final selected = tester.widget<Text>(find.text('Activity'));
      final unselected = tester.widget<Text>(find.text('Overview'));

      expect(selected.style?.fontWeight, FontWeight.w600);
      expect(unselected.style?.fontWeight, FontWeight.w500);
      expect(selected.style?.color, isNot(unselected.style?.color));
    });

    testWidgets('many tabs scroll without overflow at 320dp', (tester) async {
      final manyTabs = [
        for (var i = 0; i < 12; i++) DsTab(label: 'Section $i'),
      ];

      await pumpDs(
        tester,
        DsTabs(tabs: manyTabs, selectedIndex: 0, onChanged: (_) {}),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Section 0'), findsOneWidget);
    });
  });
}
