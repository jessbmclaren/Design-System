import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_typography.dart';
import '../atoms/ds_icon.dart';

/// A labelled, read-only date input that opens a calendar picker on tap.
///
/// [DsDateField] mirrors the look of the design system's text field: an
/// optional [label] sits above a filled, outlined control that shows the
/// currently selected [value] formatted as `yyyy-MM-dd`, or the [hintText]
/// placeholder while [value] is `null`. A trailing calendar glyph signals that
/// the field is tappable. Tapping opens the platform [showDatePicker] (themed
/// to inherit the app's [Theme]) bounded by [firstDate] and [lastDate]; the
/// chosen date — or `null` if the user cancels while no date is set — is
/// reported through [onChanged].
///
/// Use it whenever a form needs a single calendar date (a birthday, a due date,
/// a start date) and free-form typing would be error-prone. The field itself is
/// read-only, so the value is always a valid [DateTime].
///
/// All colours, spacing, radii and typography are read from [DsTokens], so the
/// control re-brands with the active theme and never hardcodes appearance.
///
/// The picker is closed by default and this widget starts no timers or
/// animations, so it is safe to render in a static screenshot.
///
/// ```dart
/// DsDateField(
///   label: 'Start date',
///   value: selected,
///   hintText: 'Select a date',
///   firstDate: DateTime(2020),
///   lastDate: DateTime(2030),
///   onChanged: (date) => setState(() => selected = date),
/// )
/// ```
class DsDateField extends StatelessWidget {
  /// Creates a labelled, read-only date field.
  ///
  /// Passing a `null` [onChanged] — or setting [enabled] to `false` — renders
  /// the control disabled (dimmed and non-interactive).
  const DsDateField({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
  });

  /// Optional text shown above the field, describing the date being collected.
  ///
  /// When `null`, no label row is rendered.
  final String? label;

  /// The currently selected date, or `null` when nothing is selected.
  final DateTime? value;

  /// Called with the newly picked date when the user confirms the picker.
  ///
  /// A `null` callback renders the control disabled (non-interactive).
  final ValueChanged<DateTime?>? onChanged;

  /// The earliest selectable date. Defaults to `DateTime(1900)`.
  final DateTime? firstDate;

  /// The latest selectable date. Defaults to `DateTime(2100)`.
  final DateTime? lastDate;

  /// Placeholder text shown in the field while [value] is `null`.
  final String? hintText;

  /// Guidance shown beneath the field. Ignored when [errorText] is set.
  final String? helperText;

  /// An error message shown beneath the field.
  ///
  /// When non-null the control adopts its error (danger) border and the message
  /// is announced with the [label] by assistive technology.
  final String? errorText;

  /// Whether the control is interactive. Defaults to `true`. When `false` the
  /// field is dimmed and cannot be opened.
  final bool enabled;

  /// Formats [date] as `yyyy-MM-dd` without an `intl` dependency.
  static String _format(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _openPicker(BuildContext context) async {
    final DateTime first = firstDate ?? DateTime(1900);
    final DateTime last = lastDate ?? DateTime(2100);
    // Clamp the seed so the picker never opens outside its own bounds.
    DateTime initial = value ?? DateTime.now();
    if (initial.isBefore(first)) {
      initial = first;
    } else if (initial.isAfter(last)) {
      initial = last;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      // Inherit the app's theme so the picker re-brands with the design system.
      builder: (BuildContext dialogContext, Widget? child) {
        return Theme(data: Theme.of(context), child: child ?? const SizedBox.shrink());
      },
    );

    if (picked != null) {
      onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    // A null callback also disables the control, matching Flutter convention.
    final bool isEnabled = enabled && onChanged != null;
    final bool hasError = errorText != null;
    final bool hasValue = value != null;

    final BorderRadius radius = BorderRadius.circular(tokens.formBorderRadius);

    final Color borderColor = hasError
        ? tokens.colorDanger
        : (isEnabled
            ? tokens.colorBorder
            : tokens.colorBorder.withValues(alpha: 0.5));

    final String displayText =
        hasValue ? _format(value!) : (hintText ?? '');
    final TextStyle textStyle = hasValue
        ? tokens.bodyMd.toTextStyle(color: tokens.colorText)
        : tokens.bodyMd.toTextStyle(color: tokens.formPlaceholderTextColor);

    final Color captionColor =
        hasError ? tokens.colorDanger : tokens.colorSecondaryText;
    final String? caption = hasError ? errorText : helperText;

    final Widget field = Semantics(
      label: label,
      button: true,
      enabled: isEnabled,
      value: hasValue ? _format(value!) : null,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.6,
        child: Material(
          color: tokens.formBackgroundColor,
          borderRadius: radius,
          child: InkWell(
            onTap: isEnabled ? () => _openPicker(context) : null,
            borderRadius: radius,
            child: ConstrainedBox(
              // Guarantee an accessible >=48dp touch target regardless of
              // density.
              constraints: const BoxConstraints(minHeight: 48),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: borderColor,
                    width: hasError ? 1.6 : 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.inputFieldPaddingX,
                    vertical: tokens.inputFieldPaddingY,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          displayText,
                          style: textStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DsIcon(
                        icon: Icons.calendar_today,
                        size: DsIconSize.sm,
                        color: tokens.colorSecondaryText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (label != null) ...<Widget>[
            Text(
              label!,
              style: tokens.labelMd
                  .toTextStyle(color: tokens.colorText)
                  .copyWith(fontWeight: DsTypography.medium),
            ),
            const SizedBox(height: 6),
          ],
          field,
          if (caption != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              caption,
              style: tokens.bodySm.toTextStyle(color: captionColor),
            ),
          ],
        ],
      ),
    );
  }
}
