import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Destination fields covering the coercing cell types plus a plain text field.
final _columns = <DsGridColumn>[
  const DsGridColumn(key: 'name', title: 'Name'),
  const DsGridColumn(
    key: 'amount',
    title: 'Amount',
    type: DsCellType.currency,
    currencySymbol: r'$',
  ),
  const DsGridColumn(key: 'due', title: 'Due', type: DsCellType.date),
];

/// Headers deliberately lower-cased so auto-matching must be case-insensitive.
/// The second row's amount ('oops') cannot coerce to a number.
ImportSource _source() => const ImportSource(
      headers: ['name', 'amount', 'due'],
      rows: [
        ['Acme', '1240', '2026-07-01'],
        ['Globex', 'oops', '2026-08-15'],
      ],
    );

Future<void> _pumpWizard(
  WidgetTester tester, {
  required Size size,
  ImportSource? source,
  VoidCallback? onBrowse,
  void Function(List<DsGridRow>)? onCommit,
  VoidCallback? onCancel,
}) {
  return pumpDs(
    tester,
    SizedBox.fromSize(
      size: size,
      child: DsImportWizard(
        destinationColumns: _columns,
        source: source,
        onBrowse: onBrowse,
        onCancel: onCancel,
        onCommit: onCommit ?? (_) {},
      ),
    ),
    surfaceSize: size,
  );
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pump();
}

void main() {
  group('DsImportWizard', () {
    testWidgets('step 1 shows the dropzone while source is null',
        (tester) async {
      await _pumpWizard(
        tester,
        size: const Size(1200, 800),
        onBrowse: () {},
      );
      await tester.pump();

      expect(find.byType(DsDropzone), findsOneWidget);
      expect(find.text('Upload your file'), findsOneWidget);
    });

    testWidgets('mapping auto-matches by case-insensitive header name',
        (tester) async {
      await _pumpWizard(
        tester,
        size: const Size(1200, 800),
        source: _source(),
      );
      await tester.pump();

      // Advance from Upload to Map columns.
      await _tapText(tester, 'Next');

      // All three destination columns matched their like-named header.
      expect(find.text('3 of 3 mapped'), findsOneWidget);
    });

    testWidgets('preview renders coerced values in a grid', (tester) async {
      await _pumpWizard(
        tester,
        size: const Size(1400, 900),
        source: _source(),
      );
      await tester.pump();

      await _tapText(tester, 'Next'); // -> Map
      await _tapText(tester, 'Next'); // -> Preview

      expect(find.byType(DsDataGrid), findsOneWidget);
      // Text is kept verbatim; currency is coerced to a num and formatted.
      expect(find.text('Acme'), findsOneWidget);
      expect(find.text(r'$1,240.00'), findsOneWidget);
    });

    testWidgets('an uncoercible value is reported as an error', (tester) async {
      await _pumpWizard(
        tester,
        size: const Size(1400, 900),
        source: _source(),
      );
      await tester.pump();

      await _tapText(tester, 'Next'); // -> Map
      await _tapText(tester, 'Next'); // -> Preview

      // The 'oops' amount fails coercion and is surfaced in the banner…
      expect(find.text('1 error in 1 row'), findsOneWidget);
      // …and the invalid row is flagged in the grid.
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Valid'), findsOneWidget);
    });

    testWidgets('an invalid calendar date is an error, not silently rolled over',
        (tester) async {
      // Regression: '2026-02-30' must not coerce to March 2 and pass as valid.
      await _pumpWizard(
        tester,
        size: const Size(1400, 900),
        source: const ImportSource(
          headers: ['name', 'amount', 'due'],
          rows: [
            ['Acme', '1240', '2026-07-01'],
            ['Globex', '320', '2026-02-30'],
          ],
        ),
      );
      await tester.pump();

      await _tapText(tester, 'Next'); // -> Map
      await _tapText(tester, 'Next'); // -> Preview

      expect(find.text('1 error in 1 row'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      // The rolled-over date must never appear in the preview.
      expect(find.text('2026-03-02'), findsNothing);
    });

    testWidgets('committing calls onCommit with the coerced rows',
        (tester) async {
      List<DsGridRow>? committed;
      await _pumpWizard(
        tester,
        size: const Size(1400, 900),
        source: _source(),
        onCommit: (rows) => committed = rows,
      );
      await tester.pump();

      await _tapText(tester, 'Next'); // -> Map
      await _tapText(tester, 'Next'); // -> Preview
      await _tapText(tester, 'Next'); // -> Commit

      expect(find.text('Import 1 record, 1 skipped'), findsOneWidget);

      await _tapText(tester, 'Import');

      expect(committed, isNotNull);
      // Only the valid row is committed.
      expect(committed!.length, 1);
      final cells = committed!.first.cells;
      expect(cells['name'], 'Acme');
      expect(cells['amount'], 1240);
      expect(cells['due'], DateTime(2026, 7, 1));
    });

    testWidgets('Cancel fires onCancel', (tester) async {
      var cancelled = 0;
      await _pumpWizard(
        tester,
        size: const Size(1200, 800),
        source: _source(),
        onCancel: () => cancelled++,
      );
      await tester.pump();

      await _tapText(tester, 'Cancel');
      expect(cancelled, 1);
    });

    for (final width in <double>[320, 768, 1440]) {
      testWidgets('walks every step without overflow at ${width.toInt()}dp',
          (tester) async {
        await _pumpWizard(
          tester,
          size: Size(width, width < 400 ? 640 : 900),
          source: _source(),
        );
        await tester.pump();
        expect(tester.takeException(), isNull); // Upload

        await _tapText(tester, 'Next'); // -> Map
        expect(tester.takeException(), isNull);

        await _tapText(tester, 'Next'); // -> Preview
        expect(tester.takeException(), isNull);

        await _tapText(tester, 'Next'); // -> Commit
        expect(tester.takeException(), isNull);
      });
    }
  });
}
