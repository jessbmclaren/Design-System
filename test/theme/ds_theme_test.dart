import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsTheme white-label wiring', () {
    test('overriding fontFamily re-fonts the text theme', () {
      final brand = DsTokens.light().copyWith(fontFamily: 'Roboto');
      final theme = DsTheme.light(tokens: brand);

      // Every ramp entry uses the overridden family, falling back to Inter.
      expect(theme.textTheme.bodyMedium!.fontFamily, 'Roboto');
      expect(theme.textTheme.displaySmall!.fontFamily, 'Roboto');
      expect(
        theme.textTheme.bodyMedium!.fontFamilyFallback,
        contains('packages/design_system/Inter'),
      );
    });

    test('default fontFamily resolves to the bundled Inter', () {
      final theme = DsTheme.light();
      expect(theme.textTheme.bodyMedium!.fontFamily,
          'packages/design_system/Inter');
    });

    test('overriding fontSizeBase scales the whole ramp', () {
      final base = DsTheme.light();
      final scaled =
          DsTheme.light(tokens: DsTokens.light().copyWith(fontSizeBase: 20));

      final baseSize = base.textTheme.bodyLarge!.fontSize!; // bodyMd = 16
      final scaledSize = scaled.textTheme.bodyLarge!.fontSize!;
      expect(scaledSize, closeTo(baseSize * 20 / 16, 0.001));
    });

    test('overriding colorPrimary flows into the color scheme', () {
      const brandPurple = Color(0xFF6D28D9);
      final theme = DsTheme.light(
        tokens: DsTokens.light().copyWith(colorPrimary: brandPurple),
      );
      expect(theme.colorScheme.primary, brandPurple);
    });

    test('overriding borderRadius drives the default surface shape', () {
      final theme = DsTheme.light(
        tokens: DsTokens.light().copyWith(borderRadius: 20),
      );
      final shape = theme.cardTheme.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(20));
    });

    test('the muted surface tier feeds the colour scheme', () {
      const probe = Color(0xFF123456);
      final theme = DsTheme.light(
        tokens: DsTokens.light().copyWith(colorSurfaceMuted: probe),
      );
      expect(theme.colorScheme.surfaceContainerHighest, probe);

      // The defaults reproduce the values the scheme used to hardcode.
      expect(
        DsTheme.light().colorScheme.surfaceContainerHighest,
        const Color(0xFFF6F8FA),
      );
      expect(
        DsTheme.dark().colorScheme.surfaceContainerHighest,
        const Color(0xFF1E2025),
      );
    });

    test('the divider theme reads the hairline tier', () {
      const probe = Color(0xFF123456);
      final theme = DsTheme.light(
        tokens: DsTokens.light().copyWith(colorBorderSubtle: probe),
      );
      expect(theme.dividerTheme.color, probe);
      // At the defaults the hairline equals colorBorder, so plain Dividers
      // render exactly as before.
      expect(
        DsTheme.light().dividerTheme.color,
        DsTokens.light().colorBorder,
      );
    });
  });

  group('DsTokens value semantics', () {
    test('equal token sets are == and share a hashCode', () {
      final a = DsTokens.light();
      final b = DsTokens.light();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('a copyWith difference breaks equality', () {
      final a = DsTokens.light();
      final b = a.copyWith(colorPrimary: const Color(0xFF123456));
      expect(a, isNot(equals(b)));
    });

    test('overlays token defaults to dialog', () {
      expect(DsTokens.light().overlays, DsOverlayStyle.dialog);
    });
  });

  group('DsTokens defaults preserve current rendering', () {
    test('button and text field padding fold in the old build-time constants',
        () {
      final tokens = DsTokens.light();
      // Previously buttonPaddingX 4 + 12 and buttonPaddingY 4 + 6 were added
      // by the button; the composed values are now the token defaults.
      expect(tokens.buttonPaddingX, 16);
      expect(tokens.buttonPaddingY, 10);
      // The shared input tokens are untouched; the text field's own vertical
      // token holds the old inputFieldPaddingY 4 + 12.
      expect(tokens.inputFieldPaddingX, 8);
      expect(tokens.inputFieldPaddingY, 4);
      expect(tokens.textFieldPaddingY, 16);
    });

    test('disabled primary defaults equal the old derived fades', () {
      for (final tokens in [DsTokens.light(), DsTokens.dark()]) {
        expect(
          tokens.buttonPrimaryDisabledColorBackground,
          tokens.buttonPrimaryColorBackground.withValues(alpha: 0.5),
        );
        expect(
          tokens.buttonPrimaryDisabledColorText,
          tokens.buttonPrimaryColorText.withValues(alpha: 0.9),
        );
      }
    });

    test('neutral button defaults equal the secondary button', () {
      for (final tokens in [DsTokens.light(), DsTokens.dark()]) {
        expect(
          tokens.buttonNeutralColorBackground,
          tokens.buttonSecondaryColorBackground,
        );
        expect(
          tokens.buttonNeutralColorBorder,
          tokens.buttonSecondaryColorBorder,
        );
        expect(
          tokens.buttonNeutralColorText,
          tokens.buttonSecondaryColorText,
        );
      }
    });

    test('the hairline tier defaults to the border colour', () {
      for (final tokens in [DsTokens.light(), DsTokens.dark()]) {
        expect(tokens.colorBorderSubtle, tokens.colorBorder);
      }
    });

    test('the state vocabulary defaults equal the old hardcoded values', () {
      for (final tokens in [DsTokens.light(), DsTokens.dark()]) {
        expect(tokens.stateHoverOpacity, 0.06);
        expect(tokens.statePressedOpacity, 0.10);
        expect(tokens.stateDisabledOpacity, 0.5);
        expect(tokens.stateDisabledTextOpacity, 0.9);
        expect(tokens.stateDisabledIconOpacity, 0.38);
        expect(tokens.focusRingWidth, 2);
        expect(tokens.buttonRestBorderWidth, 1);
        expect(tokens.inputBorderWidth, 1);
        expect(tokens.inputFocusBorderWidth, 1.6);
        expect(tokens.boxBorderWidth, 1);
        expect(tokens.fieldLabelGap, 6);
      }
    });

    test('the button metric defaults equal the old hardcoded values', () {
      for (final tokens in [DsTokens.light(), DsTokens.dark()]) {
        expect(tokens.buttonMinHeight, 40);
        // The glyph rides 2 above the label, the maths the button used at
        // build time.
        expect(tokens.buttonIconSize, tokens.buttonLabelFontSize + 2);
        expect(tokens.buttonTertiaryColorBackground, Colors.transparent);
        expect(tokens.buttonTertiaryColorBorder, Colors.transparent);
        // The tertiary label reads the same colour the button used to take
        // from the primary action.
        expect(tokens.buttonTertiaryColorText, tokens.actionPrimaryColorText);
      }
    });

    test('the muted surface tier matches the old scheme hardcodes', () {
      expect(DsTokens.light().colorSurfaceMuted, const Color(0xFFF6F8FA));
      expect(DsTokens.dark().colorSurfaceMuted, const Color(0xFF1E2025));
    });

    test('the wordmark defaults equal the old hardcoded style', () {
      final tokens = DsTokens.light();
      expect(tokens.wordmarkFontSize, 22);
      expect(tokens.wordmarkLetterSpacing, -0.2);
      expect(tokens.wordmarkHeight, 1.0);
    });

    test('the strong label weight defaults to semi-bold', () {
      for (final tokens in [DsTokens.light(), DsTokens.dark()]) {
        expect(tokens.strongLabelFontWeight, FontWeight.w600);
      }
    });

    test('the overlay backdrop is a translucent scrim in both modes', () {
      expect(DsTokens.light().overlayBackdropColor.a, lessThan(1));
      expect(DsTokens.dark().overlayBackdropColor.a, lessThan(1));
    });

    test('new tokens thread through copyWith, lerp and equality', () {
      const probe = Color(0xFF123456);
      final base = DsTokens.light();

      final copied = base.copyWith(
        colorBorderSubtle: probe,
        colorSuccess: probe,
        colorWarning: probe,
        buttonPrimaryDisabledColorBackground: probe,
        buttonPrimaryDisabledColorText: probe,
        buttonNeutralColorBackground: probe,
        buttonNeutralColorBorder: probe,
        buttonNeutralColorText: probe,
        textFieldPaddingY: 10,
      );
      expect(copied.colorBorderSubtle, probe);
      expect(copied.colorSuccess, probe);
      expect(copied.colorWarning, probe);
      expect(copied.buttonPrimaryDisabledColorBackground, probe);
      expect(copied.buttonPrimaryDisabledColorText, probe);
      expect(copied.buttonNeutralColorBackground, probe);
      expect(copied.buttonNeutralColorBorder, probe);
      expect(copied.buttonNeutralColorText, probe);
      expect(copied.textFieldPaddingY, 10);
      expect(copied, isNot(equals(base)));

      // Endpoints of a lerp resolve to each side's values.
      expect(base.lerp(copied, 0).colorSuccess, base.colorSuccess);
      expect(base.lerp(copied, 1).colorSuccess, probe);
      expect(base.lerp(copied, 1).textFieldPaddingY, 10);
    });

    test(
        'the state, metric and wordmark tokens thread through copyWith, '
        'lerp and equality', () {
      const probe = Color(0xFF123456);
      final base = DsTokens.light();

      final copied = base.copyWith(
        strongLabelFontWeight: FontWeight.w900,
        stateHoverOpacity: 0.2,
        statePressedOpacity: 0.3,
        stateDisabledOpacity: 0.4,
        stateDisabledTextOpacity: 0.6,
        stateDisabledIconOpacity: 0.7,
        focusRingWidth: 3,
        buttonTertiaryColorBackground: probe,
        buttonTertiaryColorBorder: probe,
        buttonTertiaryColorText: probe,
        buttonMinHeight: 44,
        buttonIconSize: 20,
        buttonRestBorderWidth: 2,
        colorSurfaceMuted: probe,
        inputBorderWidth: 2,
        inputFocusBorderWidth: 3,
        fieldLabelGap: 8,
        boxBorderWidth: 2,
        wordmarkFontSize: 30,
        wordmarkLetterSpacing: 0.5,
        wordmarkHeight: 1.2,
      );
      expect(copied.strongLabelFontWeight, FontWeight.w900);
      expect(copied.stateHoverOpacity, 0.2);
      expect(copied.statePressedOpacity, 0.3);
      expect(copied.stateDisabledOpacity, 0.4);
      expect(copied.stateDisabledTextOpacity, 0.6);
      expect(copied.stateDisabledIconOpacity, 0.7);
      expect(copied.focusRingWidth, 3);
      expect(copied.buttonTertiaryColorBackground, probe);
      expect(copied.buttonTertiaryColorBorder, probe);
      expect(copied.buttonTertiaryColorText, probe);
      expect(copied.buttonMinHeight, 44);
      expect(copied.buttonIconSize, 20);
      expect(copied.buttonRestBorderWidth, 2);
      expect(copied.colorSurfaceMuted, probe);
      expect(copied.inputBorderWidth, 2);
      expect(copied.inputFocusBorderWidth, 3);
      expect(copied.fieldLabelGap, 8);
      expect(copied.boxBorderWidth, 2);
      expect(copied.wordmarkFontSize, 30);
      expect(copied.wordmarkLetterSpacing, 0.5);
      expect(copied.wordmarkHeight, 1.2);
      expect(copied, isNot(equals(base)));

      // Endpoints of a lerp resolve to each side; doubles and colours
      // interpolate through the midpoint.
      expect(base.lerp(copied, 0).fieldLabelGap, 6);
      expect(base.lerp(copied, 1).fieldLabelGap, 8);
      expect(base.lerp(copied, 0.5).fieldLabelGap, closeTo(7, 0.001));
      expect(
        base.lerp(copied, 0.5).colorSurfaceMuted,
        Color.lerp(base.colorSurfaceMuted, probe, 0.5),
      );
      expect(base.lerp(copied, 1).strongLabelFontWeight, FontWeight.w900);
      expect(base.lerp(copied, 1).buttonMinHeight, 44);
      expect(base.lerp(copied, 1).wordmarkFontSize, 30);

      // Equality is structural: an unchanged copy restores it.
      final same = copied.copyWith();
      expect(same, copied);
      expect(same.hashCode, copied.hashCode);
    });

    test('each new token breaks equality on its own', () {
      const probe = Color(0xFF123456);
      final base = DsTokens.light();
      final variants = <DsTokens>[
        base.copyWith(strongLabelFontWeight: FontWeight.w900),
        base.copyWith(stateHoverOpacity: 0.2),
        base.copyWith(statePressedOpacity: 0.3),
        base.copyWith(stateDisabledOpacity: 0.4),
        base.copyWith(stateDisabledTextOpacity: 0.6),
        base.copyWith(stateDisabledIconOpacity: 0.7),
        base.copyWith(focusRingWidth: 3),
        base.copyWith(buttonTertiaryColorBackground: probe),
        base.copyWith(buttonTertiaryColorBorder: probe),
        base.copyWith(buttonTertiaryColorText: probe),
        base.copyWith(buttonMinHeight: 44),
        base.copyWith(buttonIconSize: 20),
        base.copyWith(buttonRestBorderWidth: 2),
        base.copyWith(colorSurfaceMuted: probe),
        base.copyWith(inputBorderWidth: 2),
        base.copyWith(inputFocusBorderWidth: 3),
        base.copyWith(fieldLabelGap: 8),
        base.copyWith(boxBorderWidth: 2),
        base.copyWith(wordmarkFontSize: 30),
        base.copyWith(wordmarkLetterSpacing: 0.5),
        base.copyWith(wordmarkHeight: 1.2),
      ];
      for (final variant in variants) {
        expect(variant, isNot(equals(base)));
      }
    });

    test('the auth chrome tokens thread through copyWith, lerp and equality',
        () {
      const probeWash = [Color(0xFF111111), Color(0xFF222222)];
      const probeBloom = Color(0xFF123456);
      final base = DsTokens.light();

      final copied = base.copyWith(
        authWashGradient: probeWash,
        bloomColor: probeBloom,
      );
      expect(copied.authWashGradient, probeWash);
      expect(copied.bloomColor, probeBloom);
      expect(copied, isNot(equals(base)));

      // Same-length stop lists lerp element-wise.
      final mid = base.lerp(copied, 0.5);
      expect(mid.authWashGradient, hasLength(2));
      expect(
        mid.authWashGradient.first,
        Color.lerp(base.authWashGradient.first, probeWash.first, 0.5),
      );
      expect(mid.bloomColor, Color.lerp(base.bloomColor, probeBloom, 0.5));

      // Mismatched stop counts snap at the midpoint instead of throwing.
      final threeStops = base.copyWith(
        authWashGradient: const [probeBloom, probeBloom, probeBloom],
      );
      expect(
        base.lerp(threeStops, 0.4).authWashGradient,
        base.authWashGradient,
      );
      expect(base.lerp(threeStops, 0.6).authWashGradient, hasLength(3));

      // Equality over the stop list is structural, not identity.
      final same = base.copyWith(
        authWashGradient: List<Color>.of(base.authWashGradient),
      );
      expect(same, base);
      expect(same.hashCode, base.hashCode);
    });
  });
}
