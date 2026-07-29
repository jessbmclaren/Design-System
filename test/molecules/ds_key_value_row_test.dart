import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// The row a record is read from — the other half of every form field.
void main() {
  testWidgets('a blank reads as a deliberate blank, not a missing row', (
    tester,
  ) async {
    // The alternative is collapsing the row, which makes a value the system
    // does not know look identical to one it never asked for.
    await pumpDs(tester, const DsKeyValueRow(label: 'VIN'));
    expect(find.text('VIN'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);

    await pumpDs(tester, const DsKeyValueRow(label: 'VIN', value: '   '));
    expect(
      find.text('—'),
      findsOneWidget,
      reason: 'whitespace is not an answer',
    );
  });

  testWidgets('a value renders, and its hint follows it in the same run', (
    tester,
  ) async {
    await pumpDs(
      tester,
      const DsKeyValueRow(
        label: 'Fleet number',
        value: 'FL-014',
        hint: 'Optional',
      ),
    );
    // One Text.rich, so the parenthesis flows after a wrapped value rather
    // than stranding itself on its own line.
    expect(find.textContaining('FL-014'), findsOneWidget);
    expect(find.textContaining('(Optional)'), findsOneWidget);
  });

  testWidgets('a widget value wins over a text one', (tester) async {
    await pumpDs(
      tester,
      const DsKeyValueRow(
        label: 'Status',
        value: 'ignored',
        valueWidget: DsBadge(label: 'Active'),
      ),
    );
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('ignored'), findsNothing);
  });

  testWidgets('label and value are announced as one phrase', (tester) async {
    // Two stops for one fact makes a record twice as long to hear as to read.
    final handle = tester.ensureSemantics();
    await pumpDs(
      tester,
      const DsKeyValueRow(label: 'Fuel type', value: 'Diesel'),
    );
    // Merged to "Fuel type\nDiesel" — one node, the newline giving a reader
    // its pause between the label and the value.
    expect(
      find.bySemanticsLabel(RegExp('Fuel type.*Diesel', dotAll: true)),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('it is not a control — no button semantics anywhere', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpDs(
      tester,
      const DsKeyValueRow(label: 'Fuel type', value: 'Diesel'),
    );
    final SemanticsNode node = tester.getSemantics(
      find.byType(DsKeyValueRow),
    );
    expect(
      node.flagsCollection.isButton,
      isFalse,
      reason: 'a row that announces itself as a button promises a tap that '
          'does nothing',
    );
    handle.dispose();
  });

  testWidgets('a long value wraps rather than overflowing a narrow panel', (
    tester,
  ) async {
    await pumpDs(
      tester,
      const SizedBox(
        width: 320,
        child: DsKeyValueRow(
          label: 'Vehicle type',
          value: 'Heavy Commercial Vehicle (≤8 ton)',
        ),
      ),
      surfaceSize: const Size(360, 640),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('stacked rows line their values up', (tester) async {
    await pumpDs(
      tester,
      const SizedBox(
        width: 400,
        child: Column(
          children: <Widget>[
            DsKeyValueRow(label: 'Make', value: 'Toyota'),
            DsKeyValueRow(label: 'Registration', value: 'HRV 482 GP'),
          ],
        ),
      ),
    );
    // The fixed label column is what buys the alignment. With a floor instead,
    // 'Registration' is wider than the minimum and pushes its own value out of
    // line with 'Make' — which is exactly what this caught.
    expect(
      tester.getTopLeft(find.text('Toyota')).dx,
      tester.getTopLeft(find.text('HRV 482 GP')).dx,
    );
  });
}
