import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

final _columns = <DsGridColumn>[
  const DsGridColumn(key: 'name', title: 'Name', width: 140),
  const DsGridColumn(key: 'phone', title: 'Phone', width: 140),
  const DsGridColumn(key: 'status', title: 'Status', width: 120),
];

List<DsGridRow> _rows() => [
      const DsGridRow(
        id: '1',
        cells: {
          'name': 'Amara Okafor',
          'phone': '082 555 0101',
          'status': 'Active',
        },
      ),
      const DsGridRow(
        id: '2',
        cells: {
          'name': 'Ben Nkosi',
          'phone': '083 555 0102',
          'status': 'Invited',
        },
      ),
    ];

const _segments = [
  DsRosterSegment(value: 'all', label: 'All drivers', count: 12),
  DsRosterSegment(value: 'attention', label: 'Needs attention', count: 2),
];

void main() {
  group('DsRosterView', () {
    testWidgets('renders the title, subtitle and count label', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 1000,
          child: DsRosterView(
            title: 'Drivers',
            subtitle: 'Manage your fleet',
            countLabel: '12 drivers',
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
          ),
        ),
        surfaceSize: const Size(1100, 900),
      );
      expect(find.text('Drivers'), findsOneWidget);
      expect(find.text('Manage your fleet'), findsOneWidget);
      expect(find.text('12 drivers'), findsOneWidget);
    });

    testWidgets('renders segment labels with their counts appended',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 1000,
          child: DsRosterView(
            title: 'Drivers',
            segments: _segments,
            segmentValue: 'all',
            onSegmentChanged: (_) {},
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
          ),
        ),
        surfaceSize: const Size(1100, 900),
      );
      expect(find.text('All drivers  12'), findsOneWidget);
      expect(find.text('Needs attention  2'), findsOneWidget);
    });

    testWidgets('tapping a segment fires onSegmentChanged with its value',
        (tester) async {
      String? picked;
      var calls = 0;
      await pumpDs(
        tester,
        SizedBox(
          width: 1000,
          child: DsRosterView(
            title: 'Drivers',
            segments: _segments,
            segmentValue: 'all',
            onSegmentChanged: (value) {
              picked = value;
              calls += 1;
            },
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
          ),
        ),
        surfaceSize: const Size(1100, 900),
      );
      await tester.tap(find.text('Needs attention  2'));
      await tester.pump();
      expect(picked, 'attention');
      expect(calls, 1);
    });

    testWidgets('typing in the search field fires onSearchChanged',
        (tester) async {
      String? query;
      await pumpDs(
        tester,
        SizedBox(
          width: 1000,
          child: DsRosterView(
            title: 'Drivers',
            onSearchChanged: (value) => query = value,
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
          ),
        ),
        surfaceSize: const Size(1100, 900),
      );
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'ama');
      expect(query, 'ama');
    });

    testWidgets('hides the search field when onSearchChanged is null',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 1000,
          child: DsRosterView(
            title: 'Drivers',
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
          ),
        ),
        surfaceSize: const Size(1100, 900),
      );
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('renders the grid rows', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 1000,
          child: DsRosterView(
            title: 'Drivers',
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
          ),
        ),
        surfaceSize: const Size(1100, 900),
      );
      expect(find.text('Amara Okafor'), findsOneWidget);
      expect(find.text('Ben Nkosi'), findsOneWidget);
    });

    testWidgets('renders the pagination slot under the grid', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 1000,
          child: DsRosterView(
            title: 'Drivers',
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
            pagination: const Text('PAGINATION'),
          ),
        ),
        surfaceSize: const Size(1100, 900),
      );
      expect(find.text('PAGINATION'), findsOneWidget);
    });

    testWidgets('renders the footer slot beneath a divider', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 1000,
          child: DsRosterView(
            title: 'Drivers',
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
            footer: const Text('FOOTER'),
          ),
        ),
        surfaceSize: const Size(1100, 900),
      );
      expect(find.text('FOOTER'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('renders the header and toolbar action slots', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 1000,
          child: DsRosterView(
            title: 'Drivers',
            headerActions: const [Text('HEADER-ACTION')],
            toolbarActions: const [Text('TOOLBAR-ACTION')],
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
          ),
        ),
        surfaceSize: const Size(1100, 900),
      );
      expect(find.text('HEADER-ACTION'), findsOneWidget);
      expect(find.text('TOOLBAR-ACTION'), findsOneWidget);
    });

    testWidgets('docks the detail panel alongside the roster on expanded '
        'widths', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 1200,
          child: DsRosterView(
            title: 'Drivers',
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
            detail: const Text('DETAIL'),
          ),
        ),
        surfaceSize: const Size(1280, 900),
      );
      // Both the roster and the docked panel are visible side by side.
      expect(find.text('Drivers'), findsOneWidget);
      expect(find.text('Amara Okafor'), findsOneWidget);
      expect(find.text('DETAIL'), findsOneWidget);
    });

    testWidgets('the detail takes over the roster below the expanded '
        'breakpoint', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 600,
          child: DsRosterView(
            title: 'Drivers',
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
            detail: const Text('DETAIL'),
          ),
        ),
        surfaceSize: const Size(700, 640),
      );
      expect(find.text('DETAIL'), findsOneWidget);
      expect(find.text('Drivers'), findsNothing);
    });

    testWidgets('renders without overflow at 320dp and stretched wide',
        (tester) async {
      await pumpDs(
        tester,
        DsRosterView(
          title: 'Drivers',
          subtitle: 'Manage your fleet',
          countLabel: '12 drivers',
          segments: _segments,
          segmentValue: 'all',
          onSegmentChanged: (_) {},
          onSearchChanged: (_) {},
          columns: _columns,
          rows: _rows(),
          tableHeight: 320,
        ),
        surfaceSize: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);

      await pumpDs(
        tester,
        SizedBox(
          width: 1400,
          child: DsRosterView(
            title: 'Drivers',
            subtitle: 'Manage your fleet',
            countLabel: '12 drivers',
            segments: _segments,
            segmentValue: 'all',
            onSegmentChanged: (_) {},
            onSearchChanged: (_) {},
            columns: _columns,
            rows: _rows(),
            tableHeight: 320,
          ),
        ),
        surfaceSize: const Size(1440, 900),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
