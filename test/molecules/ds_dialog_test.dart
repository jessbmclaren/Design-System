import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Pumps a button that presents [present] when tapped, recording its result.
Future<void> pumpPresenter(
  WidgetTester tester,
  Future<Object?> Function(BuildContext context) present, {
  required void Function(Object? result) onResult,
  Size? surfaceSize,
  ThemeData? theme,
}) async {
  await pumpDs(
    tester,
    Builder(
      builder: (BuildContext context) => TextButton(
        onPressed: () async => onResult(await present(context)),
        child: const Text('Open'),
      ),
    ),
    surfaceSize: surfaceSize,
    theme: theme,
  );
}

void main() {
  testWidgets('the dialog shows its title, body and actions, and returns a '
      'value', (tester) async {
    Object? result;
    await pumpPresenter(
      tester,
      (BuildContext context) => DsDialog.show<bool>(
        context,
        title: 'Delete group?',
        body: const Text('Vehicles return to Unassigned.'),
        actions: <Widget>[
          DsButton(
            label: 'Cancel',
            variant: DsButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          DsButton(
            label: 'Delete',
            variant: DsButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
      onResult: (Object? value) => result = value,
      surfaceSize: const Size(900, 700),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text('Delete group?'), findsOneWidget);
    expect(find.text('Vehicles return to Unassigned.'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(result, isTrue);
    expect(find.text('Delete group?'), findsNothing);
  });

  testWidgets('escape dismisses the dialog with null', (tester) async {
    Object? result = 'unset';
    await pumpPresenter(
      tester,
      (BuildContext context) => DsDialog.show<bool>(
        context,
        title: 'Delete group?',
        body: const Text('body'),
      ),
      onResult: (Object? value) => result = value,
      surfaceSize: const Size(900, 700),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(result, isNull);
    expect(find.text('Delete group?'), findsNothing);
  });

  testWidgets('the modal sheet shows its title, body and actions', (
    tester,
  ) async {
    Object? result;
    await pumpPresenter(
      tester,
      (BuildContext context) => DsModalSheet.show<String>(
        context,
        title: 'Filter vehicles',
        body: const Text('Filters'),
        actions: <Widget>[
          DsButton(
            label: 'Apply',
            onPressed: () => Navigator.of(context).pop('applied'),
          ),
        ],
      ),
      onResult: (Object? value) => result = value,
      surfaceSize: const Size(390, 800),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    expect(find.text('Filter vehicles'), findsOneWidget);
    expect(find.text('Filters'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(result, 'applied');
    expect(find.text('Filter vehicles'), findsNothing);
  });

  testWidgets('the responsive presenter picks the dialog on a wide window '
      'and the sheet on a narrow one', (tester) async {
    Future<void> pumpAt(Size size) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () => showDsDialogOrSheet<void>(
                  context,
                  title: 'Filter vehicles',
                  body: const Text('Filters'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
    }

    // Wide: a dialog.
    await pumpAt(const Size(900, 700));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.byType(DsDialog), findsOneWidget);
    expect(find.byType(DsModalSheet), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Narrow: a sheet.
    await pumpAt(const Size(390, 800));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.byType(DsModalSheet), findsOneWidget);
    expect(find.byType(DsDialog), findsNothing);
  });

  testWidgets('both hold 320dp and 1440dp in every theme', (tester) async {
    for (final ThemeData theme in <ThemeData>[
      DsTheme.light(),
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
    ]) {
      for (final Size size in <Size>[const Size(320, 640), const Size(1440, 900)]) {
        await pumpDs(
          tester,
          DsDialog(
            title: 'A dialog with a rather long title that must wrap',
            body: const Text('Body copy'),
            actions: <Widget>[
              DsButton(label: 'Cancel', variant: DsButtonVariant.secondary, onPressed: () {}),
              DsButton(label: 'Confirm', onPressed: () {}),
            ],
          ),
          surfaceSize: size,
          theme: theme,
        );
        expect(tester.takeException(), isNull);

        await pumpDs(
          tester,
          DsModalSheet(
            title: 'A sheet title',
            body: const Text('Body copy'),
            actions: <Widget>[DsButton(label: 'Apply', onPressed: () {})],
          ),
          surfaceSize: size,
          theme: theme,
        );
        expect(tester.takeException(), isNull);
      }
    }
  });
}
