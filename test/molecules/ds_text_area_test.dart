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

  testWidgets('border widths and the disabled fade re-style with the skin',
      (tester) async {
    await pumpDs(
      tester,
      const DsTextArea(label: 'Notes'),
      theme: DsTheme.light(
        tokens: DsTokens.light().copyWith(
          inputBorderWidth: 3,
          inputFocusBorderWidth: 5,
          stateDisabledOpacity: 0.3,
        ),
      ),
    );

    final TextField field = tester.widget(find.byType(TextField));
    final decoration = field.decoration!;
    OutlineInputBorder outline(InputBorder? border) =>
        border! as OutlineInputBorder;

    expect(outline(decoration.enabledBorder).borderSide.width, 3);
    expect(outline(decoration.focusedBorder).borderSide.width, 5);
    final disabled = outline(decoration.disabledBorder).borderSide;
    expect(disabled.width, 3);
    expect(disabled.color.a, closeTo(0.3, 0.005));
  });

  testWidgets('the error border carries the focus emphasis', (tester) async {
    await pumpDs(
      tester,
      const DsTextArea(label: 'Notes', errorText: 'Too long'),
      theme: DsTheme.light(
        tokens: DsTokens.light().copyWith(inputFocusBorderWidth: 5),
      ),
    );

    final TextField field = tester.widget(find.byType(TextField));
    final enabled = field.decoration!.enabledBorder! as OutlineInputBorder;
    expect(enabled.borderSide.width, 5);
  });

  testWidgets('the label gap reads the fieldLabelGap token', (tester) async {
    await pumpDs(
      tester,
      const DsTextArea(label: 'Notes'),
      theme: DsTheme.light(
        tokens: DsTokens.light().copyWith(fieldLabelGap: 14),
      ),
    );

    final labelBottom = tester.getBottomLeft(find.text('Notes')).dy;
    final fieldTop = tester.getTopLeft(find.byType(TextField)).dy;
    expect(fieldTop - labelBottom, 14);
  });
}
