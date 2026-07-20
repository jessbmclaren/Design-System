import 'package:flutter/services.dart';

/// A formatter that groups digits as they are typed, keeping the caret where
/// the user expects it.
///
/// Grouping is the easy half: strip everything but the digits, then insert
/// separators at fixed positions. The caret is the hard half, and the reason
/// this belongs to the system rather than each product. When a separator is
/// inserted before the caret, the caret must move past it; when the user
/// deletes across one, it must not jump to the end. Both are handled here by
/// counting digits rather than characters: the caret's position is measured
/// as "how many digits precede it", which survives any reformatting.
///
/// Subclass it with a [groups] pattern and a [separator]:
///
/// ```dart
/// class CardNumberFormatter extends DsGroupedDigitsFormatter {
///   const CardNumberFormatter() : super(groups: <int>[4, 4, 4, 4]);
/// }
/// ```
abstract class DsGroupedDigitsFormatter extends TextInputFormatter {
  /// Creates a grouped-digits formatter.
  const DsGroupedDigitsFormatter({
    required this.groups,
    this.separator = ' ',
  });

  /// The size of each group, in order. Digits beyond the final group are
  /// rejected, so the mask also caps the length.
  final List<int> groups;

  /// The text placed between groups.
  final String separator;

  /// The most digits the mask accepts.
  int get maxDigits => groups.fold<int>(0, (int sum, int g) => sum + g);

  /// Lays [digits] out into [groups], joined by [separator].
  String format(String digits) {
    final StringBuffer out = StringBuffer();
    int index = 0;
    for (int g = 0; g < groups.length && index < digits.length; g++) {
      if (g > 0) out.write(separator);
      final int end =
          (index + groups[g]).clamp(0, digits.length);
      out.write(digits.substring(index, end));
      index = end;
    }
    return out.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits =
        newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final String capped = digits.length > maxDigits
        ? digits.substring(0, maxDigits)
        : digits;
    final String formatted = format(capped);

    // Measure the caret in digits, not characters: separators come and go as
    // the text reflows, but the digit count before the caret does not.
    final int caret = newValue.selection.end.clamp(0, newValue.text.length);
    int digitsBeforeCaret = 0;
    for (int i = 0; i < caret; i++) {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[i])) digitsBeforeCaret++;
    }
    if (digitsBeforeCaret > capped.length) digitsBeforeCaret = capped.length;

    // Walk the formatted text and stop just after the last digit that
    // precedes the caret. Landing *after* that digit rather than *before*
    // the next one matters when a separator sits between them: parking the
    // caret past the separator would make the next backspace delete the
    // separator the mask immediately restores, and the deletion would never
    // make progress.
    int offset = formatted.length;
    if (digitsBeforeCaret == 0) {
      offset = 0;
    } else if (digitsBeforeCaret < capped.length) {
      int seen = 0;
      for (int i = 0; i < formatted.length; i++) {
        if (RegExp(r'[0-9]').hasMatch(formatted[i])) {
          seen++;
          if (seen == digitsBeforeCaret) {
            offset = i + 1;
            break;
          }
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }
}

/// A formatter that keeps a field to digits alone, optionally capped.
class DsDigitsOnlyFormatter extends TextInputFormatter {
  /// Creates a digits-only formatter.
  const DsDigitsOnlyFormatter({this.maxLength});

  /// The most digits accepted, or null for no cap.
  final int? maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final String capped = maxLength != null && digits.length > maxLength!
        ? digits.substring(0, maxLength!)
        : digits;
    final int removedBeforeCaret =
        newValue.text.length - capped.length;
    final int offset = (newValue.selection.end - removedBeforeCaret)
        .clamp(0, capped.length);
    return TextEditingValue(
      text: capped,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }
}
