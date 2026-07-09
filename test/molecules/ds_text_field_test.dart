import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsTextField', () {
    testWidgets('renders label, hint and helper text', (tester) async {
      await pumpDs(
        tester,
        const DsTextField(
          label: 'Email',
          hintText: 'you@example.com',
          helperText: 'We never share it.',
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('you@example.com'), findsOneWidget);
      expect(find.text('We never share it.'), findsOneWidget);
    });

    testWidgets('shows the controller value and reports typed text',
        (tester) async {
      final controller = TextEditingController(text: 'hello');
      addTearDown(controller.dispose);
      String? changed;

      await pumpDs(
        tester,
        DsTextField(
          label: 'Name',
          controller: controller,
          onChanged: (value) => changed = value,
        ),
      );

      expect(find.text('hello'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'world');
      await tester.pump();

      expect(changed, 'world');
      expect(controller.text, 'world');
    });

    testWidgets('disabled field suppresses input', (tester) async {
      String? changed;

      await pumpDs(
        tester,
        DsTextField(
          label: 'Name',
          enabled: false,
          onChanged: (value) => changed = value,
        ),
      );

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.enabled, isFalse);

      await tester.enterText(find.byType(TextField), 'nope');
      await tester.pump();

      expect(changed, isNull);
    });

    testWidgets('error state renders errorText in place of helperText',
        (tester) async {
      await pumpDs(
        tester,
        const DsTextField(
          label: 'Email',
          helperText: 'We never share it.',
          errorText: 'Enter a valid email',
        ),
      );

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('We never share it.'), findsNothing);
    });

    testWidgets('obscureText hides the input', (tester) async {
      await pumpDs(
        tester,
        const DsTextField(
          label: 'Password',
          obscureText: true,
        ),
      );

      final EditableText editable =
          tester.widget(find.byType(EditableText));
      expect(editable.obscureText, isTrue);
    });

    testWidgets('renders without overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        const DsTextField(
          label: 'Email',
          hintText: 'you@example.com',
          errorText: 'Enter a valid email',
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
