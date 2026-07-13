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
/// a name and surname row in a [DsFormFieldGroup] and a password captioned by
/// [dsFirstUnmetPasswordRule] with a [DsPasswordStrength] meter beneath.
///
/// Every required field validates on blur: its error surfaces once focus
/// leaves it empty and clears live as the user types, so a skipped name or
/// company is caught without nagging mid-entry, while the email also checks its
/// format and the taken list once touched. The primary button stays enabled: a
/// press that cannot go through reveals every outstanding error at once and
/// moves focus to the first field to fix, rather than a dead, greyed-out
/// button.
///
/// The fields start pre-filled with valid values so the first frame shows the
/// complete card with the primary action enabled and the meter reading strong.
/// No timers, network or randomness. The captured frame is stable.
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

  // Every required field validates on blur, so a skipped field is caught the
  // moment focus leaves it empty.
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _surnameFocus = FocusNode();
  final FocusNode _companyFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // Errors stay hidden until a field is touched, so the pre-filled first frame
  // renders clean and guidance appears only once someone edits or skips one.
  bool _nameTouched = false;
  bool _surnameTouched = false;
  bool _companyTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void initState() {
    super.initState();
    _touchOnBlur(_nameFocus, () => _nameTouched, () => _nameTouched = true);
    _touchOnBlur(
        _surnameFocus, () => _surnameTouched, () => _surnameTouched = true);
    _touchOnBlur(
        _companyFocus, () => _companyTouched, () => _companyTouched = true);
    _touchOnBlur(_emailFocus, () => _emailTouched, () => _emailTouched = true);
    _touchOnBlur(_passwordFocus, () => _passwordTouched,
        () => _passwordTouched = true);
  }

  /// Flips a field to "touched" the first time focus leaves it, so a required
  /// error shows on blur rather than while the user is still typing.
  void _touchOnBlur(
    FocusNode node,
    bool Function() isTouched,
    VoidCallback markTouched,
  ) {
    node.addListener(() {
      if (!node.hasFocus && !isTouched()) setState(markTouched);
    });
  }

  /// A required text field with no format: a plain, specific prompt rather than
  /// a generic "this field is required".
  String? _requiredError(String value, String message) =>
      value.trim().isEmpty ? message : null;

  /// The email error: empty first, then a format check, then the taken-address
  /// check, fed straight into the field's errorText.
  String? _emailError(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Enter your email address';
    if (!_emailFormat.hasMatch(email)) return 'This email is invalid';
    if (_takenEmails.contains(email.toLowerCase())) {
      return 'Email already taken';
    }
    return null;
  }

  /// The focus node of the first field failing validation, in reading order, or
  /// null when the whole form is valid. This is the single source of truth for
  /// both "can we submit" and "what should we jump to".
  FocusNode? _firstInvalidFocus() {
    if (_name.text.trim().isEmpty) return _nameFocus;
    if (_surname.text.trim().isEmpty) return _surnameFocus;
    if (_company.text.trim().isEmpty) return _companyFocus;
    if (_emailError(_email.text) != null) return _emailFocus;
    if (dsFirstUnmetPasswordRule(_password.text) != null) return _passwordFocus;
    return null;
  }

  /// The button stays enabled: a press that can't go through is not a dead end,
  /// it reveals every outstanding error at once and lands the user on the first
  /// field to fix, rather than leaving them to guess what a greyed-out button
  /// wants. A real product would create the account here; the demo stops at
  /// validation so it stays timer-free and its screenshot is stable.
  void _trySubmit() {
    setState(() {
      _nameTouched = true;
      _surnameTouched = true;
      _companyTouched = true;
      _emailTouched = true;
      _passwordTouched = true;
    });
    _firstInvalidFocus()?.requestFocus();
  }

  @override
  void dispose() {
    _name.dispose();
    _surname.dispose();
    _company.dispose();
    _email.dispose();
    _password.dispose();
    _nameFocus.dispose();
    _surnameFocus.dispose();
    _companyFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
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
          // screens the group stacks them so neither placeholder clips. Both
          // are required, format-free fields, so they validate on blur.
          DsFormFieldGroup(
            children: [
              DsTextField(
                controller: _name,
                focusNode: _nameFocus,
                hintText: 'Name',
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                errorText: _nameTouched
                    ? _requiredError(_name.text, 'Enter your name')
                    : null,
              ),
              DsTextField(
                controller: _surname,
                focusNode: _surnameFocus,
                hintText: 'Surname',
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                errorText: _surnameTouched
                    ? _requiredError(_surname.text, 'Enter your surname')
                    : null,
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.lg),
          DsTextField(
            controller: _company,
            focusNode: _companyFocus,
            hintText: 'Company name',
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            errorText: _companyTouched
                ? _requiredError(_company.text, 'Enter your company name')
                : null,
          ),
          const SizedBox(height: DsSpacing.lg),
          DsTextField(
            controller: _email,
            focusNode: _emailFocus,
            hintText: 'Work email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() => _emailTouched = true),
            errorText: _emailTouched ? _emailError(_email.text) : null,
          ),
          const SizedBox(height: DsSpacing.lg),
          DsPasswordField(
            controller: _password,
            focusNode: _passwordFocus,
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
      // The button stays live; the press validates and reveals what is missing.
      onSubmit: _trySubmit,
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
