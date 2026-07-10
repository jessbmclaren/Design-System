import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Group hierarchy page: a fleet organised into depots and
/// teams (parents → subgroups → children), with vehicle counts and selection.
/// Screenshot safe.
class GroupHierarchyDemo extends StatefulWidget {
  const GroupHierarchyDemo({super.key});

  @override
  State<GroupHierarchyDemo> createState() => _GroupHierarchyDemoState();
}

class _GroupHierarchyDemoState extends State<GroupHierarchyDemo> {
  String _selectedId = 'north-longhaul';

  static const _nodes = [
    DsTreeNode(
      id: 'fleet',
      label: 'Meridian Fleet',
      icon: DsIcons.hierarchy,
      badgeCount: 21,
      children: [
        DsTreeNode(
          id: 'north',
          label: 'North depot',
          icon: DsIcons.warehouse,
          badgeCount: 12,
          children: [
            DsTreeNode(id: 'north-longhaul', label: 'Long-haul team', subtitle: '5 vehicles', badgeCount: 5),
            DsTreeNode(id: 'north-city', label: 'City team', subtitle: '7 vehicles', badgeCount: 7),
          ],
        ),
        DsTreeNode(
          id: 'south',
          label: 'South depot',
          icon: DsIcons.warehouse,
          badgeCount: 9,
          children: [
            DsTreeNode(id: 'south-refrigerated', label: 'Refrigerated team', subtitle: '4 vehicles', badgeCount: 4),
            DsTreeNode(id: 'south-standard', label: 'Standard team', subtitle: '5 vehicles', badgeCount: 5),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.colorBackground,
        border: Border.all(color: tokens.colorBorder),
        borderRadius: BorderRadius.circular(tokens.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsSpacing.sm),
        child: DsTreeView(
          nodes: _nodes,
          selectedId: _selectedId,
          onSelect: (id) => setState(() => _selectedId = id),
        ),
      ),
    );
  }
}
