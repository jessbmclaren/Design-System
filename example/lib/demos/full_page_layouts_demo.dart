import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Full-page layouts page: a page header with a title,
/// subtitle and actions above tabbed sections, with the Overview tab selected
/// and its content rendered as a short list of records.
class FullPageLayoutsDemo extends StatefulWidget {
  const FullPageLayoutsDemo({super.key});

  @override
  State<FullPageLayoutsDemo> createState() => _FullPageLayoutsDemoState();
}

class _FullPageLayoutsDemoState extends State<FullPageLayoutsDemo> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DsPageHeader(
          title: 'Customers',
          subtitle: '1,284 active this month',
          actions: [
            DsButton(
              label: 'Filter',
              variant: DsButtonVariant.secondary,
              onPressed: () {},
            ),
            DsButton(label: 'Add customer', onPressed: () {}),
          ],
        ),
        const SizedBox(height: 12),
        DsTabs(
          tabs: const [
            DsTab(label: 'Overview'),
            DsTab(label: 'Activity'),
            DsTab(label: 'Settings'),
          ],
          selectedIndex: _selectedIndex,
          onChanged: (index) => setState(() => _selectedIndex = index),
        ),
        const SizedBox(height: 16),
        _sectionContent(_selectedIndex),
      ],
    );
  }

  Widget _sectionContent(int index) {
    switch (index) {
      case 1:
        return const DsList(
          bordered: true,
          children: [
            DsListItem(
              title: 'Invoice paid',
              subtitle: 'Acme Corp · 2 hours ago',
              trailing: DsBadge(
                label: 'Success',
                variant: DsBadgeVariant.success,
              ),
            ),
            DsListItem(
              title: 'Plan upgraded',
              subtitle: 'Northwind · Yesterday',
              trailing: DsBadge(label: 'Pro'),
            ),
          ],
        );
      case 2:
        return const DsList(
          bordered: true,
          children: [
            DsListItem(
              title: 'Notifications',
              subtitle: 'Email digests and alerts',
              trailing: Icon(DsIcons.chevronRight),
            ),
            DsListItem(
              title: 'Billing',
              subtitle: 'Payment method and invoices',
              trailing: Icon(DsIcons.chevronRight),
            ),
          ],
        );
      default:
        return const DsList(
          bordered: true,
          children: [
            DsListItem(
              leading: CircleAvatar(child: Text('A')),
              title: 'Acme Corp',
              subtitle: 'acme@example.com',
              trailing: DsBadge(
                label: 'Active',
                variant: DsBadgeVariant.success,
              ),
            ),
            DsListItem(
              leading: CircleAvatar(child: Text('N')),
              title: 'Northwind',
              subtitle: 'hello@northwind.example',
              trailing: DsBadge(
                label: 'Trial',
                variant: DsBadgeVariant.warning,
              ),
            ),
            DsListItem(
              leading: CircleAvatar(child: Text('G')),
              title: 'Globex',
              subtitle: 'team@globex.example',
              trailing: DsBadge(label: 'Active', variant: DsBadgeVariant.success),
            ),
          ],
        );
    }
  }
}
