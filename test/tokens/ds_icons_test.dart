import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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

  test('the family policy holds: Lucide line glyphs, filled only for true-state',
      () {
    // The vocabulary is drawn from the Lucide font (thin, consistent, open line
    // work) rather than Material — every role except the one true-state star
    // resolves to a `flutter_lucide` glyph.
    for (final icon in <IconData>[
      DsIcons.close,
      DsIcons.check,
      DsIcons.chevronRight,
      DsIcons.edit,
      DsIcons.warning,
      DsIcons.success,
      DsIcons.error,
      DsIcons.user,
      DsIcons.checkboxChecked,
      DsIcons.starOutline,
    ]) {
      expect(icon.fontFamily, 'lucide');
      expect(icon.fontPackage, 'flutter_lucide');
    }

    // A few semantic roles pinned to their Lucide glyph.
    expect(DsIcons.warning, LucideIcons.triangle_alert);
    expect(DsIcons.check, LucideIcons.check);
    expect(DsIcons.user, LucideIcons.user);
    expect(DsIcons.checkboxChecked, LucideIcons.square_check);

    // Filled is reserved for a genuine true-state (a selected rating step): the
    // one Material solid star, since Lucide is an outline-only set.
    expect(DsIcons.star, Icons.star);
    expect(DsIcons.star.fontFamily, 'MaterialIcons');
    expect(DsIcons.starOutline, LucideIcons.star);
  });
}
