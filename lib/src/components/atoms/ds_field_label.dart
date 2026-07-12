import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// A form field label.
///
/// [DsFieldLabel] is the caption that names a form control. [DsTextField] and
/// its siblings render it above the input for you, but it is exposed as its own
/// atom for the cases a field cannot own its label: a label that shares its row
/// with an inline action (a "Forgot password?" link beside "Password"), or a
/// bespoke control that still needs a caption consistent with the rest of the
/// system.
///
/// Set [optional] to append a subdued "Optional" marker after the label text.
/// Mark the optional fields rather than the required ones: most fields in a
/// form should be required, so the quieter exception carries the annotation.
class DsFieldLabel extends StatelessWidget {
  /// Creates a form field label.
  const DsFieldLabel({super.key, required this.label, this.optional = false});

  /// The label text.
  final String label;

  /// Whether to render a subdued "Optional" marker after the label.
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final Widget text = Text(
      label,
      style: tokens.labelMd.toTextStyle(color: tokens.colorText).copyWith(
            fontWeight: tokens.mediumLabelFontWeight,
          ),
    );
    if (!optional) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Flexible(child: text),
        SizedBox(width: tokens.spacingUnit),
        Text(
          'Optional',
          style: tokens.labelSm.toTextStyle(color: tokens.colorSecondaryText),
        ),
      ],
    );
  }
}
