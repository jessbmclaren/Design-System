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
          icon: Icons.description_outlined,
          color: tokens.colorSecondaryText,
        ),
        title: 'Q3 financial report',
        subtitle: _status,
        trailing: DsMenu(
          trigger: DsIcon(
            icon: Icons.more_horiz,
            semanticLabel: 'Report actions',
            color: tokens.colorSecondaryText,
          ),
          items: [
            DsMenuItem(
              label: 'Rename',
              icon: Icons.edit_outlined,
              onSelected: () => _record('Renamed just now'),
            ),
            DsMenuItem(
              label: 'Duplicate',
              icon: Icons.copy_all_outlined,
              onSelected: () => _record('Duplicated just now'),
            ),
            DsMenuItem(
              label: 'Share',
              icon: Icons.person_add_alt_outlined,
              onSelected: () => _record('Shared with your team'),
            ),
            const DsMenuItem(
              label: 'Download',
              icon: Icons.download_outlined,
              enabled: false,
            ),
            DsMenuItem(
              label: 'Delete',
              icon: Icons.delete_outline,
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
