import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Wraps a [DsRecordPanel] in a bounded box so its fill-height layout resolves,
/// then pumps it at [size].
Future<void> pumpPanel(
  WidgetTester tester,
  Widget panel, {
  Size size = const Size(800, 600),
}) {
  return pumpDs(
    tester,
    SizedBox(width: size.width, height: size.height, child: panel),
    surfaceSize: size,
  );
}

void main() {
  group('DsRecordPanel', () {
    const vehicleColumns = <DsGridColumn>[
      DsGridColumn(key: 'name', title: 'Name'),
      DsGridColumn(key: 'year', title: 'Year', type: DsCellType.number),
    ];

    testWidgets('renders the title and a labelled field per column',
        (tester) async {
      await pumpPanel(
        tester,
        DsRecordPanel(
          title: 'Ford Transit',
          columns: vehicleColumns,
          values: const {'name': 'Ford Transit', 'year': 2020},
          onChanged: (_) {},
        ),
      );

      // Title in the header (also echoed as the name field's value).
      expect(find.text('Ford Transit'), findsWidgets);
      // One label per column.
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
    });

    testWidgets('editing a text field emits an updated map with only that key '
        'changed', (tester) async {
      Map<String, Object?>? emitted;
      await pumpPanel(
        tester,
        DsRecordPanel(
          columns: vehicleColumns,
          values: const {'name': 'Ford Transit', 'year': 2020},
          onChanged: (next) => emitted = next,
        ),
      );

      final nameField = find.ancestor(
        of: find.text('Name'),
        matching: find.byType(DsTextField),
      );
      await tester.enterText(nameField, 'Ford Custom');
      await tester.pump();

      expect(emitted, isNotNull);
      expect(emitted!['name'], 'Ford Custom');
      expect(emitted!['year'], 2020);
      expect(emitted!.length, 2);
    });

    testWidgets('a readOnlyKey renders its value but no input', (tester) async {
      await pumpPanel(
        tester,
        DsRecordPanel(
          columns: const <DsGridColumn>[
            DsGridColumn(key: 'id', title: 'ID'),
            DsGridColumn(key: 'name', title: 'Name'),
          ],
          values: const {'id': 'V-1', 'name': 'Ford'},
          readOnlyKeys: const {'id'},
          onChanged: (_) {},
        ),
      );

      // The id label and value both render...
      expect(find.text('ID'), findsOneWidget);
      expect(find.text('V-1'), findsOneWidget);
      // ...but as display, not an input: only the editable name is a text field.
      expect(find.byType(DsTextField), findsOneWidget);
    });

    testWidgets('a select field edit emits the chosen value', (tester) async {
      Map<String, Object?>? emitted;
      await pumpPanel(
        tester,
        DsRecordPanel(
          columns: const <DsGridColumn>[
            DsGridColumn(
              key: 'status',
              title: 'Status',
              type: DsCellType.singleSelect,
              options: [
                DsGridOption(value: 'active', label: 'Active'),
                DsGridOption(value: 'inactive', label: 'Inactive'),
              ],
            ),
          ],
          values: const {'status': 'active'},
          onChanged: (next) => emitted = next,
        ),
      );

      await tester.tap(find.byType(DsSelect<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inactive').last);
      await tester.pumpAndSettle();

      expect(emitted, isNotNull);
      expect(emitted!['status'], 'inactive');
    });

    testWidgets('switching the record updates the displayed field text',
        (tester) async {
      var current = <String, Object?>{'name': 'Ford Transit'};
      const columns = <DsGridColumn>[DsGridColumn(key: 'name', title: 'Name')];

      await pumpPanel(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Expanded(
                child: DsRecordPanel(
                  columns: columns,
                  values: current,
                  onChanged: (next) => setState(() => current = next),
                ),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => current = {'name': 'VW Crafter'}),
                child: const Text('swap'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Ford Transit'), findsOneWidget);

      await tester.tap(find.text('swap'));
      await tester.pump();

      // The new record's value shows, with no stale text from the old record.
      expect(find.text('VW Crafter'), findsOneWidget);
      expect(find.text('Ford Transit'), findsNothing);
    });

    testWidgets('the close and save callbacks fire', (tester) async {
      var closed = false;
      var saved = false;
      await pumpPanel(
        tester,
        DsRecordPanel(
          title: 'Ford Transit',
          columns: vehicleColumns,
          values: const {'name': 'Ford Transit'},
          onChanged: (_) {},
          onClose: () => closed = true,
          onSave: () => saved = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(closed, isTrue);

      final saveButton = find.byWidgetPredicate(
        (w) => w is DsButton && w.variant == DsButtonVariant.primary,
      );
      await tester.tap(saveButton);
      await tester.pump();
      expect(saved, isTrue);
    });

    testWidgets('an empty values map (create) renders empty fields',
        (tester) async {
      await pumpPanel(
        tester,
        DsRecordPanel(
          title: 'New vehicle',
          columns: vehicleColumns,
          values: const {},
          onChanged: (_) {},
        ),
      );

      expect(find.text('New vehicle'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
      expect(find.byType(DsTextField), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders every field type without overflow at 320/768/1440',
        (tester) async {
      final columns = <DsGridColumn>[
        const DsGridColumn(key: 'name', title: 'Name'),
        const DsGridColumn(key: 'mileage', title: 'Mileage', type: DsCellType.number),
        const DsGridColumn(
          key: 'price',
          title: 'Price',
          type: DsCellType.currency,
          currencySymbol: r'$',
        ),
        const DsGridColumn(key: 'purchased', title: 'Purchased', type: DsCellType.date),
        const DsGridColumn(
          key: 'status',
          title: 'Status',
          type: DsCellType.status,
          options: [
            DsGridOption(value: 'active', label: 'Active'),
            DsGridOption(value: 'retired', label: 'Retired'),
          ],
        ),
        const DsGridColumn(
          key: 'tags',
          title: 'Tags',
          type: DsCellType.multiSelect,
          options: [
            DsGridOption(value: 'diesel', label: 'Diesel'),
            DsGridOption(value: 'leased', label: 'Leased'),
          ],
        ),
        const DsGridColumn(key: 'insured', title: 'Insured', type: DsCellType.checkbox),
        const DsGridColumn(key: 'driver', title: 'Driver', type: DsCellType.user),
        const DsGridColumn(key: 'manual', title: 'Manual', type: DsCellType.link),
        const DsGridColumn(key: 'condition', title: 'Condition', type: DsCellType.rating),
        const DsGridColumn(key: 'utilisation', title: 'Utilisation', type: DsCellType.progress),
      ];
      final values = <String, Object?>{
        'name': 'Ford Transit',
        'mileage': 84210,
        'price': 24999.5,
        'purchased': DateTime(2021, 3, 14),
        'status': 'active',
        'tags': ['diesel'],
        'insured': true,
        'driver': 'Alex Rivera',
        'manual': 'transit-manual.pdf',
        'condition': 4,
        'utilisation': 0.62,
      };

      for (final width in <double>[320, 768, 1440]) {
        await pumpPanel(
          tester,
          DsRecordPanel(
            title: 'Ford Transit',
            subtitle: 'Van · Fleet A',
            columns: columns,
            values: values,
            readOnlyKeys: const {'name'},
            groups: const [
              DsRecordFieldGroup(
                title: 'Overview',
                columnKeys: ['name', 'status', 'condition'],
              ),
              DsRecordFieldGroup(
                title: 'Costs',
                columnKeys: ['price', 'mileage'],
              ),
            ],
            onChanged: (_) {},
            onSave: () {},
            onClose: () {},
          ),
          size: Size(width, 900),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'overflow at $width');
      }
    });
  });
}
