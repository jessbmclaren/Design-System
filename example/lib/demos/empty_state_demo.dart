import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Empty state page: a records view that has no data yet.
/// It reassures the person the screen is working, explains why it is empty,
/// and offers the single next step — creating the first invoice.
class EmptyStateDemo extends StatelessWidget {
  const EmptyStateDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DsEmptyState(
      icon: Icons.inbox_outlined,
      title: 'No invoices yet',
      message: 'Invoices you create will appear here.',
      action: DsEmptyStateAction(
        label: 'Create invoice',
        onPressed: () {},
      ),
    );
  }
}
