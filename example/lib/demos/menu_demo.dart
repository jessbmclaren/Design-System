import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Menu page: a record row whose overflow (`DsMenu`) trigger
/// gathers every action that belongs to that record. The menu is closed on the
/// first frame; choosing a row runs its `onSelected`, closes the menu, and
/// updates the row's status via `setState` so the effect of the action is
/// visible.
class MenuDemo extends StatefulWidget {
  const MenuDemo({super.key});

  @override
  State<MenuDemo> createState() => _MenuDemoState();
}

class _MenuDemoState extends State<MenuDemo> {
  String _status = 'Updated 2 days ago';

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
        border: Border.all(color: tokens.colorBorder),
      ),
      child: DsListItem(
        leading: DsIcon(
          icon: DsIcons.file,
          color: tokens.colorSecondaryText,
        ),
        title: 'Q3 financial report',
        subtitle: _status,
        trailing: DsMenu(
          trigger: DsIcon(
            icon: DsIcons.moreHorizontal,
            semanticLabel: 'Report actions',
            color: tokens.colorSecondaryText,
          ),
          items: [
            DsMenuItem(
              label: 'Rename',
              icon: DsIcons.edit,
              onSelected: () => _record('Renamed just now'),
            ),
            DsMenuItem(
              label: 'Duplicate',
              icon: DsIcons.copy,
              onSelected: () => _record('Duplicated just now'),
            ),
            DsMenuItem(
              label: 'Share',
              icon: DsIcons.invite,
              onSelected: () => _record('Shared with your team'),
            ),
            const DsMenuItem(
              label: 'Download',
              icon: DsIcons.download,
              enabled: false,
            ),
            DsMenuItem(
              label: 'Delete',
              icon: DsIcons.delete,
              destructive: true,
              onSelected: () => _record('Moved to trash'),
            ),
          ],
        ),
      ),
    );
  }

  void _record(String message) {
    setState(() => _status = message);
  }
}
