import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../theme/ds_tokens_extension.dart';
import 'ds_key_hint.dart';
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
/// ignored and assistive technology announces the label as busy. A pending
/// button keeps its enabled fill and its place in the keyboard focus order
/// (busy, not disabled), so the spinner holds a clear contrast against it and
/// focus does not drop off the control mid-flight. Set [fullWidth] on compact
/// layouts where a button should span the available width.
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
    this.keyHint,
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

  /// The keys shown as a trailing hint, teaching the shortcut that triggers
  /// this action (`['N']`, `['⌘', '↵']`). The hint is decorative: the button
  /// already carries the action and its name.
  final List<String>? keyHint;

  /// Whether an action is in flight. Shows a spinner over the label (kept
  /// mounted at zero opacity so the width holds) and swallows presses while
  /// keeping the button in the keyboard focus order. The fill stays the
  /// enabled colour: the button is busy, not disabled, and the spinner needs
  /// the contrast of the full fill.
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

  /// Cached reduce-motion flag, refreshed in [didChangeDependencies].
  ///
  /// [_onStatesChanged] can fire while the element is deactivated: unmounting
  /// the button mid-press cancels the tap and the InkWell flips the pressed
  /// state on the shared controller. Looking up MediaQuery through the
  /// deactivated context would throw, so the listener reads this field
  /// instead.
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _states.addListener(_onStatesChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = DsMotion.reduced(context);
  }

  @override
  void dispose() {
    _states.removeListener(_onStatesChanged);
    _states.dispose();
    _scale.dispose();
    super.dispose();
  }

  /// Swallows a press while [DsButton.pending] is set: the button stays in
  /// the focus order, but the action must not fire twice.
  static void _ignorePress() {}

  void _onStatesChanged() {
    // A busy button swallows presses, so it gives no press feedback either.
    final pressed =
        !widget.pending && _states.value.contains(WidgetState.pressed);
    if (pressed == _wasPressed) return;
    _wasPressed = pressed;
    if (_reduceMotion) {
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
          tokens.buttonTertiaryColorBackground,
          tokens.buttonTertiaryColorBorder,
          tokens.buttonTertiaryColorText,
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
    // and label through the state opacity tokens. A text button has no fill
    // to fade, so its label carries the whole state.
    final (disabledBackground, disabledForeground) = switch (widget.variant) {
      DsButtonVariant.primary => (
          tokens.buttonPrimaryDisabledColorBackground,
          tokens.buttonPrimaryDisabledColorText,
        ),
      DsButtonVariant.tertiary => (
          background,
          foreground.withValues(alpha: tokens.stateDisabledOpacity),
        ),
      _ => (
          background.withValues(alpha: tokens.stateDisabledOpacity),
          foreground.withValues(alpha: tokens.stateDisabledTextOpacity),
        ),
    };

    final hasAction = widget.onPressed != null;
    final label = tokens.buttonLabelTextTransform.apply(widget.label);

    final Widget content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: tokens.buttonIconSize),
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
          Icon(widget.trailingIcon, size: tokens.buttonIconSize),
        ],
        if (widget.keyHint != null) ...[
          SizedBox(width: tokens.spacingUnit),
          DsKeyHint(keys: widget.keyHint!, onSurface: true),
        ],
      ],
    );

    // While pending the label is hidden, not removed, so the button keeps its
    // width and the spinner centres over it. Opacity zero also drops the
    // label from the semantics tree; the busy name is set explicitly on the
    // button's own node, so the focusable, tappable node keeps its name. The
    // wrapper node at the bottom of build carries the same name.
    final child = widget.pending
        ? Semantics(
            label: '$label, busy',
            child: Stack(
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
            ),
          )
        : content;

    return Semantics(
      button: true,
      // Busy is not disabled: a pending button with an action stays enabled
      // (and focusable), it merely swallows presses until the flight lands.
      enabled: hasAction,
      // The focus itself lives on the inner button, which stays enabled
      // while busy; this node surfaces the focusability it really has.
      focusable: widget.pending && hasAction ? true : null,
      label: widget.pending ? '$label, busy' : null,
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : null,
        child: ScaleTransition(
          scale: _scale,
          child: FilledButton(
            // A pending button keeps a live (no-op) callback, so it stays in
            // the keyboard focus order while the action is in flight; only a
            // null [DsButton.onPressed] truly disables it.
            onPressed: !hasAction
                ? null
                : widget.pending
                    ? _ignorePress
                    : widget.onPressed,
            statesController: _states,
            style: FilledButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              // Pending is busy, not disabled: the enabled fill stays, so the
              // spinner (drawn in the variant's text colour) keeps the 3:1
              // non-text contrast the disabled tint would lose.
              disabledBackgroundColor:
                  widget.pending ? background : disabledBackground,
              disabledForegroundColor:
                  widget.pending ? foreground : disabledForeground,
              elevation: 0,
              // The scale is the press feedback; drop the ink splash.
              splashFactory: NoSplash.splashFactory,
              minimumSize: Size(0, tokens.buttonMinHeight),
              // Guarantee the 48dp touch target on every platform, not just the
              // touch defaults: padded only adds an invisible hit area, so the
              // visual fill and mouse density are unchanged.
              tapTargetSize: MaterialTapTargetSize.padded,
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
                  return BorderSide(
                    color: foreground,
                    width: tokens.focusRingWidth,
                  );
                }
                return BorderSide(
                  color: border,
                  width: tokens.buttonRestBorderWidth,
                );
              }),
              // While busy the button swallows presses, so the hover and
              // press washes would promise an interaction that cannot
              // happen; the focus ring above still marks keyboard focus.
              overlayColor: widget.pending
                  ? const WidgetStatePropertyAll(Colors.transparent)
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
