import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../../tokens/ds_spacing.dart';

// ---------------------------------------------------------------------------
// Model (pure Dart, no Flutter): the rules and grading used by the meter. It
// is exposed on its own so a form can validate a password with the same logic
// the meter displays.
// ---------------------------------------------------------------------------

/// One password rule and whether the current value satisfies it.
@immutable
class DsPasswordRule {
  /// Creates a password rule result.
  const DsPasswordRule(this.label, this.met);

  /// The human-readable requirement, for example "At least 8 characters".
  final String label;

  /// Whether the current value satisfies this rule.
  final bool met;
}

/// The standard password rule set, in display order.
List<DsPasswordRule> dsPasswordRules(String value) => <DsPasswordRule>[
  DsPasswordRule('At least 8 characters', value.length >= 8),
  DsPasswordRule('One uppercase letter', RegExp('[A-Z]').hasMatch(value)),
  DsPasswordRule('One lowercase letter', RegExp('[a-z]').hasMatch(value)),
  DsPasswordRule('One number', RegExp('[0-9]').hasMatch(value)),
  DsPasswordRule(
    'One special character',
    RegExp(r'[^A-Za-z0-9]').hasMatch(value),
  ),
];

/// Whether [value] satisfies every rule in [dsPasswordRules].
bool dsPasswordMeetsAll(String value) =>
    dsPasswordRules(value).every((rule) => rule.met);

/// The messages for [dsFirstUnmetPasswordRule], one per rule in
/// [dsPasswordRules] and in the same order.
const List<String> _unmetRuleMessages = <String>[
  'Must be at least 8 characters long.',
  'Please use at least one capital letter',
  'Please use at least one lowercase letter',
  'Please use at least one number',
  'Please use at least one special character',
];

/// The first unmet rule's message, for live under-field guidance.
///
/// An empty [value] returns 'Password required'. Otherwise the rules in
/// [dsPasswordRules] are checked in order and the first failure returns its
/// message, so the caption always tells the user the next thing to fix. Once
/// every rule is met it returns null, which lets a form feed the result
/// straight into an error caption such as [DsTextField.errorText].
String? dsFirstUnmetPasswordRule(String value) {
  if (value.isEmpty) return 'Password required';
  final rules = dsPasswordRules(value);
  for (var i = 0; i < rules.length; i++) {
    if (!rules[i].met) return _unmetRuleMessages[i];
  }
  return null;
}

/// The overall strength of a password, beyond the basic rules.
enum DsPasswordTier {
  /// Below the gate: too short, too little variety or too predictable.
  tooWeak,

  /// Clears the gate but stays short or guessable.
  weak,

  /// Meets the rules with modest length and variety.
  fair,

  /// A comfortably strong password.
  good,

  /// A long, varied password with no obvious pattern.
  strong,
}

const Set<String> _commonWords = <String>{
  'password',
  'passw0rd',
  'qwerty',
  'letmein',
  'welcome',
  'admin',
  'login',
  'iloveyou',
  'monkey',
  'dragon',
};

/// Three or more of the same character in a row.
bool _hasRepeat(String value) => RegExp(r'(.)\1\1').hasMatch(value);

/// A deliberate keyboard or alphabet run of four or more characters (abcd,
/// 1234, asdf), not incidental adjacency.
bool _hasSequence(String value) {
  const runs = <String>[
    'abcdefghijklmnopqrstuvwxyz',
    '0123456789',
    'qwertyuiop',
    'asdfghjkl',
    'zxcvbnm',
  ];
  final lower = value.toLowerCase();
  for (var i = 0; i + 4 <= lower.length; i++) {
    final sub = lower.substring(i, i + 4);
    if (runs.any((run) => run.contains(sub))) return true;
  }
  return false;
}

// The classic "word + short number + optional symbols" anti-pattern, for
// example McLaren26! or Bridge2024!. It meets the rules but is highly
// guessable.
final RegExp _wordNumberSymbol = RegExp(
  r'^[A-Za-z]+[0-9]{1,4}[^A-Za-z0-9]{0,3}$',
);

