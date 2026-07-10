import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

final _columns = <DsGridColumn>[
  const DsGridColumn(key: 'name', title: 'Name'),
  const DsGridColumn(key: 'amount', title: 'Amount', type: DsCellType.number),
  const DsGridColumn(key: 'status', title: 'Status', type: DsCellType.status),
  // A non-sortable column must never be offered as a sort field.
  const DsGridColumn(key: 'locked', title: 'Locked', sortable: false),
];

/// A controlled host that feeds edits back into [DsSortBuilder], as a real
/// caller would, and reports every emitted list through [onChanged].
class _SortHarness extends StatefulWidget {
  const _SortHarness({required this.initial, this.onChanged});

  final List<DsGridSort> initial;
  final ValueChanged<List<DsGridSort>>? onChanged;

  @override
  State<_SortHarness> createState() => _SortHarnessState();
}

class _SortHarnessState extends State<_SortHarness> {
  late List<DsGridSort> _sorts = widget.initial;

  @override
  Widget build(BuildContext context) {
    return DsSortBuilder(
      columns: _columns,
      value: _sorts,
      onChanged: (sorts) {
        setState(() => _sorts = sorts);
        widget.onChanged?.call(sorts);
      },
    );
  }
}

void main() {
  group('DsSortBuilder rendering', () {
    testWidgets('reads "No sorts" when empty', (tester) async {
      await pumpDs(
        tester,
        DsSortBuilder(
          columns: _columns,
          value: const [],
          onChanged: (_) {},
        ),
        surfaceSize: const Size(900, 700),
      );
      await tester.pump();
      expect(find.text('No sorts'), findsOneWidget);
      expect(find.text('Add sort'), findsOneWidget);
    });
  });

  group('DsSortBuilder editing', () {
    testWidgets('adding a sort emits the first sortable column ascending',
        (tester) async {
      List<DsGridSort>? last;
      await pumpDs(
        tester,
        _SortHarness(initial: const [], onChanged: (s) => last = s),
        surfaceSize: const Size(900, 700),
      );
      await tester.pump();
      await tester.tap(find.text('Add sort'));
      await tester.pump();
      expect(last, isNotNull);
      expect(last, hasLength(1));
      expect(last!.first.columnKey, 'name');
      expect(last!.first.ascending, isTrue);
    });

    testWidgets('toggling direction emits a descending sort', (tester) async {
      List<DsGridSort>? last;
      await pumpDs(
        tester,
        _SortHarness(
          initial: const [DsGridSort(columnKey: 'name')],
          onChanged: (s) => last = s,
        ),
        surfaceSize: const Size(900, 700),
      );
      await tester.pump();
      await tester.tap(find.text('Desc'));
      await tester.pump();
      expect(last, isNotNull);
      expect(last!.single.ascending, isFalse);
    });

    testWidgets('removing a sort emits an empty list', (tester) async {
      List<DsGridSort>? last;
      await pumpDs(
        tester,
        _SortHarness(
          initial: const [DsGridSort(columnKey: 'name')],
          onChanged: (s) => last = s,
        ),
        surfaceSize: const Size(900, 700),
      );
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Remove sort'));
      await tester.pump();
      expect(last, isNotNull);
      expect(last, isEmpty);
    });

    testWidgets('moving a sort earlier reorders precedence', (tester) async {
      List<DsGridSort>? last;
      await pumpDs(
        tester,
        _SortHarness(
          initial: const [
            DsGridSort(columnKey: 'name'),
            DsGridSort(columnKey: 'amount'),
          ],
          onChanged: (s) => last = s,
        ),
        surfaceSize: const Size(1000, 700),
      );
      await tester.pump();
      // The second row's "move earlier" control (the first row's is disabled).
      await tester.tap(find.bySemanticsLabel('Move sort earlier').at(1));
      await tester.pump();
      expect(last, isNotNull);
      expect(last!.map((s) => s.columnKey).toList(), ['amount', 'name']);
    });
  });

  testWidgets('no overflow across device widths', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1.0;
    for (final width in <double>[320, 768, 1440]) {
      tester.view.physicalSize = Size(width, 1000);
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DsSortBuilder(
                columns: _columns,
                value: const [
                  DsGridSort(columnKey: 'name'),
                  DsGridSort(columnKey: 'amount', ascending: false),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'overflow at ${width}dp');
    }
  });
}
