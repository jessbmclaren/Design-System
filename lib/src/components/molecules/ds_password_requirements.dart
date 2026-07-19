import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_check_dot.dart';
import 'ds_password_strength.dart' show DsPasswordRule, dsPasswordRules;

/// A live checklist of the rules a password has to meet.
///
/// This is the checklist on its own, without the meter and strength word that
/// [DsPasswordStrength] wraps around it. Reach for it when the checklist should
/// be the *only* feedback on the screen: with one authority a "requirement not
/// met" and a "looks strong" can never contradict each other, which is a
/// contradiction a meter sitting beside a rule list invites.
///
/// Rows have two readings while someone types: neutral (not satisfied yet) and
/// ticked. **Nothing here turns red as you type.** Set [attempted] once a
/// submit has been refused and the still-unmet rows take the error colour;
/// until then a half-finished password is simply half-finished, not wrong.
///
/// Pass the current [value] and the rows recompute on every keystroke. By
/// default it renders [dsPasswordRules]; pass [rules] to group or reword them
/// (several rules read better as one line, such as an upper- and a lower-case
/// letter), and [extraRules] to append checks the caller owns, such as whether
/// the password appears in a known breach.
///
/// The list is one live region rather than one per row, so assistive
/// technology hears the set re-read as it changes instead of several
/// announcements racing on every keystroke. Each row still carries its own
/// checked state.
///
/// {@tool snippet}
///
/// ```dart
/// DsPasswordRequirements(
///   value: password,
///   attempted: submitRefused,
///   extraRules: <DsPasswordRule>[
///     DsPasswordRule('Not found in known data breaches', !breached),
///   ],
/// )
/// ```
///
/// {@end-tool}
class DsPasswordRequirements extends StatelessWidget {
  /// Creates a password requirements checklist.
  const DsPasswordRequirements({
    super.key,
    required this.value,
    this.attempted = false,
    this.rules,
    this.extraRules = const <DsPasswordRule>[],
    this.itemWidth,
  });

  /// The password being checked.
  final String value;

  /// Whether a submit has already been refused. While false the unmet rows
  /// stay neutral; while true they read in the error colour.
  final bool attempted;

  /// The rules to render, overriding [dsPasswordRules]. Use it to present the
  /// standard rules grouped or reworded. The widget does not evaluate these:
  /// the caller decides what each one means and whether it is met.
  final List<DsPasswordRule>? rules;

  /// Extra rows appended after [rules], for checks the design system does not
  /// own (a breach lookup, a policy the product adds).
  final List<DsPasswordRule> extraRules;

  /// A fixed width for each row, which lays the rows out in a wrapping grid.
  /// Leave it null for a single full-width column.
  final double? itemWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final resolved = <DsPasswordRule>[
      ...rules ?? dsPasswordRules(value),
      ...extraRules,
    ];

    final rows = <Widget>[
      for (final rule in resolved)
        DsPasswordRequirementRow(rule: rule, attempted: attempted),
    ];

    // One live region around the set, not one per row.
    return Semantics(
      container: true,
      liveRegion: true,
      child: itemWidth == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (var i = 0; i < rows.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: tokens.spacingUnit * 0.75),
                  rows[i],
                ],
              ],
            )
          : Wrap(
              spacing: tokens.spacingUnit * 1.5,
              runSpacing: tokens.spacingUnit / 2,
              children: <Widget>[
                for (final row in rows) SizedBox(width: itemWidth, child: row),
              ],
            ),
    );
  }
}

/// One checklist entry: a [DsCheckDot] and the rule's label.
///
/// Exposed so a caller composing its own list keeps the same row treatment;
/// most callers want [DsPasswordRequirements] instead.
class DsPasswordRequirementRow extends StatelessWidget {
  /// Creates a checklist row for [rule].
  const DsPasswordRequirementRow({
    super.key,
    required this.rule,
    this.attempted = false,
  });

  /// The rule this row reports.
  final DsPasswordRule rule;

  /// Whether a submit has already been refused, which turns an unmet row into
  /// an error rather than an unfinished one.
  final bool attempted;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final emphasiseError = attempted && !rule.met;
    final Color labelColor = rule.met
        ? tokens.colorText
        : emphasiseError
        ? tokens.colorDanger
        : tokens.colorSecondaryText;

    // The row reads as one node carrying its checked state, so assistive
    // technology hears whether the rule is met rather than a bare label.
    return Semantics(
      container: true,
      checked: rule.met,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DsCheckDot(
            met: rule.met,
            unmetTone: emphasiseError
                ? DsCheckDotTone.danger
                : DsCheckDotTone.neutral,
          ),
          SizedBox(width: tokens.spacingUnit),
          Expanded(
            child: Text(
              rule.label,
              style: tokens.bodySm.toTextStyle(color: labelColor),
            ),
          ),
        ],
      ),
    );
  }
}