/// Grades [value] into a [DsPasswordTier].
///
/// A value that fails the gate (fewer than three rules met, or under 8
/// characters) is [DsPasswordTier.tooWeak]. A predictable password (a common
/// word, a word from [brandWords] or the word, number then symbol shape)
/// stays low even when it ticks every box. Otherwise variety and length raise
/// the tier, with penalties for repeated characters and keyboard runs, so an
/// incidental three-character adjacency does not tank an otherwise strong
/// password.
///
/// Pass [brandWords] to treat a brand's own names as guessable: a password
/// built on the product name is as weak as any dictionary word. Matching is
/// case-insensitive.
DsPasswordTier dsPasswordTier(
  String value, {
  Set<String> brandWords = const <String>{},
}) {
  if (value.isEmpty) return DsPasswordTier.tooWeak;
  final met = dsPasswordRules(value).where((rule) => rule.met).length;
  if (met < 3 || value.length < 8) return DsPasswordTier.tooWeak;

  final lower = value.toLowerCase();
  final guessable =
      _commonWords.any(lower.contains) ||
      brandWords.any(
        (word) => word.isNotEmpty && lower.contains(word.toLowerCase()),
      ) ||
      _wordNumberSymbol.hasMatch(value);
  // A known-weak word or the word+number+symbol shape stays low even when
  // every rule is met.
  if (guessable) {
    return (value.length >= 14 && met == 5)
        ? DsPasswordTier.weak
        : DsPasswordTier.tooWeak;
  }

  var score = 0;
  if (met >= 4) score++;
  if (met == 5) score++;
  if (value.length >= 12) score++;
  if (value.length >= 16) score++;
  if (_hasRepeat(value)) score--;
  if (_hasSequence(value)) score--;
  score = score.clamp(0, 4);
  return switch (score) {
    0 || 1 => DsPasswordTier.weak,
    2 => DsPasswordTier.fair,
    3 => DsPasswordTier.good,
    _ => DsPasswordTier.strong,
  };
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

/// The strength word and colour for [value], resolved against [tokens].
///
/// An empty value returns an empty label. The colours come from the existing
/// danger and badge tokens, so the readout re-skins with the theme: too weak
/// and weak use the danger colour, fair the warning text colour, good and
/// strong the success text colour. [brandWords] is forwarded to
/// [dsPasswordTier].
({String label, Color color}) dsPasswordStrengthLabel(
  DsTokens tokens,
  String value, {
  Set<String> brandWords = const <String>{},
}) {
  if (value.isEmpty) return (label: '', color: tokens.colorDanger);
  return switch (dsPasswordTier(value, brandWords: brandWords)) {
    DsPasswordTier.tooWeak => (label: 'Too weak', color: tokens.colorDanger),
    DsPasswordTier.weak => (label: 'Weak', color: tokens.colorDanger),
    DsPasswordTier.fair => (label: 'Fair', color: tokens.badgeWarningColorText),
    DsPasswordTier.good => (label: 'Good', color: tokens.badgeSuccessColorText),
    DsPasswordTier.strong => (
      label: 'Strong',
      color: tokens.badgeSuccessColorText,
    ),
  };
}

/// How many of the three meter segments light up for [tier].
int _segmentsFilled(DsPasswordTier tier) => switch (tier) {
  DsPasswordTier.tooWeak || DsPasswordTier.weak => 1,
  DsPasswordTier.fair => 2,
  DsPasswordTier.good || DsPasswordTier.strong => 3,
};

/// A live password strength readout: a segmented meter and a rule checklist.
///
/// Pass the current [value]; the widget recomputes [dsPasswordRules] and
/// [dsPasswordTier] and renders a three-segment meter tinted by tier, the
/// strength word beneath it and a two-column checklist that marks each rule
/// as it is met. Every colour comes from [DsTokens], so it re-skins with the
/// theme. The meter bar is decorative for assistive technology; the strength
/// word and the checklist text carry the state.
class DsPasswordStrength extends StatelessWidget {
  /// Creates a password strength readout.
  const DsPasswordStrength({
    super.key,
    required this.value,
    this.showChecklist = true,
    this.brandWords = const <String>{},
  });

  /// The password being evaluated.
  final String value;

  /// Whether to show the per-rule checklist beneath the meter.
  final bool showChecklist;

  /// Brand names treated as guessable by [dsPasswordTier], matched without
  /// regard to case.
  final Set<String> brandWords;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final tier = dsPasswordTier(value, brandWords: brandWords);
    final rules = dsPasswordRules(value);
    final strength = dsPasswordStrengthLabel(
      tokens,
      value,
      brandWords: brandWords,
    );
    final filled = value.isEmpty ? 0 : _segmentsFilled(tier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The bar restates what the strength word says, so it is hidden from
        // assistive technology rather than announced twice.
        ExcludeSemantics(
          child: Row(
            children: <Widget>[
              for (var i = 0; i < 3; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: DsSpacing.xs),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i < filled ? strength.color : tokens.colorBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (value.isNotEmpty) ...<Widget>[
          const SizedBox(height: DsSpacing.xs),
          Text(
            strength.label,
            style: tokens.labelSm.toTextStyle(color: strength.color),
          ),
        ],
        if (showChecklist) ...<Widget>[
          const SizedBox(height: DsSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              // Two columns that always fill the available width. Without a
              // bounded width to split, the rules stack instead.
              if (!constraints.hasBoundedWidth) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final rule in rules)
                      Padding(
                        padding: const EdgeInsets.only(bottom: DsSpacing.xs),
                        child: _RuleRow(rule: rule),
                      ),
                  ],
                );
              }
              final itemWidth = ((constraints.maxWidth - DsSpacing.md) / 2)
                  .clamp(0.0, double.infinity);
              return Wrap(
                spacing: DsSpacing.md,
                runSpacing: DsSpacing.xs,
                children: <Widget>[
                  for (final rule in rules)
                    SizedBox(
                      width: itemWidth,
                      child: _RuleRow(rule: rule),
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

/// One checklist entry: a dot marker and the rule label.
class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.rule});

  final DsPasswordRule rule;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Row(
      children: <Widget>[
        _CheckDot(met: rule.met),
        const SizedBox(width: DsSpacing.sm),
        Expanded(
          child: Text(
            rule.label,
            style: tokens.bodySm.toTextStyle(
              color: rule.met ? tokens.colorText : tokens.colorSecondaryText,
            ),
          ),
        ),
      ],
    );
  }
}

/// The checklist marker: a filled check dot once the rule is met, an empty
/// outlined circle until then. The dot is decorative; the label's colour and
/// the check glyph pair up so the state never rests on colour alone.
class _CheckDot extends StatelessWidget {
  const _CheckDot({required this.met});

  final bool met;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Container(
      width: DsIconSize.md,
      height: DsIconSize.md,
      alignment: Alignment.center,
      decoration: met
          ? BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.badgeSuccessColorBackground,
              border: Border.all(color: tokens.badgeSuccessColorBorder),
            )
          : BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: tokens.colorBorder, width: 1.5),
            ),
      child: met
          ? Icon(
              DsIcons.check,
              size: DsIconSize.xxs,
              color: tokens.badgeSuccessColorText,
            )
          : null,
    );
  }
}

