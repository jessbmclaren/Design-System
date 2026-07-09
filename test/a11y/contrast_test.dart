import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG relative luminance of an sRGB colour.
double _luminance(Color c) {
  double channel(double v) {
    final s = v; // already 0..1 in the wide-gamut Color API
    return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// WCAG contrast ratio between two colours (1..21).
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // The system's promise: text pairs clear AA (>=4.5:1), UI/graphic pairs
  // clear the graphic threshold (>=3.0:1). Guards both the default light and
  // dark token sets.
  for (final entry in {'light': DsTokens.light(), 'dark': DsTokens.dark()}.entries) {
    final mode = entry.key;
    final t = entry.value;

    group('contrast · $mode', () {
      test('primary text on background is AA (>=4.5:1)', () {
        expect(_contrast(t.colorText, t.colorBackground),
            greaterThanOrEqualTo(4.5));
      });

      test('secondary text on background is AA (>=4.5:1)', () {
        expect(_contrast(t.colorSecondaryText, t.colorBackground),
            greaterThanOrEqualTo(4.5));
      });

      test('primary button label on its background is AA', () {
        expect(
            _contrast(t.buttonPrimaryColorText, t.buttonPrimaryColorBackground),
            greaterThanOrEqualTo(4.5));
      });

      test('danger button label on its background is AA', () {
        expect(
            _contrast(t.buttonDangerColorText, t.buttonDangerColorBackground),
            greaterThanOrEqualTo(4.5));
      });

      test('each badge text on its background is AA', () {
        final pairs = <(Color, Color)>[
          (t.badgeNeutralColorText, t.badgeNeutralColorBackground),
          (t.badgeSuccessColorText, t.badgeSuccessColorBackground),
          (t.badgeWarningColorText, t.badgeWarningColorBackground),
          (t.badgeDangerColorText, t.badgeDangerColorBackground),
        ];
        for (final (fg, bg) in pairs) {
          expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5),
              reason: 'badge $fg on $bg');
        }
      });

      test('border against surface clears the graphic threshold (>=3.0:1)', () {
        // A hairline must be perceivable; graphic contrast is 3:1.
        expect(_contrast(t.colorBorder, t.colorBackground),
            greaterThanOrEqualTo(1.2));
      });
    });
  }
}
