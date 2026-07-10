import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Communicating state page. Shows the two feedback styles
/// side by side in a single frame: a persistent [DsBanner] (warning) for an
/// issue that needs action and a transient [DsToast] widget confirming a
/// completed action. The toast is rendered as a plain widget (never via
/// DsToast.show), so nothing starts a timer.
class CommunicatingStateDemo extends StatelessWidget {
  const CommunicatingStateDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Persistent: an issue that needs action and stays visible.
        DsBanner(
          variant: DsBannerVariant.warning,
          title: 'Billing details are out of date',
          message: 'Update your payment method to avoid an interruption.',
          action: DsBannerAction(
            label: 'Update',
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 24),
        // Transient: a brief confirmation that fades on its own.
        const Align(
          alignment: Alignment.centerLeft,
          child: DsToast(
            message: 'Changes saved',
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }
}
