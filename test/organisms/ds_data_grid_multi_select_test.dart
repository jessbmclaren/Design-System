import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const _tagOptions = <DsGridOption>[
  DsGridOption(value: 'urgent', label: 'Urgent'),
  DsGridOption(value: 'billing', label: 'Billing'),
  DsGridOption(value: 'renewal', label: 'Renewal'),
];

/// Hosts the grid and applies committed edits, so the test drives the real
/// controlled editing loop end to end.
class _Host extends StatefulWidget {
  const _Host({required this.initialTags});

  final List<String> initialTags;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late List<String> _tags = <String>[...widget.initialTags];
  int _commits = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: 900,
      child: DsDataGrid(
        editable: true,
        columns: const <DsGridColumn>[
          DsGridColumn(key: 'name', title: 'Name'),
          DsGridColumn(
            key: 'tags',
            title: 'Tags',
            type: DsCellType.multiSelect,
            width: 260,
            editable: true,
            options: _tagOptions,
          ),
        ],
        rows: <DsGridRow>[
          DsGridRow(id: 'a', cells: {'name': 'Acme', 'tags': _tags}),
        ],
        onCellChanged: (String rowId, String columnKey, Object? value) {
          setState(() {
            _commits++;
            _tags = <String>[...(value! as List<String>)];
          });
        },
      ),
    );
  }
}

void main() {
  group('DsDataGrid multi-select cell editor', () {
    testWidgets('opens a checklist, stages toggles and commits on Done',
        (tester) async {
      await pumpDs(
        tester,
        const _Host(initialTags: <String>['urgent']),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('Edit Tags'));
      await tester.pumpAndSettle();

      // Every declared option is offered, on the shared DsCheckList.
      expect(find.byType(DsCheckList), findsOneWidget);
      expect(find.text('Billing'), findsOneWidget);
      expect(find.text('Renewal'), findsOneWidget);

      final state = tester.state<_HostState>(find.byType(_Host));

      // Toggling stages the change without committing it.
      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();
      expect(state._commits, 0);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(state._commits, 1);
      // Committed in the options' declared order, not tap order.
      expect(state._tags, <String>['urgent', 'billing']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an outside tap cancels without committing', (tester) async {
      await pumpDs(
        tester,
        const _Host(initialTags: <String>['urgent']),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('Edit Tags'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Renewal'));
      await tester.pumpAndSettle();

      // Dismiss via the overlay barrier rather than the Done row.
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();

      final state = tester.state<_HostState>(find.byType(_Host));
      expect(state._commits, 0);
      expect(state._tags, <String>['urgent']);
      expect(find.byType(DsCheckList), findsNothing);
    });

    testWidgets('a value the column no longer declares survives a commit',
        (tester) async {
      await pumpDs(
        tester,
        const _Host(initialTags: <String>['urgent', 'legacy']),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('Edit Tags'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      final state = tester.state<_HostState>(find.byType(_Host));
      // 'legacy' has no row to tick, but it is preserved rather than dropped.
      expect(state._tags, <String>['urgent', 'billing', 'legacy']);
    });
  });
}
