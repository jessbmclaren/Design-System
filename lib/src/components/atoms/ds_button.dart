import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import 'ds_spinner.dart';

/// The visual emphasis of a [DsButton].
enum DsButtonVariant {
  /// The single most important action on a screen. High emphasis.
  primary,

  /// A supporting action. Medium emphasis.
  secondary,

  /// A destructive action, such as delete. Use sparingly.
  danger,
}

/// A Design System button.
///
/// Every screen should have at most one [DsButtonVariant.primary] button — the
/// action you most want the user to take. Use [DsButtonVariant.secondary] for
/// supporting actions and [DsButtonVariant.danger] only for destructive ones.
///
/// Set [pending] while an action is in flight; the label is replaced by a
/// spinner and the button is disabled so the action cannot be triggered
/// twice. Set [fullWidth] on compact layouts where a button should span the
/// available width.
class DsButton extends StatelessWidget {
  const DsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DsButtonVariant.primary,
    this.icon,
    this.pending = false,
    this.fullWidth = false,
  });

  /// The button label.
  final String label;

  /// Called when the button is tapped. A null callback disables the button.
  final VoidCallback? onPressed;

  /// The visual emphasis of the button.
  final DsButtonVariant variant;

  /// An optional leading icon.
  final IconData? icon;

  /// Whether an action is in flight. Replaces the label with a spinner and
  /// disables the button.
  final bool pending;

  /// Whether the button expands to fill the available width.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final (background, border, foreground) = switch (variant) {
      DsButtonVariant.primary => (
          tokens.buttonPrimaryColorBackground,
          tokens.buttonPrimaryColorBorder,
          tokens.buttonPrimaryColorText,
        ),
      DsButtonVariant.secondary => (
          tokens.buttonSecondaryColorBackground,
          tokens.buttonSecondaryColorBorder,
          tokens.buttonSecondaryColorText,
        ),
      DsButtonVariant.danger => (
          tokens.buttonDangerColorBackground,
          tokens.buttonDangerColorBorder,
          tokens.buttonDangerColorText,
        ),
    };

    final enabled = onPressed != null && !pending;
    final label = tokens.buttonLabelTextTransform.apply(this.label);

    final child = pending
        ? SizedBox(
            height: tokens.buttonLabelFontSize + 4,
            child: Center(
              child: DsSpinner(
                size: DsSpinnerSize.small,
                color: foreground,
                semanticLabel: 'Working',
              ),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: tokens.buttonLabelFontSize + 2),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: tokens.buttonLabelFontSize,
                    fontWeight: tokens.buttonLabelFontWeight,
                  ),
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: enabled,
      label: pending ? 'Working' : null,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            disabledBackgroundColor: background.withValues(alpha: 0.5),
            disabledForegroundColor: foreground.withValues(alpha: 0.9),
            elevation: 0,
            minimumSize: const Size(0, 40),
            padding: EdgeInsets.symmetric(
              horizontal: tokens.buttonPaddingX + 12,
              vertical: tokens.buttonPaddingY + 6,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(tokens.buttonBorderRadius),
              side: BorderSide(color: border),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
