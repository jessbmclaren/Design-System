import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Iconography page: the full `DsIcons` vocabulary, each glyph
/// shown with the semantic role it is referenced by. Screenshot safe.
class IconographyDemo extends StatelessWidget {
  const IconographyDemo({super.key});

  static const _icons = <(String, IconData)>[
    ('chevronRight', DsIcons.chevronRight),
    ('expandMore', DsIcons.expandMore),
    ('expandLess', DsIcons.expandLess),
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
    ('filter', DsIcons.filter),
    ('moreHorizontal', DsIcons.moreHorizontal),
    ('moreVertical', DsIcons.moreVertical),
    ('externalLink', DsIcons.externalLink),
    ('upload', DsIcons.upload),
    ('uploadDone', DsIcons.uploadDone),
    ('calendar', DsIcons.calendar),
    ('success', DsIcons.success),
    ('info', DsIcons.info),
    ('warning', DsIcons.warning),
    ('error', DsIcons.error),
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
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Wrap(
      spacing: DsSpacing.sm,
      runSpacing: DsSpacing.sm,
      children: [
        for (final (name, icon) in _icons)
          SizedBox(
            width: 116,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.colorBackground,
                border: Border.all(color: tokens.colorBorder),
                borderRadius: BorderRadius.circular(tokens.borderRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DsSpacing.sm,
                  vertical: DsSpacing.md,
                ),
                child: Column(
                  children: [
                    DsIcon(icon: icon, size: DsIconSize.lg),
                    const SizedBox(height: DsSpacing.sm),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tokens.labelSm
                          .toTextStyle(color: tokens.colorSecondaryText),
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
