import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Emails already registered in this demo. Typing one shows the inline
/// "already have an account" notice with its in-line "Sign in" link, the way
/// the best sign-up forms turn a taken email into a way in rather than a dead
/// end.
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
/// Every required field validates on blur and reserves its caption line
/// ([DsTextField.reserveErrorSpace]), so an error replaces that line rather
/// than growing the field and nudging the button — the stack stays still as
/// errors appear and clear. A well-formed but already-registered email turns
/// into an inline "Sign in instead" doorway rather than a dead-end error, and
/// an explicit consent checkbox gates the account. The primary button stays
/// enabled: a press that cannot go through reveals every outstanding error at
/// once and moves focus to the first field to fix.
///
/// The text fields start pre-filled with valid values so the first frame shows
/// the complete card with the meter reading strong. No timers, network or
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

  // Whether the user has actually typed into each required-only field, so blur
  // reveals a required error only for a field they engaged with (not one they
  // merely tabbed past). Email and password validate live once typed.
  bool _nameEdited = false;
  bool _surnameEdited = false;
  bool _companyEdited = false;

  // Explicit consent, ticked before the account is created; the error shows
  // only on a submit without the tick, and clears once ticked.
  bool _agreedToTerms = false;
  bool _termsError = false;

  // Recognizer for the inline "Sign in" link inside the already-registered
  // notice; held as a field so it can be disposed.
  late final TapGestureRecognizer _signInTap;

  @override
  void initState() {
    super.initState();
    _signInTap = TapGestureRecognizer()..onTap = () {};
    _touchOnBlur(_nameFocus, () => _nameEdited, () => _nameTouched,
        () => _nameTouched = true);
    _touchOnBlur(_surnameFocus, () => _surnameEdited, () => _surnameTouched,
        () => _surnameTouched = true);
    _touchOnBlur(_companyFocus, () => _companyEdited, () => _companyTouched,
        () => _companyTouched = true);
    _touchOnBlur(_emailFocus, () => _emailTouched, () => _emailTouched,
        () => _emailTouched = true);
    _touchOnBlur(_passwordFocus, () => _passwordTouched, () => _passwordTouched,
        () => _passwordTouched = true);
  }

  /// Flips a field to "touched" the first time focus leaves it, but only once
  /// the user has actually engaged with it ([isEdited]), so tabbing forward
  /// past an untouched field does not scold them.
  void _touchOnBlur(
    FocusNode node,
    bool Function() isEdited,
    bool Function() isTouched,
    VoidCallback markTouched,
  ) {
    node.addListener(() {
      if (!node.hasFocus && isEdited() && !isTouched()) {
        setState(markTouched);
      }
    });
  }

  /// A required text field with no format: a plain, specific prompt rather than
  /// a generic "this field is required".
  String? _requiredError(String value, String message) =>
      value.trim().isEmpty ? message : null;

  /// The email error: empty first, then a format check, then the taken-address
  /// check. The taken case is shown by [_takenEmailNotice] instead, so its
  /// message here only feeds submit-gating and focus.
  String? _emailError(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Enter your email address';
    if (!_emailFormat.hasMatch(email)) return 'This email is invalid';
    if (_takenEmails.contains(email.toLowerCase())) {
      return 'This email already has an account';
    }
    return null;
  }

  /// A well-formed address that already has an account — the case worth turning
  /// into a "Sign in instead" doorway rather than a dead-end error.
  bool get _emailIsTaken {
    final e = _email.text.trim();
    if (e.isEmpty || !_emailFormat.hasMatch(e)) return false;
    return _takenEmails.contains(e.toLowerCase());
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

  /// The button stays enabled: a press that can't go through reveals every
  /// outstanding error at once and lands the user on the first field to fix.
  /// A real product would create the account here; the demo stops at validation
  /// so it stays timer-free and its screenshot is stable.
  void _trySubmit() {
    setState(() {
      _nameTouched = true;
      _surnameTouched = true;
      _companyTouched = true;
      _emailTouched = true;
      _passwordTouched = true;
      _termsError = !_agreedToTerms;
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
    _signInTap.dispose();
    super.dispose();
  }

  /// The "already registered" notice: not a dead-end "email taken", but an
  /// inline error whose own sentence carries the way out — a "Sign in" link.
  Widget _takenEmailNotice(DsTokens tokens) {
    return Padding(
      padding: const EdgeInsets.only(top: DsSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: DsSpacing.xs),
            child: Icon(DsIcons.error,
                size: DsIconSize.sm, color: tokens.colorDanger),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: tokens.bodySm.toTextStyle(color: tokens.colorDanger),
                children: [
                  const TextSpan(
                    text: 'An account already exists with this email. ',
                  ),
                  TextSpan(
                    text: 'Sign in',
                    style: TextStyle(color: tokens.actionPrimaryColorText),
                    recognizer: _signInTap,
                  ),
                  const TextSpan(
                    text: ' instead, or use a different email address.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          // screens the group stacks them so neither placeholder clips. Every
          // field reserves its caption line so an error never nudges the stack.
          DsFormFieldGroup(
            children: [
              DsTextField(
                controller: _name,
                focusNode: _nameFocus,
                hintText: 'Name',
                textInputAction: TextInputAction.next,
                reserveErrorSpace: true,
                onChanged: (_) => setState(() => _nameEdited = true),
                errorText: _nameTouched
                    ? _requiredError(_name.text, 'Enter your name')
                    : null,
              ),
              DsTextField(
                controller: _surname,
                focusNode: _surnameFocus,
                hintText: 'Surname',
                textInputAction: TextInputAction.next,
                reserveErrorSpace: true,
                onChanged: (_) => setState(() => _surnameEdited = true),
                errorText: _surnameTouched
                    ? _requiredError(_surname.text, 'Enter your surname')
                    : null,
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.sm),
          DsTextField(
            controller: _company,
            focusNode: _companyFocus,
            hintText: 'Company name',
            textInputAction: TextInputAction.next,
            reserveErrorSpace: true,
            onChanged: (_) => setState(() => _companyEdited = true),
            errorText: _companyTouched
                ? _requiredError(_company.text, 'Enter your company name')
                : null,
          ),
          const SizedBox(height: DsSpacing.sm),
          DsTextField(
            controller: _email,
            focusNode: _emailFocus,
            hintText: 'Work email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            reserveErrorSpace: true,
            onChanged: (_) => setState(() => _emailTouched = true),
            // The taken case shows its own richer notice below (with the inline
            // "Sign in" link), so suppress the plain caption for it here.
            errorText: _emailTouched && !_emailIsTaken
                ? _emailError(_email.text)
                : null,
          ),
          if (_emailTouched && _emailIsTaken) _takenEmailNotice(tokens),
          const SizedBox(height: DsSpacing.sm),
          DsPasswordField(
            controller: _password,
            focusNode: _passwordFocus,
            hintText: 'Password',
            textInputAction: TextInputAction.done,
            reserveErrorSpace: true,
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
          const SizedBox(height: DsSpacing.lg),
          // Explicit consent, ticked before the account is created — it replaces
          // the passive "by continuing you agree" line. Terms and Privacy sit
          // inside the label, and the whole row toggles the box.
          DsCheckbox(
            value: _agreedToTerms,
            onChanged: (v) => setState(() {
              _agreedToTerms = v;
              if (v) _termsError = false;
            }),
            semanticLabel: 'I agree to the Terms of Service and Privacy Policy',
            errorText: _termsError
                ? 'Please accept the Terms of Service and Privacy Policy to '
                    'continue.'
                : null,
            labelWidget: Text.rich(
              TextSpan(
                style: tokens.bodyMd.toTextStyle(color: tokens.colorSecondaryText),
                children: [
                  const TextSpan(text: 'I agree to the '),
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
          ),
        ],
      ),
      primaryActionLabel: 'Create account',
      // The button stays live; the press validates and reveals what is missing.
      onSubmit: _trySubmit,
      footer: Text(
        'Need help?',
        style: tokens.bodySm.toTextStyle(color: tokens.actionPrimaryColorText),
      ),
    );
  }
}
