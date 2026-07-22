import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const steps = [
    'Download the CSV template.',
    'Fill in one row per customer.',
    'Upload the completed file.',
  ];

  testWidgets('renders the title, description and numbered steps',
      (tester) async {
    await pumpDs(
      tester,
      const DsImportGuide(
        title: 'Add via CSV',
        description: 'Import many customers at once from a spreadsheet.',
        steps: steps,
      ),
    );

    expect(find.text('Add via CSV'), findsOneWidget);
    expect(
      find.text('Import many customers at once from a spreadsheet.'),
      findsOneWidget,
    );
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('Download the CSV template.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(find.text('Fill in one row per customer.'), findsOneWidget);
    expect(find.text('3.'), findsOneWidget);
    expect(find.text('Upload the completed file.'), findsOneWidget);
  });

  testWidgets('the download button fires onDownloadTemplate', (tester) async {
    var downloads = 0;
    await pumpDs(
      tester,
      DsImportGuide(
        title: 'Add via CSV',
        steps: steps,
        onDownloadTemplate: () => downloads++,
      ),
    );

    await tester.tap(find.widgetWithText(DsButton, 'Download template'));
    await tester.pump();

    expect(downloads, 1);
  });

  testWidgets('hides the download button when onDownloadTemplate is null',
      (tester) async {
    await pumpDs(tester, const DsImportGuide(title: 'Add via CSV', steps: steps));

    expect(find.text('Download template'), findsNothing);
    expect(find.byType(DsButton), findsNothing);
  });

  testWidgets('the guide link fires onOpenGuide', (tester) async {
    var opened = 0;
    await pumpDs(
      tester,
      DsImportGuide(
        title: 'Add via CSV',
        guideLabel: 'View template guide',
        onOpenGuide: () => opened++,
      ),
    );

    await tester.tap(find.widgetWithText(DsLink, 'View template guide'));
    await tester.pump();

    expect(opened, 1);
  });

  testWidgets('hides the guide link when guideLabel is null', (tester) async {
    var opened = 0;
    await pumpDs(
      tester,
      DsImportGuide(title: 'Add via CSV', onOpenGuide: () => opened++),
    );

    expect(find.byType(DsLink), findsNothing);
  });

  testWidgets('renders without overflow on a small phone', (tester) async {
    await pumpDs(
      tester,
      DsImportGuide(
        title: 'Add via CSV',
        description: 'Import many customers at once from a spreadsheet.',
        steps: steps,
        onDownloadTemplate: () {},
        guideLabel: 'View template guide',
        onOpenGuide: () {},
      ),
      surfaceSize: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a large desktop', (tester) async {
    await pumpDs(
      tester,
      DsImportGuide(
        title: 'Add via CSV',
        description: 'Import many customers at once from a spreadsheet.',
        steps: steps,
        onDownloadTemplate: () {},
        guideLabel: 'View template guide',
        onOpenGuide: () {},
      ),
      surfaceSize: const Size(1440, 900),
    );

    expect(tester.takeException(), isNull);
  });
}
