import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_field_label.dart';
import 'ds_text_field.dart';

/// One dialling country offered by a [DsPhoneField].
@immutable
class DsDialCode {
  /// Creates a dialling country.
  const DsDialCode({
    required this.code,
    required this.dialCode,
    this.hintExample,
  });

  /// The country's short code, shown in the selector (`US`, `ZA`).
  final String code;

  /// The dialling prefix, including its plus (`+1`, `+27`).
  final String dialCode;

  /// An optional example number, used as the field's placeholder while this
  /// country is chosen.
  final String? hintExample;
}

/// The value a [DsPhoneField] reports: the chosen country and the number as
/// typed.
@immutable
class DsPhoneValue {
  /// Creates a phone value.
  const DsPhoneValue({required this.code, required this.number});

  /// The chosen country's [DsDialCode.code].
  final String code;

  /// The national number, without the dialling prefix.
  final String number;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DsPhoneValue &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          number == other.number;

  @override
  int get hashCode => Object.hash(code, number);
}

/// A telephone input: a country selector fused to a number field.
///
/// [DsPhoneField] keeps the dialling prefix and the number in one control, so
/// they read and validate as the single thing they are. It is controlled: the
/// caller holds a [DsPhoneValue] and applies each [onChanged].
///
/// The selector is a real, keyboard-reachable control announcing the chosen
/// country, and the number field takes the phone keyboard and rejects
/// anything but digits and the usual separators. The two share one border, so
/// the control reads as a single field, and the whole thing carries one
/// accessible name.
///
/// ```dart
/// DsPhoneField(
///   label: 'Phone',
///   countries: const [
///     DsDialCode(code: 'ZA', dialCode: '+27', hintExample: '00 000 0000'),
///     DsDialCode(code: 'GB', dialCode: '+44', hintExample: '0000 000000'),
///   ],
///   value: phone,
///   onChanged: (next) => setState(() => phone = next),
/// )
/// ```
class DsPhoneField extends StatefulWidget {
  /// Creates a telephone input.
  const DsPhoneField({
    super.key,
    this.label,
    this.optional = false,
    required this.countries,
    required this.value,
    required this.onChanged,
    this.helperText,
    this.errorText,
    this.enabled = true,
  });

  /// The text shown above the control describing what it collects.
  final String? label;

  /// Whether to append the subdued Optional marker to the [label].
  final bool optional;

  /// The dialling countries offered, in display order.
  final List<DsDialCode> countries;

  /// The current value. Its [DsPhoneValue.code] should match one of the
  /// [countries]; an unmatched code falls back to the first.
  final DsPhoneValue value;

  /// Called with the new value when either part changes. Null disables the
  /// control and drops it from the focus order.
  final ValueChanged<DsPhoneValue>? onChanged;

  /// Guidance shown beneath the control. Suppressed while [errorText] shows.
  final String? helperText;

  /// An error message shown beneath the control, which also moves its border
  /// to the danger colour.
  final String? errorText;

  /// Whether the control accepts input.
  final bool enabled;

  @override
  State<DsPhoneField> createState() => _DsPhoneFieldState();
}

class _DsPhoneFieldState extends State<DsPhoneField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.number);

  /// The chosen country, falling back to the first offered when the value's
  /// code matches none of them.
  DsDialCode? get _selected {
    for (final DsDialCode country in widget.countries) {
      if (country.code == widget.value.code) return country;
    }
    return widget.countries.isEmpty ? null : widget.countries.first;
  }

  @override
  void didUpdateWidget(DsPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only adopt a number the caller changed out from under us: rewriting the
    // controller on every rebuild would fight the user's cursor.
    if (widget.value.number != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value.number,
        selection:
            TextSelection.collapsed(offset: widget.value.number.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final bool isEnabled = widget.enabled && widget.onChanged != null;
    // With no countries there is no prefix to choose: the control degrades
    // to a plain number field rather than throwing. A const constructor
    // cannot assert a list's length, so the guard lives here.
    final DsDialCode? selected = _selected;

    // The selector sits inside the field's leading edge, so the prefix and
    // the number share one border and read as a single control.
    final Widget? selector = selected == null ? null : Padding(
      padding: EdgeInsets.only(left: tokens.spacingUnit),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected.code,
          isDense: true,
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          dropdownColor: tokens.formBackgroundColor,
          style: tokens.bodyMd.toTextStyle(color: tokens.colorText),
          onChanged: isEnabled
              ? (String? code) {
                  if (code == null) return;
                  widget.onChanged!(
                    DsPhoneValue(code: code, number: widget.value.number),
                  );
                }
              : null,
          items: <DropdownMenuItem<String>>[
            for (final DsDialCode country in widget.countries)
              DropdownMenuItem<String>(
                value: country.code,
                child: Text('${country.code} ${country.dialCode}'),
              ),
          ],
          selectedItemBuilder: (BuildContext context) => <Widget>[
            for (final DsDialCode country in widget.countries)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '${country.code} ${country.dialCode}',
                  style: tokens.bodyMd.toTextStyle(
                    color: isEnabled
                        ? tokens.colorText
                        : tokens.colorTextDisabled,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          // The control below carries the accessible name, so the visible
          // label is not announced twice.
          ExcludeSemantics(
            child: DsFieldLabel(
              label: widget.label!,
              optional: widget.optional,
            ),
          ),
          SizedBox(height: tokens.fieldLabelGap),
        ],
        Semantics(
          label: widget.label == null
              ? 'Phone number'
              : (widget.optional
                  ? '${widget.label}, optional'
                  : widget.label),
          child: DsTextField(
            controller: _controller,
            enabled: isEnabled,
            keyboardType: TextInputType.phone,
            hintText: selected?.hintExample,
            helperText: widget.helperText,
            errorText: widget.errorText,
            autofillHints: const <String>[AutofillHints.telephoneNumber],
            inputFormatters: <TextInputFormatter>[
              // Digits and the separators people actually type; the caller
              // formats and validates the rest.
              FilteringTextInputFormatter.allow(RegExp(r'[0-9 ()\-]')),
            ],
            prefixIcon: selector,
            onChanged: isEnabled
                ? (String number) => widget.onChanged!(
                      DsPhoneValue(
                        code: selected?.code ?? widget.value.code,
                        number: number,
                      ),
                    )
                : null,
          ),
        ),
      ],
    );
  }
}
