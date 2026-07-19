import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const List<DsGridColumn> _columns = <DsGridColumn>[
  DsGridColumn(key: 'name', title: 'Name', editable: true),
  DsGridColumn(
      key: 'amount', title: 'Amount', type: DsCellType.number, editable: true),
  DsGridColumn(
      key: 'paid', title: 'Paid', type: DsCellType.checkbox, editable: true),
];

final List<DsGridRow> _rows = <DsGridRow>[
  const DsGridRow(id: 'a', cells: <String, Object?>{
    'name': 'Alpha',
    'amount': 10,
    'paid': true,
  }),
  const DsGridRow(id: 'b', cells: <String, Object?>{
    'name': 'Beta',
    'amount': 20,
    'paid': false,
  }),
];

/// Focuses the grid's cell node directly, as Tab traversal would.
void focusCells(WidgetTester tester) {
  final Focus focus = tester.widget<Focus>(
    find.byWidgetPredicate(
      (Widget w) =>
          w is Focus && w.focusNode?.debugLabel == 'DsDataGrid cells',
    ),
  );
  focus.focusNode!.requestFocus();
}

Widget _grid({
  bool editable = false,
  void Function(String, String, Object?)? onCellChanged,
}) {
  return SizedBox(
    width: 700,
    height: 400,
    child: DsDataGrid(
      columns: _columns,
      rows: _rows,
      editable: editable,
      onCellChanged: onCellChanged,
    ),
  );
}

void main() {
  String? clipboard;

  setUp(() {
    clipboard = null;
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform,
            (MethodCall call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        return null;
      }
      if (call.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': clipboard};
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('focusing the grid starts at the first cell and arrows move', (
    tester,
  ) async {
    await pumpDs(tester, _grid(), surfaceSize: const Size(800, 600));
    focusCells(tester);
    await tester.pump();

    // Move to (row 1, col 1) and copy: the clipboard tells us where we are.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(clipboard, '20');
  });

  testWidgets('arrows clamp at the edges', (tester) async {
    await pumpDs(tester, _grid(), surfaceSize: const Size(800, 600));
    focusCells(tester);
    await tester.pump();

    for (int i = 0; i < 5; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    }
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pump();

    expect(clipboard, 'Alpha');
  });

  testWidgets('shift and arrows grow a range and copy emits TSV', (
    tester,
  ) async {
    await pumpDs(tester, _grid(), surfaceSize: const Size(800, 600));
    focusCells(tester);
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(clipboard, 'Alpha\t10\nBeta\t20');
  });

  testWidgets('paste writes coerced values into editable cells only', (
    tester,
  ) async {
    final List<(String, String, Object?)> changes = <(String, String, Object?)>[];
    await pumpDs(
      tester,
      _grid(
        editable: true,
        onCellChanged: (String rowId, String key, Object? value) =>
            changes.add((rowId, key, value)),
      ),
      surfaceSize: const Size(800, 600),
    );
    focusCells(tester);
    await tester.pump();

    clipboard = 'Gamma\tnot-a-number\nDelta\t45';
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(changes, <(String, String, Object?)>[
      ('a', 'name', 'Gamma'),
      ('b', 'name', 'Delta'),
      ('b', 'amount', 45),
    ]);
  });

  testWidgets('paste does nothing on a read-only grid', (tester) async {
    await pumpDs(tester, _grid(), surfaceSize: const Size(800, 600));
    focusCells(tester);
    await tester.pump();

    clipboard = 'X';
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Alpha'), findsOneWidget);
  });

  testWidgets('enter opens the inline editor and arrows resume afterwards', (
    tester,
  ) async {
    final List<(String, String, Object?)> changes = <(String, String, Object?)>[];
    await pumpDs(
      tester,
      _grid(
        editable: true,
        onCellChanged: (String rowId, String key, Object? value) =>
            changes.add((rowId, key, value)),
      ),
      surfaceSize: const Size(800, 600),
    );
    focusCells(tester);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Renamed');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(changes.single, ('a', 'name', 'Renamed'));
    // Keyboard control is back with the cells: an arrow then a copy works.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(clipboard, '10');
  });

  testWidgets('enter toggles a focused checkbox', (tester) async {
    final List<(String, String, Object?)> changes = <(String, String, Object?)>[];
    await pumpDs(
      tester,
      _grid(
        editable: true,
        onCellChanged: (String rowId, String key, Object? value) =>
            changes.add((rowId, key, value)),
      ),
      surfaceSize: const Size(800, 600),
    );
    focusCells(tester);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(changes.single, ('a', 'paid', false));
  });

  testWidgets('keyboarding can be disabled', (tester) async {
    await pumpDs(
      tester,
      SizedBox(
        width: 700,
        height: 400,
        child: DsDataGrid(
          columns: _columns,
          rows: _rows,
          enableCellNavigation: false,
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(
      find.byWidgetPredicate(
        (Widget w) =>
            w is Focus && w.focusNode?.debugLabel == 'DsDataGrid cells',
      ),
      findsNothing,
    );
  });
}
