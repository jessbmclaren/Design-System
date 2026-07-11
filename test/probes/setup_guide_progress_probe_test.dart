// Probe tests for DsSetupGuide and DsProgressBar edge behaviour.
//
// Each probe drives the real widget and asserts what it observes. The
// defects these probes originally pinned with // BUG: markers have been
// fixed, so every probe now asserts the correct behaviour.

import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const Key _shotKey = Key('probe-shot');

/// A 300-character German compound word for label stress.
final String _german =
    ('Rindfleischetikettierungsueberwachungsaufgabenuebertragungsgesetz' * 5)
        .substring(0, 300);

/// A 100-character email address.
final String _longEmail = '${'a' * 88}@example.com';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(800, 1000),
  ThemeData? theme,
  bool reduceMotion = false,
  double textScale = 1.0,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? DsTheme.light(),
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(
            size: size,
            disableAnimations: reduceMotion,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Center(
            child: RepaintBoundary(key: _shotKey, child: child),
          ),
        ),
      ),
    ),
  );
}

DsSetupGuide _crossOffGuide({required bool done}) {
  return DsSetupGuide(
    title: 'Setup guide',
    tasks: [
      DsSetupTask(
        label: 'Verify your email',
        done: done,
        animateCrossOff: true,
      ),
      const DsSetupTask(label: 'Add your vehicles'),
    ],
  );
}

Finder get _crossOffClip => find.descendant(
      of: find.byType(DsSetupGuide),
      matching: find.byType(ClipRect),
    );

/// Collects every node of the app's semantics tree, root first.
List<SemanticsNode> _allSemantics(WidgetTester tester) {
  var root = tester.getSemantics(find.byType(DsSetupGuide));
  while (root.parent != null) {
    root = root.parent!;
  }
  final nodes = <SemanticsNode>[];
  bool visit(SemanticsNode node) {
    nodes.add(node);
    node.visitChildren(visit);
    return true;
  }

  visit(root);
  return nodes;
}

