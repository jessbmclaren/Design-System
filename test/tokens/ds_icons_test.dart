import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every role in the DsIcons vocabulary, in source order, so the family
/// policy is asserted over the whole registry rather than a sample. When a
/// role is added to ds_icons.dart, add it here and bump the count below.
const Map<String, IconData> _allRoles = <String, IconData>{
  // Directional.
  'chevronRight': DsIcons.chevronRight,
  'expandMore': DsIcons.expandMore,
  'expandLess': DsIcons.expandLess,
  'moveUp': DsIcons.moveUp,
  'moveDown': DsIcons.moveDown,
  'arrowUp': DsIcons.arrowUp,
  'arrowDown': DsIcons.arrowDown,
  'arrowForward': DsIcons.arrowForward,
  'arrowBack': DsIcons.arrowBack,
  // Actions.
  'close': DsIcons.close,
  'check': DsIcons.check,
  'add': DsIcons.add,
  'remove': DsIcons.remove,
  'edit': DsIcons.edit,
  'delete': DsIcons.delete,
  'copy': DsIcons.copy,
  'visibility': DsIcons.visibility,
  'visibilityOff': DsIcons.visibilityOff,
  'filter': DsIcons.filter,
  'moreHorizontal': DsIcons.moreHorizontal,
  'moreVertical': DsIcons.moreVertical,
  'externalLink': DsIcons.externalLink,
  'upload': DsIcons.upload,
  'uploadDone': DsIcons.uploadDone,
  'calendar': DsIcons.calendar,
  'download': DsIcons.download,
  'archive': DsIcons.archive,
  'refresh': DsIcons.refresh,
  'replay': DsIcons.replay,
  'invite': DsIcons.invite,
  'signOut': DsIcons.signOut,
  'filterOff': DsIcons.filterOff,
  'help': DsIcons.help,
  // Status.
  'success': DsIcons.success,
  'info': DsIcons.info,
  'warning': DsIcons.warning,
  'error': DsIcons.error,
  'lock': DsIcons.lock,
  'verified': DsIcons.verified,
  'activity': DsIcons.activity,
  'time': DsIcons.time,
  // Selection and true-state.
  'star': DsIcons.star,
  'starOutline': DsIcons.starOutline,
  'checkboxBlank': DsIcons.checkboxBlank,
  'checkboxChecked': DsIcons.checkboxChecked,
  // Entities.
  'user': DsIcons.user,
  'file': DsIcons.file,
  'folder': DsIcons.folder,
  'shipping': DsIcons.shipping,
  'workspace': DsIcons.workspace,
  'brokenImage': DsIcons.brokenImage,
  'mail': DsIcons.mail,
  'notifications': DsIcons.notifications,
  'announcement': DsIcons.announcement,
  'report': DsIcons.report,
  'security': DsIcons.security,
  'password': DsIcons.password,
  'key': DsIcons.key,
  'web': DsIcons.web,
  'dashboard': DsIcons.dashboard,
  'inbox': DsIcons.inbox,
  'vehicle': DsIcons.vehicle,
  'platform': DsIcons.platform,
  'hierarchy': DsIcons.hierarchy,
  'warehouse': DsIcons.warehouse,
  'team': DsIcons.team,
  'receipt': DsIcons.receipt,
};

void main() {
  test('DsIcons exposes the semantic vocabulary the system references', () {
    // Every role resolves to a real glyph.
    expect(_allRoles, hasLength(67));
    for (final entry in _allRoles.entries) {
      expect(entry.value, isA<IconData>(), reason: entry.key);
    }
  });

  test('the family policy holds: Lucide line glyphs, filled only for true-state',
      () {
    // The vocabulary is drawn from the Lucide font (thin, consistent, open line
    // work) rather than Material. Every role except the one true-state star
    // resolves to a `flutter_lucide` glyph, asserted over the whole registry.
    for (final entry in _allRoles.entries) {
      if (entry.key == 'star') continue;
      expect(entry.value.fontFamily, 'lucide', reason: entry.key);
      expect(entry.value.fontPackage, 'flutter_lucide', reason: entry.key);
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
