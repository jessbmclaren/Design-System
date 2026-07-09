import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const options = <DsSelectOption<String>>[
    DsSelectOption(value: 'us', label: 'United States'),
    DsSelectOption(value: 'be', label: 'Belgium'),
  ];

  testWidgets('renders label and hint when no value selected', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        hintText: 'Select a country',
        options: options,
        onChanged: (_) {},
      ),
    );

    expect(find.text('Country'), findsOneWidget);
    expect(find.text('Select a country'), findsOneWidget);
  });

  testWidgets('shows the selected option label in the closed field',
      (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        value: 'be',
        options: options,
        onChanged: (_) {},
      ),
    );

    expect(find.text('Belgium'), findsOneWidget);
  });

  testWidgets('reports the picked value through onChanged', (tester) async {
    String? picked;
    await pumpDs(
      tester,
      DsSelect<String>(
        value: null,
        hintText: 'Select a country',
        options: options,
        onChanged: (value) => picked = value,
      ),
    );

    await tester.tap(find.byType(DsSelect<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('United States').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(picked, 'us');
  });

  testWidgets('disabled select suppresses interaction', (tester) async {
    var changed = false;
    await pumpDs(
      tester,
      DsSelect<String>(
        value: null,
        hintText: 'Select a country',
        options: options,
        enabled: false,
        onChanged: (_) => changed = true,
      ),
    );

    await tester.tap(find.byType(DsSelect<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The menu never opens, so no second copy of the option text appears.
    expect(find.text('United States'), findsNothing);
    expect(changed, isFalse);
  });

  testWidgets('renders the error message', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        value: null,
        hintText: 'Select a country',
        errorText: 'Country is required',
        options: options,
        onChanged: (_) {},
      ),
    );

    expect(find.text('Country is required'), findsOneWidget);
  });

  testWidgets('does not overflow at 320x640', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        hintText: 'Select a country',
        options: options,
        onChanged: (_) {},
      ),
      surfaceSize: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
  });
}
