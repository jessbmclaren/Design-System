import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsSetupGuide', () {
    testWidgets('renders the title, count and every task label', (tester) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          tasks: const [
            DsSetupTask(label: 'Verify your email', done: true),
            DsSetupTask(label: 'Add your vehicles'),
            DsSetupTask(label: 'Invite users'),
          ],
        ),
      );

      expect(find.text('Setup guide'), findsOneWidget);
      expect(find.text('1 of 3'), findsOneWidget);
      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.text('Add your vehicles'), findsOneWidget);
      expect(find.text('Invite users'), findsOneWidget);
    });

    testWidgets('tapping an open task row fires its callback', (tester) async {
      var tapped = 0;
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          tasks: [
            DsSetupTask(label: 'Add your vehicles', onTap: () => tapped++),
          ],
        ),
      );

      await tester.tap(find.text('Add your vehicles'));
      expect(tapped, 1);
    });

    testWidgets('tappable rows meet the 48dp touch minimum', (tester) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          tasks: [
            DsSetupTask(label: 'Add your vehicles', onTap: () {}),
          ],
        ),
      );

      final row = tester.getSize(
        find.widgetWithText(InkWell, 'Add your vehicles'),
      );
      expect(row.height, greaterThanOrEqualTo(48));
    });

    testWidgets('done and pending tasks are not tappable', (tester) async {
      var tapped = 0;
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          tasks: [
            DsSetupTask(label: 'Done task', done: true, onTap: () => tapped++),
            DsSetupTask(
              label: 'Pending task',
              pending: true,
              onTap: () => tapped++,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Done task'), warnIfMissed: false);
      await tester.tap(find.text('Pending task'), warnIfMissed: false);
      expect(tapped, 0);
    });

    testWidgets('done tasks show a check marker, pending tasks a pill', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          tasks: const [
            DsSetupTask(label: 'Done task', done: true),
            DsSetupTask(label: 'Pending task', pending: true),
          ],
        ),
      );

      expect(find.byIcon(DsIcons.check), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('a locked task shows the gate in a tooltip on tap', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          tasks: const [
            DsSetupTask(
              label: 'Go live',
              locked: true,
              lockedMessage: 'Verify your email to go live',
            ),
          ],
        ),
      );

      expect(find.byIcon(DsIcons.lock), findsOneWidget);
      expect(find.text('Verify your email to go live'), findsNothing);

      await tester.tap(find.text('Go live'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Verify your email to go live'), findsOneWidget);

      // Let the tooltip's show timer elapse and its fade-out finish.
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('the header collapses the list and expands it again', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          tasks: const [
            DsSetupTask(label: 'Add your vehicles'),
            DsSetupTask(label: 'Invite users'),
          ],
        ),
      );

      expect(find.text('Invite users'), findsOneWidget);

      await tester.tap(find.text('Setup guide'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Collapsed: the list gives way to the "Next" line, which names only
      // the first actionable task.
      expect(find.text('Invite users'), findsNothing);
      expect(find.text('Next:'), findsOneWidget);
      expect(find.text('Add your vehicles'), findsOneWidget);

      await tester.tap(find.text('Setup guide'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Invite users'), findsOneWidget);
      expect(find.text('Next:'), findsNothing);
    });

    testWidgets('initiallyCollapsed starts closed', (tester) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          initiallyCollapsed: true,
          tasks: const [DsSetupTask(label: 'Add your vehicles')],
        ),
      );

      expect(find.text('Next:'), findsOneWidget);
      expect(find.widgetWithText(DsLink, 'Add your vehicles'), findsOneWidget);
    });

    testWidgets('the collapsed Next line skips done and pending tasks', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          initiallyCollapsed: true,
          tasks: [
            const DsSetupTask(label: 'Verify your email', done: true),
            const DsSetupTask(label: 'Verify your business', pending: true),
            DsSetupTask(label: 'Add your vehicles', onTap: () {}),
          ],
        ),
      );

      expect(find.text('Verify your email'), findsNothing);
      expect(find.text('Verify your business'), findsNothing);
      expect(find.text('Add your vehicles'), findsOneWidget);
    });

    testWidgets('the collapsed Next line skips locked tasks', (tester) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          initiallyCollapsed: true,
          tasks: [
            const DsSetupTask(label: 'Go live', locked: true),
            DsSetupTask(label: 'Invite users', onTap: () {}),
          ],
        ),
      );

      expect(find.text('Go live'), findsNothing);
      expect(find.text('Invite users'), findsOneWidget);
    });

    testWidgets('tapping the Next link fires the task callback', (
      tester,
    ) async {
      var tapped = 0;
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          initiallyCollapsed: true,
          tasks: [
            DsSetupTask(label: 'Add your vehicles', onTap: () => tapped++),
          ],
        ),
      );

      await tester.tap(find.text('Add your vehicles'));
      expect(tapped, 1);
    });

    testWidgets('shows collapsedSummary once nothing is actionable', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          initiallyCollapsed: true,
          collapsedSummary: 'You are all set',
          tasks: const [
            DsSetupTask(label: 'Verify your email', done: true),
            DsSetupTask(label: 'Verify your business', pending: true),
          ],
        ),
      );

      expect(find.text('Next:'), findsNothing);
      expect(find.text('You are all set'), findsOneWidget);
    });

    testWidgets('a cross-off task strikes through then collapses away', (
      tester,
    ) async {
      const before = DsSetupTask(label: 'Verify your email', animateCrossOff: true);
      const after = DsSetupTask(
        label: 'Verify your email',
        done: true,
        animateCrossOff: true,
      );

      await pumpDs(
        tester,
        const DsSetupGuide(title: 'Setup guide', tasks: [before]),
      );
      expect(find.text('Verify your email'), findsOneWidget);

      await pumpDs(
        tester,
        const DsSetupGuide(title: 'Setup guide', tasks: [after]),
      );

      final crossOffRow = find.descendant(
        of: find.byType(DsSetupGuide),
        matching: find.byType(ClipRect),
      );

      // Mid-animation the row is still visible (strike phase).
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.getSize(crossOffRow).height, greaterThan(0));

      // Once the collapse phase finishes the row has cleared out.
      await tester.pump(const Duration(seconds: 2));
      expect(tester.getSize(crossOffRow).height, 0);
    });

    testWidgets('a cross-off task settles instantly under reduced motion', (
      tester,
    ) async {
      Widget reduced(DsSetupTask task) => MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: DsSetupGuide(title: 'Setup guide', tasks: [task]),
          );

      await pumpDs(
        tester,
        reduced(const DsSetupTask(
          label: 'Verify your email',
          animateCrossOff: true,
        )),
      );

      await pumpDs(
        tester,
        reduced(const DsSetupTask(
          label: 'Verify your email',
          done: true,
          animateCrossOff: true,
        )),
      );
      await tester.pump();

      final crossOffRow = find.descendant(
        of: find.byType(DsSetupGuide),
        matching: find.byType(ClipRect),
      );
      expect(tester.getSize(crossOffRow).height, 0);
    });

    testWidgets('a task mounted already done and cross-off renders cleared', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsSetupGuide(
          title: 'Setup guide',
          tasks: [
            DsSetupTask(
              label: 'Verify your email',
              done: true,
              animateCrossOff: true,
            ),
          ],
        ),
      );

      final crossOffRow = find.descendant(
        of: find.byType(DsSetupGuide),
        matching: find.byType(ClipRect),
      );
      expect(tester.getSize(crossOffRow).height, 0);
    });

    testWidgets('the list scrolls inside a maxHeight budget', (tester) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          maxHeight: 220,
          tasks: [
            for (var i = 1; i <= 10; i++)
              DsSetupTask(label: 'Task number $i', onTap: () {}),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(
        tester.getSize(find.byType(DsSetupGuide)).height,
        lessThanOrEqualTo(220),
      );
    });

    testWidgets('does not overflow at 320dp or stretched wide', (tester) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'A rather long setup guide title that could overflow',
          tasks: const [
            DsSetupTask(
              label: 'A very long task label that should ellipsize not wrap',
            ),
            DsSetupTask(label: 'Pending with a pill', pending: true),
            DsSetupTask(
              label: 'Locked with a message',
              locked: true,
              lockedMessage: 'Finish the earlier tasks first',
            ),
          ],
        ),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          fullWidth: true,
          tasks: const [DsSetupTask(label: 'Add your vehicles')],
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the header announces itself as a disclosure button', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsSetupGuide(
          title: 'Setup guide',
          tasks: const [DsSetupTask(label: 'Add your vehicles')],
        ),
      );

      // The label is announced (possibly merged with the header's own text).
      expect(find.bySemanticsLabel(RegExp('Setup guide')), findsWidgets);

      // The header annotates itself as an expandable button.
      Semantics header() => tester.widget<Semantics>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.properties.label == 'Setup guide',
            ),
          );
      expect(header().properties.button, isTrue);
      expect(header().properties.expanded, isTrue);

      await tester.tap(find.text('Setup guide'));
      await tester.pump();
      expect(header().properties.expanded, isFalse);
    });
  });
}
