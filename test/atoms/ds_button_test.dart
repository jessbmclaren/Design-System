import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// WCAG relative luminance of an sRGB colour.
double _luminance(Color c) {
  double channel(double v) {
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// WCAG contrast ratio between two colours (1..21).
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('DsButton', () {
    testWidgets('pins a padded tap target so it is 48dp on every platform',
        (tester) async {
      await pumpDs(tester, DsButton(label: 'Continue', onPressed: () {}));
      final style = tester.widget<FilledButton>(find.byType(FilledButton)).style;
      expect(style?.tapTargetSize, MaterialTapTargetSize.padded);
    });

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

    testWidgets('pending keeps the enabled fill and the spinner in the '
        'variant text colour', (tester) async {
      await pumpDs(
        tester,
        DsButton(label: 'Saving', pending: true, onPressed: () {}),
      );
      await tester.pump();

      final tokens = DsTokens.of(tester.element(find.byType(DsButton)));
      final style =
          tester.widget<FilledButton>(find.byType(FilledButton)).style!;
      // The button is busy, not disabled: the resolved fill stays the
      // enabled background so the spinner holds its contrast.
      expect(
        style.backgroundColor!.resolve({WidgetState.disabled}),
        tokens.buttonPrimaryColorBackground,
      );
      expect(
        style.foregroundColor!.resolve({WidgetState.disabled}),
        tokens.buttonPrimaryColorText,
      );
      final spinner = tester.widget<DsSpinner>(find.byType(DsSpinner));
      expect(spinner.color, tokens.buttonPrimaryColorText);
    });

    testWidgets('the pending spinner clears 3:1 against its fill in every '
        'shipped theme', (tester) async {
      final themes = <String, DsTokens>{
        'light': DsTokens.light(),
        'dark': DsTokens.dark(),
        'engenLight': DsSkins.engenLight(),
        'engenDark': DsSkins.engenDark(),
      };
      for (final entry in themes.entries) {
        final ratio = _contrast(
          entry.value.buttonPrimaryColorText,
          entry.value.buttonPrimaryColorBackground,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'pending spinner on ${entry.key}: '
              '${ratio.toStringAsFixed(2)}:1',
        );
      }
    });

    testWidgets('removal mid-press does not throw', (tester) async {
      await pumpDs(tester, DsButton(label: 'Save', onPressed: () {}));

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(DsButton)));
      await tester.pump(const Duration(milliseconds: 40));

      // Removing the button cancels the press, which flips the pressed state
      // after the element is deactivated. The state listener must read its
      // cached reduce-motion flag, never MediaQuery through the context.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(tester.takeException(), isNull);

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
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

    testWidgets('stays still and runs no press animation under reduced '
        'motion', (tester) async {
      await pumpDs(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: DsButton(label: 'Save', onPressed: () {}),
        ),
      );

      double scale() => tester
          .widget<ScaleTransition>(
            find.descendant(
              of: find.byType(DsButton),
              matching: find.byType(ScaleTransition),
            ),
          )
          .scale
          .value;

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(DsButton)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      // Mid-press the button has not scaled down.
      expect(scale(), 1);

      await gesture.up();
      await tester.pump();
      expect(scale(), 1);

      // Flush the ink highlight fade (a fixed, non-repeating Material
      // effect), after which nothing may still be animating: the press
      // spring must never have started.
      await tester.pump(const Duration(milliseconds: 400));
      expect(scale(), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a pending button stays keyboard focusable', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsButton(label: 'Saving', pending: true, onPressed: () {}),
      );
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(DsButton)),
        isSemantics(isFocusable: true),
      );
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

    testWidgets('a skin can retune the button metrics and state tokens',
        (tester) async {
      final skin = DsTokens.light().copyWith(
        buttonMinHeight: 56,
        buttonIconSize: 30,
        buttonRestBorderWidth: 3,
        focusRingWidth: 4,
        stateDisabledOpacity: 0.25,
        stateDisabledTextOpacity: 0.7,
      );
      await pumpDs(
        tester,
        const DsButton(
          label: 'Save',
          icon: Icons.check,
          variant: DsButtonVariant.secondary,
        ),
        theme: DsTheme.light(tokens: skin),
      );

      final style =
          tester.widget<FilledButton>(find.byType(FilledButton)).style!;
      expect(style.minimumSize!.resolve({})!.height, 56);
      expect(tester.widget<Icon>(find.byIcon(Icons.check)).size, 30);
      expect(style.side!.resolve({})!.width, 3);
      expect(style.side!.resolve({WidgetState.focused})!.width, 4);
      // The non-primary disabled fade follows the state opacity tokens.
      expect(
        style.backgroundColor!.resolve({WidgetState.disabled}),
        skin.buttonSecondaryColorBackground.withValues(alpha: 0.25),
      );
      expect(
        style.foregroundColor!.resolve({WidgetState.disabled}),
        skin.buttonSecondaryColorText.withValues(alpha: 0.7),
      );
    });

    testWidgets('a skin can restyle the tertiary variant through its tokens',
        (tester) async {
      final skin = DsTokens.light().copyWith(
        buttonTertiaryColorBackground: const Color(0xFFEEF2FF),
        buttonTertiaryColorBorder: const Color(0xFF6366F1),
        buttonTertiaryColorText: const Color(0xFF312E81),
      );
      await pumpDs(
        tester,
        DsButton(
          label: 'Back',
          variant: DsButtonVariant.tertiary,
          onPressed: () {},
        ),
        theme: DsTheme.light(tokens: skin),
      );

      final style =
          tester.widget<FilledButton>(find.byType(FilledButton)).style!;
      expect(style.backgroundColor!.resolve({}), const Color(0xFFEEF2FF));
      expect(style.side!.resolve({})!.color, const Color(0xFF6366F1));
      expect(style.foregroundColor!.resolve({}), const Color(0xFF312E81));
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

  group('DsButton gradient fill', () {
    /// The gradient the button paints, or null when it is a flat fill.
    LinearGradient? gradientOf(WidgetTester tester) {
      final Finder decorated = find.descendant(
        of: find.byType(FilledButton),
        matching: find.byType(DecoratedBox),
      );
      for (final DecoratedBox box
          in tester.widgetList<DecoratedBox>(decorated)) {
        final Decoration decoration = box.decoration;
        if (decoration is BoxDecoration && decoration.gradient != null) {
          return decoration.gradient! as LinearGradient;
        }
      }
      return null;
    }

    testWidgets('the neutral base paints a flat primary fill', (tester) async {
      // Empty stops mean nothing changes for the white-label default.
      expect(DsTokens.light().buttonPrimaryGradient, isEmpty);
      expect(DsTokens.dark().buttonPrimaryGradient, isEmpty);

      await pumpDs(tester, DsButton(label: 'Save', onPressed: () {}));
      expect(gradientOf(tester), isNull);
    });

    testWidgets('a skin with stops paints them corner to corner', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsButton(label: 'Approve all', onPressed: () {}),
        theme: DsTheme.light(tokens: DsSkins.engenMobileLight()),
      );

      final LinearGradient? gradient = gradientOf(tester);
      expect(gradient, isNotNull);
      expect(gradient!.colors, DsSkins.engenMobileLight().buttonPrimaryGradient);
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
    });

    testWidgets('only the primary variant takes the gradient', (tester) async {
      for (final DsButtonVariant variant in <DsButtonVariant>[
        DsButtonVariant.secondary,
        DsButtonVariant.tertiary,
        DsButtonVariant.neutral,
        DsButtonVariant.danger,
      ]) {
        await pumpDs(
          tester,
          DsButton(label: 'Act', variant: variant, onPressed: () {}),
          theme: DsTheme.light(tokens: DsSkins.engenMobileLight()),
        );
        expect(gradientOf(tester), isNull, reason: '$variant took a gradient');
      }
    });

    testWidgets('a disabled button drops the gradient for its solid tint', (
      tester,
    ) async {
      // A gradient reads as available, so the disabled treatment stays flat.
      await pumpDs(
        tester,
        const DsButton(label: 'Approve all', onPressed: null),
        theme: DsTheme.light(tokens: DsSkins.engenMobileLight()),
      );
      expect(gradientOf(tester), isNull);
    });

    testWidgets('a pending button keeps the gradient', (tester) async {
      // Pending is busy, not disabled: the resting fill stays so the spinner
      // holds its contrast.
      await pumpDs(
        tester,
        DsButton(label: 'Approve all', pending: true, onPressed: () {}),
        theme: DsTheme.light(tokens: DsSkins.engenMobileLight()),
      );
      expect(gradientOf(tester), isNotNull);
    });

    testWidgets('a single stop stays a flat fill', (tester) async {
      await pumpDs(
        tester,
        DsButton(label: 'Save', onPressed: () {}),
        theme: DsTheme.light(
          tokens: DsTokens.light()
              .copyWith(buttonPrimaryGradient: const <Color>[Color(0xFF1650B8)]),
        ),
      );
      expect(gradientOf(tester), isNull);
    });

    testWidgets('holds the label and 320dp with a gradient, both modes', (
      tester,
    ) async {
      for (final ThemeData theme in <ThemeData>[
        DsTheme.light(tokens: DsSkins.engenMobileLight()),
        DsTheme.dark(tokens: DsSkins.engenMobileDark()),
      ]) {
        await pumpDs(
          tester,
          DsButton(
            label: 'A remarkably long call to action that will not fit',
            fullWidth: true,
            onPressed: () {},
          ),
          theme: theme,
          surfaceSize: const Size(320, 480),
        );
        expect(find.byType(DsButton), findsOneWidget);
        expect(gradientOf(tester), isNotNull);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
