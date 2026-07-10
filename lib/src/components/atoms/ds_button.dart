import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../util/ds_motion.dart';
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
/// Every screen should have at most one [DsButtonVariant.primary] button, the
/// action you most want the user to take. Use [DsButtonVariant.secondary] for
/// supporting actions and [DsButtonVariant.danger] only for destructive ones.
///
/// Set [pending] while an action is in flight; the label is replaced by a
/// spinner and the button is disabled so the action cannot be triggered
/// twice. Set [fullWidth] on compact layouts where a button should span the
/// available width.
///
/// Pressing the button gives a physical, tactile response: it scales down and
/// springs back through the [DsMotion] tokens (and stays still under reduced
/// motion), with the ink ripple removed so the motion itself is the feedback.
class DsButton extends StatefulWidget {
  const DsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DsButtonVariant.primary,
    this.icon,
    this.pending = false,
    this.fullWidth = false,
  });

  /// A provider sign-in button, such as "Continue with Google".
  ///
  /// A preset of [DsButton]: a full-width [DsButtonVariant.secondary] button
  /// with a leading provider [icon], so every social or SSO action across the
  /// product reads identically. A social button is a variant of the button, not
  /// a component of its own. The glyph inherits the button's text colour, so
  /// pass a monochrome provider mark.
  factory DsButton.social({
    Key? key,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool pending = false,
  }) {
    return DsButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      pending: pending,
      variant: DsButtonVariant.secondary,
      fullWidth: true,
    );
  }

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
  State<DsButton> createState() => _DsButtonState();
}

class _DsButtonState extends State<DsButton>
    with SingleTickerProviderStateMixin {
  /// How far the button scales down while held: a subtle physical push.
  static const double _pressedScale = 0.96;

  final WidgetStatesController _states = WidgetStatesController();

  /// Drives the scale. Unbounded so the spring can overshoot slightly past 1.0
  /// on release before settling.
  late final AnimationController _scale = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );

  bool _wasPressed = false;

  @override
  void initState() {
    super.initState();
    _states.addListener(_onStatesChanged);
  }

  @override
  void dispose() {
    _states.removeListener(_onStatesChanged);
    _states.dispose();
    _scale.dispose();
    super.dispose();
  }

  void _onStatesChanged() {
    final pressed = _states.value.contains(WidgetState.pressed);
    if (pressed == _wasPressed) return;
    _wasPressed = pressed;
    if (DsMotion.reduced(context)) {
      _scale.value = 1;
      return;
    }
    if (pressed) {
      // Quick, decisive push down.
      _scale.animateTo(
        _pressedScale,
        duration: DsMotion.fast,
        curve: DsMotion.emphasized,
      );
    } else {
      // Spring back to rest with the calm spring token — near-critically
      // damped, so it settles with a single small overshoot and no rebounds.
      _scale.animateWith(
        SpringSimulation(DsMotion.spring, _scale.value, 1, _scale.velocity),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final (background, border, foreground) = switch (widget.variant) {
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

    final enabled = widget.onPressed != null && !widget.pending;
    final label = tokens.buttonLabelTextTransform.apply(widget.label);

    final child = widget.pending
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
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: tokens.buttonLabelFontSize + 2),
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
      label: widget.pending ? 'Working' : null,
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : null,
        child: ScaleTransition(
          scale: _scale,
          child: FilledButton(
            onPressed: enabled ? widget.onPressed : null,
            statesController: _states,
            style: FilledButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              disabledBackgroundColor: background.withValues(alpha: 0.5),
              disabledForegroundColor: foreground.withValues(alpha: 0.9),
              elevation: 0,
              // The scale is the press feedback; drop the ink splash.
              splashFactory: NoSplash.splashFactory,
              minimumSize: const Size(0, 40),
              padding: EdgeInsets.symmetric(
                horizontal: tokens.buttonPaddingX + 12,
                vertical: tokens.buttonPaddingY + 6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.buttonBorderRadius),
                side: BorderSide(color: border),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
