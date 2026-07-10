import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Password strength page.
///
/// A [DsPasswordField] wired to [DsPasswordStrength] and
/// [DsPasswordStrengthHint], pre-filled with a medium-strength password so
/// the meter opens on a partial fill with its strength word and the checklist
/// mostly ticked. Every keystroke re-grades the value via setState, and the
/// submit button is gated on [dsPasswordMeetsAll], the same model the meter
/// shows.
class PasswordStrengthDemo extends StatefulWidget {
  const PasswordStrengthDemo({super.key});

  @override
  State<PasswordStrengthDemo> createState() => _PasswordStrengthDemoState();
}

class _PasswordStrengthDemoState extends State<PasswordStrengthDemo> {
  // Meets every rule but stays short of 12 characters, so it grades Fair: a
  // partial meter on the first frame with room to type towards Strong.
  final TextEditingController _controller =
      TextEditingController(text: 'Harbour9!x');
  late String _password = _controller.text;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DsPasswordField(
            label: 'New password',
            hintText: 'Enter a new password',
            controller: _controller,
            onChanged: (value) => setState(() => _password = value),
          ),
          const SizedBox(height: 8),
          DsPasswordStrength(value: _password),
          const SizedBox(height: 8),
          // Renders nothing while the password grades fair or better; clear
          // the field or type a common word and the guidance appears.
          DsPasswordStrengthHint(value: _password),
          const SizedBox(height: 16),
          DsButton(
            label: 'Create account',
            onPressed: dsPasswordMeetsAll(_password) ? () {} : null,
          ),
        ],
      ),
    );
  }
}
