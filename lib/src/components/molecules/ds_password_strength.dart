import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../../util/ds_motion.dart';
import 'ds_password_requirements.dart';

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

// Hoisted so per-keystroke grading does not recompile them. The letter
// classes are unicode-aware, so a Cyrillic or Greek capital counts as an
// uppercase letter, and a special character is anything that is neither a
// letter nor a number.
final RegExp _upperCaseLetter = RegExp(r'\p{Lu}', unicode: true);
final RegExp _lowerCaseLetter = RegExp(r'\p{Ll}', unicode: true);
final RegExp _digit = RegExp('[0-9]');
final RegExp _specialCharacter = RegExp(r'[^\p{L}\p{N}]', unicode: true);

/// The standard password rule set, in display order.
///
/// The letter rules recognise any script, not just Latin, and the special
/// character rule matches anything that is neither a letter nor a number.
/// Length counts user-perceived characters (grapheme clusters), so an emoji
/// counts once. Whitespace is a character like any other: spaces satisfy the
/// special character rule and a whitespace-only value is graded on its own
/// merits rather than treated as empty, so trim input first if your form
/// forbids it.
List<DsPasswordRule> dsPasswordRules(String value) => <DsPasswordRule>[
  DsPasswordRule('At least 8 characters', value.characters.length >= 8),
  DsPasswordRule('One uppercase letter', _upperCaseLetter.hasMatch(value)),
  DsPasswordRule('One lowercase letter', _lowerCaseLetter.hasMatch(value)),
  DsPasswordRule('One number', _digit.hasMatch(value)),
  DsPasswordRule('One special character', _specialCharacter.hasMatch(value)),
];

/// Whether [value] satisfies every rule in [dsPasswordRules].
bool dsPasswordMeetsAll(String value) =>
    dsPasswordRules(value).every((rule) => rule.met);

