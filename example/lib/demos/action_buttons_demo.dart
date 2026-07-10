import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Action buttons page: a record header (`DsPageHeader`) with
/// its main actions anchored to the top right (one secondary "Edit" beside a
/// single primary "Send") and a separate row illustrating the reserved
/// `danger` variant for a destructive action.
class ActionButtonsDemo extends StatelessWidget {
  const ActionButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsPageHeader(
          title: 'Invoice #1042',
          subtitle: 'Draft · Due 30 July 2026',
          actions: [
            DsButton(
              label: 'Edit',
              variant: DsButtonVariant.secondary,
              onPressed: () {},
            ),
            DsButton(label: 'Send', onPressed: () {}),
          ],
        ),
        const SizedBox(height: 24),
        DsButton(
          label: 'Delete invoice',
          variant: DsButtonVariant.danger,
          icon: DsIcons.delete,
          onPressed: () {},
        ),
      ],
    );
  }
}
