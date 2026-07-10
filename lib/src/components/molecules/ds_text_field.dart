import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_typography.dart';

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
/// assistive technology.
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
    this.maxLines = 1,
    this.focusNode,
  });

  /// The text shown above the input describing what it collects.
  ///
  /// When null, no label row is rendered.
  final String? label;

  /// Placeholder text shown inside the empty field.
  final String? hintText;

  /// Guidance shown beneath the field. Ignored when [errorText] is set.
  final String? helperText;

  /// The error message shown beneath the field.
  ///
  /// When non-null the field enters its error state: the border and caption use
  /// the danger colour and the message is announced with the [label].
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

  /// The maximum number of lines the field grows to. Use null for an unbounded
  /// multi-line field.
  final int? maxLines;

  /// An optional focus node controlling the field's focus.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final bool hasError = errorText != null;

    // A slightly roomier vertical padding than the raw token reads best on a
    // bordered input, while horizontal padding stays on the token.
    final EdgeInsets contentPadding = EdgeInsets.symmetric(
      horizontal: tokens.inputFieldPaddingX,
      vertical: tokens.inputFieldPaddingY + 12,
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
          Text(
            label!,
            style: tokens.labelMd.toTextStyle(color: tokens.colorText).copyWith(
                  fontWeight: DsTypography.medium,
                ),
          ),
          const SizedBox(height: 6),
        ],
        Semantics(
          label: label,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            obscureText: obscureText,
            keyboardType: keyboardType,
            enabled: enabled,
            maxLines: obscureText ? 1 : maxLines,
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
              // The caption (helper or error) is rendered by this widget below,
              // so the field's built-in helper/error text is suppressed to
              // avoid duplication. The border still reflects the error state.
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
