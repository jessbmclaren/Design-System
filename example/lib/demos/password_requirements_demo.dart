import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Password requirements page.
///
/// A [DsPasswordField] wired to [DsPasswordRequirements] as the *only*
/// password feedback: no meter, no strength word, so nothing on screen can
/// disagree with the checklist. It opens on a password with one rule
/// deliberately unmet, sitting neutral rather than red.
///
/// Pressing "Save new password" with a rule outstanding is what turns the
/// unmet rows red, which is the behaviour worth playing with here: the error
/// answers a submit, it never runs alongside typing. Editing the field returns
/// the rows to neutral.
class PasswordRequirementsDemo extends StatefulWidget {
  const PasswordRequirementsDemo({super.key});

  @override
  State<PasswordRequirementsDemo> createState() =>
      _PasswordRequirementsDemoState();
}

class _PasswordRequirementsDemoState extends State<PasswordRequirementsDemo> {
  // Long enough, with a number and a symbol, but no capital: one rule sits
  // unmet on the first frame so the neutral reading is what you see first.
  final TextEditingController _controller = TextEditingController(
    text: 'harbour9!x',
  );
  late String _password = _controller.text;
  bool _attempted = false;

  // Stands in for a breach lookup the product owns, not the design system.
  static const Set<String> _breached = <String>{'password1!', 'harbour9!x'};
  bool get _isBreached => _breached.contains(_password.toLowerCase());
  bool get _meetsAll => dsPasswordMeetsAll(_password) && !_isBreached;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    // An invalid submit is the only thing that turns the rows red.
    if (!_meetsAll) {
      setState(() => _attempted = true);
      return;
    }
    setState(() => _attempted = false);
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
            onChanged: (value) => setState(() {
              _password = value;
              // Typing is not the moment to keep shouting.
              _attempted = false;
            }),
          ),
          const SizedBox(height: 8),
          DsPasswordRequirements(
            value: _password,
            attempted: _attempted,
            extraRules: <DsPasswordRule>[
              DsPasswordRule(
                'Not found in known data breaches',
                _password.isNotEmpty && !_isBreached,
              ),
            ],
          ),
          const SizedBox(height: 16),
          DsButton(label: 'Save new password', onPressed: _save),
        ],
      ),
    );
  }
}
