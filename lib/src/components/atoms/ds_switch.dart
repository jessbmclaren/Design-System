import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../util/ds_motion.dart';

/// A labelled on/off switch.
///
/// Use a [DsSwitch] for a binary setting that takes effect immediately, such as
/// toggling a preference on or off. For a choice the user must confirm as part
/// of a form submission, prefer a checkbox instead.
///
/// The control renders a pill-shaped track with a circular thumb that slides
/// between the off and on positions. When [value] is `false` the track uses the
/// resting border colour; when `true` it fills with the form accent colour. The
/// thumb keeps the theme's [DsTokens.buttonPrimaryColorText] in both positions,
/// the same content-on-accent colour a primary button label uses, so it stays
/// legible on the filled track in dark themes, and lifts on
/// [DsTokens.shadowLow]. The thumb animates between the two positions and
/// settles instantly when the user has requested reduced motion. Keyboard
/// focus draws a ring around the track in the accent colour.
///
/// Pass an [onChanged] callback to receive the requested value. A `null`
/// callback renders the switch as disabled at a reduced opacity and stops it
/// responding to input. Provide an optional [label] to describe what the switch
/// controls; it sits to the right of the track, wraps on narrow layouts and is
/// associated with the control so tapping either toggles the value.
///
/// ```dart
/// DsSwitch(
///   value: notificationsEnabled,
///   label: 'Email notifications',
///   onChanged: (next) => setState(() => notificationsEnabled = next),
/// )
/// ```
class DsSwitch extends StatefulWidget {
  /// Creates a labelled on/off switch.
  const DsSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  /// Whether the switch is currently on.
  final bool value;

  /// Called with the requested value when the user toggles the switch.
  ///
  /// A `null` callback disables the control.
  final ValueChanged<bool>? onChanged;

  /// An optional description shown to the right of the track.
  final String? label;

  // The track is a 44x26 pill; the thumb is a 22dp circle inset by 2dp, so it
  // travels 18dp between the off and on positions.
  static const double _trackWidth = 44;
  static const double _trackHeight = 26;
  static const double _thumbInset = 2;
  static const double _thumbDiameter = _trackHeight - (_thumbInset * 2);

  /// Focus ring geometry: an accent ring of this width, held off the track by
  /// a surface-coloured gap. There is no dedicated focus-ring token yet, so
  /// the widths are fixed here and the colours come from existing tokens.
  static const double _focusRingWidth = 2;
  static const double _focusRingGap = 1;

  @override
  State<DsSwitch> createState() => _DsSwitchState();
}

class _DsSwitchState extends State<DsSwitch> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final enabled = widget.onChanged != null;
    final value = widget.value;

    final trackColor = value ? tokens.formAccentColor : tokens.colorBorder;

    final duration =
        DsMotion.durationOf(context, const Duration(milliseconds: 150));
    final curve = DsMotion.curveOf(context, Curves.easeInOut);

    // Keyboard focus draws an accent ring around the pill, separated by a
    // thin surface-coloured gap so it stays visible on the accent-filled
    // track. Shadows take no layout space, so the ring never shifts the row.
    final List<BoxShadow>? focusRing = _focused
        ? <BoxShadow>[
            BoxShadow(
              color: tokens.formAccentColor,
              spreadRadius: DsSwitch._focusRingWidth + DsSwitch._focusRingGap,
            ),
            BoxShadow(
              color: tokens.colorBackground,
              spreadRadius: DsSwitch._focusRingGap,
            ),
          ]
        : null;

    final track = AnimatedContainer(
      duration: duration,
      curve: curve,
      width: DsSwitch._trackWidth,
      height: DsSwitch._trackHeight,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(DsSwitch._trackHeight / 2),
        border: Border.all(
          color: value ? tokens.formAccentColor : tokens.colorBorder,
        ),
        boxShadow: focusRing,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsSwitch._thumbInset),
        child: AnimatedAlign(
          duration: duration,
          curve: curve,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: DsSwitch._thumbDiameter,
            height: DsSwitch._thumbDiameter,
            decoration: BoxDecoration(
              // Content-on-accent: the thumb rides the accent-filled track, so
              // it takes the same token a primary button label uses. White in
              // the default themes, which keeps the resting appearance
              // unchanged and the thumb legible on the dark theme's track.
              color: tokens.buttonPrimaryColorText,
              shape: BoxShape.circle,
              boxShadow: tokens.shadowLow,
            ),
          ),
        ),
      ),
    );

    final labelText = widget.label;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        track,
        if (labelText != null) ...[
          SizedBox(width: tokens.inputFieldPaddingX),
          Flexible(
            child: Text(
              labelText,
              style: tokens.bodyMd.toTextStyle(color: tokens.colorText),
            ),
          ),
        ],
      ],
    );

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: labelText,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled ? () => widget.onChanged!(!value) : null,
            onFocusChange: (focused) => setState(() => _focused = focused),
            borderRadius: BorderRadius.circular(tokens.formBorderRadius),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: tokens.inputFieldPaddingY,
                ),
                child: row,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
