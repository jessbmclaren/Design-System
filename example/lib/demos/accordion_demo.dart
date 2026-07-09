import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Accordion page: a single-open DsAccordion of common
/// help-centre topics. Each section has a leading icon, a one-line header, and
/// a body of supporting detail. The first section starts expanded so the demo
/// is useful on the first frame; opening another collapses it.
class AccordionDemo extends StatelessWidget {
  const AccordionDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const DsAccordion(
      items: [
        DsAccordionItem(
          title: 'Billing & invoices',
          leading: Icon(Icons.receipt_long_outlined),
          initiallyExpanded: true,
          child: Text(
            'Invoices are issued on the first of each month and charged to your '
            'default payment method. Download any invoice from Billing history.',
          ),
        ),
        DsAccordionItem(
          title: 'Team & permissions',
          leading: Icon(Icons.group_outlined),
          child: Text(
            'Owners and admins can invite teammates and assign roles. Members '
            'keep access until an admin removes them from the workspace.',
          ),
        ),
        DsAccordionItem(
          title: 'Data & privacy',
          leading: Icon(Icons.lock_outline),
          child: Text(
            'Your data is encrypted in transit and at rest. Export or delete '
            'your workspace at any time from Settings.',
          ),
        ),
      ],
    );
  }
}
