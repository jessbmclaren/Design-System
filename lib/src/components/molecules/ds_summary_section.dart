import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_link.dart';

/// A read-back panel: a titled section of entered values with a way back to
/// change them.
///
/// [DsSummarySection] is the shape a review step takes, where a flow shows
/// what the user typed before they commit. The title names the step, the
/// [onEdit] link returns to it, and [child] holds the values, usually a
/// column of label and value rows.
///
/// Keeping the edit affordance beside the title, rather than at the end of
/// the values, means a user scanning the review always finds the way back in
/// the same place.
///
/// ```dart
/// DsSummarySection(
///   title: 'Business details',
///   onEdit: () => goToStep(1),
///   child: Column(children: rows),
/// )
/// ```
class DsSummarySection extends StatelessWidget {
  /// Creates a read-back panel.
  const DsSummarySection({
    super.key,
    required this.title,
    required this.child,
    this.onEdit,
    this.editLabel = 'Edit',
  });

  /// The name of the step or section being read back.
  final String title;

  /// The values, typically a column of label and value rows.
  final Widget child;

  /// Called when the edit affordance is chosen. Null hides it, for a section
  /// that cannot be changed from here.
  final VoidCallback? onEdit;

  /// The edit affordance's label.
  final String editLabel;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;

    return Container(
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        border: Border.all(color: tokens.colorBorder),
        borderRadius: BorderRadius.circular(tokens.formBorderRadius),
      ),
      padding: EdgeInsets.all(unit * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style:
                        tokens.headingSm.toTextStyle(color: tokens.colorText),
                  ),
                ),
              ),
              if (onEdit != null) ...<Widget>[
                SizedBox(width: unit),
                DsLink(
                  label: editLabel,
                  small: true,
                  onPressed: onEdit,
                  // The link names what it edits, so a screen reader moving
                  // between sections never meets a row of bare Edit links.
                  semanticLabel: '$editLabel $title',
                ),
              ],
            ],
          ),
          SizedBox(height: unit * 1.5),
          child,
        ],
      ),
    );
  }
}
