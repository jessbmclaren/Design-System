import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsButton', () {
    testWidgets('renders its label', (tester) async {
      await pumpDs(tester, const DsButton(label: 'Continue'));

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('renders a leading icon when set', (tester) async {
      await pumpDs(
        tester,
        const DsButton(label: 'Add', icon: Icons.add),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders a trailing icon when set', (tester) async {
      await pumpDs(
        tester,
        const DsButton(label: 'Continue', trailingIcon: Icons.arrow_forward),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsButton(label: 'Save', onPressed: () => taps++),
      );

      await tester.tap(find.byType(DsButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('a null onPressed disables it and swallows taps',
        (tester) async {
      await pumpDs(tester, const DsButton(label: 'Disabled'));

      // Tapping a disabled button must not throw and does nothing observable.
      await tester.tap(find.byType(DsButton), warnIfMissed: false);
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('a disabled primary button uses the disabled tokens',
        (tester) async {
      await pumpDs(tester, const DsButton(label: 'Disabled'));

      final tokens = DsTokens.of(tester.element(find.byType(DsButton)));
      final style =
          tester.widget<FilledButton>(find.byType(FilledButton)).style!;
      expect(
        style.backgroundColor!.resolve({WidgetState.disabled}),
        tokens.buttonPrimaryDisabledColorBackground,
      );
      expect(
        style.foregroundColor!.resolve({WidgetState.disabled}),
        tokens.buttonPrimaryDisabledColorText,
      );
      // The default disabled tokens equal the fade the button used to derive.
      expect(
        tokens.buttonPrimaryDisabledColorBackground,
        tokens.buttonPrimaryColorBackground.withValues(alpha: 0.5),
      );
    });

    testWidgets('pending shows a spinner over the label and blocks taps',
        (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsButton(
          label: 'Saving',
          pending: true,
          onPressed: () => taps++,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // The label stays mounted (at zero opacity) so the width holds.
      expect(find.text('Saving'), findsOneWidget);
      final opacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('Saving'), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, 0);

      await tester.tap(find.byType(DsButton), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('pending keeps the button at its label width', (tester) async {
      await pumpDs(
        tester,
        DsButton(label: 'Create account', onPressed: () {}),
      );
      final restingSize = tester.getSize(find.byType(FilledButton));

      await pumpDs(
        tester,
        const DsButton(label: 'Create account', pending: true),
      );
      await tester.pump();

      expect(tester.getSize(find.byType(FilledButton)), restingSize);
    });

    testWidgets('pending is announced as the label, busy', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const DsButton(label: 'Saving', pending: true),
      );
      await tester.pump();

      final node = tester.getSemantics(find.byType(DsButton));
      expect(node.label, contains('Saving, busy'));
      handle.dispose();
    });

    testWidgets('every variant renders', (tester) async {
      for (final variant in DsButtonVariant.values) {
        await pumpDs(
          tester,
          DsButton(
            label: 'Action',
            variant: variant,
            onPressed: () {},
          ),
        );
        await tester.pump();

        expect(find.byType(DsButton), findsOneWidget);
        expect(find.text('Action'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('tertiary renders text-only in the action colour',
        (tester) async {
      await pumpDs(
        tester,
        DsButton(
          label: 'Back',
          variant: DsButtonVariant.tertiary,
          onPressed: () {},
        ),
      );

      final tokens = DsTokens.of(tester.element(find.byType(DsButton)));
      final style =
          tester.widget<FilledButton>(find.byType(FilledButton)).style!;
      expect(style.backgroundColor!.resolve({}), Colors.transparent);
      expect(
        style.foregroundColor!.resolve({}),
        tokens.actionPrimaryColorText,
      );
      expect(
        style.side!.resolve({})!.color,
        Colors.transparent,
      );
    });

    testWidgets('neutral uses the neutral tokens, defaulting to secondary',
        (tester) async {
      await pumpDs(
        tester,
        DsButton(
          label: 'Continue with SSO',
          variant: DsButtonVariant.neutral,
          onPressed: () {},
        ),
      );

      final tokens = DsTokens.of(tester.element(find.byType(DsButton)));
      final style =
          tester.widget<FilledButton>(find.byType(FilledButton)).style!;
      expect(
        style.backgroundColor!.resolve({}),
        tokens.buttonNeutralColorBackground,
      );
      // The neutral defaults equal the secondary variant, so existing
      // surfaces keep their appearance.
      expect(
        tokens.buttonNeutralColorBackground,
        tokens.buttonSecondaryColorBackground,
      );
      expect(tokens.buttonNeutralColorText, tokens.buttonSecondaryColorText);
    });

    testWidgets('keyboard focus draws a ring distinct from the resting border',
        (tester) async {
      await pumpDs(
        tester,
        DsButton(label: 'Save', onPressed: () {}),
      );

      final tokens = DsTokens.of(tester.element(find.byType(DsButton)));
      final style =
          tester.widget<FilledButton>(find.byType(FilledButton)).style!;
      final resting = style.side!.resolve({})!;
      final focused = style.side!.resolve({WidgetState.focused})!;

      expect(resting.color, tokens.buttonPrimaryColorBorder);
      expect(resting.width, 1);
      expect(focused.color, tokens.buttonPrimaryColorText);
      expect(focused.width, 2);
      expect(focused, isNot(equals(resting)));
    });

    testWidgets('does not overflow at 320dp with fullWidth', (tester) async {
      await pumpDs(
        tester,
        DsButton(
          label: 'Full width action label',
          fullWidth: true,
          icon: Icons.check,
          onPressed: () {},
        ),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('DsButton.social', () {
    testWidgets('is a full-width neutral button with a provider glyph',
        (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsButton.social(
          icon: Icons.g_mobiledata,
          label: 'Continue with Google',
          onPressed: () => taps++,
        ),
      );

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
      // A social button is a DsButton, so type-based finders still match.
      final social = tester.widget<DsButton>(find.byType(DsButton));
      expect(social.variant, DsButtonVariant.neutral);

      await tester.tap(find.byType(DsButton));
      expect(taps, 1);
    });
  });
}
