import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Choose a password page.
///
/// A [DsChoosePasswordView] the reader can drive: it opens on a password with
/// one rule unmet, sitting neutral rather than red. Pressing "Save new
/// password" with a rule outstanding is what turns the unmet rows red, which is
/// the behaviour worth playing with; editing the field returns them to neutral.
/// A breach row shows how a product check rides along in the checklist.
class ChoosePasswordDemo extends StatefulWidget {
  const ChoosePasswordDemo({super.key});

  @override
  State<ChoosePasswordDemo> createState() => _ChoosePasswordDemoState();
}

class _ChoosePasswordDemoState extends State<ChoosePasswordDemo> {
  final TextEditingController _controller = TextEditingController(
    text: 'harbour9!x',
  );
  final FocusNode _focus = FocusNode();
  late String _password = _controller.text;
  bool _attempted = false;

  // Stands in for a breach lookup the product owns, not the design system.
  static const Set<String> _breached = <String>{'password1!', 'harbour9!x'};
  bool get _isBreached => _breached.contains(_password.toLowerCase());
  bool get _meetsAll => dsPasswordMeetsAll(_password) && !_isBreached;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save() {
    if (!_meetsAll) {
      // The one thing that turns the rows red, and it takes the field with it.
      setState(() => _attempted = true);
      _focus.requestFocus();
      return;
    }
    setState(() => _attempted = false);
  }

  @override
  Widget build(BuildContext context) {
    return DsChoosePasswordView(
      value: _password,
      controller: _controller,
      focusNode: _focus,
      attempted: _attempted,
      onChanged: (value) => setState(() {
        _password = value;
        _attempted = false;
      }),
      extraRules: <DsPasswordRule>[
        DsPasswordRule(
          'Not found in known data breaches',
          _password.isNotEmpty && !_isBreached,
        ),
      ],
      primaryAction: DsSignInAction(
        label: 'Save new password',
        onPressed: _save,
      ),
    );
  }
}
