import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const capital = 'One uppercase letter';

  Color labelColour(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style!.color!;
  Color danger(WidgetTester tester) =>
      DsTokens.of(tester.element(find.text(capital))).colorDanger;

  DsChoosePasswordView view({
    String value = '',
    bool attempted = false,
    VoidCallback? onSave,
    List<DsPasswordRule> extraRules = const <DsPasswordRule>[],
  }) => DsChoosePasswordView(
    value: value,
    attempted: attempted,
    extraRules: extraRules,
    primaryAction: DsSignInAction(
      label: 'Save new password',
      onPressed: onSave,
    ),
  );

  group('DsChoosePasswordView', () {
    testWidgets('it renders one password field and the checklist', (
      tester,
    ) async {
      await pumpDs(tester, view());
      expect(find.text('Choose a new password'), findsOneWidget);
      // One field: no confirm box.
      expect(find.byType(DsPasswordField), findsOneWidget);
      expect(find.byType(DsPasswordRequirements), findsOneWidget);
      expect(find.widgetWithText(DsButton, 'Save new password'), findsOneWidget);
    });

    testWidgets('the checklist is the only feedback: no meter, no strength word', (
      tester,
    ) async {
      await pumpDs(tester, view(value: '7xQ!ropVma2z'));
      expect(find.byType(DsPasswordStrength), findsNothing);
      expect(find.text('Good'), findsNothing);
      expect(find.text('Strong'), findsNothing);
    });

    testWidgets('unmet rows stay neutral while typing', (tester) async {
      await pumpDs(tester, view(value: 'abcdefgh1234567890!!'));
      expect(labelColour(tester, capital), isNot(danger(tester)));
    });

    testWidgets('unmet rows turn red once attempted', (tester) async {
      await pumpDs(
        tester,
        view(value: 'abcdefgh1234567890!!', attempted: true),
      );
      expect(labelColour(tester, capital), danger(tester));
    });

    testWidgets('the primary action fires', (tester) async {
      var saves = 0;
      await pumpDs(tester, view(value: '7xQ!ropVma2z', onSave: () => saves++));
      await tester.tap(find.widgetWithText(DsButton, 'Save new password'));
      expect(saves, 1);
    });

    testWidgets('a null action disables the button', (tester) async {
      await pumpDs(tester, view(value: 'short'));
      final button = tester.widget<DsButton>(
        find.widgetWithText(DsButton, 'Save new password'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('caller extra rules appear in the checklist', (tester) async {
      await pumpDs(
        tester,
        view(
          value: '7xQ!ropVma2z',
          extraRules: const <DsPasswordRule>[
            DsPasswordRule('Not found in known data breaches', true),
          ],
        ),
      );
      expect(find.text('Not found in known data breaches'), findsOneWidget);
    });

    testWidgets('embedded mode drops its own scroll for a host that frames', (
      tester,
    ) async {
      // Standalone: frames its own page, so it scrolls itself.
      await pumpDs(tester, view(value: 'abc'));
      expect(find.byType(SingleChildScrollView), findsWidgets);

      // Embedded: the host owns the scroll, so the view adds none of its own —
      // otherwise two vertical scrollables would nest and throw.
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DsChoosePasswordView(
                value: 'abc',
                embedded: true,
                primaryAction: const DsSignInAction(
                  label: 'Save new password',
                  onPressed: null,
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      // Exactly the host's one scroll view; the card added none.
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Choose a new password'), findsOneWidget);
    });

    testWidgets('it renders without overflow at 320dp and stretched wide', (
      tester,
    ) async {
      await pumpDs(
        tester,
        view(value: 'abcdefgh1234567890!!', attempted: true),
        surfaceSize: const Size(320, 900),
      );
      expect(tester.takeException(), isNull);
      await pumpDs(
        tester,
        view(value: 'abc'),
        surfaceSize: const Size(1440, 900),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('it renders in dark and under a skin', (tester) async {
      await pumpDs(tester, view(value: 'abc'), theme: DsTheme.dark());
      expect(find.text('Choose a new password'), findsOneWidget);
      await pumpDs(
        tester,
        view(value: 'abc'),
        theme: DsTheme.light(tokens: DsSkins.engenLight()),
      );
      expect(find.text('Choose a new password'), findsOneWidget);
    });
  });
}
