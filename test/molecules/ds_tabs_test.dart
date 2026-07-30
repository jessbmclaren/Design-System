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

    group('the overflowing edge fades', () {
      // The mask's key names the edges it is softening.
      Finder fade(String edges) =>
          find.byKey(ValueKey<String>('ds-scroll-fade:$edges'));

      final manyTabs = [
        for (var i = 0; i < 12; i++) DsTab(label: 'Section $i'),
      ];

      testWidgets('tabs that fit are not faded, and pay no mask', (
        tester,
      ) async {
        await pumpDs(
          tester,
          DsTabs(tabs: tabs, selectedIndex: 0, onChanged: (_) {}),
          surfaceSize: const Size(800, 640),
        );
        await tester.pump();

        expect(find.byType(ShaderMask), findsNothing);
      });

      testWidgets('at rest the far edge fades, because that is where the '
          'hidden tabs are', (tester) async {
        await pumpDs(
          tester,
          DsTabs(tabs: manyTabs, selectedIndex: 0, onChanged: (_) {}),
          surfaceSize: const Size(320, 640),
        );
        await tester.pump();

        expect(fade('trailing'), findsOneWidget);
      });

      testWidgets('scrolled to the end, the fade moves to the edge the tabs '
          'are now behind', (tester) async {
        await pumpDs(
          tester,
          DsTabs(tabs: manyTabs, selectedIndex: 0, onChanged: (_) {}),
          surfaceSize: const Size(320, 640),
        );
        await tester.pump();

        // Dragged part of the way along by hand: hidden tabs in both
        // directions now, so both ends say so. The drag also pins that the
        // scroll position survives the mask appearing above it.
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(DsTabs)),
        );
        await gesture.moveBy(const Offset(-40, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(-260, 0));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();
        expect(fade('leading+trailing'), findsOneWidget);

        final position = tester
            .state<ScrollableState>(find.byType(Scrollable))
            .position;
        expect(position.pixels, greaterThan(0));

        position.jumpTo(position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(fade('leading'), findsOneWidget);
        expect(find.text('Section 11'), findsOneWidget);
      });
    });
  });
}
