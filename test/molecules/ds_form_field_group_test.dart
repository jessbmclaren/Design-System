import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsFormFieldGroup', () {
    testWidgets('renders legend and description', (tester) async {
      await pumpDs(
        tester,
        const DsFormFieldGroup(
          legend: 'Shipping address',
          description: 'Where should we send your order?',
          children: [
            DsTextField(label: 'Street'),
            DsTextField(label: 'City'),
          ],
        ),
      );

      expect(find.text('Shipping address'), findsOneWidget);
      expect(find.text('Where should we send your order?'), findsOneWidget);
    });

    testWidgets('renders its children fields', (tester) async {
      await pumpDs(
        tester,
        const DsFormFieldGroup(
          legend: 'Name',
          children: [
            DsTextField(label: 'First name'),
            DsTextField(label: 'Last name'),
          ],
        ),
      );

      expect(find.text('First name'), findsOneWidget);
      expect(find.text('Last name'), findsOneWidget);
    });

    testWidgets('forwards interaction to a child field callback',
        (tester) async {
      String? changed;
      await pumpDs(
        tester,
        DsFormFieldGroup(
          legend: 'Contact',
          columns: 1,
          children: [
            DsTextField(
              label: 'Email',
              onChanged: (value) => changed = value,
            ),
          ],
        ),
      );

      await tester.enterText(find.byType(TextField), 'hi@example.com');
      await tester.pump();

      expect(changed, 'hi@example.com');
    });

    testWidgets('flows two columns on a wide layout via Wrap', (tester) async {
      await pumpDs(
        tester,
        const DsFormFieldGroup(
          legend: 'Address',
          children: [
            DsTextField(label: 'Street'),
            DsTextField(label: 'City'),
            DsTextField(label: 'Postal code'),
            DsTextField(label: 'Country'),
          ],
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();

      expect(find.byType(Wrap), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('goes two-up in a card wider than minRowWidth, below the old '
        'window breakpoint', (tester) async {
      await pumpDs(
        tester,
        const DsFormFieldGroup(
          legend: 'Name',
          children: [
            DsTextField(label: 'First name'),
            DsTextField(label: 'Last name'),
          ],
        ),
        surfaceSize: const Size(440, 900),
      );
      await tester.pump();

      expect(find.byType(Wrap), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stacks when narrower than minRowWidth', (tester) async {
      await pumpDs(
        tester,
        const DsFormFieldGroup(
          legend: 'Name',
          children: [
            DsTextField(label: 'First name'),
            DsTextField(label: 'Last name'),
          ],
        ),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();

      expect(find.byType(Wrap), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stacks children when columns is 1', (tester) async {
      await pumpDs(
        tester,
        const DsFormFieldGroup(
          legend: 'Notes',
          columns: 1,
          children: [
            DsTextField(label: 'Line one'),
            DsTextField(label: 'Line two'),
          ],
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();

      expect(find.byType(Wrap), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at 320 width', (tester) async {
      await pumpDs(
        tester,
        const DsFormFieldGroup(
          legend: 'Shipping address',
          description: 'Where should we send your order?',
          children: [
            DsTextField(label: 'Street'),
            DsTextField(label: 'City'),
            DsTextField(label: 'Postal code'),
            DsTextField(label: 'Country'),
          ],
        ),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();

      expect(find.text('Shipping address'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at 1200 width', (tester) async {
      await pumpDs(
        tester,
        const DsFormFieldGroup(
          legend: 'Shipping address',
          children: [
            DsTextField(label: 'Street'),
            DsTextField(label: 'City'),
            DsTextField(label: 'Postal code'),
            DsTextField(label: 'Country'),
          ],
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
