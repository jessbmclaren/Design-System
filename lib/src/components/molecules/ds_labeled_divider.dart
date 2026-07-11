import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_divider.dart';

/// A horizontal rule with a centred label.
///
/// A [DsDivider] runs to each side of a short caption, which sits in the
/// secondary text colour. Use it to break a form or list into labelled
/// sections without the weight of a heading, for example an "Or sign in with"
/// separator above a set of alternative actions.
class DsLabeledDivider extends StatelessWidget {
  /// Creates a labelled divider.
  const DsLabeledDivider({super.key, required this.label});

  /// The caption shown between the two rules.
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Row(
      children: <Widget>[
        const Expanded(child: DsDivider()),
        Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacingUnit),
            child: Text(
              label,
              style:
                  tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Expanded(child: DsDivider()),
      ],
    );
  }
}
