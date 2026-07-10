import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Business verification page: a `DsBusinessVerification`
/// flow rendered inside a bounded-height frame.
///
/// The component fills the height it is given, so the demo wraps it in a
/// [SizedBox]. It starts deterministically on step 0 with empty fields (no
/// timers, animation or network), so it is screenshot-safe. The submit and
/// cancel callbacks are wired to no-ops here; in an app they would persist the
/// details and dismiss the flow.
class BusinessVerificationDemo extends StatelessWidget {
  const BusinessVerificationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 460,
      child: DsBusinessVerification(),
    );
  }
}
