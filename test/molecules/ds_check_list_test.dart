import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Holds the selection, so each test drives the real controlled loop.
class _Host extends StatefulWidget {
  const _Host({
    required this.options,
    required this.initial,
    this.enabled = true,
    this.actionLabel,
    this.maxHeight = 320,
  });

  final List<DsCheckOption> options;
  final Set<String> initial;
  final bool enabled;
  final String? actionLabel;
  final double maxHeight;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late Set<String> _selected = <String>{...widget.initial};
  int _actions = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: DsCheckList(
        options: widget.options,
        selected: _selected,
        maxHeight: widget.maxHeight,
        actionLabel: widget.actionLabel,
        onAction: widget.actionLabel == null ? null : () => _actions++,
        onChanged: widget.enabled
            ? (Set<String> next) => setState(() => _selected = next)
            : null,
      ),
    );
  }
}

const _options = <DsCheckOption>[
  DsCheckOption(value: 'status', label: 'Status', enabled: false),
  DsCheckOption(value: 'spend', label: 'Spend'),
  DsCheckOption(value: 'clicks', label: 'Clicks'),
];

void main() {
  group('DsCheckList', () {
    testWidgets('renders a row per option', (tester) async {
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status', 'spend'}),
      );
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Spend'), findsOneWidget);
      expect(find.text('Clicks'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('toggling a row reports the whole next selection',
        (tester) async {
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status', 'spend'}),
      );
      final state = tester.state<_HostState>(find.byType(_Host));

      await tester.tap(find.text('Clicks'));
      await tester.pumpAndSettle();
      expect(state._selected, <String>{'status', 'spend', 'clicks'});

      await tester.tap(find.text('Spend'));
      await tester.pumpAndSettle();
      expect(state._selected, <String>{'status', 'clicks'});
    });

    testWidgets('a locked option ignores taps', (tester) async {
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status'}),
      );
      await tester.tap(find.text('Status'), warnIfMissed: false);
      await tester.pumpAndSettle();
      final state = tester.state<_HostState>(find.byType(_Host));
      expect(state._selected, <String>{'status'});
    });

    testWidgets('a null onChanged leaves every row inert', (tester) async {
      await pumpDs(
        tester,
        const _Host(
          options: _options,
          initial: {'status'},
          enabled: false,
        ),
      );
      await tester.tap(find.text('Clicks'), warnIfMissed: false);
      await tester.pumpAndSettle();
      final state = tester.state<_HostState>(find.byType(_Host));
      expect(state._selected, <String>{'status'});
    });

    testWidgets('no action row without an actionLabel', (tester) async {
      await pumpDs(
        tester,
        const _Host(options: _options, initial: {'status'}),
      );
      expect(find.text('Done'), findsNothing);
    });

    testWidgets('the action row fires and stays pinned below a scrolling list',
        (tester) async {
      final many = <DsCheckOption>[
        for (var i = 0; i < 24; i++)
          DsCheckOption(value: 'c$i', label: 'Column number $i'),
      ];
      await pumpDs(
        tester,
        _Host(
          options: many,
          initial: const {'c0'},
          actionLabel: 'Done',
          maxHeight: 200,
        ),
        surfaceSize: const Size(320, 640),
      );

      // The rows scroll…
      final ScrollableState list = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(SingleChildScrollView),
              matching: find.byType(Scrollable),
            )
            .last,
      );
      expect(list.position.maxScrollExtent, greaterThan(0));

      // …while the action row is still reachable, not pushed off the bottom.
      expect(find.text('Done'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(tester.state<_HostState>(find.byType(_Host))._actions, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at 320dp and in dark',
        (tester) async {
      for (final ThemeData theme in <ThemeData>[
        DsTheme.light(),
        DsTheme.dark(),
        DsTheme.light(tokens: DsSkins.engenLight()),
      ]) {
        await pumpDs(
          tester,
          const _Host(
            options: _options,
            initial: {'status'},
            actionLabel: 'Done',
          ),
          surfaceSize: const Size(320, 640),
          theme: theme,
        );
        expect(find.text('Done'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
