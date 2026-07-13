import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_typography.dart';
import '../atoms/ds_field_label.dart';

/// A labelled multi-line text input.
///
/// [DsTextArea] is the Design System's way to collect longer, free-form text
/// such as notes, descriptions or messages. It composes an optional [label],
/// a filled, bordered input that grows from [minLines] to [maxLines], and an
/// optional caption ([helperText] or [errorText]) into a single accessible
/// column so the caption is always associated with the field it describes.
///
/// It shares its visual language with `DsTextField`: the label sits above in
/// `labelMd`/medium, the field is filled with [DsTokens.formBackgroundColor]
/// and bordered with [DsTokens.colorBorder] at [DsTokens.formBorderRadius],
/// the focus border uses [DsTokens.formHighlightColorBorder] and the error
/// state uses [DsTokens.colorDanger].
///
/// When a [maxLength] is supplied a live character counter (for example
/// `40 / 200`) is rendered to the right of the caption row.
///
/// All colours, spacing, radii and typography are read from [DsTokens] so the
/// field re-skins automatically with the active theme:
///
/// ```dart
/// DsTextArea(
///   label: 'Notes',
///   hintText: 'Add any additional detail…',
///   maxLength: 200,
///   onChanged: (value) => setState(() => _notes = value),
/// )
/// ```
class DsTextArea extends StatelessWidget {
  /// Creates a labelled multi-line text input.
  const DsTextArea({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.enabled = true,
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

  /// The minimum number of lines the field occupies before it starts to grow.
  final int minLines;

  /// The maximum number of lines the field grows to before it starts to scroll.
  final int maxLines;

  /// The maximum number of characters allowed. When non-null a live character
  /// counter is shown and input beyond the limit is prevented.
  final int? maxLength;

  /// Whether the field accepts input. A disabled field is dimmed and skipped by
  /// focus traversal.
  final bool enabled;

  /// An optional focus node controlling the field's focus.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final bool hasError = errorText != null;

    // The horizontal inset stays on the shared input token; the vertical
    // inset reads the same full-padding token as [DsTextField], so the two
    // fields stay in step when a skin retunes their height.
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
          DsFieldLabel(label: label!),
          SizedBox(height: tokens.fieldLabelGap),
        ],
        Semantics(
          label: label,
          multiline: true,
          textField: true,
          enabled: enabled,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            enabled: enabled,
            minLines: minLines,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.top,
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
              // The caption (helper or error) and the character counter are
              // rendered by this widget below, so the field's built-in
              // helper/error/counter text is suppressed to avoid duplication.
              // The border still reflects the error state.
              counterText: '',
              border: borderWith(tokens.colorBorder, tokens.inputBorderWidth),
              // The error border carries the focus emphasis, as documented on
              // [DsTokens.inputFocusBorderWidth].
              enabledBorder: borderWith(
                hasError ? tokens.colorDanger : tokens.colorBorder,
                hasError
                    ? tokens.inputFocusBorderWidth
                    : tokens.inputBorderWidth,
              ),
              focusedBorder: borderWith(
                hasError ? tokens.colorDanger : tokens.formHighlightColorBorder,
                tokens.inputFocusBorderWidth,
              ),
              disabledBorder: borderWith(
                tokens.colorBorder
                    .withValues(alpha: tokens.stateDisabledOpacity),
                tokens.inputBorderWidth,
              ),
            ),
          ),
        ),
        if (caption != null || maxLength != null) ...<Widget>[
          SizedBox(height: tokens.fieldLabelGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (caption != null)
                Expanded(
                  child: Text(
                    caption,
                    style: tokens.bodySm.toTextStyle(color: captionColor),
                  ),
                )
              else
                const Spacer(),
              if (maxLength != null) ...<Widget>[
                SizedBox(width: tokens.spacingUnit),
                _CharacterCounter(
                  controller: controller,
                  maxLength: maxLength!,
                  color: tokens.colorSecondaryText,
                  style: tokens.bodySm,
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// A live `count / max` counter that rebuilds as the associated
/// [controller] changes. When no controller is provided it renders the limit
/// with a zero count, so a demo without a controller still reads correctly.
class _CharacterCounter extends StatelessWidget {
  const _CharacterCounter({
    required this.controller,
    required this.maxLength,
    required this.color,
    required this.style,
  });

  final TextEditingController? controller;
  final int maxLength;
  final Color color;
  final DsTypeToken style;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = style.toTextStyle(color: color);
    if (controller == null) {
      return Text(
        '0 / $maxLength',
        style: textStyle,
        semanticsLabel: '0 of $maxLength characters',
      );
    }
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller!,
      builder: (BuildContext context, TextEditingValue value, _) {
        final int count = value.text.characters.length;
        return Text(
          '$count / $maxLength',
          style: textStyle,
          semanticsLabel: '$count of $maxLength characters',
        );
      },
    );
  }
}
