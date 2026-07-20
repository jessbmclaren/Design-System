// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Foundations → Validators and masks.
final PatternPage validatorsPage = PatternPage(
  id: 'validators',
  group: DocGroup.foundations,
  navTitle: 'Validators and masks',
  title: 'Validators and masks',
  description:
      'Validators check what a field holds; masks shape it as the user types. '
      '`DsValidators` carries the generic rules every product needs, and '
      '`DsGroupedDigitsFormatter` carries the part worth owning centrally: '
      'the caret maths behind a digit mask.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'Each validator returns null for an acceptable value and a message '
      'otherwise, matching Flutter\'s form contract, so they drop straight '
      'into a field\'s `validator`. Every message is a parameter, because '
      'the wording belongs to the product and its voice rather than to the '
      'system. Compose several rules on one field with `DsValidators.all`, '
      'which reports the first failure only.',
    ),
    ProseBlock(
      'Grouping digits is the easy half of a mask; the caret is the hard '
      'half. The formatter measures the caret in digits rather than '
      'characters, so reformatting cannot move it, and it lands after the '
      'last digit that precedes it, so deleting a separator makes progress '
      'instead of looping. Market-specific rules live in their own opt-in '
      'module beside the generic tier, so a product serving another country '
      'ignores them rather than working around them. Subclass the formatter '
      'with a group pattern for a card '
      'number, a registration number or any other grouped identifier: '
      '`class CardNumberFormatter extends DsGroupedDigitsFormatter { '
      'CardNumberFormatter() : super(groups: const [4, 4, 4, 4]); }`.',
    ),
  ],
  dos: const [
    'Pass your own messages, in your product\'s voice.',
    'Validate on submit, and on a field once the user has left it.',
    'Subclass the formatter rather than writing caret maths again.',
  ],
  donts: const [
    'Don\'t validate an email with a stricter pattern; only sending mail proves one.',
    'Don\'t mask a field whose format the user cannot predict.',
    'Don\'t put market-specific rules in the generic tier; a market module holds those.',
  ],
  code: '''
DsTextField(
  label: 'Email',
  validator: DsValidators.all([
    (value) => DsValidators.required(value, message: 'Enter your email'),
    (value) => DsValidators.email(value, message: 'That email looks wrong'),
  ]),
);

// A digits-only field, capped at its identifier length:
DsTextField(
  label: 'Reference',
  inputFormatters: const [DsDigitsOnlyFormatter(maxLength: 12)],
);
''',
  related: const ['text-fields', 'phone-field', 'form-field-group'],
);
