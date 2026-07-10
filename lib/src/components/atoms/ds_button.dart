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

  /// A quiet, text-only action such as "Back" or "Skip". Lowest emphasis.
  tertiary,

  /// A grey outline for third-party and utility actions that must not
  /// compete with the brand pair, such as federated sign-in.
  neutral,

  /// A destructive action, such as delete. Use sparingly.
  danger,
}

/// A Design System button.
///
/// Every screen should have at most one [DsButtonVariant.primary] button, the
/// action you most want the user to take. Use [DsButtonVariant.secondary] for
/// supporting actions, [DsButtonVariant.tertiary] for quiet inline actions,
/// [DsButtonVariant.neutral] for third-party actions and
/// [DsButtonVariant.danger] only for destructive ones.
///
/// Set [pending] while an action is in flight: the label stays mounted at
/// zero opacity beneath a spinner, so the button keeps its width, presses are
/// ignored and assistive technology announces the label as busy. Set
/// [fullWidth] on compact layouts where a button should span the available
/// width.
///
/// Keyboard focus draws a ring in the variant's text colour, so it reads
/// distinctly from the hover wash. Pressing the button gives a physical,
/// tactile response: it scales down and springs back through the [DsMotion]
/// tokens (and stays still under reduced motion), with the ink ripple removed
/// so the motion itself is the feedback.
class DsButton extends StatefulWidget {
  const DsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DsButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.pending = false,
    this.fullWidth = false,
  });

  /// A provider sign-in button, such as "Continue with Google".
  ///
  /// A preset of [DsButton]: a full-width [DsButtonVariant.neutral] button
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
      variant: DsButtonVariant.neutral,
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

  /// An optional trailing icon, such as a forward arrow on a continue action.
  final IconData? trailingIcon;

  /// Whether an action is in flight. Shows a spinner over the label (kept
  /// mounted at zero opacity so the width holds) and disables the button.
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
      // Spring back to rest with the calm spring token. Near-critically
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
      DsButtonVariant.tertiary => (
          Colors.transparent,
          Colors.transparent,
          tokens.actionPrimaryColorText,
        ),
      DsButtonVariant.neutral => (
          tokens.buttonNeutralColorBackground,
          tokens.buttonNeutralColorBorder,
          tokens.buttonNeutralColorText,
        ),
      DsButtonVariant.danger => (
          tokens.buttonDangerColorBackground,
          tokens.buttonDangerColorBorder,
          tokens.buttonDangerColorText,
        ),
    };

    // The primary variant reads its disabled treatment from real tokens so a
    // skin can supply a solid tint; the other variants fade their own fill
    // and label. A text button has no fill to fade, so its label carries the
    // whole state.
    final (disabledBackground, disabledForeground) = switch (widget.variant) {
      DsButtonVariant.primary => (
          tokens.buttonPrimaryDisabledColorBackground,
          tokens.buttonPrimaryDisabledColorText,
        ),
      DsButtonVariant.tertiary => (
          Colors.transparent,
          foreground.withValues(alpha: 0.5),
        ),
      _ => (
          background.withValues(alpha: 0.5),
          foreground.withValues(alpha: 0.9),
        ),
    };

    final enabled = widget.onPressed != null && !widget.pending;
    final label = tokens.buttonLabelTextTransform.apply(widget.label);

    final Widget content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: tokens.buttonLabelFontSize + 2),
          SizedBox(width: tokens.spacingUnit),
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
        if (widget.trailingIcon != null) ...[
          SizedBox(width: tokens.spacingUnit),
          Icon(widget.trailingIcon, size: tokens.buttonLabelFontSize + 2),
        ],
      ],
    );

    // While pending the label is hidden, not removed, so the button keeps its
    // width and the spinner centres over it. Opacity zero also drops the
    // label from the semantics tree; the outer node announces the state.
    final child = widget.pending
        ? Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: 0, child: content),
              ExcludeSemantics(
                child: DsSpinner(
                  size: DsSpinnerSize.small,
                  color: foreground,
                ),
              ),
            ],
          )
        : content;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.pending ? '$label, busy' : null,
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
              disabledBackgroundColor: disabledBackground,
              disabledForegroundColor: disabledForeground,
              elevation: 0,
              // The scale is the press feedback; drop the ink splash.
              splashFactory: NoSplash.splashFactory,
              minimumSize: const Size(0, 40),
              padding: EdgeInsets.symmetric(
                horizontal: tokens.buttonPaddingX,
                vertical: tokens.buttonPaddingY,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.buttonBorderRadius),
              ),
            ).copyWith(
              // Keyboard focus draws a ring in the variant's text colour,
              // which is guaranteed to contrast with the fill, so focus reads
              // distinctly from the hover wash.
              side: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.focused)) {
                  return BorderSide(color: foreground, width: 2);
                }
                return BorderSide(color: border);
              }),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
