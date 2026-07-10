import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// A three-level tree: two top-level groups, one with subgroups and children.
List<DsTreeNode> _nodes() => const <DsTreeNode>[
      DsTreeNode(
        id: 'customers',
        label: 'Customers',
        icon: Icons.folder_outlined,
        badgeCount: 3,
        children: <DsTreeNode>[
          DsTreeNode(
            id: 'active',
            label: 'Active',
            badgeCount: 2,
            children: <DsTreeNode>[
              DsTreeNode(id: 'acme', label: 'Acme Corp'),
              DsTreeNode(id: 'globex', label: 'Globex'),
            ],
          ),
          DsTreeNode(id: 'churned', label: 'Churned'),
        ],
      ),
      DsTreeNode(
        id: 'suppliers',
        label: 'Suppliers',
        icon: Icons.local_shipping_outlined,
        badgeCount: 1,
        children: <DsTreeNode>[
          DsTreeNode(id: 'northwind', label: 'Northwind'),
        ],
      ),
    ];

/// A deep, long-labelled tree used to prove rows never overflow.
List<DsTreeNode> _deepNodes() {
  DsTreeNode leaf(int i) => DsTreeNode(
        id: 'leaf-$i',
        label: 'A very very long node label that must ellipsize gracefully $i',
        subtitle: 'A secondary line of descriptive text that also ellipsizes',
        badgeCount: 128,
      );

  DsTreeNode node = leaf(8);
  for (var depth = 7; depth >= 0; depth--) {
    node = DsTreeNode(
      id: 'branch-$depth',
      label: 'Deeply nested branch level $depth with a long trailing label',
      icon: Icons.folder_outlined,
      badgeCount: 999,
      children: <DsTreeNode>[node],
    );
  }
  return <DsTreeNode>[node];
}

void main() {
  group('DsTreeView', () {
    testWidgets('renders top-level nodes', (tester) async {
      await pumpDs(
        tester,
        SizedBox(width: 360, child: DsTreeView(nodes: _nodes())),
        surfaceSize: const Size(800, 800),
      );
      await tester.pump();

      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Suppliers'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expanding a parent reveals its children and collapsing hides '
        'them', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 360,
          // Start collapsed so we drive expansion ourselves.
          child: DsTreeView(nodes: _nodes(), initiallyExpandsAll: false),
        ),
        surfaceSize: const Size(800, 800),
      );
      await tester.pump();

      // Collapsed: only the top-level rows are visible.
      expect(find.text('Active'), findsNothing);

      // Expand 'Customers' via its chevron.
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pump();
      expect(find.text('Active'), findsOneWidget);
      // Its grandchildren stay hidden until 'Active' is expanded too.
      expect(find.text('Acme Corp'), findsNothing);

      // Collapse again hides the children.
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pump();
      expect(find.text('Active'), findsNothing);
    });

    testWidgets('badgeCount renders as a trailing badge', (tester) async {
      await pumpDs(
        tester,
        SizedBox(width: 360, child: DsTreeView(nodes: _nodes())),
        surfaceSize: const Size(800, 800),
      );
      await tester.pump();

      expect(find.byType(DsBadge), findsWidgets);
      // The top-level 'Customers' count.
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tapping a row calls onSelect with the id', (tester) async {
      String? selected;
      await pumpDs(
        tester,
        SizedBox(
          width: 360,
          child: DsTreeView(
            nodes: _nodes(),
            onSelect: (id) => selected = id,
          ),
        ),
        surfaceSize: const Size(800, 800),
      );
      await tester.pump();

      await tester.tap(find.text('Suppliers'));
      await tester.pump();
      expect(selected, 'suppliers');
    });

    testWidgets('keyboard focus + Enter selects a row', (tester) async {
      String? selected;
      await pumpDs(
        tester,
        SizedBox(
          width: 360,
          child: DsTreeView(
            nodes: _nodes(),
            onSelect: (id) => selected = id,
          ),
        ),
        surfaceSize: const Size(800, 800),
      );
      await tester.pump();

      // Tab focuses the first row; Enter activates (selects) it.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(selected, 'customers');
    });

    testWidgets('a reparent drop reports onMoveNode with the right ids',
        (tester) async {
      DsTreeReparent? move;
      await pumpDs(
        tester,
        SizedBox(
          width: 420,
          child: DsTreeView(
            nodes: _nodes(),
            onMoveNode: (m) => move = m,
          ),
        ),
        surfaceSize: const Size(800, 800),
      );
      await tester.pump();

      // Long-press-drag 'Globex' (a leaf) onto 'Suppliers' (a top-level group).
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Globex')),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      await gesture.moveTo(tester.getCenter(find.text('Suppliers')));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(move, isNotNull);
      expect(move!.nodeId, 'globex');
      expect(move!.newParentId, 'suppliers');
    });

    testWidgets('a drop onto the current parent reports no move', (tester) async {
      // Regression: dropping a node back onto its own parent changes nothing and
      // must not be reported as a move.
      DsTreeReparent? move;
      await pumpDs(
        tester,
        SizedBox(
          width: 420,
          child: DsTreeView(
            nodes: _nodes(),
            onMoveNode: (m) => move = m,
          ),
        ),
        surfaceSize: const Size(800, 800),
      );
      await tester.pump();

      // 'Globex' is already a child of 'Active'; dropping it there is a no-op.
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Globex')),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      await gesture.moveTo(tester.getCenter(find.text('Active')));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(move, isNull);
    });

    testWidgets('a self / descendant drop is rejected', (tester) async {
      DsTreeReparent? move;
      await pumpDs(
        tester,
        SizedBox(
          width: 420,
          child: DsTreeView(
            nodes: _nodes(),
            onMoveNode: (m) => move = m,
          ),
        ),
        surfaceSize: const Size(800, 800),
      );
      await tester.pump();

      // Drag 'Customers' onto 'Active', its own descendant — a cycle. The move
      // must not be reported.
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Customers')),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      await gesture.moveTo(tester.getCenter(find.text('Active')));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(move, isNull);
    });

    testWidgets('no overflow across the responsive sweep', (tester) async {
      for (final width in <double>[320, 768, 1440]) {
        await pumpDs(
          tester,
          SizedBox(
            width: width,
            height: 640,
            child: SingleChildScrollView(
              child: DsTreeView(nodes: _deepNodes()),
            ),
          ),
          surfaceSize: Size(width, 800),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: 'DsTreeView overflowed at width $width',
        );
      }
    });
  });
}
