import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_typography.dart';

/// A single choice within a [DsSelect].
///
/// Pairs the underlying [value] the control reports through its
/// `onChanged` callback with the human-readable [label] shown in the menu and
/// in the closed field.
@immutable
class DsSelectOption<T> {
  /// Creates an option binding a [value] to a display [label].
  const DsSelectOption({required this.value, required this.label});

  /// The value reported when this option is selected.
  final T value;

  /// The text shown for this option, both in the open menu and once selected.
  final String label;
}

/// A labelled dropdown select, generic over the selected value type [T].
///
/// `DsSelect` mirrors the look of the design system's text field: an optional
/// [label] sits above a filled, outlined control that opens a menu of
/// [options]. Selecting an option reports its `value` through [onChanged]; the
/// closed field shows that option's label, or the [hintText] placeholder while
/// [value] is `null`.
///
/// Use it whenever a user must pick exactly one value from a known, bounded
/// list — a country, a status, a currency — where a set of radio buttons would
/// take too much room. For free-form entry use a text field instead; for
/// multi-select, use a different control.
///
/// All colours, spacing, radii and typography are read from [DsTokens], so the
/// control re-brands with the active theme and never hardcodes appearance.
///
/// ```dart
/// DsSelect<String>(
///   label: 'Country',
///   value: selected,
///   hintText: 'Select a country',
///   options: const [
///     DsSelectOption(value: 'us', label: 'United States'),
///     DsSelectOption(value: 'be', label: 'Belgium'),
///   ],
///   onChanged: (value) => setState(() => selected = value),
/// )
/// ```
class DsSelect<T> extends StatelessWidget {
  /// Creates a labelled dropdown select.
  ///
  /// [value] is the currently selected value (or `null` for none) and must
  /// match the `value` of one of the [options], or be `null`. [onChanged] is
  /// called with the newly picked value; passing `null` — or setting [enabled]
  /// to `false` — renders the control disabled.
  const DsSelect({
    super.key,
    this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hintText,
    this.errorText,
    this.enabled = true,
  });

  /// Optional text shown above the field, describing what is being chosen.
  final String? label;

  /// The currently selected value, or `null` when nothing is selected.
  ///
  /// Must equal the [DsSelectOption.value] of exactly one entry in [options],
  /// or be `null`.
  final T? value;

  /// The choices offered in the dropdown menu.
  final List<DsSelectOption<T>> options;

  /// Called with the newly selected value when the user picks an option.
  ///
  /// A `null` callback renders the control disabled (non-interactive).
  final ValueChanged<T?>? onChanged;

  /// Placeholder text shown in the closed field while [value] is `null`.
  final String? hintText;

  /// An error message shown beneath the field. When non-null the control also
  /// adopts its error (danger) border.
  final String? errorText;

  /// Whether the control is interactive. Defaults to `true`. When `false` the
  /// field is dimmed and cannot be opened.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    // A null callback also disables the control, matching Flutter convention.
    final bool isEnabled = enabled && onChanged != null;
    final bool hasError = errorText != null;

    final radius = BorderRadius.circular(tokens.formBorderRadius);

    OutlineInputBorder borderWith(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final selectedTextStyle = tokens.bodyMd.toTextStyle(color: tokens.colorText);
    final placeholderStyle =
        tokens.bodyMd.toTextStyle(color: tokens.formPlaceholderTextColor);

    final decoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: tokens.formBackgroundColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.inputFieldPaddingX,
        vertical: tokens.inputFieldPaddingY,
      ),
      enabledBorder: borderWith(tokens.colorBorder, 1),
      border: borderWith(tokens.colorBorder, 1),
      focusedBorder: borderWith(tokens.formHighlightColorBorder, 2),
      disabledBorder: borderWith(tokens.colorBorder, 1),
      errorBorder: borderWith(tokens.colorDanger, 1),
      focusedErrorBorder: borderWith(tokens.colorDanger, 2),
      // The message is rendered below via [errorText]; only the border should
      // react here so we suppress the default in-decoration error line.
      errorStyle: const TextStyle(height: 0, fontSize: 0),
      error: hasError ? const SizedBox.shrink() : null,
    );

    final Widget? hint = hintText != null
        ? Text(
            hintText!,
            style: placeholderStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : null;

    final field = ConstrainedBox(
      // Guarantee an accessible >=48dp touch target regardless of density.
      constraints: const BoxConstraints(minHeight: 48),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        // Expand so long labels ellipsize within the field instead of
        // overflowing on narrow (320dp) screens.
        isExpanded: true,
        decoration: decoration,
        hint: hint,
        disabledHint: hint,
        style: selectedTextStyle,
        dropdownColor: tokens.formBackgroundColor,
        borderRadius: radius,
        icon: Icon(
          Icons.expand_more,
          size: DsIconSize.md,
          color: tokens.colorSecondaryText,
        ),
        onChanged: isEnabled ? onChanged : null,
        items: [
          for (final option in options)
            DropdownMenuItem<T>(
              value: option.value,
              child: Text(
                option.label,
                style: selectedTextStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: tokens.labelMd
                  .toTextStyle(color: tokens.colorText)
                  .copyWith(fontWeight: DsTypography.medium),
            ),
            const SizedBox(height: 6),
          ],
          field,
          if (hasError) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: tokens.bodySm.toTextStyle(color: tokens.colorDanger),
            ),
          ],
        ],
      ),
    );
  }
}
