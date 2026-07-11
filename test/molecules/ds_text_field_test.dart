import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    testWidgets('a failing validator wins over errorText, so exactly one '
        'caption shows', (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: formKey,
          child: DsTextField(
            label: 'Email',
            errorText: 'From errorText',
            validator: (_) => 'From validator',
          ),
        ),
      );

      // Until the validator runs, the errorText prop shows.
      expect(find.text('From errorText'), findsOneWidget);

      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('From validator'), findsOneWidget);
      expect(find.text('From errorText'), findsNothing);
    });

    testWidgets('helperText is suppressed while a validator error shows',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: formKey,
          child: DsTextField(
            label: 'Email',
            helperText: 'We never share it.',
            validator: (_) => 'Email is required',
          ),
        ),
      );

      expect(find.text('We never share it.'), findsOneWidget);

      formKey.currentState!.validate();
      // Let the decorator's helper-to-error fade finish: the outgoing helper
      // stays in the tree until the transition completes.
      await tester.pumpAndSettle();
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('We never share it.'), findsNothing);
    });

    testWidgets('passes autofill hints and the keyboard suggestion switches '
        'through', (tester) async {
      await pumpDs(
        tester,
        const DsTextField(
          label: 'Email',
          autofillHints: <String>[AutofillHints.email],
          autocorrect: false,
          enableSuggestions: false,
        ),
      );

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.autofillHints, <String>[AutofillHints.email]);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
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

    testWidgets('optional renders the subdued marker in the label row',
        (tester) async {
      await pumpDs(
        tester,
        const DsTextField(label: 'Company', optional: true),
      );

      expect(find.text('Company'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
    });

    testWidgets('validator reports its message when the form validates',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: formKey,
          child: DsTextField(
            label: 'Email',
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Email required' : null,
          ),
        ),
      );

      expect(find.text('Email required'), findsNothing);
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Email required'), findsOneWidget);
    });

    testWidgets('autovalidateMode onUserInteraction validates after edits',
        (tester) async {
      await pumpDs(
        tester,
        Form(
          child: DsTextField(
            label: 'Email',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) =>
                (value ?? '').contains('@') ? null : 'Enter a valid email',
          ),
        ),
      );

      // Untouched, the field shows no error.
      expect(find.text('Enter a valid email'), findsNothing);

      await tester.enterText(find.byType(TextField), 'nope');
      await tester.pump();
      expect(find.text('Enter a valid email'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'a@b.co');
      await tester.pump();
      expect(find.text('Enter a valid email'), findsNothing);
    });

    testWidgets('onSaved receives the value when the form saves',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      String? saved;
      await pumpDs(
        tester,
        Form(
          key: formKey,
          child: DsTextField(label: 'Name', onSaved: (value) => saved = value),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Ada');
      formKey.currentState!.save();
      expect(saved, 'Ada');
    });

    testWidgets('inputFormatters filter what the user types', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpDs(
        tester,
        DsTextField(
          label: 'Amount',
          controller: controller,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      );

      await tester.enterText(find.byType(TextField), '12ab3');
      expect(controller.text, '123');
    });

    testWidgets('maxLength caps input and shows a counter', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpDs(
        tester,
        DsTextField(label: 'Code', controller: controller, maxLength: 4),
      );

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      expect(controller.text, '1234');
      expect(find.text('4/4'), findsOneWidget);
    });

    testWidgets('minLines reserves a taller text area', (tester) async {
      await pumpDs(
        tester,
        const DsTextField(label: 'Notes', minLines: 3, maxLines: 6),
      );

      final EditableText editable = tester.widget(find.byType(EditableText));
      expect(editable.minLines, 3);
      expect(editable.maxLines, 6);
    });

    testWidgets('readOnly keeps the value but rejects edits', (tester) async {
      final controller = TextEditingController(text: 'fixed');
      addTearDown(controller.dispose);
      await pumpDs(
        tester,
        DsTextField(label: 'Reference', controller: controller, readOnly: true),
      );

      final EditableText editable = tester.widget(find.byType(EditableText));
      expect(editable.readOnly, isTrue);
    });

    testWidgets('the label is announced with the control', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(tester, const DsTextField(label: 'Email'));

      // The semantics wrapper carries the label on the node that holds the
      // text field, so assistive technology names the control.
      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(label: 'Email'),
      );
      handle.dispose();
    });

    testWidgets('the error is announced as a live region', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const DsTextField(label: 'Email', errorText: 'Enter a valid email'),
      );

      // The decorator marks the error caption as a live region, so screen
      // readers announce it as soon as it appears.
      expect(
        tester.getSemantics(find.text('Enter a valid email')),
        isSemantics(label: 'Enter a valid email', isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('announces the label exactly once', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(tester, const DsTextField(label: 'Email'));

      // The visible label text is excluded from semantics; only the control
      // itself carries the label.
      expect(find.bySemanticsLabel('Email'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('folds the optional marker into the field label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(tester, const DsTextField(label: 'Company', optional: true));

      final node = tester.getSemantics(find.byType(TextFormField));
      expect(node.label, contains('Company'));
      expect(node.label.toLowerCase(), contains('optional'));
      handle.dispose();
    });

    testWidgets('border widths and the disabled fade re-style with the skin',
        (tester) async {
      await pumpDs(
        tester,
        const DsTextField(label: 'Email'),
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
      // Error borders share the focus emphasis.
      expect(outline(decoration.errorBorder).borderSide.width, 5);
      expect(outline(decoration.focusedErrorBorder).borderSide.width, 5);
      final disabled = outline(decoration.disabledBorder).borderSide;
      expect(disabled.width, 3);
      expect(disabled.color.a, closeTo(0.3, 0.005));
    });

    testWidgets('the label gap reads the fieldLabelGap token', (tester) async {
      await pumpDs(
        tester,
        const DsTextField(label: 'Email'),
        theme: DsTheme.light(
          tokens: DsTokens.light().copyWith(fieldLabelGap: 14),
        ),
      );

      final labelBottom = tester.getBottomLeft(find.text('Email')).dy;
      final fieldTop = tester.getTopLeft(find.byType(TextField)).dy;
      expect(fieldTop - labelBottom, 14);
    });
  });
}
