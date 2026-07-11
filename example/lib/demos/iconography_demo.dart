import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../ui/docs_style.dart';

/// Live demo for the Iconography page: the full `DsIcons` vocabulary, each glyph
/// shown with the semantic role it is referenced by. Screenshot safe.
class IconographyDemo extends StatelessWidget {
  const IconographyDemo({super.key});

  // Every DsIcons role, in the registry's source order, so the catalogue and
  // the vocabulary can never drift apart silently.
  static const _icons = <(String, IconData)>[
    ('chevronRight', DsIcons.chevronRight),
    ('expandMore', DsIcons.expandMore),
    ('expandLess', DsIcons.expandLess),
    ('moveUp', DsIcons.moveUp),
    ('moveDown', DsIcons.moveDown),
    ('arrowUp', DsIcons.arrowUp),
    ('arrowDown', DsIcons.arrowDown),
    ('arrowForward', DsIcons.arrowForward),
    ('arrowBack', DsIcons.arrowBack),
    ('close', DsIcons.close),
    ('check', DsIcons.check),
    ('add', DsIcons.add),
    ('remove', DsIcons.remove),
    ('edit', DsIcons.edit),
    ('delete', DsIcons.delete),
    ('copy', DsIcons.copy),
    ('visibility', DsIcons.visibility),
    ('visibilityOff', DsIcons.visibilityOff),
    ('filter', DsIcons.filter),
    ('moreHorizontal', DsIcons.moreHorizontal),
    ('moreVertical', DsIcons.moreVertical),
    ('externalLink', DsIcons.externalLink),
    ('upload', DsIcons.upload),
    ('uploadDone', DsIcons.uploadDone),
    ('calendar', DsIcons.calendar),
    ('download', DsIcons.download),
    ('archive', DsIcons.archive),
    ('refresh', DsIcons.refresh),
    ('replay', DsIcons.replay),
    ('invite', DsIcons.invite),
    ('signOut', DsIcons.signOut),
    ('filterOff', DsIcons.filterOff),
    ('help', DsIcons.help),
    ('success', DsIcons.success),
    ('info', DsIcons.info),
    ('warning', DsIcons.warning),
    ('error', DsIcons.error),
    ('lock', DsIcons.lock),
    ('verified', DsIcons.verified),
    ('activity', DsIcons.activity),
    ('time', DsIcons.time),
    ('star', DsIcons.star),
    ('starOutline', DsIcons.starOutline),
    ('checkboxBlank', DsIcons.checkboxBlank),
    ('checkboxChecked', DsIcons.checkboxChecked),
    ('user', DsIcons.user),
    ('file', DsIcons.file),
    ('folder', DsIcons.folder),
    ('shipping', DsIcons.shipping),
    ('workspace', DsIcons.workspace),
    ('brokenImage', DsIcons.brokenImage),
    ('mail', DsIcons.mail),
    ('notifications', DsIcons.notifications),
    ('announcement', DsIcons.announcement),
    ('report', DsIcons.report),
    ('security', DsIcons.security),
    ('password', DsIcons.password),
    ('key', DsIcons.key),
    ('web', DsIcons.web),
    ('dashboard', DsIcons.dashboard),
    ('inbox', DsIcons.inbox),
    ('vehicle', DsIcons.vehicle),
    ('platform', DsIcons.platform),
    ('hierarchy', DsIcons.hierarchy),
    ('warehouse', DsIcons.warehouse),
    ('team', DsIcons.team),
    ('receipt', DsIcons.receipt),
  ];

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final (name, icon) in _icons)
          // A fixed-size cell so every tile in the catalogue is exactly the
          // same height, giving a clean matrix rather than a ragged grid.
          SizedBox(
            width: DocsMetrics.iconCellWidth,
            height: DocsMetrics.iconCellHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: docs.surface,
                border: Border.all(color: docs.separator),
                borderRadius: BorderRadius.circular(DocsRadii.md),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DsIcon(
                      icon: icon,
                      size: DsIconSize.lg,
                      color: docs.textPrimary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: DocsType.caption(docs.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
