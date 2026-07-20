import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Appends the Luhn check digit to a twelve-digit stem, so the fixtures are
/// valid by construction rather than by a number copied from somewhere real.
String withCheckDigit(String stem) {
  int sum = 0;
  bool double = true; // The check digit will occupy the final, undoubled slot.
  for (int i = stem.length - 1; i >= 0; i--) {
    int digit = int.parse(stem[i]);
    if (double) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
    double = !double;
  }
  final int check = (10 - (sum % 10)) % 10;
  return '$stem$check';
}

TextEditingValue typeAll(TextInputFormatter formatter, String text) {
  return formatter.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );
}

void main() {
  group('postal code', () {
    test('accepts four digits and rejects the rest', () {
      expect(DsValidatorsZa.postalCode('7441'), isNull);
      expect(DsValidatorsZa.postalCode('744'), isNotNull);
      expect(DsValidatorsZa.postalCode('74415'), isNotNull);
      expect(DsValidatorsZa.postalCode(''), isNotNull);
      expect(DsValidatorsZa.postalCode('', allowEmpty: true), isNull);
    });
  });

  group('identity number', () {
    // 1990-03-14, sequence and citizenship digits, then a real check digit.
    final String valid = withCheckDigit('900314500108');

    test('accepts a well-formed number', () {
      expect(DsValidatorsZa.idNumber(valid), isNull);
      // Spacing is the user's business, not the rule's.
      expect(DsValidatorsZa.idNumber('${valid.substring(0, 6)} '
          '${valid.substring(6)}'), isNull);
    });

    test('rejects a wrong check digit', () {
      final int last = int.parse(valid[12]);
      final String broken =
          '${valid.substring(0, 12)}${(last + 1) % 10}';
      expect(DsValidatorsZa.idNumber(broken), isNotNull);
    });

    test('rejects an impossible birth date', () {
      // Month 13 cannot exist, whichever century the year belongs to.
      expect(DsValidatorsZa.idNumber(withCheckDigit('901314500108')),
          isNotNull);
      // 30 February is unreal in both centuries.
      expect(DsValidatorsZa.idNumber(withCheckDigit('900230500108')),
          isNotNull);
    });

    test('rejects the wrong length', () {
      expect(DsValidatorsZa.idNumber('90031450010'), isNotNull);
      expect(DsValidatorsZa.idNumber(''), isNotNull);
      expect(DsValidatorsZa.idNumber('', allowEmpty: true), isNull);
    });
  });

  group('company registration', () {
    test('accepts the year, sequence and type', () {
      expect(DsValidatorsZa.companyRegistration('2019/123456/07'), isNull);
      expect(DsValidatorsZa.companyRegistration('201912345607'), isNull);
    });

    test('rejects an impossible year or length', () {
      expect(DsValidatorsZa.companyRegistration('1019/123456/07'), isNotNull);
      expect(DsValidatorsZa.companyRegistration('2019/12345/07'), isNotNull);
    });
  });

  group('mobile number', () {
    test('accepts a national number in the mobile ranges', () {
      expect(DsValidatorsZa.mobileNumber('082 123 4567'), isNull);
      expect(DsValidatorsZa.mobileNumber('0721234567'), isNull);
      expect(DsValidatorsZa.mobileNumber('0631234567'), isNull);
    });

    test('accepts the international form as the same number', () {
      expect(DsValidatorsZa.mobileNumber('+27 82 123 4567'), isNull);
    });

    test('rejects a landline or a wrong length', () {
      expect(DsValidatorsZa.mobileNumber('021 123 4567'), isNotNull);
      expect(DsValidatorsZa.mobileNumber('082 123 456'), isNotNull);
    });
  });

  group('masks', () {
    test('the identity mask groups six, four and three', () {
      expect(typeAll(DsZaIdNumberFormatter(), '9003145001081').text,
          '900314 5001 081');
    });

    test('the registration mask slashes year, sequence and type', () {
      expect(typeAll(DsZaCompanyRegistrationFormatter(), '201912345607').text,
          '2019/123456/07');
    });

    test('the mobile mask groups three, three and four', () {
      expect(typeAll(DsZaMobileFormatter(), '0821234567').text,
          '082 123 4567');
    });

    test('the mobile mask rewrites an international prefix', () {
      expect(typeAll(DsZaMobileFormatter(), '27821234567').text,
          '082 123 4567');
    });
  });
}
