import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const options = <DsFilterOption<String>>[
    DsFilterOption(value: 'open', label: 'Open'),
    DsFilterOption(value: 'closed', label: 'Closed'),
  ];

  group('DsFilterChip', () {
    testWidgets('suggested state shows the filter label', (tester) async {
      await pumpDs(
        tester,
        DsFilterChip<String>(
          label: 'Status',
          options: options,
          value: null,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Status'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping suggested chip opens the option menu', (tester) async {
      await pumpDs(
        tester,
        DsFilterChip<String>(
          label: 'Status',
          options: options,
          value: null,
          onChanged: (_) {},
        ),
      );

      await tester.tap(find.text('Status'));
      await tester.pump();

      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('selecting an option reports its value', (tester) async {
      String? selected = 'unset';
      await pumpDs(
        tester,
        DsFilterChip<String>(
          label: 'Status',
          options: options,
          value: null,
          onChanged: (value) => selected = value,
        ),
      );

      await tester.tap(find.text('Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Closed').last);
      await tester.pumpAndSettle();

      expect(selected, 'closed');
    });

    testWidgets('active state shows "label: selectedLabel"', (tester) async {
      await pumpDs(
        tester,
        DsFilterChip<String>(
          label: 'Status',
          options: options,
          value: 'open',
          onChanged: (_) {},
        ),
      );

      expect(find.text('Status: Open'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('tapping the clear icon reports null', (tester) async {
      String? selected = 'open';
      await pumpDs(
        tester,
        DsFilterChip<String>(
          label: 'Status',
          options: options,
          value: 'open',
          onChanged: (value) => selected = value,
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(selected, isNull);
    });

    testWidgets('renders without overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        DsFilterChip<String>(
          label: 'Status',
          options: options,
          value: 'closed',
          onChanged: (_) {},
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