/// An inline warning shown while the password still needs work.
///
/// While one of the basic rules is unmet it restates the requirements in one
/// line. Once every rule is met but [dsPasswordTier] still grades the value
/// weak or below (a common word, a brand word or a predictable shape), it
/// swaps to guidance on avoiding guessable passwords. It renders nothing for
/// an empty value or a password graded fair or better, so it can sit
/// permanently beneath the meter.
class DsPasswordStrengthHint extends StatelessWidget {
  /// Creates a password guidance line.
  const DsPasswordStrengthHint({
    super.key,
    required this.value,
    this.brandWords = const <String>{},
  });

  /// The password being evaluated.
  final String value;

  /// Brand names treated as guessable by [dsPasswordTier], matched without
  /// regard to case.
  final Set<String> brandWords;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    final String? message;
    if (!dsPasswordMeetsAll(value)) {
      message =
          'Use at least 8 characters with upper- and lower-case '
          'letters, a number and a symbol.';
    } else {
      message = switch (dsPasswordTier(value, brandWords: brandWords)) {
        DsPasswordTier.tooWeak || DsPasswordTier.weak =>
          "Your password isn't strong enough. Avoid common words, names, "
              'dates and repeating characters to make it more secure.',
        _ => null,
      };
    }
    if (message == null) return const SizedBox.shrink();
    final tokens = DsTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(DsIcons.error, size: DsIconSize.sm, color: tokens.colorDanger),
        const SizedBox(width: DsSpacing.xs),
        Expanded(
          child: Text(
            message,
            style: tokens.bodySm.toTextStyle(color: tokens.colorDanger),
          ),
        ),
      ],
    );
  }
}
