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

  testWidgets('a disabled select does not validate', (tester) async {
    final formKey = GlobalKey<FormState>();
    await pumpDs(
      tester,
      Form(
        key: formKey,
        child: DsSelect<String>(
          label: 'Country',
          value: null,
          options: options,
          enabled: false,
          onChanged: (_) {},
          validator: (value) => value == null ? 'Country is required' : null,
        ),
      ),
    );

    // The user cannot operate a disabled control, so its validator must not
    // be able to block the form with an unfixable error.
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Country is required'), findsNothing);
  });

  testWidgets('a disabled select does not save', (tester) async {
    final formKey = GlobalKey<FormState>();
    var savedCalls = 0;
    await pumpDs(
      tester,
      Form(
        key: formKey,
        child: DsSelect<String>(
          value: 'be',
          options: options,
          enabled: false,
          onChanged: (_) {},
          onSaved: (_) => savedCalls++,
        ),
      ),
    );

    formKey.currentState!.save();
    expect(savedCalls, 0);
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

  testWidgets('renders helperText beneath the field', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        hintText: 'Select a country',
        helperText: 'Where the business is registered',
        options: options,
        onChanged: (_) {},
      ),
    );

    expect(find.text('Where the business is registered'), findsOneWidget);
  });

  testWidgets('errorText replaces helperText', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        hintText: 'Select a country',
        helperText: 'Where the business is registered',
        errorText: 'Country is required',
        options: options,
        onChanged: (_) {},
      ),
    );

    expect(find.text('Country is required'), findsOneWidget);
    expect(find.text('Where the business is registered'), findsNothing);
  });

  testWidgets('validator reports its message when the form validates',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    await pumpDs(
      tester,
      Form(
        key: formKey,
        child: DsSelect<String>(
          label: 'Country',
          value: null,
          hintText: 'Select a country',
          options: options,
          onChanged: (_) {},
          validator: (value) => value == null ? 'Country is required' : null,
        ),
      ),
    );

    expect(find.text('Country is required'), findsNothing);

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Country is required'), findsOneWidget);
  });

  testWidgets('validates on user interaction when asked to', (tester) async {
    await pumpDs(
      tester,
      Form(
        child: DsSelect<String>(
          label: 'Country',
          value: null,
          hintText: 'Select a country',
          options: options,
          onChanged: (_) {},
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) =>
              value == 'us' ? 'Not available in that country' : null,
        ),
      ),
    );

    await tester.tap(find.byType(DsSelect<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('United States').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Not available in that country'), findsOneWidget);
  });

  testWidgets('onSaved receives the value when the form saves',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    String? saved;
    await pumpDs(
      tester,
      Form(
        key: formKey,
        child: DsSelect<String>(
          label: 'Country',
          value: 'be',
          options: options,
          onChanged: (_) {},
          onSaved: (value) => saved = value,
        ),
      ),
    );

    formKey.currentState!.save();
    expect(saved, 'be');
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
