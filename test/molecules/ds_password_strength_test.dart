import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsPasswordStrength model', () {
    test('rules reflect the value', () {
      final met = dsPasswordRules('ab').map((r) => r.met).toList();
      expect(met, <bool>[false, false, true, false, false]);
    });

    test('meetsAll is true only when every rule passes', () {
      expect(dsPasswordMeetsAll('short'), isFalse);
      expect(dsPasswordMeetsAll('Aa1!aaaa'), isTrue);
    });

    test('tier grades strength and downgrades predictable passwords', () {
      expect(dsPasswordTier(''), DsPasswordTier.tooWeak);
      expect(dsPasswordTier('Aa1!aaaa'), DsPasswordTier.weak);
      expect(dsPasswordTier('Aaaaaa1!aa'), DsPasswordTier.fair);
      expect(dsPasswordTier(r'Xk9#mPq2$vLz7!'), DsPasswordTier.strong);
      // Meets every rule, but a common word drags it back down.
      expect(dsPasswordTier('Password1!'), DsPasswordTier.weak);
    });
  });

  group('DsPasswordStrength widget', () {
    testWidgets('ticks every met rule', (tester) async {
      await pumpDs(tester, const DsPasswordStrength(value: 'Aa1!aaaa'));
      expect(find.byIcon(DsIcons.success), findsNWidgets(5));
    });

    testWidgets('shows unmet rules for an empty value', (tester) async {
      await pumpDs(tester, const DsPasswordStrength(value: ''));
      expect(find.byIcon(DsIcons.close), findsNWidgets(5));
      expect(find.byIcon(DsIcons.success), findsNothing);
    });
  });
}
