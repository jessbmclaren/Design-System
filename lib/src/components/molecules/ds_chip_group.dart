import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_choice_chip.dart';

/// One option offered by a [DsChipGroup], binding a [value] to its [label].
@immutable
class DsChipOption<T> {
  /// Creates a chip option.
  const DsChipOption({required this.value, required this.label});

  /// The value reported when this option is chosen.
  final T value;

  /// The text shown on the chip.
  final String label;
}

/// A multi-select set of chips: pick any number from a short list.
///
/// [DsChipGroup] wraps a row of [DsChoiceChip]s and reports the whole
/// selection each time one is toggled, so the caller keeps a single set
/// rather than tracking chips. Use it where a handful of small choices read
/// better inline than as a list of checkboxes: days of the week, capabilities,
/// tags.
///
/// It is controlled and immutable about its value: each toggle reports a new
/// set rather than mutating the one it was given, so a caller comparing the
/// old and new sets always sees a change. An [errorText] renders beneath the
/// chips in the danger colour, for a group that must not be left empty.
///
/// Each chip is its own checkbox to assistive technology, so the group adds
/// no wrapper of its own beyond the error message.
///
/// ```dart
/// DsChipGroup<Day>(
///   options: const [
///     DsChipOption(value: Day.monday, label: 'Monday'),
///     DsChipOption(value: Day.tuesday, label: 'Tuesday'),
///   ],
///   selected: days,
///   onChanged: (next) => setState(() => days = next),
/// )
/// ```
class DsChipGroup<T> extends StatelessWidget {
  /// Creates a multi-select chip set.
  const DsChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  /// The choices offered, in display order.
  final List<DsChipOption<T>> options;

  /// The values currently chosen.
  final Set<T> selected;

  /// Called with the whole new selection whenever a chip is toggled. Null
  /// leaves every chip inert.
  final ValueChanged<Set<T>>? onChanged;

  /// An error message shown beneath the chips, for example when the group
  /// requires at least one choice.
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
        Wrap(
          spacing: unit,
          runSpacing: unit,
          children: <Widget>[
            for (final DsChipOption<T> option in options)
              DsChoiceChip(
                label: option.label,
                selected: selected.contains(option.value),
                enabled: enabled,
                onSelected: isEnabled
                    ? (bool next) {
                        // A new set every time: the caller can compare the
                        // old and new values without a defensive copy.
                        final Set<T> updated = Set<T>.of(selected);
                        if (next) {
                          updated.add(option.value);
                        } else {
                          updated.remove(option.value);
                        }
                        onChanged!(updated);
                      }
                    : null,
              ),
          ],
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
