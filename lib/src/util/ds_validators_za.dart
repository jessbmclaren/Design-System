import 'package:flutter/services.dart';

import 'ds_input_masks.dart';

/// Validators and masks for South African identifiers.
///
/// This is a market module, opt-in beside the generic `DsValidators`: the
/// rules here encode one country's formats, so a product serving another
/// market ignores it rather than working around it. Import it only where the
/// market applies.
///
/// Every validator returns null for an acceptable value and a message
/// otherwise, and takes that message as a parameter, because the wording
/// belongs to the product.
abstract final class DsValidatorsZa {
  /// Fails when [value] is not a four-digit postal code.
  static String? postalCode(
    String? value, {
    String message = 'Enter a 4-digit postal code',
    bool allowEmpty = false,
  }) {
    final String digits = _digits(value);
    if (digits.isEmpty) return allowEmpty ? null : message;
    return digits.length == 4 ? null : message;
  }

  /// Fails when [value] is not a valid national identity number.
  ///
  /// The number is thirteen digits carrying a birth date in its first six,
  /// followed by a checksum. Both are verified: a wrong date and a wrong
  /// check digit are equally invalid, and catching them here saves a round
  /// trip to a service that would only say the same thing.
  static String? idNumber(
    String? value, {
    String message = 'Enter a valid ID number',
    bool allowEmpty = false,
  }) {
    final String digits = _digits(value);
    if (digits.isEmpty) return allowEmpty ? null : message;
    if (digits.length != 13) return message;
    if (!_hasPlausibleBirthDate(digits)) return message;
    if (!_passesLuhn(digits)) return message;
    return null;
  }

  /// Fails when [value] is not a company registration number.
  ///
  /// The format is a four-digit year, a six-digit sequence and a two-digit
  /// entity type, usually written with slashes between them.
  static String? companyRegistration(
    String? value, {
    String message = 'Enter a valid registration number',
    bool allowEmpty = false,
  }) {
    final String digits = _digits(value);
    if (digits.isEmpty) return allowEmpty ? null : message;
    if (digits.length != 12) return message;
    final int year = int.parse(digits.substring(0, 4));
    // A registration cannot predate the modern companies register, and a
    // year far in the future is a typo rather than a company.
    if (year < 1900 || year > 2100) return message;
    return null;
  }

  /// Fails when [value] is not a mobile number in national form.
  ///
  /// A number typed with the international prefix is accepted: the mask
  /// rewrites it to the national form as it is typed.
  static String? mobileNumber(
    String? value, {
    String message = 'Enter a valid mobile number',
    bool allowEmpty = false,
  }) {
    final String digits = _digits(value);
    if (digits.isEmpty) return allowEmpty ? null : message;
    final String national = _toNational(digits);
    if (national.length != 10) return message;
    if (!national.startsWith('0')) return message;
    // Mobile ranges begin 06, 07 or 08; a landline in this field is a
    // mistake worth catching before a message is sent to it.
    final String prefix = national.substring(0, 2);
    if (prefix != '06' && prefix != '07' && prefix != '08') return message;
    return null;
  }

  /// The digits of [value], with everything else dropped.
  static String _digits(String? value) =>
      (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');

  /// Rewrites an international-prefixed number to its national form.
  static String _toNational(String digits) {
    if (digits.startsWith('27') && digits.length >= 11) {
      return '0${digits.substring(2)}';
    }
    return digits;
  }

  /// Whether the first six digits read as a real calendar date.
  static bool _hasPlausibleBirthDate(String digits) {
    final int month = int.parse(digits.substring(2, 4));
    final int day = int.parse(digits.substring(4, 6));
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    // A two-digit year cannot say its century, so both readings are tried
    // and the date only has to be real in one of them.
    final int shortYear = int.parse(digits.substring(0, 2));
    for (final int century in <int>[1900, 2000]) {
      final int year = century + shortYear;
      final DateTime date = DateTime(year, month, day);
      if (date.year == year && date.month == month && date.day == day) {
        return true;
      }
    }
    return false;
  }

  /// The Luhn checksum over every digit, the last being the check digit.
  static bool _passesLuhn(String digits) {
    int sum = 0;
    bool double = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);
      if (double) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      double = !double;
    }
    return sum % 10 == 0;
  }
}

/// Masks a national identity number as `000000 0000 000`.
class DsZaIdNumberFormatter extends DsGroupedDigitsFormatter {
  /// Creates an identity-number mask.
  DsZaIdNumberFormatter() : super(groups: const <int>[6, 4, 3]);
}

/// Masks a company registration number as `0000/000000/00`.
class DsZaCompanyRegistrationFormatter extends DsGroupedDigitsFormatter {
  /// Creates a registration-number mask.
  DsZaCompanyRegistrationFormatter()
      : super(groups: const <int>[4, 6, 2], separator: '/');
}

/// Masks a mobile number as `000 000 0000`, rewriting an international
/// prefix to the national form as the user types.
class DsZaMobileFormatter extends TextInputFormatter {
  /// Creates a mobile-number mask.
  DsZaMobileFormatter();

  final DsGroupedDigitsFormatter _grouped = _ZaMobileGrouping();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    // Someone pasting an international number gets it rewritten rather than
    // rejected: the two forms are the same number.
    if (digits.startsWith('27') && digits.length >= 11) {
      final String national = '0${digits.substring(2)}';
      return _grouped.formatEditUpdate(
        oldValue,
        TextEditingValue(
          text: national,
          selection: TextSelection.collapsed(offset: national.length),
        ),
      );
    }
    return _grouped.formatEditUpdate(oldValue, newValue);
  }
}

/// The national mobile grouping used by [DsZaMobileFormatter].
class _ZaMobileGrouping extends DsGroupedDigitsFormatter {
  _ZaMobileGrouping() : super(groups: const <int>[3, 3, 4]);
}
