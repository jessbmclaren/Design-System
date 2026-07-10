import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_field_label.dart';

/// A labelled single- or multi-line text input.
///
/// [DsTextField] is the Design System's primary way to collect free-form text
/// (names, emails, passwords, multi-line notes). It composes an optional
/// [label], the input itself and an optional [helperText] or [errorText] into
/// a single accessible column so that the caption is always associated with the
/// field it describes.
///
/// Use it whenever a form needs a text entry. Pass an [errorText] to move
/// the field into its error state: the border and the caption beneath it
/// switch to the danger colour and the label is read out with the error by
/// assistive technology. Inside a [Form], pass a [validator] instead and the
/// field reports its own message when the form validates; [autovalidateMode]
/// controls when that happens. Set [optional] to mark the field with a
/// subdued Optional label rather than decorating the required majority.
///
/// All colours, spacing, radii and typography are read from [DsTokens] so the
/// field re-skins automatically with the active theme:
///
/// ```dart
/// DsTextField(
///   label: 'Email',
///   hintText: 'you@example.com',
///   keyboardType: TextInputType.emailAddress,
///   onChanged: (value) => setState(() => _email = value),
/// )
/// ```
class DsTextField extends StatelessWidget {
  /// Creates a labelled text input.
  const DsTextField({
    super.key,
    this.label,
    this.optional = false,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
    this.validator,
    this.autovalidateMode,
    this.inputFormatters,
    this.onSaved,
  });

  /// The text shown above the input describing what it collects.
  ///
  /// When null, no label row is rendered.
  final String? label;

  /// Whether to append a subdued Optional marker to the [label]. Ignored when
  /// no label is set.
  final bool optional;

  /// Placeholder text shown inside the empty field.
  final String? hintText;

  /// Guidance shown beneath the field. Ignored when [errorText] is set.
  final String? helperText;

  /// The error message shown beneath the field.
  ///
  /// When non-null the field enters its error state: the border and caption use
  /// the danger colour and the message is announced with the [label]. For
  /// [Form]-driven validation prefer [validator], which reports its message
  /// through the field itself.
  final String? errorText;

  /// Controls the text being edited. When null, the field manages its own
  /// [TextEditingController] internally.
  final TextEditingController? controller;

  /// Called whenever the user changes the text.
  final ValueChanged<String>? onChanged;

  /// Whether to hide the text being edited, for example for passwords.
  final bool obscureText;

  /// The keyboard layout to request for editing.
  final TextInputType? keyboardType;

  /// An optional widget shown before the editable text (typically an icon).
  final Widget? prefixIcon;

  /// An optional widget shown after the editable text (typically an icon).
  final Widget? suffixIcon;

  /// Whether the field accepts input. A disabled field is dimmed and skipped by
  /// focus traversal.
  final bool enabled;

  /// Whether the field is read-only. A read-only field keeps its full styling
  /// and stays focusable so its value can be selected and copied, but it
  /// rejects edits.
  final bool readOnly;

  /// The maximum number of lines the field grows to. Use null for an unbounded
  /// multi-line field.
  final int? maxLines;

  /// The minimum number of lines the field reserves. Pair with [maxLines] for
  /// a text area that starts tall and grows.
  final int? minLines;

  /// The maximum number of characters the field accepts. When set, a counter
  /// renders beneath the field.
  final int? maxLength;

  /// An optional focus node controlling the field's focus.
  final FocusNode? focusNode;

  /// The action button shown on the keyboard, such as next or done.
  final TextInputAction? textInputAction;

  /// Called when the user submits the field, for example via the keyboard's
  /// done action.
  final ValueChanged<String>? onSubmitted;

  /// Whether the field requests focus as soon as it is shown.
  final bool autofocus;

  /// Validates the field's value inside a [Form]. Return null for a valid
  /// value or the message to show beneath the field. The message renders in
  /// the same caption style as [errorText] and moves the border to the danger
  /// colour.
  final FormFieldValidator<String>? validator;

  /// When the [validator] runs. Defaults to the enclosing [Form]'s mode; set
  /// [AutovalidateMode.onUserInteraction] to validate only once the user has
  /// edited this field, so an untouched field never shows a required error.
  final AutovalidateMode? autovalidateMode;

  /// Restricts or rewrites input as the user types, for example
  /// [FilteringTextInputFormatter.digitsOnly].
  final List<TextInputFormatter>? inputFormatters;

  /// Called with the final value when the enclosing [Form] is saved.
  final FormFieldSetter<String>? onSaved;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final bool hasError = errorText != null;

    // The horizontal inset stays on the shared input token; the vertical
    // inset is the text field's own token, so a skin can retune the field
    // without moving every other form control.
    final EdgeInsets contentPadding = EdgeInsets.symmetric(
      horizontal: tokens.inputFieldPaddingX,
      vertical: tokens.textFieldPaddingY,
    );

    final BorderRadius radius = BorderRadius.circular(tokens.formBorderRadius);

    OutlineInputBorder borderWith(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final Color captionColor =
        hasError ? tokens.colorDanger : tokens.colorSecondaryText;
    final String? caption = hasError ? errorText : helperText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null) ...<Widget>[
          DsFieldLabel(label: label!, optional: optional),
          const SizedBox(height: 6),
        ],
        Semantics(
          label: label,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            onSaved: onSaved,
            validator: validator,
            autovalidateMode: autovalidateMode,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            obscureText: obscureText,
            keyboardType: keyboardType,
            enabled: enabled,
            readOnly: readOnly,
            maxLines: obscureText ? 1 : maxLines,
            minLines: obscureText ? null : minLines,
            maxLength: maxLength,
            style: tokens.bodyMd.toTextStyle(color: tokens.colorText),
            cursorColor: tokens.formAccentColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: tokens.formBackgroundColor,
              isDense: true,
              contentPadding: contentPadding,
              hintText: hintText,
              hintStyle: tokens.bodyMd
                  .toTextStyle(color: tokens.formPlaceholderTextColor),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              counterStyle:
                  tokens.labelSm.toTextStyle(color: tokens.colorSecondaryText),
              // The caption for [helperText] and [errorText] is rendered by
              // this widget below, so the field's built-in helper text is
              // suppressed to avoid duplication. Messages from [validator]
              // do render through the decoration, styled to match the
              // caption. The border reflects both error paths.
              errorStyle: tokens.bodySm.toTextStyle(color: tokens.colorDanger),
              errorMaxLines: 3,
              border: borderWith(tokens.colorBorder, 1),
              enabledBorder: borderWith(
                hasError ? tokens.colorDanger : tokens.colorBorder,
                hasError ? 1.6 : 1,
              ),
              focusedBorder: borderWith(
                hasError
                    ? tokens.colorDanger
                    : tokens.formHighlightColorBorder,
                1.6,
              ),
              errorBorder: borderWith(tokens.colorDanger, 1.6),
              focusedErrorBorder: borderWith(tokens.colorDanger, 1.6),
              disabledBorder: borderWith(
                tokens.colorBorder.withValues(alpha: 0.5),
                1,
              ),
            ),
          ),
        ),
        if (caption != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            caption,
            style: tokens.bodySm.toTextStyle(color: captionColor),
          ),
        ],
      ],
    );
  }
}