void main() {
  group('DsProgressBar probes', () {
    testWidgets('NaN value renders an empty bar', (tester) async {
      await _pump(tester, const DsProgressBar(value: double.nan));
      expect(tester.takeException(), isNull);
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      // NaN (a 0/0 progress fraction in a careless caller) is documented to
      // render as 0, an empty bar, instead of surviving the clamp and
      // painting 100 percent complete.
      expect(indicator.value, 0.0);

      // The animated path treats NaN the same way.
      await _pump(
        tester,
        const DsProgressBar(value: double.nan, animate: true),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.0,
      );
    });

    testWidgets('infinite value clamps to a full bar', (tester) async {
      await _pump(tester, const DsProgressBar(value: double.infinity));
      expect(tester.takeException(), isNull);
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 1.0);
    });

    testWidgets('value flapping every frame retargets without error', (
      tester,
    ) async {
      var value = 0.0;
      for (var i = 0; i < 30; i++) {
        value = value == 0.0 ? 1.0 : 0.0;
        await tester.pumpWidget(
          MaterialApp(
            theme: DsTheme.light(),
            home: Scaffold(body: DsProgressBar(value: value, animate: true)),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, value);
    });

    testWidgets('a retarget under reduced motion lands instantly', (
      tester,
    ) async {
      await _pump(
        tester,
        const DsProgressBar(value: 0.2, animate: true),
        reduceMotion: true,
      );
      await tester.pump();
      await _pump(
        tester,
        const DsProgressBar(value: 0.9, animate: true),
        reduceMotion: true,
      );
      await tester.pump();
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.9);
    });

    testWidgets('an unbounded-width parent fails the layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: const Scaffold(
            body: Row(children: [DsProgressBar(value: 0.5)]),
          ),
        ),
      );
      // Standard LinearProgressIndicator behaviour: it sizes to the maximum
      // width, which a Row leaves unbounded. Recorded as expected Flutter
      // behaviour, not a defect; callers must bound the width.
      expect(tester.takeException(), isNotNull);
    });
  });

  group('DsSetupGuide structure edges', () {
    testWidgets('zero tasks renders 0 of 0 with an empty bar', (tester) async {
      await _pump(
        tester,
        const DsSetupGuide(title: 'Setup guide', tasks: []),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('0 of 0'), findsOneWidget);
      await tester.pumpAndSettle();
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.0);

      // Collapsed with zero tasks and no summary shows just the chrome.
      await tester.tap(find.text('Setup guide'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Next:'), findsNothing);
    });

    testWidgets('all done reaches a full bar and n of n copy', (tester) async {
      await _pump(
        tester,
        const DsSetupGuide(
          title: 'Setup guide',
          tasks: [
            DsSetupTask(label: 'One', done: true),
            DsSetupTask(label: 'Two', done: true),
            DsSetupTask(label: 'Three', done: true),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3 of 3'), findsOneWidget);
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 1.0);
      expect(find.byIcon(DsIcons.check), findsNWidgets(3));
    });

    testWidgets('collapsed with all done shows the summary, all pending none', (
      tester,
    ) async {
      await _pump(
        tester,
        const DsSetupGuide(
          title: 'Setup guide',
          initiallyCollapsed: true,
          collapsedSummary: 'You are all set',
          tasks: [
            DsSetupTask(label: 'One', done: true),
            DsSetupTask(label: 'Two', done: true),
          ],
        ),
      );
      expect(find.text('Next:'), findsNothing);
      expect(find.text('You are all set'), findsOneWidget);

      await _pump(
        tester,
        const DsSetupGuide(
          title: 'Setup guide',
          initiallyCollapsed: true,
          tasks: [
            DsSetupTask(label: 'One', pending: true),
            DsSetupTask(label: 'Two', pending: true),
          ],
        ),
      );
      expect(find.text('Next:'), findsNothing);
      expect(find.byType(DsLink), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('one task drives the fraction and the Next line', (
      tester,
    ) async {
      await _pump(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          initiallyCollapsed: true,
          tasks: [DsSetupTask(label: 'Only task', onTap: () {})],
        ),
      );
      expect(find.text('0 of 1'), findsOneWidget);
      expect(find.text('Next:'), findsOneWidget);
      expect(find.widgetWithText(DsLink, 'Only task'), findsOneWidget);
    });

    testWidgets('40 tasks scroll under maxHeight and the header stays put', (
      tester,
    ) async {
      await _pump(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          maxHeight: 300,
          tasks: [
            for (var i = 1; i <= 40; i++)
              DsSetupTask(label: 'Task number $i', onTap: () {}),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      final card = tester.getRect(find.byType(DsSetupGuide));
      expect(card.height, lessThanOrEqualTo(300));

      final headerBefore = tester.getRect(find.text('Setup guide'));
      // The last task is built but laid out beyond the card, clipped away.
      expect(
        tester.getRect(find.text('Task number 40')).top,
        greaterThan(card.bottom),
      );

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -3000),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      // Header does not scroll with the list.
      expect(tester.getRect(find.text('Setup guide')), headerBefore);
      // The end of the list is now inside the card.
      expect(
        tester.getRect(find.text('Task number 40')).bottom,
        lessThanOrEqualTo(card.bottom),
      );
    });

    testWidgets('a maxHeight below the fixed chrome clamps up to the chrome', (
      tester,
    ) async {
      await _pump(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          maxHeight: 80,
          tasks: [DsSetupTask(label: 'Task', onTap: () {})],
        ),
      );
      // The budget clamps up to the fixed chrome (border, padding, header
      // and bar), so the card renders the chrome intact and starves only the
      // task list instead of overflowing the Column.
      expect(tester.takeException(), isNull);
      final card = tester.getRect(find.byType(DsSetupGuide));
      expect(card.height, 106);
      expect(find.text('Setup guide'), findsOneWidget);

      // The same starvation holds collapsed: the Next line is flexible too.
      await _pump(
        tester,
        DsSetupGuide(
          key: const ValueKey('collapsed-starved'),
          title: 'Setup guide',
          initiallyCollapsed: true,
          maxHeight: 80,
          tasks: [DsSetupTask(label: 'Task', onTap: () {})],
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.byType(DsSetupGuide)).height, 106);
    });

    testWidgets('long labels ellipsize at 320dp and 1.3x scale', (
      tester,
    ) async {
      final tasks = [
        DsSetupTask(label: 'L' * 200, onTap: () {}),
        DsSetupTask(label: _longEmail, pending: true),
        DsSetupTask(label: _german, locked: true, lockedMessage: _german),
      ];
      await _pump(
        tester,
        DsSetupGuide(title: _german, tasks: tasks),
        size: const Size(320, 900),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);

      // Collapsed, the 200-char label flows into the Next line's DsLink. A
      // fresh key forces a remount, because initiallyCollapsed is only read
      // once when the state is created.
      await _pump(
        tester,
        DsSetupGuide(
          key: const ValueKey('collapsed-guide'),
          title: _german,
          initiallyCollapsed: true,
          tasks: tasks,
        ),
        size: const Size(320, 900),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(DsLink), findsOneWidget);
    });

    testWidgets('2x text scale at 320dp does not overflow a row', (
      tester,
    ) async {
      await _pump(
        tester,
        const DsSetupGuide(
          title: 'Setup guide',
          tasks: [
            DsSetupTask(label: 'Verify your email', done: true),
            DsSetupTask(label: 'Verify your business', pending: true),
            DsSetupTask(
              label: 'Go live',
              locked: true,
              lockedMessage: 'Verify your business to go live',
            ),
          ],
        ),
        size: const Size(320, 900),
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders under the dark theme and the engen skin', (
      tester,
    ) async {
      const guide = DsSetupGuide(
        title: 'Setup guide',
        tasks: [
          DsSetupTask(label: 'One', done: true),
          DsSetupTask(label: 'Two', pending: true),
          DsSetupTask(label: 'Three', locked: true, lockedMessage: 'Later'),
        ],
      );
      await _pump(tester, guide, theme: DsTheme.dark());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await _pump(
        tester,
        guide,
        theme: DsTheme.light(tokens: DsSkins.engenLight()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('1 of 3'), findsOneWidget);
    });

    testWidgets('fullWidth inside an unbounded-width Row fails the layout', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: const Scaffold(
            body: Row(
              children: [
                DsSetupGuide(
                  title: 'Setup guide',
                  fullWidth: true,
                  tasks: [DsSetupTask(label: 'One')],
                ),
              ],
            ),
          ),
        ),
      );
      // Documented behaviour: fullWidth presumes a parent that bounds the
      // card's width. A Row slot without Expanded provides none, so
      // width: double.infinity fails the layout the same way SizedBox.expand
      // would; wrap the card in Expanded there.
      expect(tester.takeException(), isNotNull);
    });

    testWidgets('the floating card is safe in an unbounded-width Row', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: const Scaffold(
            body: Row(
              children: [
                DsSetupGuide(
                  title: 'Setup guide',
                  tasks: [DsSetupTask(label: 'One')],
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(DsSetupGuide)).width, 320);
    });

    testWidgets('initiallyCollapsed changing after mount is ignored', (
      tester,
    ) async {
      await _pump(
        tester,
        const DsSetupGuide(
          title: 'Setup guide',
          tasks: [DsSetupTask(label: 'One')],
        ),
      );
      expect(find.text('One'), findsOneWidget);

      await _pump(
        tester,
        const DsSetupGuide(
          title: 'Setup guide',
          initiallyCollapsed: true,
          tasks: [DsSetupTask(label: 'One')],
        ),
      );
      await tester.pump();
      // Documented as "initially": the disclosure state stays internal after
      // mount, so the flip has no effect. Recorded as intended behaviour.
      expect(find.text('Next:'), findsNothing);
      expect(find.text('One'), findsOneWidget);
    });
  });

  group('cross-off interruption probes', () {
    testWidgets('disposing the guide the frame after done flips is safe', (
      tester,
    ) async {
      await _pump(tester, _crossOffGuide(done: false));
      await _pump(tester, _crossOffGuide(done: true));
      // The cross-off controller is now mid-flight; unmount everything.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('collapsing the card mid cross-off disposes cleanly', (
      tester,
    ) async {
      await _pump(tester, _crossOffGuide(done: false));
      await _pump(tester, _crossOffGuide(done: true));
      await tester.pump(const Duration(milliseconds: 300));

      // Collapse while the strike is playing: the row unmounts mid-flight.
      await tester.tap(find.text('Setup guide'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      // By 1.4s the chevron, ink ripple and bar tween have all finished but a
      // leaked cross-off controller would still be ticking (it runs to 1.56s).
      // Zero transient callbacks proves the row's controller was disposed.
      await tester.pump(const Duration(milliseconds: 800));
      expect(tester.binding.transientCallbackCount, 0);

      // Expanding again mounts the row already done: cleared, no replay.
      await tester.tap(find.text('Setup guide'));
      await tester.pump();
      expect(tester.getSize(_crossOffClip).height, 0);
    });

    testWidgets('done flipped back off mid-animation stops and rewinds', (
      tester,
    ) async {
      await _pump(tester, _crossOffGuide(done: false));
      await _pump(tester, _crossOffGuide(done: true));
      await tester.pump(const Duration(milliseconds: 300));

      // Mid-strike the task is marked not done again.
      await _pump(tester, _crossOffGuide(done: false));
      await tester.pump();
      expect(find.text('Verify your email'), findsOneWidget);
      // By 1s the progress bar tween (520ms) has settled and nothing was
      // tapped. The cross-off controller stopped and rewound with the row,
      // so nothing at all is left ticking behind the restored to-do.
      await tester.pump(const Duration(milliseconds: 700));
      expect(tester.binding.transientCallbackCount, 0);

      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);

      // When the task genuinely completes later the cross-off plays again
      // from the start: mid-strike the row is still visible, and only after
      // the collapse phase does it clear out.
      await _pump(tester, _crossOffGuide(done: true));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getSize(_crossOffClip).height, greaterThan(0));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.getSize(_crossOffClip).height, 0);
    });

    testWidgets('flapping done every frame never crashes the row', (
      tester,
    ) async {
      var done = false;
      await _pump(tester, _crossOffGuide(done: done));
      for (var i = 0; i < 30; i++) {
        done = !done;
        await _pump(tester, _crossOffGuide(done: done));
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull);
      }
      await _pump(tester, _crossOffGuide(done: true));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(_crossOffClip).height, 0);
    });

    testWidgets('reduced motion cross-off clears without a ticker', (
      tester,
    ) async {
      await _pump(tester, _crossOffGuide(done: false), reduceMotion: true);
      await _pump(tester, _crossOffGuide(done: true), reduceMotion: true);
      await tester.pump();
      expect(tester.getSize(_crossOffClip).height, 0);
      expect(tester.binding.transientCallbackCount, 0);
    });
  });

  group('keyboard probes', () {
    testWidgets('tab reaches the header and space toggles the disclosure', (
      tester,
    ) async {
      var tapped = 0;
      await _pump(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          tasks: [DsSetupTask(label: 'Add your vehicles', onTap: () => tapped++)],
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Next:'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Next:'), findsNothing);

      // The next tab stop is the task row; enter activates it.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('the collapsed Next link is keyboard operable', (
      tester,
    ) async {
      var tapped = 0;
      await _pump(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          initiallyCollapsed: true,
          tasks: [DsSetupTask(label: 'Add your vehicles', onTap: () => tapped++)],
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(tapped, 1);
    });
  });

  group('semantics probes', () {
    testWidgets('the header label is announced once in traversal', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          tasks: [
            const DsSetupTask(label: 'Verify your email', done: true),
            DsSetupTask(label: 'Add your vehicles', onTap: () {}),
          ],
        ),
      );
      final labels = _allSemantics(tester)
          .map((node) => node.label)
          .where((label) => label.isNotEmpty)
          .toList();
      // The header's own Text is the one label source, so the disclosure
      // button announces "Setup guide 1 of 2" with the title said once.
      expect(
        labels.singleWhere((label) => label.contains('Setup guide')),
        'Setup guide\n1 of 2',
      );
      handle.dispose();
    });

    testWidgets('no live regions and no leaked percentage in the guide', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          tasks: [
            const DsSetupTask(label: 'Verify your email', done: true),
            DsSetupTask(label: 'Add your vehicles', onTap: () {}),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final nodes = _allSemantics(tester);
      for (final node in nodes) {
        expect(node.flagsCollection.isLiveRegion, isFalse);
        // The guide's bar is decorative; its percentage must not be exposed.
        expect(node.value, isNot(contains('%')));
      }
      handle.dispose();
    });

    testWidgets('locked and done states reach a screen reader', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const DsSetupGuide(
          title: 'Setup guide',
          tasks: [
            DsSetupTask(label: 'Verify your email', done: true),
            DsSetupTask(label: 'Go live', locked: true),
          ],
        ),
      );
      final nodes = _allSemantics(tester);
      final doneNode =
          nodes.firstWhere((node) => node.label == 'Verify your email');
      final lockedNode = nodes.firstWhere((node) => node.label == 'Go live');
      // A done task reads as checked; a locked task (even without a
      // lockedMessage) reads as a disabled row with a Locked hint, so a
      // screen reader user can tell both apart from an open to-do.
      expect(doneNode.flagsCollection.isChecked, ui.CheckedState.isTrue);
      expect(lockedNode.flagsCollection.isEnabled, ui.Tristate.isFalse);
      expect(lockedNode.hint, 'Locked');
      handle.dispose();
    });

    testWidgets('a lockedMessage reaches semantics and shows on tap and long-press', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const DsSetupGuide(
          title: 'Setup guide',
          tasks: [
            DsSetupTask(
              label: 'Go live',
              locked: true,
              lockedMessage: 'Verify your business to go live',
            ),
          ],
        ),
      );
      final nodes = _allSemantics(tester);
      expect(
        nodes.any((node) => node.tooltip == 'Verify your business to go live'),
        isTrue,
      );

      // Long-press also reveals the bubble (the tap recogniser fires on the
      // release), so touch users are covered either way.
      await tester.longPress(find.text('Go live'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Verify your business to go live'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 1));
      handle.dispose();
    });
  });
}
