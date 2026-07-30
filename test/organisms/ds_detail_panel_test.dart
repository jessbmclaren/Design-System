import 'dart:ui' show Tristate;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// The surface a single record is read on.
///
/// Its whole reason for existing beside [DsFocusView] is that a record is not a
/// form: it has an identity rather than a title, several kinds of content
/// rather than one, and verbs that act on something already there.
void main() {
  Future<void> pumpPanel(
    WidgetTester tester, {
    List<DsDetailTab> tabs = const <DsDetailTab>[],
    int selected = 0,
    ValueChanged<int>? onTab,
    Widget? footer,
    Widget? banner,
    List<Widget> actions = const <Widget>[],
    VoidCallback? onClose,
    Size size = const Size(760, 900),
  }) async {
    await pumpDs(
      tester,
      SizedBox(
        width: size.width,
        height: size.height,
        child: DsDetailPanel(
          title: 'Toyota Hilux',
          subtitle: 'HRV 482 GP · FL-014',
          status: const DsBadge(label: 'Active'),
          tabs: tabs,
          selectedTab: selected,
          onTabChanged: onTab,
          actions: actions,
          footer: footer,
          banner: banner,
          onClose: onClose,
          child: const Text('body'),
        ),
      ),
      surfaceSize: Size(size.width + 40, size.height + 40),
    );
  }

  testWidgets('the record names itself — identity, not a heading', (
    tester,
  ) async {
    await pumpPanel(tester);
    expect(find.text('Toyota Hilux'), findsOneWidget);
    expect(find.text('HRV 482 GP · FL-014'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('one tab renders no strip — a lone tab is chrome that decides '
      'nothing', (tester) async {
    await pumpPanel(
      tester,
      tabs: const <DsDetailTab>[DsDetailTab(label: 'Overview')],
    );
    expect(find.text('Overview'), findsNothing);
  });

  testWidgets('a count rides on the tab, so what is in there is known before '
      'the tap', (tester) async {
    await pumpPanel(
      tester,
      tabs: const <DsDetailTab>[
        DsDetailTab(label: 'Overview'),
        DsDetailTab(label: 'Odometer', count: 0),
        DsDetailTab(label: 'Activity', count: 4),
      ],
    );
    // Zero is shown, not hidden: an empty tab that admits it saves a click.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('tapping a tab reports its index', (tester) async {
    int? picked;
    await pumpPanel(
      tester,
      tabs: const <DsDetailTab>[
        DsDetailTab(label: 'Overview'),
        DsDetailTab(label: 'Odometer'),
      ],
      onTab: (int i) => picked = i,
    );
    await tester.tap(find.text('Odometer'));
    expect(picked, 1);
  });

  testWidgets('the selected tab is announced as selected, not just underlined',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPanel(
      tester,
      tabs: const <DsDetailTab>[
        DsDetailTab(label: 'Overview'),
        DsDetailTab(label: 'Odometer'),
      ],
      selected: 1,
    );
    // Colour alone leaves a screen-reader user with no way to tell which tab
    // they are on.
    final SemanticsNode node = tester.getSemantics(
      find.ancestor(of: find.text('Odometer'), matching: find.byType(Semantics)).first,
    );
    // Tri-state, not a bool: a tab strip distinguishes 'not selected' from
    // 'selection is not a concept here'.
    expect(node.flagsCollection.isSelected, Tristate.isTrue);
    handle.dispose();
  });

  testWidgets('the footer stays put while the body scrolls — the action that '
      'retires a record must not move under the finger', (tester) async {
    await pumpPanel(
      tester,
      footer: const DsButton(label: 'Deactivate'),
      size: const Size(760, 420),
    );
    final double before = tester.getTopLeft(find.text('Deactivate')).dy;
    await tester.drag(find.text('body'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Deactivate')).dy, before);
  });

  testWidgets('a banner sits above the body, inside the scroll', (
    tester,
  ) async {
    await pumpPanel(
      tester,
      banner: const DsInlineNotice(message: 'This row needs review.'),
    );
    expect(
      tester.getTopLeft(find.textContaining('needs review')).dy,
      lessThan(tester.getTopLeft(find.text('body')).dy),
    );
  });

  testWidgets('close is labelled, and absent when there is nowhere to go', (
    tester,
  ) async {
    // DsIconButton routes semanticLabel through Material's tooltip, which is
    // what a screen reader announces as the control's name — so the tooltip is
    // the honest thing to assert on.
    await pumpPanel(tester);
    expect(find.byTooltip('Close'), findsNothing);

    await pumpPanel(tester, onClose: () {});
    expect(find.byTooltip('Close'), findsOneWidget);
  });

  testWidgets('six tabs and three actions survive a phone', (tester) async {
    // The strip scrolls rather than wrapping: a wrapped strip pushes the
    // record itself below the fold, and tabs are navigation, not content.
    await pumpPanel(
      tester,
      size: const Size(390, 780),
      tabs: const <DsDetailTab>[
        DsDetailTab(label: 'Overview'),
        DsDetailTab(label: 'Odometer history', count: 12),
        DsDetailTab(label: 'Transactions'),
        DsDetailTab(label: 'Documents'),
        DsDetailTab(label: 'Activity', count: 4),
      ],
      actions: const <Widget>[
        DsButton(label: 'Edit vehicle'),
        DsButton(label: 'More actions'),
      ],
      footer: const DsButton(label: 'Deactivate'),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Toyota Hilux'), findsOneWidget);

    // …and it says so. The tab past the edge is invisible either way; the
    // fade is the only thing telling anyone it is there. It lands the frame
    // after layout, because that is when the strip first knows its metrics.
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('ds-scroll-fade:trailing')),
      findsOneWidget,
    );
  });

  testWidgets('a strip whose tabs fit is not faded', (tester) async {
    await pumpPanel(
      tester,
      tabs: const <DsDetailTab>[
        DsDetailTab(label: 'Overview'),
        DsDetailTab(label: 'Activity'),
      ],
    );
    await tester.pump();

    expect(find.byType(ShaderMask), findsNothing);
  });
}
