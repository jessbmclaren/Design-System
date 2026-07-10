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

/// The overall strength of a password, beyond the basic rules.
enum DsPasswordTier {
  /// Fails one or more basic rules.
  tooWeak,

  /// Meets the rules but is short or predictable.
  weak,

  /// Meets the rules with modest length and variety.
  fair,

  /// A comfortably strong password.
  good,

  /// A long, varied password with no obvious pattern.
  strong,
}

const Set<String> _commonPasswords = <String>{
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
  'abc123',
  '12345678',
};

/// Grades [value] into a [DsPasswordTier]. Predictable passwords (a common
/// word, or the classic word plus number plus symbol shape) are graded down
/// even when they tick every box.
DsPasswordTier dsPasswordTier(String value) {
  if (!dsPasswordMeetsAll(value)) return DsPasswordTier.tooWeak;
  final lower = value.toLowerCase();
  final predictable = _commonPasswords.any(lower.contains);
  var score = 0;
  if (value.length >= 10) score++;
  if (value.length >= 14) score++;
  if (RegExp(r'[^A-Za-z0-9]').allMatches(value).length >= 2) score++;
  if (RegExp('[0-9]').allMatches(value).length >= 2) score++;
  if (predictable) score -= 2;
  if (score <= 0) return DsPasswordTier.weak;
  if (score == 1) return DsPasswordTier.fair;
  if (score == 2) return DsPasswordTier.good;
  return DsPasswordTier.strong;
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

/// A live password strength readout: a segmented meter and a rule checklist.
///
/// Pass the current [value]; the widget recomputes [dsPasswordRules] and
/// [dsPasswordTier] and renders a four-segment meter tinted by tier, above an
/// optional checklist that ticks each rule as it is met. Every colour comes
/// from [DsTokens], so it re-skins with the theme.
class DsPasswordStrength extends StatelessWidget {
  /// Creates a password strength readout.
  const DsPasswordStrength({
    super.key,
    required this.value,
    this.showChecklist = true,
  });

  /// The password being evaluated.
  final String value;

  /// Whether to show the per-rule checklist beneath the meter.
  final bool showChecklist;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final tier = dsPasswordTier(value);
    final rules = dsPasswordRules(value);

    final (Color color, String label, int filled) = switch (tier) {
      DsPasswordTier.tooWeak => (
          tokens.colorDanger,
          'Too weak',
          value.isEmpty ? 0 : 1,
        ),
      DsPasswordTier.weak => (tokens.colorDanger, 'Weak', 1),
      DsPasswordTier.fair => (tokens.badgeWarningColorText, 'Fair', 2),
      DsPasswordTier.good => (tokens.badgeSuccessColorText, 'Good', 3),
      DsPasswordTier.strong => (tokens.badgeSuccessColorText, 'Strong', 4),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (var i = 0; i < 4; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: DsSpacing.xs),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < filled ? color : tokens.colorBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (value.isNotEmpty) ...<Widget>[
          const SizedBox(height: DsSpacing.xs),
          Text(label, style: tokens.labelSm.toTextStyle(color: color)),
        ],
        if (showChecklist) ...<Widget>[
          const SizedBox(height: DsSpacing.sm),
          for (final rule in rules)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    rule.met ? DsIcons.success : DsIcons.close,
                    size: DsIconSize.xs,
                    color: rule.met
                        ? tokens.badgeSuccessColorText
                        : tokens.colorSecondaryText,
                  ),
                  const SizedBox(width: DsSpacing.xs),
                  Text(
                    rule.label,
                    style: tokens.bodySm.toTextStyle(
                      color: rule.met
                          ? tokens.colorText
                          : tokens.colorSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
