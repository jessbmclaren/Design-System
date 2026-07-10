import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// The containers that make up the strength meter bar (it sits inside the
/// widget's [ExcludeSemantics] wrapper).
Finder _meterSegments() => find.descendant(
  of: find.descendant(
    of: find.byType(DsPasswordStrength),
    matching: find.byType(ExcludeSemantics),
  ),
  matching: find.byType(Container),
);

/// How many meter segments are painted with [color].
int _segmentsPainted(WidgetTester tester, Color color) => tester
    .widgetList<Container>(_meterSegments())
    .where((c) => (c.decoration as BoxDecoration?)?.color == color)
    .length;

void main() {
  group('DsPasswordStrength model', () {
    test('rules reflect the value', () {
      final met = dsPasswordRules('ab').map((r) => r.met).toList();
      expect(met, <bool>[false, false, true, false, false]);
    });

    test('each rule flips exactly at its boundary', () {
      expect(dsPasswordRules('Aa1!aaa')[0].met, isFalse); // 7 characters
      expect(dsPasswordRules('Aa1!aaaa')[0].met, isTrue); // 8 characters
      expect(dsPasswordRules('aa1!aaaa')[1].met, isFalse); // no capital
      expect(dsPasswordRules('Aa1!aaaa')[1].met, isTrue);
      expect(dsPasswordRules('AA1!AAAA')[2].met, isFalse); // no lowercase
      expect(dsPasswordRules('Aa1!aaaa')[2].met, isTrue);
      expect(dsPasswordRules('Aab!aaaa')[3].met, isFalse); // no number
      expect(dsPasswordRules('Aa1!aaaa')[3].met, isTrue);
      expect(dsPasswordRules('Aab1aaaa')[4].met, isFalse); // no special
      expect(dsPasswordRules('Aa1!aaaa')[4].met, isTrue);
    });

    test('meetsAll is true only when every rule passes', () {
      expect(dsPasswordMeetsAll('short'), isFalse);
      expect(dsPasswordMeetsAll('Aa1!aaaa'), isTrue);
    });

    test('firstUnmetRule walks the ladder in rule order', () {
      expect(dsFirstUnmetPasswordRule(''), 'Password required');
      expect(
        dsFirstUnmetPasswordRule('Aa1!aaa'),
        'Must be at least 8 characters long.',
      );
      expect(
        dsFirstUnmetPasswordRule('aa1!aaaa'),
        'Please use at least one capital letter',
      );
      expect(
        dsFirstUnmetPasswordRule('AA1!AAAA'),
        'Please use at least one lowercase letter',
      );
      expect(
        dsFirstUnmetPasswordRule('Aab!aaaa'),
        'Please use at least one number',
      );
      expect(
        dsFirstUnmetPasswordRule('Aab1aaaa'),
        'Please use at least one special character',
      );
      expect(dsFirstUnmetPasswordRule('Aab1aaa!'), isNull);
      // Several rules unmet at once: the shortest value still surfaces the
      // length message first.
      expect(
        dsFirstUnmetPasswordRule('a'),
        'Must be at least 8 characters long.',
      );
    });

    test('tier gate needs three rules met and eight characters', () {
      expect(dsPasswordTier(''), DsPasswordTier.tooWeak);
      // Long enough but only two rules met (length, lowercase).
      expect(dsPasswordTier('aaaaaaaa'), DsPasswordTier.tooWeak);
      // Four rules met but under eight characters.
      expect(dsPasswordTier('Aa1!Aa1'), DsPasswordTier.tooWeak);
      // Three rules met at eight characters clears the gate.
      expect(dsPasswordTier('1111aaaa'), DsPasswordTier.weak);
    });

    test('tier grades by variety and length', () {
      expect(dsPasswordTier('Aa1!aaaa'), DsPasswordTier.weak);
      expect(dsPasswordTier('Axcr1935!kdz'), DsPasswordTier.good);
      expect(dsPasswordTier('Xk9#mPq2\$vLz7!Qw'), DsPasswordTier.strong);
    });

    test('a common word drags a rule-passing value down', () {
      expect(dsPasswordTier('Password1!'), DsPasswordTier.tooWeak);
      // At fourteen characters with every rule met it recovers to weak.
      expect(dsPasswordTier('Password1!xyzA'), DsPasswordTier.weak);
    });

    test('brandWords downgrade like common words, case-insensitively', () {
      expect(dsPasswordTier('xEngenz19!Ab'), DsPasswordTier.good);
      expect(
        dsPasswordTier('xEngenz19!Ab', brandWords: {'engen'}),
        DsPasswordTier.tooWeak,
      );
      expect(
        dsPasswordTier('xEngenz19!Ab', brandWords: {'Engen'}),
        DsPasswordTier.tooWeak,
      );
    });

    test('the word+number+symbol shape is penalised', () {
      expect(dsPasswordTier('McLaren26!'), DsPasswordTier.tooWeak);
      // Long and fully varied, so the same shape recovers to weak.
      expect(dsPasswordTier('Bridgewater2024!'), DsPasswordTier.weak);
    });

    test('repeats and keyboard runs cost a step', () {
      // 'abcd' and '1234' are runs; the same shape without them grades good.
      expect(dsPasswordTier('Abcd1234!xyz'), DsPasswordTier.fair);
      expect(dsPasswordTier('Axcr1935!kdz'), DsPasswordTier.good);
      // 'sss' is a repeat; the same shape without it grades good.
      expect(dsPasswordTier('Xsss9!Krtmvpz'), DsPasswordTier.fair);
      expect(dsPasswordTier('Xsrs9!Krtmvpz'), DsPasswordTier.good);
    });

    test('strength label pairs the word with a signal colour', () {
      final tokens = DsTokens.light();
      expect(dsPasswordStrengthLabel(tokens, ''), (
        label: '',
        color: tokens.colorDanger,
      ));
      expect(dsPasswordStrengthLabel(tokens, 'Password1!'), (
        label: 'Too weak',
        color: tokens.colorDanger,
      ));
      expect(dsPasswordStrengthLabel(tokens, 'Aa1!aaaa'), (
        label: 'Weak',
        color: tokens.colorDanger,
      ));
      expect(dsPasswordStrengthLabel(tokens, 'Abcd1234!xyz'), (
        label: 'Fair',
        color: tokens.badgeWarningColorText,
      ));
      expect(dsPasswordStrengthLabel(tokens, 'Axcr1935!kdz'), (
        label: 'Good',
        color: tokens.badgeSuccessColorText,
      ));
      expect(dsPasswordStrengthLabel(tokens, 'Xk9#mPq2\$vLz7!Qw'), (
        label: 'Strong',
        color: tokens.badgeSuccessColorText,
      ));
      expect(
        dsPasswordStrengthLabel(tokens, 'xEngenz19!Ab', brandWords: {'engen'}),
        (label: 'Too weak', color: tokens.colorDanger),
      );
    });
  });

  group('DsPasswordStrength widget', () {
    testWidgets('draws a three-segment meter, excluded from semantics', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsPasswordStrength(value: '', showChecklist: false),
      );
      expect(_meterSegments(), findsNWidgets(3));
    });

    testWidgets('fills segments by tier in the tier colour', (tester) async {
      await pumpDs(
        tester,
        const DsPasswordStrength(value: 'Aa1!aaaa', showChecklist: false),
      );
      final tokens = DsTokens.of(
        tester.element(find.byType(DsPasswordStrength)),
      );
      expect(_segmentsPainted(tester, tokens.colorDanger), 1);
      expect(find.text('Weak'), findsOneWidget);

      await pumpDs(
        tester,
        const DsPasswordStrength(value: 'Abcd1234!xyz', showChecklist: false),
      );
      expect(_segmentsPainted(tester, tokens.badgeWarningColorText), 2);
      expect(find.text('Fair'), findsOneWidget);

      await pumpDs(
        tester,
        const DsPasswordStrength(value: 'Axcr1935!kdz', showChecklist: false),
      );
      expect(_segmentsPainted(tester, tokens.badgeSuccessColorText), 3);
      expect(find.text('Good'), findsOneWidget);
    });

    testWidgets('shows no filled segment or word for an empty value', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsPasswordStrength(value: '', showChecklist: false),
      );
      final tokens = DsTokens.of(
        tester.element(find.byType(DsPasswordStrength)),
      );
      expect(_segmentsPainted(tester, tokens.colorBorder), 3);
      expect(find.text('Too weak'), findsNothing);
    });

    testWidgets('brandWords downgrade the meter reading', (tester) async {
      await pumpDs(
        tester,
        const DsPasswordStrength(
          value: 'xEngenz19!Ab',
          brandWords: {'engen'},
          showChecklist: false,
        ),
      );
      expect(find.text('Too weak'), findsOneWidget);
    });

    testWidgets('marks every met rule with a check dot', (tester) async {
      await pumpDs(tester, const DsPasswordStrength(value: 'Aa1!aaaa'));
      expect(find.byIcon(DsIcons.check), findsNWidgets(5));
    });

    testWidgets('lists unmet rules without check dots for an empty value', (
      tester,
    ) async {
      await pumpDs(tester, const DsPasswordStrength(value: ''));
      expect(find.byIcon(DsIcons.check), findsNothing);
      expect(find.text('At least 8 characters'), findsOneWidget);
      expect(find.text('One uppercase letter'), findsOneWidget);
      expect(find.text('One lowercase letter'), findsOneWidget);
      expect(find.text('One number'), findsOneWidget);
      expect(find.text('One special character'), findsOneWidget);
    });

    testWidgets('showChecklist false hides the rules', (tester) async {
      await pumpDs(
        tester,
        const DsPasswordStrength(value: 'Aa1!aaaa', showChecklist: false),
      );
      expect(find.text('One number'), findsNothing);
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        const DsPasswordStrength(value: 'Aa1!aaaa'),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('One special character'), findsOneWidget);
    });

    testWidgets('does not overflow on a wide layout', (tester) async {
      await pumpDs(
        tester,
        const DsPasswordStrength(value: 'Aa1!aaaa'),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('DsPasswordStrengthHint', () {
    testWidgets('restates the basics while a rule is unmet', (tester) async {
      await pumpDs(tester, const DsPasswordStrengthHint(value: 'abc'));
      expect(
        find.text(
          'Use at least 8 characters with upper- and lower-case letters, '
          'a number and a symbol.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('warns about guessable passwords once the rules pass', (
      tester,
    ) async {
      await pumpDs(tester, const DsPasswordStrengthHint(value: 'Password1!'));
      expect(
        find.text(
          "Your password isn't strong enough. Avoid common words, names, "
          'dates and repeating characters to make it more secure.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders nothing when empty or fair and better', (
      tester,
    ) async {
      await pumpDs(tester, const DsPasswordStrengthHint(value: ''));
      expect(find.byType(Text), findsNothing);

      await pumpDs(tester, const DsPasswordStrengthHint(value: 'Axcr1935!kdz'));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        const DsPasswordStrengthHint(value: 'Password1!'),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
