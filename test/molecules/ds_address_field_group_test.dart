import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const countries = <DsSelectOption<String>>[
    DsSelectOption(value: 'BE', label: 'Belgium'),
    DsSelectOption(value: 'NL', label: 'Netherlands'),
  ];

  group('DsAddressFieldGroup', () {
    testWidgets('renders the default fields and the country select',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            countries: countries,
            onChanged: (_) {},
          ),
        ),
        surfaceSize: const Size(600, 1000),
      );

      expect(find.text('Street address'), findsOneWidget);
      expect(find.text('Unit or building'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Region'), findsOneWidget);
      expect(find.text('Postal code'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
    });

    testWidgets('reports every edit through onChanged as a new value',
        (tester) async {
      DsAddressValue? value;
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            countries: countries,
            onChanged: (v) => value = v,
          ),
        ),
        surfaceSize: const Size(600, 1000),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        '12 Harbour Lane',
      );
      await tester.pump();
      expect(value, isNotNull);
      expect(value!.street, '12 Harbour Lane');
      expect(value!.city, isEmpty);
    });

    testWidgets('selecting a country reports it through onChanged',
        (tester) async {
      DsAddressValue? value;
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            countries: countries,
            onChanged: (v) => value = v,
          ),
        ),
        surfaceSize: const Size(600, 1200),
      );

      await tester.tap(find.text('Select a country'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Belgium').last);
      await tester.pumpAndSettle();

      expect(value, isNotNull);
      expect(value!.country, 'BE');
    });

    testWidgets('config renames and hides fields per market', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            countries: countries,
            config: const DsAddressFieldConfig(
              regionLabel: 'Province',
              showUnit: false,
              showPostalCode: false,
            ),
            onChanged: (_) {},
          ),
        ),
        surfaceSize: const Size(600, 1000),
      );

      expect(find.text('Province'), findsOneWidget);
      expect(find.text('Region'), findsNothing);
      expect(find.text('Unit or building'), findsNothing);
      expect(find.text('Postal code'), findsNothing);
    });

    testWidgets('an empty country list hides the country select',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(onChanged: (_) {}),
        ),
        surfaceSize: const Size(600, 1000),
      );

      expect(find.text('Country'), findsNothing);
    });

    testWidgets('a null onChanged disables every field', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          width: 500,
          child: DsAddressFieldGroup(countries: countries),
        ),
        surfaceSize: const Size(600, 1000),
      );

      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields, isNotEmpty);
      for (final field in fields) {
        expect(field.enabled, isFalse);
      }
    });

    testWidgets('follows an external value update', (tester) async {
      Widget build(DsAddressValue value) {
        return SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            value: value,
            countries: countries,
            onChanged: (_) {},
          ),
        );
      }

      await pumpDs(
        tester,
        build(const DsAddressValue(street: '1 Old Street')),
        surfaceSize: const Size(600, 1000),
      );
      expect(find.text('1 Old Street'), findsOneWidget);

      await pumpDs(
        tester,
        build(const DsAddressValue(street: '2 New Street')),
        surfaceSize: const Size(600, 1000),
      );
      await tester.pump();

      expect(find.text('2 New Street'), findsOneWidget);
      expect(find.text('1 Old Street'), findsNothing);
    });

    testWidgets('shows a legend and description when given', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            legend: 'Registered address',
            description: 'As it appears on your registration.',
            countries: countries,
            onChanged: (_) {},
          ),
        ),
        surfaceSize: const Size(600, 1000),
      );

      expect(find.text('Registered address'), findsOneWidget);
      expect(find.text('As it appears on your registration.'), findsOneWidget);
    });

    for (final width in <double>[320, 1440]) {
      testWidgets('does not overflow at ${width.toInt()}dp', (tester) async {
        await pumpDs(
          tester,
          SingleChildScrollView(
            child: SizedBox(
              width: width,
              child: DsAddressFieldGroup(
                countries: countries,
                onChanged: (_) {},
              ),
            ),
          ),
          surfaceSize: Size(width, 900),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('DsAddressValue', () {
    test('copyWith replaces only the given parts', () {
      const value = DsAddressValue(street: '1 Main Road', city: 'Bruges');
      final updated = value.copyWith(city: 'Ghent');

      expect(updated.street, '1 Main Road');
      expect(updated.city, 'Ghent');
      expect(updated, isNot(equals(value)));
    });

    test('format joins the non-empty parts with commas', () {
      const value = DsAddressValue(
        street: '1 Main Road',
        city: 'Ghent',
        postalCode: '9000',
        country: 'Belgium',
      );

      expect(value.format(), '1 Main Road, Ghent, 9000, Belgium');
    });

    test('isEmpty is true only when every part is blank', () {
      expect(const DsAddressValue().isEmpty, isTrue);
      expect(const DsAddressValue(city: 'Ghent').isEmpty, isFalse);
    });

    test('suburb rides through the value contract', () {
      const value = DsAddressValue(street: '1 Main Road', suburb: 'Claremont');
      expect(value.isEmpty, isFalse);
      expect(value.format(), '1 Main Road, Claremont');
      expect(value.copyWith(suburb: 'Rondebosch').suburb, 'Rondebosch');
      expect(value, const DsAddressValue(street: '1 Main Road', suburb: 'Claremont'));
      expect(value, isNot(const DsAddressValue(street: '1 Main Road')));
    });
  });

  group('DsAddressFieldGroup market shape', () {
    const provinces = <DsSelectOption<String>>[
      DsSelectOption(value: 'Gauteng', label: 'Gauteng'),
      DsSelectOption(value: 'Western Cape', label: 'Western Cape'),
    ];

    testWidgets('shows the suburb field only when configured', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            config: const DsAddressFieldConfig(showSuburb: true),
            onChanged: (_) {},
          ),
        ),
        surfaceSize: const Size(600, 1000),
      );
      expect(find.text('Suburb'), findsOneWidget);
    });

    testWidgets('reports a suburb edit through onChanged', (tester) async {
      DsAddressValue? value;
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            config: const DsAddressFieldConfig(showSuburb: true),
            onChanged: (v) => value = v,
          ),
        ),
        surfaceSize: const Size(600, 1000),
      );

      // Target the suburb field by the DsTextField that carries its label.
      final suburbField = find.descendant(
        of: find.ancestor(
          of: find.text('Suburb'),
          matching: find.byType(DsTextField),
        ),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(suburbField, 'Claremont');
      await tester.pump();
      expect(value?.suburb, 'Claremont');
    });

    testWidgets('renders the region as a select when given options',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            config: const DsAddressFieldConfig(regionLabel: 'Province'),
            regionOptions: provinces,
            onChanged: (_) {},
          ),
        ),
        surfaceSize: const Size(600, 1000),
      );

      // The Province label sits inside a DsSelect, not a free-text field.
      expect(
        find.ancestor(
          of: find.text('Province'),
          matching: find.byType(DsSelect<String>),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.text('Province'),
          matching: find.byType(DsTextField),
        ),
        findsNothing,
      );
    });

    testWidgets('states the country as a read-back and hides the select',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            countries: countries,
            countryReadback: 'South Africa',
            onChanged: (_) {},
          ),
        ),
        surfaceSize: const Size(600, 1000),
      );

      expect(find.text('South Africa'), findsOneWidget);
      // The editable country select is suppressed: no placeholder to pick from.
      expect(find.text('Select a country'), findsNothing);
    });

    testWidgets('the read-back country enters the collected value',
        (tester) async {
      DsAddressValue? value;
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            countryReadback: 'South Africa',
            onChanged: (v) => value = v,
          ),
        ),
        surfaceSize: const Size(600, 1000),
      );

      await tester.enterText(find.byType(TextFormField).first, '1 Main Road');
      await tester.pump();
      // The stated country is not display-only: it rides in the value.
      expect(value?.country, 'South Africa');
    });

    testWidgets('a country validator can make the country required',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: DsAddressFieldGroup(
              countries: countries,
              config: DsAddressFieldConfig(
                countryValidator: (v) =>
                    (v == null || v.isEmpty) ? 'Country is required' : null,
              ),
              onChanged: (_) {},
            ),
          ),
        ),
        surfaceSize: const Size(600, 1000),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Country is required'), findsOneWidget);
    });

    testWidgets('a field validator surfaces an inline error on validate',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpDs(
        tester,
        SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: DsAddressFieldGroup(
              config: DsAddressFieldConfig(
                streetValidator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter a street' : null,
              ),
              onChanged: (_) {},
            ),
          ),
        ),
        surfaceSize: const Size(600, 1000),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter a street'), findsOneWidget);
    });
  });
}
