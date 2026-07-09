import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders label, formatted value and calendar icon', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      DsDateField(
        label: 'Start date',
        value: DateTime(2026, 7, 9),
        onChanged: (_) {},
      ),
    );

    expect(find.text('Start date'), findsOneWidget);
    expect(find.text('2026-07-09'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
  });

  testWidgets('shows hintText while value is null', (WidgetTester tester) async {
    await pumpDs(
      tester,
      DsDateField(
        label: 'Due date',
        hintText: 'Select a date',
        onChanged: (_) {},
      ),
    );

    expect(find.text('Select a date'), findsOneWidget);
    expect(find.text('Due date'), findsOneWidget);
  });

  testWidgets('shows errorText and its danger caption', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      DsDateField(
        label: 'Birthday',
        errorText: 'Date is required',
        onChanged: (_) {},
      ),
    );

    expect(find.text('Date is required'), findsOneWidget);
  });

  testWidgets('tapping opens the date picker and confirming fires onChanged', (
    WidgetTester tester,
  ) async {
    DateTime? picked;
    await pumpDs(
      tester,
      DsDateField(
        label: 'Start date',
        value: DateTime(2026, 7, 9),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        onChanged: (DateTime? date) => picked = date,
      ),
    );

    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The picker overlay is open with an OK confirmation action.
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(picked, isNotNull);
  });

  testWidgets('disabled field does not open the picker', (
    WidgetTester tester,
  ) async {
    bool called = false;
    await pumpDs(
      tester,
      DsDateField(
        label: 'Start date',
        value: DateTime(2026, 7, 9),
        enabled: false,
        onChanged: (_) => called = true,
      ),
    );

    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('OK'), findsNothing);
    expect(called, isFalse);
  });

  testWidgets('renders without overflow on a small phone surface', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      DsDateField(
        label: 'Start date',
        value: DateTime(2026, 7, 9),
        helperText: 'Pick the project kickoff date',
        onChanged: (_) {},
      ),
      surfaceSize: const Size(320, 900),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a large desktop surface', (
    WidgetTester tester,
  ) async {
    await pumpDs(
      tester,
      DsDateField(
        label: 'Start date',
        value: DateTime(2026, 7, 9),
        helperText: 'Pick the project kickoff date',
        onChanged: (_) {},
      ),
      surfaceSize: const Size(1200, 900),
    );

    expect(tester.takeException(), isNull);
  });
}
