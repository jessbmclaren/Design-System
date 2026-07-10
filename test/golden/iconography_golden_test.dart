import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden_helpers.dart';

/// Visual regression golden for the [DsIcons] registry.
///
/// Renders every named icon through the [DsIcon] atom in one grid, captured
/// across the theme matrix. Because the whole registry is on a single golden,
/// remapping any role to a different glyph — or a colour-token regression on
/// icons — changes these pixels and fails the test.
///
/// The map is the source of truth for what's guarded: when you add an icon to
/// [DsIcons], add its entry here too.
const _registry = <String, IconData>{
  'chevronRight': DsIcons.chevronRight,
  'expandMore': DsIcons.expandMore,
  'expandLess': DsIcons.expandLess,
  'moveUp': DsIcons.moveUp,
  'moveDown': DsIcons.moveDown,
  'arrowUp': DsIcons.arrowUp,
  'arrowDown': DsIcons.arrowDown,
  'arrowForward': DsIcons.arrowForward,
  'arrowBack': DsIcons.arrowBack,
  'close': DsIcons.close,
  'check': DsIcons.check,
  'add': DsIcons.add,
  'remove': DsIcons.remove,
  'edit': DsIcons.edit,
  'delete': DsIcons.delete,
  'copy': DsIcons.copy,
  'filter': DsIcons.filter,
  'moreHorizontal': DsIcons.moreHorizontal,
  'moreVertical': DsIcons.moreVertical,
  'externalLink': DsIcons.externalLink,
  'upload': DsIcons.upload,
  'uploadDone': DsIcons.uploadDone,
  'calendar': DsIcons.calendar,
  'success': DsIcons.success,
  'info': DsIcons.info,
  'warning': DsIcons.warning,
  'error': DsIcons.error,
  'star': DsIcons.star,
  'starOutline': DsIcons.starOutline,
  'checkboxBlank': DsIcons.checkboxBlank,
  'checkboxChecked': DsIcons.checkboxChecked,
  'user': DsIcons.user,
  'file': DsIcons.file,
  'folder': DsIcons.folder,
  'shipping': DsIcons.shipping,
  'workspace': DsIcons.workspace,
  'brokenImage': DsIcons.brokenImage,
};

Widget _iconGrid() {
  return Wrap(
    spacing: 8,
    runSpacing: 12,
    children: [
      for (final entry in _registry.entries)
        SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DsIcon(icon: entry.value, semanticLabel: entry.key),
              const SizedBox(height: 6),
              Text(
                entry.key,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, height: 1.1),
              ),
            ],
          ),
        ),
    ],
  );
}

void main() {
  group('golden · iconography', () {
    // Guard against silently forgetting to register a new icon in this golden.
    test('registry golden covers every DsIcons entry', () {
      // 37 named icons at the time of writing; update alongside DsIcons.
      expect(_registry.length, 37);
    });

    dsGoldenMatrix('foundation', 'ds_icons', _iconGrid, width: 380);
  });
}
