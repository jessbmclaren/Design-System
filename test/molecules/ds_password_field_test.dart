import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsPasswordField', () {
    testWidgets('starts obscured and the eye toggle reveals the value',
        (tester) async {
      await pumpDs(tester, const DsPasswordField(label: 'Password'));

      // While obscured, the control offers to reveal (an open eye).
      expect(find.byIcon(DsIcons.visibility), findsOneWidget);
      expect(find.byIcon(DsIcons.visibilityOff), findsNothing);

      await tester.tap(find.byIcon(DsIcons.visibility));
      await tester.pump();

      expect(find.byIcon(DsIcons.visibilityOff), findsOneWidget);
    });

    testWidgets('reports changes through onChanged', (tester) async {
      String? latest;
      await pumpDs(
        tester,
        DsPasswordField(label: 'Password', onChanged: (v) => latest = v),
      );

      await tester.enterText(find.byType(TextField), 'hunter2');
      expect(latest, 'hunter2');
    });

    testWidgets('forwards validator to the underlying field', (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: formKey,
          child: DsPasswordField(
            label: 'Password',
            validator: (value) =>
                dsPasswordMeetsAll(value ?? '') ? null : 'Password too weak',
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Password too weak'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Aa1!aaaa');
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('forwards autovalidateMode to the underlying field',
        (tester) async {
      await pumpDs(
        tester,
        Form(
          child: DsPasswordField(
            label: 'Password',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) =>
                (value ?? '').length >= 8 ? null : 'Too short',
          ),
        ),
      );

      expect(find.text('Too short'), findsNothing);
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.text('Too short'), findsOneWidget);
    });

    testWidgets('declares password autofill and keeps the value out of the '
        'keyboard suggestion engine', (tester) async {
      await pumpDs(tester, const DsPasswordField(label: 'Password'));

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.autofillHints, <String>[AutofillHints.password]);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
    });

    testWidgets('newPassword switches the autofill hint for sign-up flows',
        (tester) async {
      await pumpDs(
        tester,
        const DsPasswordField(label: 'Password', newPassword: true),
      );

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.autofillHints, <String>[AutofillHints.newPassword]);
    });
  });
}
