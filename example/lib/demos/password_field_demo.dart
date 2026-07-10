import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Password field page.
///
/// Two [DsPasswordField]s from a change-password form. The first is
/// pre-filled and masked with the eye toggle in its suffix; the second is a
/// confirmation field pre-filled with a near-miss, so its errorText state
/// shows on the first frame. Editing either field re-checks the match via
/// setState.
class PasswordFieldDemo extends StatefulWidget {
  const PasswordFieldDemo({super.key});

  @override
  State<PasswordFieldDemo> createState() => _PasswordFieldDemoState();
}

class _PasswordFieldDemoState extends State<PasswordFieldDemo> {
  final TextEditingController _password =
      TextEditingController(text: 'correct-horse-battery');
  final TextEditingController _confirm =
      TextEditingController(text: 'correct-horse-batery');

  bool get _passwordsMatch => _confirm.text == _password.text;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
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
            helperText: 'Use the eye toggle to check what you typed.',
            controller: _password,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DsPasswordField(
            label: 'Confirm new password',
            hintText: 'Re-enter your new password',
            controller: _confirm,
            errorText: _passwordsMatch ? null : 'Passwords do not match.',
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
