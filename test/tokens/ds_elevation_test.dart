import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsElevation', () {
    test('forLevel maps every semantic step to its scale', () {
      expect(DsElevation.forLevel(DsElevationLevel.none), DsElevation.none);
      expect(DsElevation.forLevel(DsElevationLevel.low), DsElevation.low);
      expect(
        DsElevation.forLevel(DsElevationLevel.medium),
        DsElevation.medium,
      );
      expect(DsElevation.forLevel(DsElevationLevel.high), DsElevation.high);
    });

    test('tinted returns the whole low, medium and high scale', () {
      const brand = Color(0xFF15259B);
      final scale = DsElevation.tinted(brand);

      // The three steps share the default scale's geometry.
      expect(scale.low, hasLength(2));
      expect(scale.low.first.offset, DsElevation.low.first.offset);
      expect(scale.low.first.blurRadius, DsElevation.low.first.blurRadius);
      expect(scale.medium, hasLength(1));
      expect(scale.medium.single.offset, DsElevation.medium.single.offset);
      expect(
        scale.medium.single.blurRadius,
        DsElevation.medium.single.blurRadius,
      );
      expect(scale.high, hasLength(1));
      expect(scale.high.single.offset, DsElevation.high.single.offset);
      expect(scale.high.single.blurRadius, DsElevation.high.single.blurRadius);

      // Every drop carries the brand hue, deepening with elevation.
      for (final shadow in [...scale.low, ...scale.medium, ...scale.high]) {
        expect(shadow.color.r, brand.r);
        expect(shadow.color.g, brand.g);
        expect(shadow.color.b, brand.b);
      }
      expect(scale.medium.single.color.a, greaterThan(scale.low.last.color.a));
      expect(scale.high.single.color.a, greaterThan(scale.medium.single.color.a));
    });

    test('tinted intensity deepens or softens every step at once', () {
      const brand = Color(0xFF15259B);
      final base = DsElevation.tinted(brand);
      final deeper = DsElevation.tinted(brand, intensity: 2);

      expect(
        deeper.medium.single.color.a,
        closeTo(base.medium.single.color.a * 2, 0.005),
      );
      expect(
        deeper.high.single.color.a,
        closeTo(base.high.single.color.a * 2, 0.005),
      );
    });

    test('the tinted scale feeds the shadow tokens directly', () {
      final scale = DsElevation.tinted(const Color(0xFF15259B));
      final tokens = DsTokens.light().copyWith(
        shadowLow: scale.low,
        shadowMedium: scale.medium,
        shadowHigh: scale.high,
      );
      expect(tokens.shadowLow, scale.low);
      expect(tokens.shadowMedium, scale.medium);
      expect(tokens.shadowHigh, scale.high);
    });
  });
}
