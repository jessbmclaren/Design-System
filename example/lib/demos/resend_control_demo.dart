import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Resend control page.
///
/// A [DsResendControl] that cycles the three outcomes as it is tapped, so the
/// reader sees the cooldown restart, then the rate-limited wait, then a failure
/// that stays offerable, without a real backend. The first tap resends, the
/// next is rate-limited, and a third stands in for an offline failure.
class ResendControlDemo extends StatefulWidget {
  const ResendControlDemo({super.key});

  @override
  State<ResendControlDemo> createState() => _ResendControlDemoState();
}

class _ResendControlDemoState extends State<ResendControlDemo> {
  int _taps = 0;

  Future<DsResendResult> _resend() async {
    _taps++;
    // Walk the outcomes so all three states are reachable from the demo.
    return switch (_taps % 3) {
      1 => const DsResendResult.sent(),
      2 => const DsResendResult.rateLimited('Try again in 5 minutes'),
      _ => const DsResendResult.failed(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DsResendControl(
        // A short cooldown so the demo does not make the reader wait 30s.
        cooldown: const Duration(seconds: 5),
        rateLimitedLabel: 'Try again in 5 minutes',
        onResend: _resend,
      ),
    );
  }
}
