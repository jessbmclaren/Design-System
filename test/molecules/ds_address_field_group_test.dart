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
  });
}
