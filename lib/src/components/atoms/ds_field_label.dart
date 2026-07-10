import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_typography.dart';

/// A form field label.
///
/// [DsFieldLabel] is the caption that names a form control. [DsTextField] and
/// its siblings render it above the input for you, but it is exposed as its own
/// atom for the cases a field cannot own its label: a label that shares its row
/// with an inline action (a "Forgot password?" link beside "Password"), or a
/// bespoke control that still needs a caption consistent with the rest of the
/// system.
class DsFieldLabel extends StatelessWidget {
  /// Creates a form field label.
  const DsFieldLabel({super.key, required this.label});

  /// The label text.
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Text(
      label,
      style: tokens.labelMd.toTextStyle(color: tokens.colorText).copyWith(
            fontWeight: DsTypography.medium,
          ),
    );
  }
}
