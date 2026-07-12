import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Verify email page.
///
/// A [DsVerifyEmailCard] the reader can drive through its two states without a
/// timer: tapping Resend email flips the card straight to the verified
/// confirmation, and Continue resets it back to the inbox prompt. The first
/// frame shows the check-your-inbox state with a resend action and a close.
class VerifyEmailDemo extends StatefulWidget {
  const VerifyEmailDemo({super.key});

  @override
  State<VerifyEmailDemo> createState() => _VerifyEmailDemoState();
}

class _VerifyEmailDemoState extends State<VerifyEmailDemo> {
  bool _verified = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DsVerifyEmailCard(
        email: 'sam@example.com',
        verified: _verified,
        // No inbox in the demo, so resending stands in for opening the link.
        onResend: () => setState(() => _verified = true),
        onContinue: () => setState(() => _verified = false),
        onClose: () => setState(() => _verified = false),
      ),
    );
  }
}
