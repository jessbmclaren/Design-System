import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Hosts the menu and holds the selection, so each test drives the real
/// controlled loop rather than asserting on a callback in isolation.
class _Host extends StatefulWidget {
  const _Host({
    required this.options,
    required this.initial,
    this.enabled = true,
    this.showSelectAll = true,
  });

  final List<DsCheckOption> options;
  final Set<String> initial;
  final bool enabled;
  final bool showSelectAll;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late Set<String> _selected = <String>{...widget.initial};

  @override
  Widget build(BuildContext context) {
    return DsCheckMenu(
      trigger: const Text('Columns'),
      options: widget.options,
      selected: _selected,
      showSelectAll: widget.showSelectAll,
      onChanged: widget.enabled
          ? (Set<String> next) => setState(() => _selected = next)
          : null,
    );
  }
}

const _options = <DsCheckOption>[
  DsCheckOption(value: 'status', label: 'Status', enabled: false),
  DsCheckOption(value: 'spend', label: 'Spend'),
  DsCheckOption(value: 'clicks', label: 'Clicks'),
];

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Columns'));
  await tester.pumpAndSettle();
}

void main() {
  group('DsCheckMenu', () {
    testWidgets('opens from its trigger and lists every option', (tester) async {
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status', 'spend'}),
      );

      // Closed on first build, so a static demo screenshots deterministically.
      expect(find.text('Spend'), findsNothing);

      await _open(tester);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Spend'), findsOneWidget);
      expect(find.text('Clicks'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ticking a row reports the whole next selection and stays open',
        (tester) async {
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status', 'spend'}),
      );
      await _open(tester);

      await tester.tap(find.text('Clicks'));
      await tester.pumpAndSettle();

      // The menu is still open — this is a checklist, not a command menu.
      expect(find.text('Clicks'), findsOneWidget);
      final state = tester.state<_HostState>(find.byType(_Host));
      expect(state._selected, <String>{'status', 'spend', 'clicks'});

      await tester.tap(find.text('Spend'));
      await tester.pumpAndSettle();
      expect(state._selected, <String>{'status', 'clicks'});
    });

    testWidgets('a locked option ignores taps', (tester) async {
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status', 'spend'}),
      );
      await _open(tester);

      await tester.tap(find.text('Status'), warnIfMissed: false);
      await tester.pumpAndSettle();

      final state = tester.state<_HostState>(find.byType(_Host));
      expect(state._selected, <String>{'status', 'spend'});
    });

    testWidgets('select-all ticks every togglable option, then flips to clear',
        (tester) async {
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status'}),
      );
      await _open(tester);

      expect(find.text('Select all'), findsOneWidget);
      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();

      final state = tester.state<_HostState>(find.byType(_Host));
      expect(state._selected, <String>{'status', 'spend', 'clicks'});

      // With everything togglable ticked, the row becomes clear-all.
      expect(find.text('Clear all'), findsOneWidget);
      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();

      // The locked option survives, so the selection can never empty.
      expect(state._selected, <String>{'status'});
    });

    testWidgets('showSelectAll false drops the row', (tester) async {
      await pumpDs(
        tester,
        const _Host(
          options: _options,
          initial: {'status'},
          showSelectAll: false,
        ),
      );
      await _open(tester);

      expect(find.text('Select all'), findsNothing);
      expect(find.text('Spend'), findsOneWidget);
    });

    testWidgets('a null onChanged leaves every row inert', (tester) async {
      await pumpDs(
        tester,
        const _Host(
          options: _options,
          initial: {'status', 'spend'},
          enabled: false,
        ),
      );
      await _open(tester);

      await tester.tap(find.text('Clicks'), warnIfMissed: false);
      await tester.tap(find.text('Select all'), warnIfMissed: false);
      await tester.pumpAndSettle();

      final state = tester.state<_HostState>(find.byType(_Host));
      expect(state._selected, <String>{'status', 'spend'});
    });

    testWidgets('the trigger is a button that reports its expanded state',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status'}),
      );

      // The trigger's label and its state are one node, not two, so it is
      // announced as a single "Columns, button, collapsed" control.
      expect(
        tester.getSemantics(find.text('Columns')),
        isSemantics(
          label: 'Columns',
          isButton: true,
          hasTapAction: true,
          hasExpandedState: true,
          isExpanded: false,
        ),
      );

      await _open(tester);
      expect(
        tester.getSemantics(find.text('Columns')),
        isSemantics(hasExpandedState: true, isExpanded: true),
      );
      handle.dispose();
    });

    testWidgets('the trigger opens from the keyboard alone', (tester) async {
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status'}),
      );

      // Tab to the trigger, then activate it — no pointer involved.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(find.text('Spend'), findsOneWidget);
      expect(find.text('Select all'), findsOneWidget);
    });

    testWidgets('a long option list scrolls instead of overflowing at 320dp',
        (tester) async {
      final many = <DsCheckOption>[
        for (var i = 0; i < 24; i++)
          DsCheckOption(value: 'c$i', label: 'Column number $i'),
      ];
      await pumpDs(
        tester,
        _Host(options: many, initial: const {'c0'}),
        surfaceSize: const Size(320, 640),
      );
      await _open(tester);

      expect(find.text('Column number 0'), findsOneWidget);
      // No overflow was painted at the narrowest supported width.
      expect(tester.takeException(), isNull);

      // The list itself scrolls past maxListHeight rather than growing, and
      // the select-all row stays pinned below it.
      final ScrollableState list = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(SingleChildScrollView),
              matching: find.byType(Scrollable),
            )
            .last,
      );
      expect(list.position.maxScrollExtent, greaterThan(0));
      expect(find.text('Select all'), findsOneWidget);
    });

    testWidgets('renders in dark', (tester) async {
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status'}),
        theme: DsTheme.dark(),
      );
      await _open(tester);
      expect(find.text('Spend'), findsOneWidget);
      expect(find.text('Select all'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders under a skin', (tester) async {
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status'}),
        theme: DsTheme.light(tokens: DsSkins.engenLight()),
      );
      await _open(tester);
      expect(find.text('Spend'), findsOneWidget);
      expect(find.text('Select all'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
