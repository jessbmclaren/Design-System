import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// One labelled value on a record: "Tank capacity — 80 litres".
///
/// The row a detail view is built out of, and the counterpart to the form
/// field that captured the value. A product that can enter a field but never
/// show it again has captured it for nobody, so this is the other half of
/// every input the system offers.
///
/// The label sits left in a muted column with a floor under its width, so
/// stacked rows line their values up without a table's machinery. The value
/// flexes and wraps — long ones are the common case on a narrow panel, and a
/// value that overflows is worse than one that takes two lines.
///
/// **A blank reads as a deliberate blank.** An absent value renders an em dash
/// rather than collapsing the row, because a record that silently omits what it
/// does not know looks identical to one that was never asked.
///
/// Pass [valueWidget] for a value that is not text — a badge, a chip, a link.
/// It wins over [value] when both are given.
///
/// Deliberately **not a control**: compact density with no 48dp floor, no
/// button semantics, and the pair merged into one node so assistive tech reads
/// "Tank capacity, 80 litres" as a phrase rather than two stops. Where a row
/// does need to be actionable, put the affordance in [valueWidget] so the
/// tappable thing is the value, not the whole row.
///
/// ```dart
/// DsKeyValueRow(label: 'Fuel type', value: 'Diesel')
/// DsKeyValueRow(label: 'VIN', value: null)                 // renders —
/// DsKeyValueRow(label: 'Status', valueWidget: DsBadge(...))
/// DsKeyValueRow(label: 'Fleet number', value: 'FL-014', hint: 'Optional')
/// ```
class DsKeyValueRow extends StatelessWidget {
  /// Creates a labelled value row.
  const DsKeyValueRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.mandatory = false,
    this.hint,
    this.labelWidth,
  });

  /// What the value is, shown muted in the left column.
  final String label;

  /// The value. Null or blank renders an em dash.
  final String? value;

  /// A value that is not text — a badge, a chip, a link. Wins over [value].
  final Widget? valueWidget;

  /// Marks the field as required, with an asterisk in the danger colour.
  ///
  /// Only meaningful where the row sits beside an edit affordance; on a
  /// read-only record it tells someone which blanks will block them later.
  final bool mandatory;

  /// A parenthesised aside after the value — "(Optional)", "(At fill)".
  final String? hint;

  /// Overrides the label column's width.
  ///
  /// A **fixed** width, not a floor: a floor lets a long label push its own
  /// value out of line with its neighbours, which is the one thing a column of
  /// these has to get right. A label too long for the column wraps inside it
  /// and the values stay where they are.
  ///
  /// Rows in the same section must share this value or they will not align.
  /// The default fits two words at the label size.
  final double? labelWidth;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;

    final TextStyle labelStyle =
        tokens.labelSm.toTextStyle(color: tokens.colorSecondaryText);
    final TextStyle valueStyle = tokens.bodySm.toTextStyle(
      color: tokens.colorText,
    );
    final TextStyle mutedStyle = tokens.bodySm.toTextStyle(
      color: tokens.colorSecondaryText,
    );

    final bool hasValue = value != null && value!.trim().isNotEmpty;

    // A text value carries its hint inside the same span, so the parenthesis
    // flows after a wrapped value instead of stranding itself on a line.
    final Widget valueContent;
    if (valueWidget != null) {
      valueContent = hint == null
          ? valueWidget!
          : Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: unit * 0.75,
              runSpacing: unit * 0.5,
              children: <Widget>[
                valueWidget!,
                Text('($hint)', style: mutedStyle),
              ],
            );
    } else {
      valueContent = Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: hasValue ? value : '—',
              style: hasValue ? valueStyle : mutedStyle,
            ),
            if (hint != null) TextSpan(text: ' ($hint)', style: mutedStyle),
          ],
        ),
      );
    }

    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: unit * 0.75),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: labelWidth ?? unit * 16,
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: labelStyle,
                  children: <InlineSpan>[
                    if (mandatory)
                      TextSpan(
                        text: ' *',
                        style: labelStyle.copyWith(color: tokens.colorDanger),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(width: unit * 2),
            Expanded(child: valueContent),
          ],
        ),
      ),
    );
  }
}
