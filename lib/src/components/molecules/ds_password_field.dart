import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../tokens/ds_icon_size.dart';
import '../../theme/ds_tokens_extension.dart';
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
    this.showCapsLockHint = false,
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
    this.reserveErrorSpace = false,
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

  /// Whether to warn while caps lock is on and the field has focus. A typed
  /// password is masked, so the usual clue that the shift key is stuck is
  /// missing; this restores it. The row appears only while both conditions
  /// hold and announces itself once, rather than on every keystroke.
  final bool showCapsLockHint;

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

  /// Whether to always reserve the caption line, so the field keeps the same
  /// height with or without an error. Forwarded to [DsTextField.reserveErrorSpace].
  final bool reserveErrorSpace;

  @override
  State<DsPasswordField> createState() => _DsPasswordFieldState();
}

class _DsPasswordFieldState extends State<DsPasswordField> {
  bool _obscured = true;

  /// The field's own focus node, created only when the caller supplies none
  /// and the caps-lock hint needs to know whether the field has focus.
  FocusNode? _internalFocusNode;
  bool _focused = false;
  bool _capsLockOn = false;

  FocusNode? get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    if (widget.showCapsLockHint) _attachCapsLock();
  }

  @override
  void didUpdateWidget(DsPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showCapsLockHint && !oldWidget.showCapsLockHint) {
      _attachCapsLock();
    } else if (!widget.showCapsLockHint && oldWidget.showCapsLockHint) {
      _detachCapsLock();
    }
  }

  @override
  void dispose() {
    _detachCapsLock();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _attachCapsLock() {
    _internalFocusNode ??= widget.focusNode == null ? FocusNode() : null;
    _focusNode?.addListener(_onFocusChange);
    HardwareKeyboard.instance.addHandler(_onKey);
    _syncCapsLock();
  }

  void _detachCapsLock() {
    _focusNode?.removeListener(_onFocusChange);
    HardwareKeyboard.instance.removeHandler(_onKey);
  }

  void _onFocusChange() {
    final bool focused = _focusNode?.hasFocus ?? false;
    if (focused == _focused) return;
    setState(() => _focused = focused);
    if (focused) _syncCapsLock();
  }

  /// Reads the lock state directly, so the hint is right on focus rather
  /// than waiting for the next keystroke.
  void _syncCapsLock() {
    final bool on = HardwareKeyboard.instance.lockModesEnabled
        .contains(KeyboardLockMode.capsLock);
    if (on != _capsLockOn) setState(() => _capsLockOn = on);
  }

  bool _onKey(KeyEvent event) {
    _syncCapsLock();
    // Never consume the key: this is an observer, not a handler.
    return false;
  }

  void _toggle() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final bool showHint =
        widget.showCapsLockHint && _focused && _capsLockOn;

    final Widget field = DsTextField(
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
      focusNode: _focusNode,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      reserveErrorSpace: widget.reserveErrorSpace,
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

    if (!widget.showCapsLockHint) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        field,
        if (showHint)
          Padding(
            padding: EdgeInsets.only(top: tokens.fieldLabelGap),
            child: Semantics(
              liveRegion: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    DsIcons.warning,
                    size: DsIconSize.xs,
                    color: tokens.colorSecondaryText,
                  ),
                  SizedBox(width: tokens.spacingUnit / 2),
                  Text(
                    'Caps Lock is on',
                    style: tokens.bodySm
                        .toTextStyle(color: tokens.colorSecondaryText),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
