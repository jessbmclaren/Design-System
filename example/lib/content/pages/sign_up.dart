// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Patterns → Sign up.
final PatternPage signUpPage = PatternPage(
  id: 'sign-up',
  group: DocGroup.patterns,
  navTitle: 'Sign up',
  title: 'Sign up',
  description:
      'The sign-up view turns a first visit into an account. `DsSignUpView` '
      'frames registration as one focused, brand-led card: a `header` wordmark '
      'centred with `headingAlignment`, a short title, an "Already have an '
      'account?" prompt in the `aboveForm` slot, your own form and a single '
      'full-width primary action. The scaffold owns only the surrounding '
      'layout, spacing and responsive behaviour: you supply the `form` '
      '(typically a `DsFormFieldGroup` and fields) and own its validation, '
      'while `onSubmit` does the work and, when `null`, disables the button '
      'until every field is valid. `onClose` adds a corner close for a card '
      'opened over another surface, and `showBorder: false` lets the card '
      'rest on its shadow alone.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Ask for the fewest fields you truly need, then validate them where '
      'the user is looking. Name and surname share one `DsFormFieldGroup` '
      'row and stack on narrow screens. The work email validates live once '
      'touched: a format check surfaces "This email is invalid" and a '
      'directory check "Email already taken", both through the field\'s '
      '`errorText`. The password is captioned by `dsFirstUnmetPasswordRule`, '
      'which names one rule at a time so the error always says the next '
      'thing to fix, and a `DsPasswordStrength` meter beneath the field '
      'grades the value as it is typed. A `DsPasswordStrengthHint` line sits '
      'below the meter: it restates the requirements while a basic rule is '
      'unmet, then, once every rule passes but the value still grades weak, '
      'warns against a guessable password, and shows nothing otherwise. While '
      'the request is in flight, set '
      '`submitPending` to show a spinner and block repeat taps; the view '
      'never touches the network or a timer itself, so it renders '
      'identically in a screenshot and in production.',
    ),
    ProseBlock(
      'For a glyph-led card, pass `brandIcon` in place of the wordmark '
      '`header`: it renders in a tinted rounded square above the title, '
      'filled with `brandColor` or the primary button background when that '
      'is omitted. A short `description` beneath the title carries '
      'supporting copy, such as the trial terms, so the form itself stays '
      'lean.',
    ),
    ProseBlock(
      'Earlier revisions of this pattern paired the card with a benefits '
      '`aside`. The slot still exists for trial-style layouts, but this '
      'composition drops it: the single card keeps attention on the form, '
      'and the terms line in the `footer` stays short so the primary action '
      'is never buried.',
    ),
  ],
  dos: const [
    'Ask for the fewest fields that let someone get started, then progressively collect the rest.',
    'Put name and surname in one `DsFormFieldGroup` row; the group stacks them itself when the card narrows.',
    'Validate the email live once touched: a format check first, then the taken-address check, both through `errorText`.',
    'Caption the password with `dsFirstUnmetPasswordRule` so the error always names the next rule to fix.',
    'Gate `onSubmit` on the same checks the fields show and pass `null` until every one passes.',
    'Use `submitPending` while the request is in flight to prevent duplicate submissions.',
  ],
  donts: const [
    'Don\'t flag an email error before the field is touched; an empty field is not yet wrong.',
    'Don\'t list every unmet password rule at once; the ladder shows one message at a time.',
    'Don\'t crowd the card with links that pull people out before they finish.',
    'Don\'t bury the primary action beneath long terms copy; one short line under the button is enough.',
    'Don\'t add an `aside` to this composition; the card stands alone by design.',
  ],
  code: '''
DsSignUpView(
  header: DsWordmark(
    primary: 'acme',
    accent: 'id',
    fontSize: tokens.headingXl.fontSize,
  ),
  headingAlignment: DsHeadingAlignment.center,
  showBorder: false,
  onClose: _abandonSignUp,
  title: 'Seconds to sign up',
  aboveForm: Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text('Already have an account?',
          style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText)),
      DsLink(label: 'Sign in', onPressed: _goToSignIn),
    ],
  ),
  form: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Name and surname share a row; the group stacks them when narrow.
      DsFormFieldGroup(
        children: [
          DsTextField(controller: _name, hintText: 'Name'),
          DsTextField(controller: _surname, hintText: 'Surname'),
        ],
      ),
      const SizedBox(height: DsSpacing.lg),
      DsTextField(controller: _company, hintText: 'Company name'),
      const SizedBox(height: DsSpacing.lg),
      DsTextField(
        controller: _email,
        hintText: 'Work email',
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) => setState(() => _emailTouched = true),
        // 'This email is invalid' or 'Email already taken', live.
        errorText: _emailTouched ? _emailError(_email.text) : null,
      ),
      const SizedBox(height: DsSpacing.lg),
      DsPasswordField(
        controller: _password,
        hintText: 'Password',
        // Cue password managers to generate and save, not fill a stored value.
        newPassword: true,
        onChanged: (_) => setState(() => _passwordTouched = true),
        // One rule at a time: the first unmet rule is the next fix.
        errorText: _passwordTouched
            ? dsFirstUnmetPasswordRule(_password.text)
            : null,
      ),
      const SizedBox(height: DsSpacing.sm),
      DsPasswordStrength(value: _password.text, showChecklist: false),
      DsPasswordStrengthHint(value: _password.text),
    ],
  ),
  primaryActionLabel: 'Create account',
  onSubmit: _allFieldsValid ? _handleSubmit : null,
  submitPending: _submitting,
  footer: Text.rich(
    textAlign: TextAlign.center,
    TextSpan(
      style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
      children: [
        const TextSpan(text: 'By continuing, you agree to our '),
        TextSpan(text: 'Terms of Service',
            style: TextStyle(color: tokens.actionPrimaryColorText)),
        const TextSpan(text: ' and '),
        TextSpan(text: 'Privacy Policy',
            style: TextStyle(color: tokens.actionPrimaryColorText)),
        const TextSpan(text: '.'),
      ],
    ),
  ),
)
''',
  shots: const [
    Shot(pageId: 'sign-up', size: ShotSize.desktop),
    Shot(pageId: 'sign-up', size: ShotSize.phone),
  ],
  related: const ['sign-in', 'onboarding', 'password-strength'],
);
