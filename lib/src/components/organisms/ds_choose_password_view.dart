import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_heading_alignment.dart';
import '../molecules/ds_password_field.dart';
import '../molecules/ds_password_requirements.dart';
import '../molecules/ds_password_strength.dart' show DsPasswordRule;
import 'ds_forgot_password_view.dart';
import 'ds_sign_in_view.dart' show DsSignInAction;

/// A centred "set a new password" card.
///
/// The sibling of [DsForgotPasswordView] for the step where someone chooses a
/// password: a single obscured field with the visibility toggle, a live
/// [DsPasswordRequirements] checklist as the *only* feedback, and one primary
/// action. It is not reset-specific; the same card sets a password on an
/// invited account, on a first sign-in or on a forced rotation.
///
/// **One field, no confirm field.** A second "confirm password" box is a
/// workaround for hidden input, and the visibility toggle solves that better.
/// **The checklist is the only feedback.** There is no meter and no strength
/// word, so a "requirement not met" and a "looks strong" cannot contradict
/// each other. Rows stay neutral while typing and turn red only when
/// [attempted] is set after a refused submit.
///
/// Like the other auth scaffolds it **owns no form state**. The caller holds
/// the controller, decides when a rule is met (so a breach check or a policy
/// the product owns can be passed through [extraRules]), gates
/// [primaryAction.onPressed], and flips [attempted] on an invalid submit. The
/// view renders and lays out; it does not validate.
///
/// {@tool snippet}
///
/// ```dart
/// DsChoosePasswordView(
///   controller: _controller,
///   value: _password,
///   attempted: _attempted,
///   onChanged: (v) => setState(() => _password = v),
///   primaryAction: DsSignInAction(
///     label: 'Save new password',
///     onPressed: _save,
///     pending: _saving,
///   ),
/// )
/// ```
///
/// {@end-tool}
class DsChoosePasswordView extends StatelessWidget {
  /// Creates a choose-a-password card.
  const DsChoosePasswordView({
    super.key,
    required this.value,
    required this.primaryAction,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.attempted = false,
    this.rules,
    this.extraRules = const <DsPasswordRule>[],
    this.title = 'Choose a new password',
    this.description,
    this.fieldLabel = 'New password',
    this.footer,
    this.autofocus = true,
    this.finishAutofillOnSubmit = true,
    this.brandIcon,
    this.brandColor,
    this.onClose,
    this.showBorder = true,
    this.embedded = false,
  });

  /// The current password value, for the live checklist.
  final String value;

  /// The full-width primary action, e.g. "Save new password".
  final DsSignInAction primaryAction;

  /// The field's controller. The caller owns it.
  final TextEditingController? controller;

  /// The field's focus node — pass one to focus the field on an invalid
  /// submit.
  final FocusNode? focusNode;

  /// Called on every keystroke, so the caller can re-grade the value.
  final ValueChanged<String>? onChanged;

  /// Called when the field is submitted from the keyboard. Defaults to running
  /// [primaryAction.onPressed].
  final ValueChanged<String>? onSubmitted;

  /// Whether a submit has been refused, which turns the unmet checklist rows
  /// red. Keep it false while the person types.
  final bool attempted;

  /// The checklist rules, overriding the standard [dsPasswordRules]. Use it to
  /// present them grouped or reworded — an upper- and a lower-case letter read
  /// better as one line than two. See [DsPasswordRequirements.rules].
  final List<DsPasswordRule>? rules;

  /// Extra checklist rows the product owns, appended after the standard rules —
  /// a breach lookup, say. See [DsPasswordRequirements.extraRules].
  final List<DsPasswordRule> extraRules;

  /// The card heading.
  final String title;

  /// Optional supporting copy beneath the heading.
  final String? description;

  /// The password field's label.
  final String fieldLabel;

  /// Optional content below the primary action, such as a "Return to sign-in"
  /// link.
  final Widget? footer;

  /// Whether the field takes focus when the card appears.
  final bool autofocus;

  /// Whether submitting from the keyboard commits the platform autofill "save
  /// password?" prompt. Leave true so a password manager offers to store it.
  final bool finishAutofillOnSubmit;

  /// An optional brand glyph above the title.
  final IconData? brandIcon;

  /// The tint behind [brandIcon].
  final Color? brandColor;

  /// Called when the corner close button is tapped. No close affordance shows
  /// when null.
  final VoidCallback? onClose;

  /// Whether the card draws a hairline border.
  final bool showBorder;

  /// Whether a host frames the page. See [DsForgotPasswordView.embedded].
  final bool embedded;

  void _submit(String value) {
    if (finishAutofillOnSubmit) TextInput.finishAutofillContext();
    if (onSubmitted != null) {
      onSubmitted!(value);
    } else {
      primaryAction.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    // Grouped so the platform commits and offers to save the new credential.
    final form = AutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DsPasswordField(
            label: fieldLabel,
            controller: controller,
            focusNode: focusNode,
            newPassword: true,
            autofocus: autofocus,
            textInputAction: TextInputAction.done,
            onChanged: onChanged,
            onSubmitted: _submit,
          ),
          SizedBox(height: tokens.spacingUnit * 2),
          DsPasswordRequirements(
            value: value,
            attempted: attempted,
            rules: rules,
            extraRules: extraRules,
          ),
        ],
      ),
    );

    // The heading, field, checklist and action all share the recovery card
    // chrome, so this view is that scaffold with a password body.
    return DsForgotPasswordView(
      title: title,
      description: description,
      form: form,
      primaryAction: primaryAction,
      footer: footer,
      brandIcon: brandIcon,
      brandColor: brandColor,
      onClose: onClose,
      showBorder: showBorder,
      embedded: embedded,
      headingAlignment: DsHeadingAlignment.start,
    );
  }
}
