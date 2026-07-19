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
      // The default token set must remain the neutral teal identity: a skin
      // is data you pass in, never a mutation of the defaults.
      expect(DsSkins.engenLight().colorPrimary, isNot(const Color(0xFF0F766E)));
      expect(DsTokens.light().colorPrimary, const Color(0xFF0F766E));
      expect(DsTokens.light().buttonBorderRadius, 4);
      expect(DsTheme.light().colorScheme.primary, const Color(0xFF0F766E));
    });

    test('a skin is still fully white-labellable on top', () {
      final custom = DsSkins.engenLight().copyWith(
        colorPrimary: const Color(0xFF0EA5E9),
      );
      expect(custom.colorPrimary, const Color(0xFF0EA5E9));
      // Untouched skin fields are preserved.
      expect(custom.buttonBorderRadius, 10);
    });

    test('the Engen skin aligns badge borders to their backgrounds', () {
      final engen = DsSkins.engenLight();
      expect(engen.badgeSuccessColorBorder, engen.badgeSuccessColorBackground);
      expect(engen.badgeWarningColorBorder, engen.badgeWarningColorBackground);
      expect(engen.badgeDangerColorBorder, engen.badgeDangerColorBackground);
      // The neutral badge keeps its hairline outline.
      expect(
        engen.badgeNeutralColorBorder,
        isNot(engen.badgeNeutralColorBackground),
      );
    });

    test('the Engen skin supplies the hairline and signal tiers', () {
      final engen = DsSkins.engenLight();
      expect(engen.colorBorderSubtle, const Color(0xFFE5E8F0));
      expect(engen.colorSuccess, const Color(0xFF1F9D57));
      expect(engen.colorWarning, const Color(0xFFD9870B));
    });

    test('the Engen skin brands the auth chrome; the defaults stay neutral',
        () {
      final engen = DsSkins.engenLight();
      // The corrected wash: white easing out to clear, left to right.
      expect(
        engen.authWashGradient,
        const [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
      );
      expect(engen.authWashStops, const [0.42, 0.74]);
      expect(engen.authWashBegin, Alignment.centerLeft);
      expect(engen.authWashEnd, Alignment.centerRight);
      expect(engen.bloomColor, const Color(0xFF5AA8E0));

      // The white-label defaults keep the quiet neutral wash on its
      // original top-to-bottom axis.
      expect(DsTokens.light().authWashGradient, DsColors.authWash);
      expect(DsTokens.light().authWashStops, isNull);
      expect(DsTokens.light().authWashBegin, Alignment.topCenter);
      expect(DsTokens.light().authWashEnd, Alignment.bottomCenter);
      expect(DsTokens.light().bloomColor, DsColors.bloom);
    });

    test('the Engen skin uses solid disabled button tints', () {
      final light = DsSkins.engenLight();
      expect(
        light.buttonPrimaryDisabledColorBackground,
        const Color(0xFF9DA3D5),
      );
      expect(light.buttonPrimaryDisabledColorText, const Color(0xFFF5F6FB));

      final dark = DsSkins.engenDark();
      expect(
        dark.buttonPrimaryDisabledColorBackground,
        const Color(0xFF232A60),
      );
      expect(dark.buttonPrimaryDisabledColorText, const Color(0xFFE9EAEF));
    });

    test('the Engen neutral button matches its secondary outline', () {
      final engen = DsSkins.engenLight();
      expect(
        engen.buttonNeutralColorBackground,
        engen.buttonSecondaryColorBackground,
      );
      expect(engen.buttonNeutralColorBorder, engen.buttonSecondaryColorBorder);
      expect(engen.buttonNeutralColorText, engen.buttonSecondaryColorText);
    });

    test('the Engen skins keep the brand heading voice', () {
      final light = DsSkins.engenLight();
      final dark = DsSkins.engenDark();
      // The corrected light ramp: a tighter, shorter top tier.
      expect(light.headingXl.height, 1.15);
      expect(light.headingXl.letterSpacing, -0.6);
      expect(light.headingLg.letterSpacing, -0.3);
      expect(light.headingMd.height, 1.2);
      expect(light.headingMd.letterSpacing, -0.3);
      // Dark keeps its own heading overrides, bold in both themes, and the
      // shared small heading is identical.
      expect(dark.headingSm, light.headingSm);
      for (final token in [dark.headingXl, dark.headingLg, dark.headingMd]) {
        expect(token.fontWeight, DsTypography.bold);
      }
    });

    test('the Engen skins keep the tertiary label and icon maths in step', () {
      for (final skin in [DsSkins.engenLight(), DsSkins.engenDark()]) {
        expect(skin.buttonTertiaryColorText, skin.actionPrimaryColorText);
        // The brand spec pins a 16dp glyph beside the 15dp label.
        expect(skin.buttonLabelFontSize, 15);
        expect(skin.buttonIconSize, 16);
      }
    });
  });
}
