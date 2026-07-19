// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Patterns → Choose a password.
final PatternPage choosePasswordPage = PatternPage(
  id: 'choose-password',
  group: DocGroup.patterns,
  navTitle: 'Choose a password',
  title: 'Choose a password',
  description:
      '`DsChoosePasswordView` is the card for the step where someone sets a '
      'password: a single obscured field with the visibility toggle, a live '
      '`DsPasswordRequirements` checklist as the only feedback, and one '
      'primary action. It is the sibling of `DsForgotPasswordView`, and it is '
      'not reset-specific. The same card accepts an invite, sets a first '
      'password or forces a rotation.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'One field, no confirm box: a second "confirm password" field is a '
      'workaround for hidden input, and the visibility toggle solves that '
      'better. The checklist is the only feedback, so there is no meter and no '
      'strength word to disagree with a "requirement not met". Rows stay '
      'neutral while typing and turn red only when `attempted` is set after a '
      'refused submit, so the error answers a submit rather than running '
      'alongside every keystroke.',
    ),
    ProseBlock(
      'Like the other auth scaffolds it owns no form state. The caller holds '
      'the controller, decides when each rule is met (pass a breach lookup or '
      'a product policy through `extraRules`), gates `primaryAction.onPressed` '
      'with `dsPasswordMeetsAll`, and flips `attempted` on an invalid submit. '
      'Submitting from the keyboard commits the platform "save password?" '
      'prompt, so a password manager offers to store it.',
    ),
  ],
  dos: const [
    'Gate primaryAction.onPressed on dsPasswordMeetsAll plus any product rule.',
    'Set attempted only after a refused submit, and focus the field then.',
    'Pass breach or policy checks through extraRules so they read as rows.',
    'Keep the single field; the visibility toggle replaces a confirm box.',
  ],
  donts: const [
    'Don\'t add a confirm-password field; it is the workaround this pattern removes.',
    'Don\'t pair it with a strength meter; the checklist is the one authority.',
    'Don\'t set attempted on every keystroke; that is red-while-typing.',
    'Don\'t sign the person in from here if the step only proves inbox access; return them to sign-in.',
  ],
  code: '''
DsChoosePasswordView(
  value: _password,
  attempted: _attempted,
  controller: _controller,
  focusNode: _focus,
  onChanged: (v) => setState(() => _password = v),
  extraRules: [
    DsPasswordRule('Not found in known data breaches', !_breached),
  ],
  primaryAction: DsSignInAction(
    label: 'Save new password',
    onPressed: dsPasswordMeetsAll(_password) ? _save : null,
    pending: _saving,
  ),
);
''',
  shots: const [
    Shot(pageId: 'choose-password', size: ShotSize.desktop),
    Shot(pageId: 'choose-password', size: ShotSize.phone),
  ],
  related: const ['password-requirements', 'sign-in', 'verify-email'],
);
