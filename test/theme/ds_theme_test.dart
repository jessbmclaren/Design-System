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
}
