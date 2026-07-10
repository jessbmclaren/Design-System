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
  });
}
