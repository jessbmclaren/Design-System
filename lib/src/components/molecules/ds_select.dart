import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';

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
/// list (a country, a status, a currency) where a set of radio buttons would
/// take too much room. For free-form entry use a text field instead; for
/// multi-select, use a different control.
///
/// Pass a [helperText] to show a subdued line of guidance beneath the field,
/// and an [errorText] to move it into its error state. Inside a [Form], pass
/// a [validator] instead and the field reports its own message when the form
/// validates; [autovalidateMode] controls when that happens and [onSaved]
/// receives the chosen value when the form is saved.
///
/// All colours, spacing, radii and typography are read from [DsTokens], so the
/// control re-brands with the active theme and never hardcodes appearance.
///
/// The focused border reads [DsTokens.inputFocusBorderWidth], the same
/// emphasis as the rest of the field family. Earlier releases drew it at 2dp;
/// it now matches the family default of 1.6dp.
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
  /// called with the newly picked value; passing `null` (or setting [enabled]
  /// to `false`) renders the control disabled.
  const DsSelect({
    super.key,
    this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.onSaved,
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

  /// Guidance shown beneath the field. Ignored when [errorText] is set.
  final String? helperText;

  /// An error message shown beneath the field. When non-null the control also
  /// adopts its error (danger) border. For [Form]-driven validation prefer
  /// [validator], which reports its message through the field itself.
  final String? errorText;

  /// Whether the control is interactive. Defaults to `true`. When `false` the
  /// field is dimmed and cannot be opened, and it sits the form out: its
  /// [validator] does not run and [onSaved] is not called, so a disabled
  /// select can never block a form with an error the user cannot fix.
  final bool enabled;

  /// Validates the selected value inside a [Form]. Return null for a valid
  /// value or the message to show beneath the field. The message renders in
  /// the same caption style as [errorText] and moves the border to the danger
  /// colour. Not run while the control is disabled.
  final FormFieldValidator<T>? validator;

  /// When the [validator] runs. Defaults to the enclosing [Form]'s mode; set
  /// [AutovalidateMode.onUserInteraction] to validate only once the user has
  /// picked an option, so an untouched field never shows a required error.
  final AutovalidateMode? autovalidateMode;

  /// Called with the selected value when the enclosing [Form] is saved. Not
  /// called while the control is disabled.
  final FormFieldSetter<T>? onSaved;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    // A null callback also disables the control, matching Flutter convention.
    final bool isEnabled = enabled && onChanged != null;
    final bool hasError = errorText != null;

    // The caption beneath the field mirrors DsTextField: a manual error wins,
    // otherwise the helper renders in the secondary colour.
    final Color captionColor =
        hasError ? tokens.colorDanger : tokens.colorSecondaryText;
    final String? caption = hasError ? errorText : helperText;

    final radius = BorderRadius.circular(tokens.formBorderRadius);

    OutlineInputBorder borderWith(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    // DropdownButtonFormField applies `style` as the DefaultTextStyle for its
    // own value/hint/menu text, replacing the ambient one, so a family-less
    // token style would strip the effective font family and render tofu. Bake
    // the ambient family (the theme's effective font) into these styles so the
    // dropdown text keeps it.
    final ambient = DefaultTextStyle.of(context).style;
    final selectedTextStyle = tokens.bodyMd.toTextStyle(color: tokens.colorText).copyWith(
          fontFamily: ambient.fontFamily,
          fontFamilyFallback: ambient.fontFamilyFallback,
        );
    final placeholderStyle =
        tokens.bodyMd.toTextStyle(color: tokens.formPlaceholderTextColor).copyWith(
              fontFamily: ambient.fontFamily,
              fontFamilyFallback: ambient.fontFamilyFallback,
            );

    final decoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: tokens.formBackgroundColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.inputFieldPaddingX,
        vertical: tokens.inputFieldPaddingY,
      ),
      enabledBorder: borderWith(tokens.colorBorder, tokens.inputBorderWidth),
      border: borderWith(tokens.colorBorder, tokens.inputBorderWidth),
      // Focused borders share the family's emphasis token; see the class doc
      // for the 2dp to 1.6dp alignment.
      focusedBorder: borderWith(
        tokens.formHighlightColorBorder,
        tokens.inputFocusBorderWidth,
      ),
      disabledBorder: borderWith(tokens.colorBorder, tokens.inputBorderWidth),
      errorBorder: borderWith(tokens.colorDanger, tokens.inputBorderWidth),
      focusedErrorBorder: borderWith(
        tokens.colorDanger,
        tokens.inputFocusBorderWidth,
      ),
      // A manual [errorText] is rendered below by this widget, so only the
      // border should react here and the in-decoration error line is
      // suppressed. Messages from [validator] have no other outlet, so they
      // render through the decoration, styled to match the caption.
      errorStyle: hasError
          ? const TextStyle(height: 0, fontSize: 0)
          : tokens.bodySm.toTextStyle(color: tokens.colorDanger),
      errorMaxLines: 3,
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
      // Guarantee an accessible touch target regardless of density.
      constraints: BoxConstraints(minHeight: tokens.minTapTarget),
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
          DsIcons.expandMore,
          size: DsIconSize.md,
          color: tokens.colorSecondaryText,
        ),
        onChanged: isEnabled ? onChanged : null,
        // A disabled control cannot be operated, so it neither validates nor
        // saves; otherwise Form.validate() could fail on an error the user
        // has no way to fix.
        validator: isEnabled ? validator : null,
        autovalidateMode: autovalidateMode,
        onSaved: isEnabled ? onSaved : null,
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
                  .copyWith(fontWeight: tokens.mediumLabelFontWeight),
            ),
            SizedBox(height: tokens.fieldLabelGap),
          ],
          field,
          if (caption != null) ...[
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
