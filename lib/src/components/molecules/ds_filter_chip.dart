import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_chip.dart';

/// A single selectable option offered by a [DsFilterChip].
///
/// [value] is the payload reported through [DsFilterChip.onChanged] when the
/// option is chosen; [label] is the human-readable text shown in the menu and,
/// once selected, inside the active chip.
@immutable
class DsFilterOption<T> {
  /// Creates an option pairing a [value] with its display [label].
  const DsFilterOption({required this.value, required this.label});

  /// The value reported when this option is selected.
  final T value;

  /// The text shown for this option.
  final String label;
}

/// A filter control chip with two states, used above tables to filter rows.
///
/// The chip has two visual states driven entirely by [value]:
///
///  * **Suggested** ([value] is null): an outlined pill showing the filter
///    [label] with a trailing add icon. Tapping the pill opens a menu of
///    [options]; choosing one reports its value through [onChanged].
///  * **Active** ([value] is non-null): a filled pill showing
///    `"<label>: <selected option label>"` with a trailing clear icon. Tapping
///    the clear icon reports null through [onChanged]. The body of an active
///    chip does not reopen the menu, avoiding a gesture conflict with the clear
///    affordance; clear first, then pick again.
///
/// Place several [DsFilterChip]s in a [Wrap] above a table so they reflow
/// gracefully from a 320dp phone up to a wide desktop.
///
/// The generic parameter [T] is the type of each option's value, letting the
/// chip carry enums, ids or any domain value without stringly-typed lookups.
class DsFilterChip<T> extends StatelessWidget {
  /// Creates a filter chip.
  const DsFilterChip({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  /// The name of the filter, for example `"Status"`.
  final String label;

  /// The options offered when the chip is in its suggested state.
  final List<DsFilterOption<T>> options;

  /// The currently selected value, or null for the suggested state.
  final T? value;

  /// Called with the chosen value when an option is picked, or null when the
  /// active chip is cleared.
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final isActive = value != null;

    if (!isActive) {
      return PopupMenuButton<T>(
        tooltip: label,
        position: PopupMenuPosition.under,
        onSelected: onChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
        ),
        itemBuilder: (context) => [
          for (final option in options)
            PopupMenuItem<T>(
              value: option.value,
              child: Text(
                option.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: tokens.colorText),
              ),
            ),
        ],
        child: DsChip(
          label: label,
          textColor: tokens.colorSecondaryText,
          borderColor: tokens.colorBorder,
          trailing: Icon(
            Icons.add,
            size: tokens.badgeLabelFontSize + 2,
            color: tokens.colorSecondaryText,
          ),
        ),
      );
    }

    final selected = _selectedLabel();
    final activeLabel = selected == null ? label : '$label: $selected';

    return Semantics(
      button: true,
      label: activeLabel,
      child: DsChip(
        label: activeLabel,
        backgroundColor: tokens.formBackgroundColor,
        borderColor: tokens.formAccentColor,
        textColor: tokens.colorText,
        trailing: _ClearButton(
          color: tokens.colorText,
          size: tokens.badgeLabelFontSize + 2,
          tooltip: 'Clear $label',
          onTap: () => onChanged(null),
        ),
      ),
    );
  }

  String? _selectedLabel() {
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return null;
  }
}

/// The trailing clear affordance of an active [DsFilterChip].
///
/// Kept private: it wires an [InkResponse] around a close icon so that tapping
/// only the icon clears the filter, without the surrounding pill absorbing the
/// gesture.
class _ClearButton extends StatelessWidget {
  const _ClearButton({
    required this.color,
    required this.size,
    required this.tooltip,
    required this.onTap,
  });

  final Color color;
  final double size;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: size,
          child: Icon(Icons.close, size: size, color: color),
        ),
      ),
    );
  }
}
