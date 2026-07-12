import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ds_tokens_extension.dart';

/// A labelled numeric input for collecting monetary amounts.
///
/// [DsCurrencyField] is the Design System's field for entering a single money
/// value. It renders a bordered input that mirrors [DsTextField]'s styling, but
/// prepends a currency [symbol] (for example `R`, `$` or `€`) inside the field
/// and constrains typing to a valid decimal number. The raw text is parsed to a
/// [num] and surfaced through [onChanged], so callers never have to strip the
/// symbol or validate the keystrokes themselves.
///
/// The input requests a decimal numeric keyboard on mobile and rejects any
/// character that is not a digit or a single decimal point, so the value stays
/// parseable while the user types.
///
/// All colours, spacing, radii and typography are read from [DsTokens] so the
/// field re-skins automatically with the active theme:
///
/// ```dart
/// DsCurrencyField(
///   label: 'Amount',
///   symbol: r'$',
///   value: 19.99,
///   helperText: 'Charged monthly',
///   onChanged: (amount) => setState(() => _amount = amount),
/// )
/// ```
///
/// Pass an [errorText] to move the field into its error state: the border and
/// the caption beneath it switch to the danger colour and the message is
/// announced together with the [label] by assistive technology.
class DsCurrencyField extends StatelessWidget {
  /// Creates a currency input.
  const DsCurrencyField({
    super.key,
    required this.symbol,
    this.label,
    this.value,
    this.onChanged,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
  });

  /// The currency symbol shown before the amount, for example `R`, `$` or `€`.
  ///
  /// Rendered in [DsTokens.colorSecondaryText] as a non-editable prefix so it is
  /// visually distinct from the amount the user types.
  final String symbol;

  /// The text shown above the input describing what it collects.
  ///
  /// When null, no label row is rendered.
  final String? label;

  /// The current amount shown in the field.
  ///
  /// Formatted without a trailing `.0` for whole numbers, so `12` renders as
  /// `12` and `12.5` renders as `12.5`.
  final num? value;

  /// Called whenever the user changes the amount.
  ///
  /// Receives the parsed [num], or null when the field is empty or holds an
  /// incomplete value such as a lone decimal point.
  final ValueChanged<num?>? onChanged;

  /// Placeholder text shown inside the empty field.
  final String? hintText;

  /// Guidance shown beneath the field. Ignored when [errorText] is set.
  final String? helperText;

  /// The error message shown beneath the field.
  ///
  /// When non-null the field enters its error state: the border and caption use
  /// the danger colour and the message is announced with the [label].
  final String? errorText;

  /// Whether the field accepts input. A disabled field is dimmed and skipped by
  /// focus traversal.
  final bool enabled;

  /// Formats [value] for display, trimming a redundant trailing `.0`.
  String get _displayValue {
    final num? amount = value;
    if (amount == null) {
      return '';
    }
    if (amount is int || amount == amount.truncateToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toString();
  }

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

    // The symbol sits in a padded prefix. A tight box (min width 0) keeps it
    // from pushing the input off-screen at 320dp for multi-character symbols.
    final Widget prefix = Padding(
      padding: EdgeInsets.only(
        left: tokens.inputFieldPaddingX,
        right: tokens.spacingUnit / 2,
      ),
      child: Text(
        symbol,
        style: tokens.bodyMd.toTextStyle(color: tokens.colorSecondaryText),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Text(
            label!,
            style: tokens.labelMd.toTextStyle(color: tokens.colorText).copyWith(
                  fontWeight: tokens.mediumLabelFontWeight,
                ),
          ),
          SizedBox(height: tokens.fieldLabelGap),
        ],
        Semantics(
          label: label,
          textField: true,
          child: TextFormField(
            initialValue: _displayValue,
            enabled: enabled,
            onChanged: (String text) => onChanged?.call(num.tryParse(text)),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              // Digits and at most one decimal point, nothing else.
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              _SingleDecimalFormatter(),
            ],
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
              // The symbol is a non-editable prefix, kept snug so the amount
              // still fits on a 320dp screen.
              prefixIcon: prefix,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              // The caption (helper or error) is rendered by this widget below,
              // so the field's built-in helper/error text is suppressed to
              // avoid duplication. The border still reflects the error state.
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
                hasError
                    ? tokens.colorDanger
                    : tokens.formHighlightColorBorder,
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
        if (caption != null) ...<Widget>[
          SizedBox(height: tokens.fieldLabelGap),
          Text(
            caption,
            style: tokens.bodySm.toTextStyle(color: captionColor),
          ),
        ],
      ],
    );
  }
}

/// Rejects a keystroke that would introduce a second decimal point.
///
/// [FilteringTextInputFormatter] already limits input to digits and dots; this
/// formatter additionally guarantees at most one dot survives so the text stays
/// parseable as a [num].
class _SingleDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int dotCount = '.'.allMatches(newValue.text).length;
    if (dotCount > 1) {
      return oldValue;
    }
    return newValue;
  }
}
