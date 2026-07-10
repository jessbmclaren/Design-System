import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Emails already registered in this demo. Typing one shows the inline
/// 'Email already taken' error, the way the best sign-up forms validate live.
const Set<String> _takenEmails = <String>{
  'sam@acmeid.com',
  'taken@acmeid.com',
  'admin@northwind.io',
};

/// A pragmatic format check for the live email error. Real products would
/// confirm ownership with a verification step.
final RegExp _emailFormat = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Live demo for the Sign up page.
///
/// Renders a real [DsSignUpView] as a single brand-led card: a centred
/// [DsWordmark] header, an "Already have an account?" prompt above the form,
/// a name and surname row in a [DsFormFieldGroup], live email validation once
/// the field is touched and a password captioned by
/// [dsFirstUnmetPasswordRule] with a [DsPasswordStrength] meter beneath. The
/// fields start pre-filled with valid values so the first frame shows the
/// complete card with the primary action enabled and the meter reading
/// strong; editing a field re-runs validation via [setState], so the button
/// disables the moment any field goes invalid. No timers, network or
/// randomness. The captured frame is stable.
class SignUpDemo extends StatefulWidget {
  const SignUpDemo({super.key});

  @override
  State<SignUpDemo> createState() => _SignUpDemoState();
}

class _SignUpDemoState extends State<SignUpDemo> {
  final TextEditingController _name = TextEditingController(text: 'Jordan');
  final TextEditingController _surname = TextEditingController(text: 'Lee');
  final TextEditingController _company =
      TextEditingController(text: 'Northwind Traders');
  final TextEditingController _email =
      TextEditingController(text: 'jordan@northwind.io');
  final TextEditingController _password =
      TextEditingController(text: 'Mint-Trellis-4271');

  // Errors stay hidden until a field is touched, so the pre-filled first
  // frame renders clean and guidance appears only once someone edits.
  bool _emailTouched = false;
  bool _passwordTouched = false;

  /// The live email error: a format check first, then the taken-address
  /// check, fed straight into the field's errorText.
  String? _emailError(String value) {
    final email = value.trim();
    if (email.isEmpty) return null;
    if (!_emailFormat.hasMatch(email)) return 'This email is invalid';
    if (_takenEmails.contains(email.toLowerCase())) {
      return 'Email already taken';
    }
    return null;
  }

  bool get _isValid =>
      _name.text.trim().isNotEmpty &&
      _surname.text.trim().isNotEmpty &&
      _company.text.trim().isNotEmpty &&
      _emailFormat.hasMatch(_email.text.trim()) &&
      !_takenEmails.contains(_email.text.trim().toLowerCase()) &&
      dsFirstUnmetPasswordRule(_password.text) == null;

  @override
  void dispose() {
    _name.dispose();
    _surname.dispose();
    _company.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return DsSignUpView(
      header: const DsWordmark(primary: 'acme', accent: 'id', fontSize: 28),
      headingAlignment: DsHeadingAlignment.center,
      // Shadow-only card, with a corner close for a sign-up opened over
      // another surface. The handler is harmless in the docs.
      showBorder: false,
      onClose: () => setState(() {}),
      title: 'Seconds to sign up',
      aboveForm: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Already have an account?',
            style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
          ),
          DsLink(label: 'Sign in', onPressed: () {}),
        ],
      ),
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name and surname share a row where there is room; on very narrow
          // screens the group stacks them so neither placeholder clips.
          DsFormFieldGroup(
            children: [
              DsTextField(
                controller: _name,
                hintText: 'Name',
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              DsTextField(
                controller: _surname,
                hintText: 'Surname',
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.lg),
          DsTextField(
            controller: _company,
            hintText: 'Company name',
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: DsSpacing.lg),
          DsTextField(
            controller: _email,
            hintText: 'Work email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() => _emailTouched = true),
            errorText: _emailTouched ? _emailError(_email.text) : null,
          ),
          const SizedBox(height: DsSpacing.lg),
          DsPasswordField(
            controller: _password,
            hintText: 'Password',
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() => _passwordTouched = true),
            errorText: _passwordTouched
                ? dsFirstUnmetPasswordRule(_password.text)
                : null,
          ),
          const SizedBox(height: DsSpacing.sm),
          // The meter's bar is already hidden from assistive technology
          // inside the widget; the strength word carries the value. The
          // error ladder above names the rules, so the checklist stays off.
          DsPasswordStrength(value: _password.text, showChecklist: false),
          DsPasswordStrengthHint(value: _password.text),
        ],
      ),
      primaryActionLabel: 'Create account',
      onSubmit: _isValid ? () {} : null,
      footer: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(color: tokens.actionPrimaryColorText),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(color: tokens.actionPrimaryColorText),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
