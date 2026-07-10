import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Policies page: a group tree on the left picks which part
/// of the fleet a policy is applied to, and a `DsPolicyBuilder` on the right
/// authors it (name, the "applies when" filter, and the "then" rules). Stacks
/// on a narrow phone. Screenshot safe.
class PoliciesDemo extends StatefulWidget {
  const PoliciesDemo({super.key});

  @override
  State<PoliciesDemo> createState() => _PoliciesDemoState();
}

class _PoliciesDemoState extends State<PoliciesDemo> {
  static const _statusOptions = [
    DsGridOption(value: 'active', label: 'Active', variant: DsBadgeVariant.success),
    DsGridOption(value: 'grounded', label: 'Grounded', variant: DsBadgeVariant.danger),
  ];

  static final _columns = <DsGridColumn>[
    const DsGridColumn(key: 'vehicle', title: 'Vehicle'),
    const DsGridColumn(key: 'status', title: 'Status', type: DsCellType.status, options: _statusOptions),
    const DsGridColumn(key: 'serviceDue', title: 'Service due', type: DsCellType.date),
    const DsGridColumn(key: 'monthly', title: 'Monthly cost', type: DsCellType.currency, currencySymbol: r'$'),
  ];

  static const _groups = [
    DsTreeNode(
      id: 'fleet',
      label: 'Meridian Fleet',
      icon: Icons.account_tree_outlined,
      children: [
        DsTreeNode(id: 'north', label: 'North depot', icon: Icons.warehouse_outlined, badgeCount: 12),
        DsTreeNode(id: 'south', label: 'South depot', icon: Icons.warehouse_outlined, badgeCount: 9),
      ],
    ),
  ];

  static const _groupLabels = {
    'fleet': 'Meridian Fleet',
    'north': 'North depot',
    'south': 'South depot',
  };

  String _groupId = 'north';

  DsPolicy _policy = const DsPolicy(
    id: 'winter-tyres',
    name: 'Winter tyres',
    description: 'Cold-weather readiness for active vehicles.',
    filter: DsFilter(conditions: [
      DsFilterCondition(columnKey: 'status', operator: DsFilterOperator.is_, value: 'active'),
    ]),
    rules: [
      DsPolicyRule(effect: DsPolicyEffect.require, description: 'winter tyres fitted from November to March'),
      DsPolicyRule(effect: DsPolicyEffect.warn, description: 'if the service is overdue'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final tree = DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.colorBackground,
        border: Border.all(color: tokens.colorBorder),
        borderRadius: BorderRadius.circular(tokens.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsSpacing.sm),
        child: DsTreeView(
          nodes: _groups,
          selectedId: _groupId,
          onSelect: (id) => setState(() => _groupId = id),
        ),
      ),
    );

    final builder = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: DsSpacing.sm),
          child: Text(
            'Applied to: ${_groupLabels[_groupId]}',
            style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
          ),
        ),
        DsPolicyBuilder(
          columns: _columns,
          value: _policy,
          onChanged: (p) => setState(() => _policy = p),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 720) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 240, child: tree),
              const SizedBox(width: DsSpacing.lg),
              Expanded(child: builder),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            tree,
            const SizedBox(height: DsSpacing.lg),
            builder,
          ],
        );
      },
    );
  }
}
