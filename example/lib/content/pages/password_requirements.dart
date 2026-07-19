// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Inputs → Password requirements.
final PatternPage passwordRequirementsPage = PatternPage(
  id: 'password-requirements',
  group: DocGroup.inputs,
  navTitle: 'Password requirements',
  title: 'Password requirements',
  description:
      '`DsPasswordRequirements` is the rule checklist on its own, without the '
      'meter and strength word that `DsPasswordStrength` wraps around it. '
      'Reach for it when the checklist should be the only password feedback on '
      'the screen. With one authority a "requirement not met" and a "looks '
      'strong" can never disagree, which is exactly what a meter sitting '
      'beside a rule list invites. Pass the current `value` and the rows '
      'recompute on every keystroke.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Rows have two readings while someone types: neutral, meaning not '
      'satisfied yet, and ticked. Nothing turns red as you type. Set '
      '`attempted: true` once a submit has actually been refused and the '
      'still-unmet rows take the error colour, so the red is a response to '
      'someone trying to move on rather than a running commentary on a '
      'half-typed password. A rule already met never turns red.',
    ),
    ProseBlock(
      'The rows come from `dsPasswordRules(value)` by default. Pass `rules` to '
      'group or reword them, which is worth doing when two rules read better '
      'as one line: an upper-case and a lower-case letter is one idea to a '
      'reader and two rules to the model. Pass `extraRules` to append checks '
      'the design system does not own, such as whether the password appears in '
      'a known breach. Leave `itemWidth` null for a single column, or set it '
      'to lay the rows out in a wrapping grid.',
    ),
    ProseBlock(
      'The list is one live region rather than one per row, so assistive '
      'technology hears the set re-read as it changes instead of five '
      'announcements racing each other on every keystroke. Each row still '
      'carries its own checked state, and the marker pairs a check glyph with '
      'its tint so the state never rests on colour alone.',
    ),
  ],
  dos: const [
    'Use it when the checklist is the only password feedback, so nothing can contradict it.',
    'Keep attempted false while someone types; set it only when a submit was refused.',
    'Gate the submit button with dsPasswordMeetsAll rather than reading the rows.',
    'Group rules with the rules parameter when two read better as one line.',
  ],
  donts: const [
    'Don\'t show this and DsPasswordStrength together; pick one authority for the rules.',
    'Don\'t set attempted on every keystroke; that is the red-while-typing this component exists to avoid.',
    'Don\'t reword the standard rules in prose elsewhere; they come from dsPasswordRules and must match.',
    'Don\'t use it to validate; it reports the model, it does not enforce it.',
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
    DsPasswordRequirements(
      value: _password,
      attempted: _submitRefused,
      extraRules: [
        DsPasswordRule('Not found in known data breaches', !_breached),
      ],
    ),
    const SizedBox(height: 16),
    DsButton(
      label: 'Save new password',
      onPressed: dsPasswordMeetsAll(_password) ? _save : null,
    ),
  ],
);
''',
  shots: const [
    Shot(pageId: 'password-requirements', size: ShotSize.desktop),
    Shot(pageId: 'password-requirements', size: ShotSize.phone),
  ],
  related: const ['password-strength', 'password-field'],
);
