import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Back link page: a DsBackLink that names its destination,
/// sitting at the top-left of a customer detail view to give context.
class BackLinkDemo extends StatelessWidget {
  const BackLinkDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsBackLink(
          label: 'Back to customers',
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        const DsPageHeader(
          title: 'Ava Morgan',
          subtitle: 'ava.morgan@example.com',
          actions: [
            DsBadge(label: 'Active', variant: DsBadgeVariant.success),
          ],
        ),
      ],
    );
  }
}
