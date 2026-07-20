// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Inputs → Phone field.
final PatternPage phoneFieldPage = PatternPage(
  id: 'phone-field',
  group: DocGroup.inputs,
  navTitle: 'Phone field',
  title: 'Phone field',
  description:
      'A phone field fuses a dialling-country selector to a number field, so '
      'the prefix and the number read and validate as the single thing they '
      'are. `DsPhoneField` is controlled: the caller holds a `DsPhoneValue` '
      'of the chosen country and the number as typed, and applies each '
      'change.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'The selector sits inside the field\'s leading edge, so the two share '
      'one border and one accessible name. The number takes the telephone '
      'keyboard and accepts only digits and the separators people actually '
      'type, and each country can carry an example number that becomes the '
      'placeholder while it is chosen.',
    ),
    ProseBlock(
      'Formatting and validation stay with the caller, because a national '
      'number format is a market rule rather than a system one. Reach for '
      'the grouped-digits formatter to mask as the user types.',
    ),
  ],
  dos: const [
    'Offer the countries your product actually serves, most likely first.',
    'Give each country an example number so the expected shape is obvious.',
    'Validate on submit rather than on every keystroke.',
  ],
  donts: const [
    'Don\'t store the prefix inside the number; the value keeps them apart.',
    'Don\'t reject a number for its spacing; the field accepts the usual separators.',
    'Don\'t hide the country selector when your product serves more than one market.',
  ],
  code: '''
DsPhoneField(
  label: 'Mobile number',
  countries: const [
    DsDialCode(code: 'ZA', dialCode: '+27', hintExample: '00 000 0000'),
    DsDialCode(code: 'GB', dialCode: '+44', hintExample: '0000 000000'),
  ],
  value: phone,
  onChanged: (next) => setState(() => phone = next),
);
''',
  related: const ['text-fields', 'address-field-group', 'validators'],
);
