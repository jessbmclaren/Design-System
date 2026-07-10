import 'package:flutter/material.dart';

import 'ds_button.dart';

/// A provider sign-in button, such as "Continue with Google".
///
/// [DsSocialButton] is a preset of [DsButton]: a full-width secondary button
/// with a leading provider [icon]. It exists so every social or SSO action
/// across the product reads identically and inherits the button's press
/// feedback, pending state and theming.
///
/// A null [onPressed] disables the button. Set [pending] while the provider
/// handshake is in flight; the label is replaced by a spinner and taps are
/// blocked, exactly as on [DsButton]. The glyph inherits the button's text
/// colour, so pass a monochrome provider mark.
class DsSocialButton extends StatelessWidget {
  /// Creates a provider sign-in button.
  const DsSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.pending = false,
  });

  /// The provider glyph shown before the label.
  final IconData icon;

  /// The button label, for example "Continue with Google".
  final String label;

  /// Called when the button is tapped. A null callback disables it.
  final VoidCallback? onPressed;

  /// Whether the provider handshake is in flight. Shows a spinner and blocks
  /// taps.
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return DsButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      pending: pending,
      variant: DsButtonVariant.secondary,
      fullWidth: true,
    );
  }
}
