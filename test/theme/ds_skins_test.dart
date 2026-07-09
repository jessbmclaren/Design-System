import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsSkins (opt-in presets)', () {
    test('the Engen skin re-brands to indigo', () {
      final engen = DsSkins.engenLight();
      expect(engen.colorPrimary, const Color(0xFF15259B));
      expect(engen.buttonPrimaryColorBackground, const Color(0xFF15259B));
      expect(engen.buttonBorderRadius, 10);

      final theme = DsTheme.light(tokens: DsSkins.engenLight());
      expect(theme.colorScheme.primary, const Color(0xFF15259B));
    });

    test('opting into a skin does NOT change the core defaults', () {
      // The default token set must remain the neutral blue identity — a skin
      // is data you pass in, never a mutation of the defaults.
      expect(DsSkins.engenLight().colorPrimary, isNot(const Color(0xFF0074D4)));
      expect(DsTokens.light().colorPrimary, const Color(0xFF0074D4));
      expect(DsTokens.light().buttonBorderRadius, 4);
      expect(DsTheme.light().colorScheme.primary, const Color(0xFF0074D4));
    });

    test('a skin is still fully white-labellable on top', () {
      final custom = DsSkins.engenLight().copyWith(
        colorPrimary: const Color(0xFF0EA5E9),
      );
      expect(custom.colorPrimary, const Color(0xFF0EA5E9));
      // Untouched skin fields are preserved.
      expect(custom.buttonBorderRadius, 10);
    });
  });
}
