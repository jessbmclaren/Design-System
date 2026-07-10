// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Inputs → Password strength.
final PatternPage passwordStrengthPage = PatternPage(
  id: 'password-strength',
  group: DocGroup.inputs,
  navTitle: 'Password strength',
  title: 'Password strength',
  description:
      '`DsPasswordStrength` reads a password value and shows two things: a '
      'four-segment meter tinted by strength, and a checklist that ticks each '
      'rule as it is met. Pass the current `value` and it recomputes on every '
      'keystroke, so the guidance stays live while someone types. Set '
      '`showChecklist: false` to keep the meter on its own where space is '
      'tight. The same grading is exposed as a pure model, so a form can '
      'validate with the exact logic the meter shows.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'The widget shows guidance; the model decides. `dsPasswordRules(value)` '
      'returns the same rules the checklist renders, `dsPasswordMeetsAll(value)` '
      'is true once every rule passes, and `dsPasswordTier(value)` grades the '
      'value from too weak up to strong, marking common words and the usual '
      'word plus number plus symbol shape down a notch. Gate the submit button '
      'on the model and leave the widget to explain why.',
    ),
  ],
  dos: const [
    'Render DsPasswordStrength below the password field so the meter tracks what the user types.',
    'Gate the submit button with dsPasswordMeetsAll rather than reading the meter\'s colour.',
    'Set showChecklist: false on compact forms where the meter alone is enough.',
    'Feed it the same value your controller holds so the readout never lags the field.',
  ],
  donts: const [
    'Don\'t treat the meter as validation; check dsPasswordMeetsAll before you submit.',
    'Don\'t show the checklist and the field\'s own rule text at once; pick one place for the rules.',
    'Don\'t hide the meter until submit; live feedback is the point.',
    'Don\'t reword the rules in your copy; they come from dsPasswordRules and must match.',
  ],
  code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    DsPasswordField(
      label: 'New password',
      controller: _controller,
      onChanged: (value) => setState(() => _password = value),
    ),
    const SizedBox(height: 8),
    DsPasswordStrength(value: _password),
    const SizedBox(height: 16),
    DsButton(
      label: 'Create account',
      onPressed:
          dsPasswordMeetsAll(_password) ? _createAccount : null,
    ),
  ],
);
''',
  related: const ['password-field'],
);
