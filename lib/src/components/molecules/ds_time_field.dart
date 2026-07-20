import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_field_label.dart';
import '../atoms/ds_icon.dart';

/// A time-of-day field: a control that opens the platform time picker.
///
/// [DsTimeField] is the sibling of [DsDateField], for the hour a thing
/// happens rather than the day: a window opens, a report runs, a shift
/// starts. It is controlled, holding no time of its own: the caller passes
/// [value] and applies each [onChanged].
///
/// The control mirrors the date field exactly, so the two sit together in a
/// form without a seam: the same fill, border, caption and 48dp target, and
/// the whole control opens the picker rather than only its glyph. There is
/// nothing to type, so a time is always a real time. Passing null as
/// [onChanged] disables it.
///
/// The time is formatted through [MaterialLocalizations], so it follows the
/// user's locale and their 12- or 24-hour preference rather than a pattern
/// chosen here.
///
/// ```dart
/// DsTimeField(
///   label: 'Opens at',
///   value: opensAt,
///   onChanged: (time) => setState(() => opensAt = time),
/// )
/// ```
class DsTimeField extends StatelessWidget {
  /// Creates a time-of-day field.
  const DsTimeField({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
  });

  /// The text above the field describing what it collects.
  final String? label;

  /// The chosen time, or null when nothing is chosen yet.
  final TimeOfDay? value;

  /// Called with the chosen time. A null callback disables the field.
  final ValueChanged<TimeOfDay?>? onChanged;

  /// Placeholder shown while no time is chosen.
  final String? hintText;

  /// Guidance beneath the field. Suppressed while [errorText] shows.
  final String? helperText;

  /// An error message beneath the field, which also moves its border to the
  /// danger colour.
  final String? errorText;

  /// Whether the field is interactive.
  final bool enabled;

  Future<void> _openPicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) onChanged?.call(picked);
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
            : tokens.colorBorder
                .withValues(alpha: tokens.stateDisabledOpacity));

    final String formatted = hasValue
        ? MaterialLocalizations.of(context).formatTimeOfDay(value!)
        : '';
    final String displayText = hasValue ? formatted : (hintText ?? '');
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
      value: hasValue ? formatted : null,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.6,
        child: Material(
          color: tokens.formBackgroundColor,
          borderRadius: radius,
          child: InkWell(
            onTap: isEnabled ? () => _openPicker(context) : null,
            borderRadius: radius,
            child: ConstrainedBox(
              // Guarantee an accessible touch target regardless of density.
              constraints: BoxConstraints(minHeight: tokens.minTapTarget),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: borderColor,
                    width: hasError
                        ? tokens.inputFocusBorderWidth
                        : tokens.inputBorderWidth,
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
                      SizedBox(width: tokens.spacingUnit),
                      DsIcon(
                        icon: DsIcons.time,
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
            DsFieldLabel(label: label!),
            SizedBox(height: tokens.fieldLabelGap),
          ],
          field,
          if (caption != null) ...<Widget>[
            SizedBox(height: tokens.fieldLabelGap),
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
