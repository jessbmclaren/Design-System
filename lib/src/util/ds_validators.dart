/// Field validators shared across the system's forms.
///
/// Every validator returns null for an acceptable value and a message
/// otherwise, matching Flutter's `FormFieldValidator` contract, so they drop
/// straight into `DsTextField.validator` and its siblings. Each takes its
/// message as a parameter, because the wording belongs to the product and its
/// voice, not to the system.
///
/// These are the generic rules any product needs. Market-specific rules (a
/// national identity number, a local telephone format) belong in an opt-in
/// module beside this one.
///
/// ```dart
/// DsTextField(
///   label: 'Email',
///   validator: (value) => DsValidators.email(value, message: 'Enter a valid email'),
/// )
/// ```
abstract final class DsValidators {
  /// Fails when [value] is null, empty or only whitespace.
  static String? required(
    String? value, {
    String message = 'This field is required',
  }) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  /// Fails when [value] is not a plausible email address.
  ///
  /// The rule is deliberately permissive: something before an at sign,
  /// something after it, and a dot in the domain. Anything stricter rejects
  /// addresses that genuinely deliver, and only sending mail proves an
  /// address real.
  static String? email(
    String? value, {
    String message = 'Enter a valid email address',
    bool allowEmpty = false,
  }) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return allowEmpty ? null : message;
    final RegExp pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return pattern.hasMatch(text) ? null : message;
  }

  /// Fails when [value] is not a plausible web address.
  ///
  /// A bare host (`example.com`) passes, as does one with a scheme. An empty
  /// value passes by default, since a website is usually optional.
  static String? website(
    String? value, {
    String message = 'Enter a valid website address',
    bool allowEmpty = true,
  }) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return allowEmpty ? null : message;
    final String withScheme =
        text.contains('://') ? text : 'https://$text';
    final Uri? uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) {
      return message;
    }
    return null;
  }

  /// Fails when nothing has been chosen from a select or a similar control.
  static String? selected(
    Object? value, {
    String message = 'Choose an option',
  }) {
    if (value == null) return message;
    if (value is String && value.trim().isEmpty) return message;
    if (value is Iterable && value.isEmpty) return message;
    return null;
  }

  /// Fails when [value] is shorter than [length] characters.
  static String? minLength(
    String? value,
    int length, {
    String? message,
  }) {
    final String text = value ?? '';
    if (text.length >= length) return null;
    return message ?? 'Enter at least $length characters';
  }

  /// Runs [validators] in order and reports the first failure, so a field can
  /// carry several rules without nesting them by hand.
  static String? Function(String?) all(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final String? Function(String?) validator in validators) {
        final String? failure = validator(value);
        if (failure != null) return failure;
      }
      return null;
    };
  }
}
