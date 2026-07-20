import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A four-by-four grouped mask, the shape a long reference number takes.
class _QuadFormatter extends DsGroupedDigitsFormatter {
  _QuadFormatter() : super(groups: const <int>[4, 4, 4, 4]);
}

/// Runs [formatter] over a typed value, reporting text and caret.
TextEditingValue type(
  TextInputFormatter formatter, {
  required String from,
  required int fromCaret,
  required String to,
  required int toCaret,
}) {
  return formatter.formatEditUpdate(
    TextEditingValue(
      text: from,
      selection: TextSelection.collapsed(offset: fromCaret),
    ),
    TextEditingValue(
      text: to,
      selection: TextSelection.collapsed(offset: toCaret),
    ),
  );
}

void main() {
  group('DsValidators', () {
    test('required rejects empty and whitespace', () {
      expect(DsValidators.required(null), isNotNull);
      expect(DsValidators.required(''), isNotNull);
      expect(DsValidators.required('   '), isNotNull);
      expect(DsValidators.required('Jordan'), isNull);
    });

    test('email accepts plausible addresses and rejects the rest', () {
      expect(DsValidators.email('someone@example.com'), isNull);
      expect(DsValidators.email('first.last@sub.example.co.uk'), isNull);
      expect(DsValidators.email('someone@example'), isNotNull);
      expect(DsValidators.email('someone.example.com'), isNotNull);
      expect(DsValidators.email('two @example.com'), isNotNull);
      expect(DsValidators.email(''), isNotNull);
      expect(DsValidators.email('', allowEmpty: true), isNull);
    });

    test('website accepts a bare host or a full address', () {
      expect(DsValidators.website('example.com'), isNull);
      expect(DsValidators.website('https://example.com/pricing'), isNull);
      expect(DsValidators.website('not a host'), isNotNull);
      expect(DsValidators.website(''), isNull);
      expect(DsValidators.website('', allowEmpty: false), isNotNull);
    });

    test('selected rejects nothing chosen, in every shape', () {
      expect(DsValidators.selected(null), isNotNull);
      expect(DsValidators.selected(''), isNotNull);
      expect(DsValidators.selected(<String>[]), isNotNull);
      expect(DsValidators.selected('za'), isNull);
      expect(DsValidators.selected(<String>{'mon'}), isNull);
    });

    test('minLength counts characters', () {
      expect(DsValidators.minLength('abc', 4), isNotNull);
      expect(DsValidators.minLength('abcd', 4), isNull);
    });

    test('all reports the first failure only', () {
      final String? Function(String?) validator = DsValidators.all(
        <String? Function(String?)>[
          (String? v) => DsValidators.required(v, message: 'first'),
          (String? v) => DsValidators.email(v, message: 'second'),
        ],
      );
      expect(validator(''), 'first');
      expect(validator('nope'), 'second');
      expect(validator('someone@example.com'), isNull);
    });
  });

  group('DsGroupedDigitsFormatter', () {
    final _QuadFormatter formatter = _QuadFormatter();

    test('groups digits as they arrive', () {
      final TextEditingValue result = type(
        formatter,
        from: '',
        fromCaret: 0,
        to: '12345',
        toCaret: 5,
      );
      expect(result.text, '1234 5');
      // The caret sits after the digit just typed, past the new separator.
      expect(result.selection.baseOffset, 6);
    });

    test('strips anything that is not a digit', () {
      expect(
        type(formatter, from: '', fromCaret: 0, to: '12-ab34', toCaret: 7).text,
        '1234',
      );
    });

    test('caps at the mask length', () {
      final TextEditingValue result = type(
        formatter,
        from: '',
        fromCaret: 0,
        to: '12345678901234567890',
        toCaret: 20,
      );
      expect(result.text, '1234 5678 9012 3456');
    });

    test('keeps the caret in place when editing mid-string', () {
      // Typing a 9 after the first group: 1234| 5678 → 12349| 5678.
      final TextEditingValue result = type(
        formatter,
        from: '1234 5678',
        fromCaret: 4,
        to: '12349 5678',
        toCaret: 5,
      );
      expect(result.text, '1234 9567 8');
      // Five digits precede the caret, so it lands after the fifth.
      expect(result.selection.baseOffset, 6);
    });

    test('deleting across a separator does not fling the caret to the end', () {
      // Backspacing the separator between groups removes the digit before it.
      final TextEditingValue result = type(
        formatter,
        from: '1234 5678',
        fromCaret: 5,
        to: '12345678',
        toCaret: 4,
      );
      expect(result.text, '1234 5678');
      expect(result.selection.baseOffset, 4);
    });
  });

  group('DsDigitsOnlyFormatter', () {
    test('keeps digits and honours the cap', () {
      const DsDigitsOnlyFormatter formatter =
          DsDigitsOnlyFormatter(maxLength: 4);
      expect(
        type(formatter, from: '', fromCaret: 0, to: 'a1b2c3d4e5', toCaret: 10)
            .text,
        '1234',
      );
    });
  });
}