/// The messages for [dsFirstUnmetPasswordRule], one per rule in
/// [dsPasswordRules] and in the same order.
///
/// Each names its rule with the same word the rule's own label uses — a
/// checklist row reading "One uppercase letter" beside a caption asking for a
/// "capital letter" reads as two requirements rather than one, and a form is
/// free to show both at once. One voice, and no trailing full stops, so the
/// five sit together as a set.
const List<String> _unmetRuleMessages = <String>[
  'Please use at least 8 characters',
  'Please use at least one uppercase letter',
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
// guessable. The word part is capped at 24 letters: beyond that the value
// reads as a passphrase rather than a guessable single word, so the penalty
// no longer applies.
final RegExp _wordNumberSymbol = RegExp(
  r'^[A-Za-z]{1,24}[0-9]{1,4}[^A-Za-z0-9]{0,3}$',
);

/// Whether [value] is predictable enough to refuse outright.
///
/// True for a common word, a word from [brandWords], the "word then a few
/// digits then a symbol" shape (Bridge2024!), three or more of the same
/// character in a row, and a deliberate keyboard or alphabet run of four or
/// more (abcd, 1234, asdf).
///
/// This is the boolean gate a form needs when length and a breach check are
/// doing the rest of the work — the arrangement current guidance points at,
/// where character-class rules give way to refusing the guessable.
/// [dsPasswordTier] weighs the same signals differently: a five-level grade can
/// afford to treat a keyboard run as a deduction, where a gate cannot. Both
/// read the same underlying checks, so neither can drift from the other's idea
/// of what is guessable.
///
/// Pass [brandWords] to refuse a password built on the product's own name,
/// which is as guessable as any dictionary word and the first thing anyone
/// tries. Matching lowercases both sides, so list locale-specific spelling
/// variants (straße and strasse) separately.
bool dsPasswordIsPredictable(
  String value, {
  Set<String> brandWords = const <String>{},
}) {
  if (value.isEmpty) return false;
  final lower = value.toLowerCase();
  return _commonWords.any(lower.contains) ||
      brandWords.any(
        (word) => word.isNotEmpty && lower.contains(word.toLowerCase()),
      ) ||
      _wordNumberSymbol.hasMatch(value) ||
      _hasRepeat(value) ||
      _hasSequence(value);
}

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
/// case-insensitive by lowercasing both sides, which cannot round-trip
/// locale-specific uppercasings (STRASSE is the capital form of straße but
/// lowercases to strasse), so list spelling variants such as straße and
/// strasse as separate entries. Length thresholds count user-perceived
/// characters (grapheme clusters), matching [dsPasswordRules].
DsPasswordTier dsPasswordTier(
  String value, {
  Set<String> brandWords = const <String>{},
}) {
  if (value.isEmpty) return DsPasswordTier.tooWeak;
  final int length = value.characters.length;
  final met = dsPasswordRules(value).where((rule) => rule.met).length;
  if (met < 3 || length < 8) return DsPasswordTier.tooWeak;

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
    return (length >= 14 && met == 5)
        ? DsPasswordTier.weak
        : DsPasswordTier.tooWeak;
  }

  var score = 0;
  if (met >= 4) score++;
  if (met == 5) score++;
  if (length >= 12) score++;
  if (length >= 16) score++;
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
/// An empty value returns an empty label. The colours come from the bright
/// signal tier, so the readout re-skins with the theme: too weak and weak use
/// the danger colour, fair uses [DsTokens.colorWarning], good and strong use
/// [DsTokens.colorSuccess]. [brandWords] is forwarded to [dsPasswordTier].
({String label, Color color}) dsPasswordStrengthLabel(
  DsTokens tokens,
  String value, {
  Set<String> brandWords = const <String>{},
}) {
  if (value.isEmpty) return (label: '', color: tokens.colorDanger);
  return switch (dsPasswordTier(value, brandWords: brandWords)) {
    DsPasswordTier.tooWeak => (label: 'Too weak', color: tokens.colorDanger),
    DsPasswordTier.weak => (label: 'Weak', color: tokens.colorDanger),
    DsPasswordTier.fair => (label: 'Fair', color: tokens.colorWarning),
    DsPasswordTier.good => (label: 'Good', color: tokens.colorSuccess),
    DsPasswordTier.strong => (label: 'Strong', color: tokens.colorSuccess),
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
/// word is a live region so tier changes are announced as the user types, and
/// each checklist row exposes its met state as a checked flag.
class DsPasswordStrength extends StatelessWidget {
  /// Creates a password strength readout.
  const DsPasswordStrength({
    super.key,
    required this.value,
    this.showChecklist = true,
    this.brandWords = const <String>{},
  });

  /// The width the readout falls back to when its host provides none (a Row
  /// or a horizontal list), so the meter segments and rule rows have
  /// something to fill.
  static const double _fallbackWidth = 240;

  /// The narrowest column (before text scaling) that still fits a rule label
  /// without wrapping it over several lines. Below it the checklist collapses
  /// to a single column.
  static const double _minChecklistItemWidth = 140;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final Widget readout = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // The bar restates what the strength word says, so it is hidden
            // from assistive technology rather than announced twice.
            ExcludeSemantics(
              child: Row(
                children: <Widget>[
                  for (var i = 0; i < 3; i++) ...<Widget>[
                    if (i > 0) SizedBox(width: tokens.spacingUnit / 2),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: i < filled
                              ? strength.color
                              : tokens.colorBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (value.isNotEmpty) ...<Widget>[
              SizedBox(height: tokens.spacingUnit / 2),
              // A live region so assistive technology announces the tier as
              // it changes under the user's typing.
              Semantics(
                container: true,
                liveRegion: true,
                child: Text(
                  strength.label,
                  style: tokens.labelSm.toTextStyle(color: strength.color),
                ),
              ),
            ],
            if (showChecklist) ...<Widget>[
              SizedBox(height: tokens.spacingUnit),
              _Checklist(value: value, rules: rules),
            ],
          ],
        );
        // The meter segments and rule rows split whatever width the host
        // provides; a host with none to offer (a Row, a horizontal list)
        // gets a fixed-width readout instead of a failed layout.
        if (constraints.hasBoundedWidth) return readout;
        return SizedBox(width: _fallbackWidth, child: readout);
      },
    );
  }
}

/// The rule checklist: two columns where each fits a label at the ambient
/// text scale, one column otherwise.
///
/// The rows themselves are [DsPasswordRequirements], so the meter's checklist
/// and a standalone one are the same code. This wrapper only decides how many
/// columns the available width affords.
class _Checklist extends StatelessWidget {
  const _Checklist({required this.value, required this.rules});

  final String value;
  final List<DsPasswordRule> rules;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth =
            (constraints.maxWidth - tokens.spacingUnit * 1.5) / 2;
        // Two columns only when each is wide enough for a rule label at the
        // ambient text scale; otherwise one column keeps each rule on a line
        // or two instead of wrapping into a tall sliver.
        final double minItemWidth = MediaQuery.textScalerOf(
          context,
        ).scale(DsPasswordStrength._minChecklistItemWidth);
        return DsPasswordRequirements(
          value: value,
          // Already computed one level up, so they are passed through rather
          // than graded a second time on every keystroke.
          rules: rules,
          itemWidth: itemWidth < minItemWidth ? null : itemWidth,
        );
      },
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
/// permanently beneath the meter. The message is a polite live region, and
/// the hint resizes through an [AnimatedSize] (immediate under reduced
/// motion) so the form beneath it does not jump.
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
    String? message;
    if (value.isEmpty) {
      message = null;
    } else if (!dsPasswordMeetsAll(value)) {
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
    final Widget child;
    if (message == null) {
      child = const SizedBox.shrink();
    } else {
      final tokens = DsTokens.of(context);
      // A live region: the warning swaps in under the user's typing, so it
      // is announced without stealing focus.
      child = Semantics(
        container: true,
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(DsIcons.error, size: tokens.iconSizeSm, color: tokens.colorDanger),
            SizedBox(width: tokens.spacingUnit / 2),
            Expanded(
              child: Text(
                message,
                style: tokens.bodySm.toTextStyle(color: tokens.colorDanger),
              ),
            ),
          ],
        ),
      );
    }
    // The hint grows and collapses smoothly so the form beneath it does not
    // jump. Under reduced motion the wrapper is skipped for an immediate
    // resize: an AnimatedSize must not be given Duration.zero, as a
    // zero-length animation completes during its own layout pass.
    if (DsMotion.reduced(context)) return child;
    return AnimatedSize(
      duration: DsMotion.base,
      curve: DsMotion.standard,
      alignment: Alignment.topCenter,
      child: child,
    );
  }
}
