import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_field_label.dart';
import '../atoms/ds_radio.dart';

/// One option offered by a [DsRadioGroup], binding a [value] to its [label].
@immutable
class DsRadioOption<T> {
  /// Creates a radio option.
  const DsRadioOption({required this.value, required this.label});

  /// The value reported when this option is chosen.
  final T value;

  /// The text shown beside the option's indicator.
  final String label;
}

/// A single-select list of radio rows: pick exactly one from a short list with
/// every option shown in full.
///
/// [DsRadioGroup] stacks one [DsRadio] per option and reports the chosen value
/// through [onChanged]. Reach for it — rather than a [DsSelect] dropdown — when
/// the choices are few and worth seeing at a glance (a role, a plan, a
/// delivery speed): laying them out flat trades a little height for a decision
/// the reader can make without opening a menu.
///
/// It is controlled: the parent owns [value] and updates it in [onChanged]. An
/// optional [label] renders a [DsFieldLabel] above the list, and an [errorText]
/// renders beneath it in the danger colour for a group that must not be left
/// empty. Each row is its own radio to assistive technology and announces the
/// group as mutually exclusive, so the group adds no wrapper of its own beyond
/// the label and error message.
///
/// ```dart
/// DsRadioGroup<Role>(
///   label: 'What is your role?',
///   options: const [
///     DsRadioOption(value: Role.owner, label: 'Founder / owner'),
///     DsRadioOption(value: Role.ops, label: 'Operations'),
///   ],
///   value: role,
///   onChanged: (next) => setState(() => role = next),
/// )
/// ```
class DsRadioGroup<T> extends StatelessWidget {
  /// Creates a single-select radio list.
  const DsRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.errorText,
    this.enabled = true,
  });

  /// The choices offered, in display order.
  final List<DsRadioOption<T>> options;

  /// The currently selected value, or null when nothing is chosen yet.
  final T? value;

  /// Called with the chosen value whenever a row is tapped. Null leaves every
  /// row inert.
  final ValueChanged<T?>? onChanged;

  /// An optional field label rendered above the list.
  final String? label;

  /// An error message shown beneath the list, for example when the group
  /// requires a choice.
  final String? errorText;

  /// Whether the group accepts interaction.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;
    final bool isEnabled = enabled && onChanged != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null) ...<Widget>[
          DsFieldLabel(label: label!),
          SizedBox(height: unit),
        ],
        for (final DsRadioOption<T> option in options)
          DsRadio<T>(
            value: option.value,
            groupValue: value,
            label: option.label,
            onChanged: isEnabled ? onChanged : null,
          ),
        if (errorText != null) ...<Widget>[
          SizedBox(height: unit),
          Text(
            errorText!,
            style: tokens.bodySm.toTextStyle(color: tokens.colorDanger),
          ),
        ],
      ],
    );
  }
}
