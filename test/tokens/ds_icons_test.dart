import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DsIcons exposes the semantic vocabulary the system references', () {
    // A representative spread of roles resolve to real glyphs.
    for (final icon in <IconData>[
      DsIcons.close,
      DsIcons.check,
      DsIcons.chevronRight,
      DsIcons.success,
      DsIcons.warning,
      DsIcons.error,
      DsIcons.user,
      DsIcons.upload,
    ]) {
      expect(icon, isA<IconData>());
    }
  });

  test('the family policy holds: outlined defaults, filled only for true-state',
      () {
    // Status/entity roles are the outlined line glyphs, not the rounded/filled
    // Material variants.
    expect(DsIcons.warning, Icons.warning_amber); // not warning_amber_rounded
    expect(DsIcons.check, Icons.check); // not check_rounded
    expect(DsIcons.user, Icons.person_outline); // not filled Icons.person
    expect(DsIcons.checkboxChecked, Icons.check_box_outlined); // not filled

    // Filled is reserved for a genuine true-state (a selected rating step).
    expect(DsIcons.star, Icons.star);
    expect(DsIcons.starOutline, Icons.star_border);
  });
}
