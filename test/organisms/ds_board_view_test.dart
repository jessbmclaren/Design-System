import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// A group column whose options define the lanes, plus a few card fields.
const _columns = <DsGridColumn>[
  DsGridColumn(key: 'name', title: 'Name'),
  DsGridColumn(
    key: 'stage',
    title: 'Stage',
    type: DsCellType.status,
    options: [
      DsGridOption(value: 'todo', label: 'To do', variant: DsBadgeVariant.warning),
      DsGridOption(
          value: 'doing', label: 'In progress', variant: DsBadgeVariant.neutral),
      DsGridOption(
          value: 'done', label: 'Done', variant: DsBadgeVariant.success),
    ],
  ),
  DsGridColumn(key: 'owner', title: 'Owner', type: DsCellType.user),
  DsGridColumn(
      key: 'amount', title: 'Amount', type: DsCellType.currency, currencySymbol: r'$'),
  DsGridColumn(key: 'due', title: 'Due', type: DsCellType.date),
];

List<DsGridRow> _rows() => [
      DsGridRow(id: 'a', cells: {
        'name': 'Task A', 'stage': 'todo', 'owner': 'Ada Lovelace',
        'amount': 1200, 'due': DateTime(2026, 7, 1),
      }),
      DsGridRow(id: 'b', cells: {
        'name': 'Task B', 'stage': 'doing', 'owner': 'Grace Hopper',
        'amount': 800, 'due': DateTime(2026, 8, 15),
      }),
      DsGridRow(id: 'c', cells: {
        'name': 'Task C', 'stage': 'done', 'owner': 'Alan Turing',
        'amount': 300, 'due': DateTime(2026, 6, 20),
      }),
      DsGridRow(id: 'd', cells: {
        'name': 'Task D', 'stage': 'todo', 'owner': 'Katherine Johnson',
        'amount': 500, 'due': DateTime(2026, 9, 5),
      }),
      // 'stage' is not one of the options -> lands in the Ungrouped lane.
      DsGridRow(id: 'e', cells: {
        'name': 'Task E', 'stage': 'archived', 'owner': 'Edsger Dijkstra',
      }),
      // Missing 'stage' -> also Ungrouped.
      DsGridRow(id: 'f', cells: {'name': 'Task F'}),
    ];

void main() {
  group('DsBoardView', () {
    testWidgets('renders a lane per option plus an Ungrouped lane',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          height: 600,
          child: DsBoardView(
            columns: _columns,
            rows: _rows(),
            groupByKey: 'stage',
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      // Lane headers render the option labels (as badges) and the Ungrouped lane.
      expect(find.text('To do'), findsWidgets);
      expect(find.text('In progress'), findsWidgets);
      expect(find.text('Done'), findsWidgets);
      expect(find.text('Ungrouped'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cards land in the lane matching their group value',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          height: 600,
          child: DsBoardView(
            columns: _columns,
            rows: _rows(),
            groupByKey: 'stage',
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      // Every card's primary text is shown exactly once, in some lane.
      for (final name in ['Task A', 'Task B', 'Task C', 'Task D', 'Task E', 'Task F']) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
    });

    testWidgets('lane card counts are correct', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          height: 600,
          child: DsBoardView(
            columns: _columns,
            rows: _rows(),
            groupByKey: 'stage',
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      // Counts are exposed on each lane header's semantics label.
      // To do: A + D = 2. In progress: B = 1. Done: C = 1. Ungrouped: E + F = 2.
      expect(find.bySemanticsLabel('To do lane, 2 cards'), findsOneWidget);
      expect(find.bySemanticsLabel('In progress lane, 1 cards'), findsOneWidget);
      expect(find.bySemanticsLabel('Done lane, 1 cards'), findsOneWidget);
      expect(find.bySemanticsLabel('Ungrouped lane, 2 cards'), findsOneWidget);
    });

    testWidgets('the "Move to…" menu reports the target group', (tester) async {
      ({String rowId, String? toGroup})? moved;
      await pumpDs(
        tester,
        SizedBox(
          height: 600,
          child: DsBoardView(
            columns: _columns,
            rows: _rows(),
            groupByKey: 'stage',
            onRowMoved: (m) => moved = m,
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      // Open Task A's move menu (it currently sits in the To do lane). The move
      // affordance is the kebab button inside Task A's card.
      final cardA = find.ancestor(
        of: find.text('Task A'),
        matching: find.byType(LongPressDraggable<String>),
      );
      await tester.tap(
        find.descendant(of: cardA, matching: find.byIcon(DsIcons.moreVertical)),
      );
      await tester.pumpAndSettle();

      // Choose the In progress ('doing') lane.
      await tester.tap(find.text('Move to In progress'));
      await tester.pumpAndSettle();

      expect(moved, isNotNull);
      expect(moved!.rowId, 'a');
      expect(moved!.toGroup, 'doing');
    });

    testWidgets('moving to the Ungrouped lane reports an empty group',
        (tester) async {
      ({String rowId, String? toGroup})? moved;
      await pumpDs(
        tester,
        SizedBox(
          height: 600,
          child: DsBoardView(
            columns: _columns,
            rows: _rows(),
            groupByKey: 'stage',
            onRowMoved: (m) => moved = m,
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      final cardB = find.ancestor(
        of: find.text('Task B'),
        matching: find.byType(LongPressDraggable<String>),
      );
      await tester.tap(
        find.descendant(of: cardB, matching: find.byIcon(DsIcons.moreVertical)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move to Ungrouped'));
      await tester.pumpAndSettle();

      expect(moved, isNotNull);
      expect(moved!.rowId, 'b');
      expect(moved!.toGroup, isNull);
    });

    testWidgets('tapping a card invokes onCardTap', (tester) async {
      DsGridRow? tapped;
      await pumpDs(
        tester,
        SizedBox(
          height: 600,
          child: DsBoardView(
            columns: _columns,
            rows: _rows(),
            groupByKey: 'stage',
            onCardTap: (row) => tapped = row,
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      await tester.tap(find.text('Task C'));
      await tester.pump();
      expect(tapped, isNotNull);
      expect(tapped!.id, 'c');
    });

    testWidgets('collapses a lane on a narrow phone', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          height: 700,
          child: DsBoardView(
            columns: _columns,
            rows: _rows(),
            groupByKey: 'stage',
          ),
        ),
        surfaceSize: const Size(360, 700),
      );
      await tester.pump();

      // The card is visible before collapsing its lane.
      expect(find.text('Task B'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Collapse In progress'));
      await tester.pump();
      // After collapsing, the In progress lane's card is hidden.
      expect(find.text('Task B'), findsNothing);
    });

    testWidgets('no overflow across device widths', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;
      for (final w in <double>[320, 600, 768, 1440]) {
        tester.view.physicalSize = Size(w, 1000);
        await tester.pumpWidget(
          MaterialApp(
            theme: DsTheme.light(),
            home: Scaffold(
              body: SizedBox(
                height: 800,
                child: DsBoardView(
                  columns: _columns,
                  rows: _rows(),
                  groupByKey: 'stage',
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'overflow at ${w}dp');
      }
    });
  });
}
