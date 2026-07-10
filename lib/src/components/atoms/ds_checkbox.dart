import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../util/ds_motion.dart';

/// A labelled checkbox.
///
/// Use a [DsCheckbox] for an independent on/off choice, such as accepting terms
/// or toggling a single option. For a set of mutually exclusive options prefer a
/// radio group instead.
///
/// The control renders a small square that is empty when unchecked and filled
/// with the theme's [DsTokens.formAccentColor] and a white check when checked.
/// Provide a [label] to render tappable text beside the box; the entire row is
/// then a single tap target that toggles the value. A null [onChanged] disables
/// the control and dims it. Set [isError] to colour the border with
/// [DsTokens.colorDanger] when the surrounding form field is invalid.
///
/// The whole control exposes a semantics node describing its checked, enabled
/// and label state, and always presents at least a 48dp tap target for
/// accessible touch.
class DsCheckbox extends StatelessWidget {
  /// Creates a labelled checkbox.
  const DsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.isError = false,
  });

  /// Whether the checkbox is currently checked.
  final bool value;

  /// Called with the new value when the control is tapped. A null callback
  /// disables the checkbox.
  final ValueChanged<bool>? onChanged;

  /// Optional text rendered to the right of the box. The whole row is tappable.
  final String? label;

  /// Whether the field is in an error state, which colours the box border with
  /// the theme's danger colour.
  final bool isError;

  static const double _boxSize = 18;
  static const double _minTapTarget = 48;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final enabled = onChanged != null;

    final Color borderColor;
    if (isError) {
      borderColor = tokens.colorDanger;
    } else if (value) {
      borderColor = tokens.formAccentColor;
    } else {
      borderColor = tokens.colorBorder;
    }

    final box = AnimatedContainer(
      duration: DsMotion.durationOf(context, const Duration(milliseconds: 150)),
      curve: DsMotion.curveOf(context, Curves.easeOut),
      width: _boxSize,
      height: _boxSize,
      decoration: BoxDecoration(
        color: value ? tokens.formAccentColor : tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: value
          ? const Icon(
              Icons.check,
              size: DsIconSize.xs,
              color: Colors.white,
            )
          : null,
    );

    Widget content = box;
    if (label != null) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label!,
              style: tokens.bodyMd.toTextStyle(color: tokens.colorText),
            ),
          ),
        ],
      );
    }

    final control = Opacity(
      opacity: enabled ? 1 : 0.5,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minTapTarget),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: content,
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      checked: value,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: enabled ? () => onChanged!(!value) : null,
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          child: control,
        ),
      ),
    );
  }
}
