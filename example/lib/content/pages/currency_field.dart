// Pure Dart — NO Flutter imports.
import '../pattern_page_content.dart';

/// Forms → Currency field.
final PatternPage currencyFieldPage = PatternPage(
  id: 'currency-field',
  group: DocGroup.forms,
  navTitle: 'CurrencyField',
  title: 'Currency field',
  description:
      'The currency field collects a single monetary amount without making the '
      'user fight the keyboard. `DsCurrencyField` pins the currency `symbol` as '
      'a non-editable prefix inside the control, requests a decimal numeric '
      'keypad on mobile, and filters every keystroke down to digits and a single '
      'decimal point — so a value like `1249.5` can never become unparseable. '
      'It parses the text to a `num` for you, surfacing it through `onChanged` '
      '(or null while the field is empty or holds a lone decimal point), and it '
      'renders whole amounts cleanly without a trailing `.0`. Label, hint, '
      'helper and error states mirror the text field, and passing `errorText` '
      'flips the border and caption to the danger colour and announces the '
      'message alongside the label for assistive technology.',
  hasLiveDemo: true,
  dos: const [
    'Set the symbol to match the amount people are entering, and keep it as a single currency indicator rather than a full ISO code inline.',
    'Read the parsed num from onChanged instead of re-parsing the text yourself — the field has already stripped the symbol and validated the keystrokes.',
    'Handle the null value onChanged reports for an empty or half-typed amount, treating it as "no value yet" rather than zero.',
    'Use helperText to state a constraint up front (a minimum charge, the billing cadence) and errorText only once an entered amount is invalid.',
    'Keep the symbol and the surrounding copy agreed on one currency so the number is never ambiguous.',
  ],
  donts: const [
    "Don't ask users to type the currency symbol, thousands separators, or spaces — the field prefixes the symbol and rejects anything but digits and one decimal point.",
    "Don't show helperText and errorText at once; setting errorText replaces the helper caption.",
    "Don't reach for a plain text field and post-process the string when you need a money value — this field guarantees a parseable num.",
  ],
  code: '''
DsCurrencyField(
  label: 'Amount',
  symbol: r'\$',
  value: _amount,
  hintText: '0.00',
  helperText: 'Charged monthly, excluding tax.',
  onChanged: (amount) => setState(() => _amount = amount),
)
''',
  shots: const [
    Shot(pageId: 'currency-field', size: ShotSize.desktop),
    Shot(pageId: 'currency-field', size: ShotSize.phone),
  ],
  related: const ['text-fields', 'select'],
);
