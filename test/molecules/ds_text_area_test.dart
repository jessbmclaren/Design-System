import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders label, hint and helper text', (tester) async {
    await pumpDs(
      tester,
      const DsTextArea(
        label: 'Notes',
        hintText: 'Add any additional detail',
        helperText: 'Optional',
      ),
    );

    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Add any additional detail'), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);
  });

  testWidgets('fires onChanged when the user types', (tester) async {
    String? changed;
    await pumpDs(
      tester,
      DsTextArea(
        label: 'Notes',
        onChanged: (value) => changed = value,
      ),
    );

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();

    expect(changed, 'hello');
  });

  testWidgets('shows a live character counter that updates with input',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpDs(
      tester,
      DsTextArea(
        label: 'Notes',
        controller: controller,
        maxLength: 200,
      ),
    );

    expect(find.text('0 / 200'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'abcd');
    await tester.pump();

    expect(find.text('4 / 200'), findsOneWidget);
  });

  testWidgets('renders error text and prefers it over helper text',
      (tester) async {
    await pumpDs(
      tester,
      const DsTextArea(
        label: 'Notes',
        helperText: 'Optional',
        errorText: 'This field is required',
      ),
    );

    expect(find.text('This field is required'), findsOneWidget);
    expect(find.text('Optional'), findsNothing);
  });

  testWidgets('lays out without overflow at small phone width', (tester) async {
    await pumpDs(
      tester,
      const DsTextArea(
        label: 'Notes',
        hintText: 'Add any additional detail',
        helperText: 'Optional',
        maxLength: 200,
      ),
      surfaceSize: const Size(320, 900),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out without overflow at large desktop width',
      (tester) async {
    await pumpDs(
      tester,
      const DsTextArea(
        label: 'Notes',
        hintText: 'Add any additional detail',
        helperText: 'Optional',
        maxLength: 200,
      ),
      surfaceSize: const Size(1200, 900),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
