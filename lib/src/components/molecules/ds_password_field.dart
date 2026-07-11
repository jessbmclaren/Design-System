import 'package:flutter/material.dart';

import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import 'ds_text_field.dart';

/// A password input with a show and hide toggle.
///
/// [DsPasswordField] is a [DsTextField] preconfigured to obscure its text, with
/// an eye toggle in the suffix that reveals or hides the value. The toggle is a
/// real [IconButton], so it is keyboard-focusable and labelled for assistive
/// technology, and the field itself keeps [DsTextField] as its single visual
/// source of truth.
///
/// It forwards the field props a password needs (controller, an [errorText]
/// caption, submit handling) and owns its own show and hide state. The field
/// declares itself to the platform's autofill service ([AutofillHints.password]
/// by default, [AutofillHints.newPassword] when [newPassword] is set) and
/// keeps autocorrect and keyboard suggestions off, so password managers can
/// fill and save the value and it never reaches the suggestion engine.
class DsPasswordField extends StatefulWidget {
  /// Creates a password input with a show and hide toggle.
  const DsPasswordField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.validator,
    this.autovalidateMode,
    this.newPassword = false,
  });

  /// The text shown above the input. When null, no label row is rendered.
  final String? label;

  /// Placeholder text shown inside the empty field.
  final String? hintText;

  /// Guidance shown beneath the field. Ignored when [errorText] is set.
  final String? helperText;

  /// The error message shown beneath the field, which moves it into its error
  /// state.
  final String? errorText;

  /// Controls the text being edited. When null, the field manages its own
  /// controller internally.
  final TextEditingController? controller;

  /// Called whenever the user changes the text.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// The action button shown on the keyboard, such as done.
  final TextInputAction? textInputAction;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether the field requests focus as soon as it is shown.
  final bool autofocus;

  /// An optional focus node controlling the field's focus.
  final FocusNode? focusNode;

  /// Validates the password inside a [Form], forwarded to [DsTextField].
  /// Pair it with the rules in `dsPasswordRules` so the form gate and the
  /// visible checklist agree.
  final FormFieldValidator<String>? validator;

  /// When the [validator] runs, forwarded to [DsTextField].
  final AutovalidateMode? autovalidateMode;

  /// Whether this field collects a brand-new password (sign-up or change
  /// password) rather than an existing one. Switches the autofill hint from
  /// [AutofillHints.password] to [AutofillHints.newPassword], so password
  /// managers offer to generate and save a password instead of filling a
  /// stored one.
  final bool newPassword;

  @override
  State<DsPasswordField> createState() => _DsPasswordFieldState();
}

class _DsPasswordFieldState extends State<DsPasswordField> {
  bool _obscured = true;

  void _toggle() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    return DsTextField(
      label: widget.label,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      controller: widget.controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      obscureText: _obscured,
      // Declare the field to password managers and keep the value away from
      // the keyboard's correction and suggestion engines.
      autofillHints: <String>[
        widget.newPassword ? AutofillHints.newPassword : AutofillHints.password,
      ],
      autocorrect: false,
      enableSuggestions: false,
      suffixIcon: IconButton(
        onPressed: widget.enabled ? _toggle : null,
        icon: Icon(
          _obscured ? DsIcons.visibility : DsIcons.visibilityOff,
          size: DsIconSize.sm,
        ),
        tooltip: _obscured ? 'Show password' : 'Hide password',
      ),
    );
  }
}
