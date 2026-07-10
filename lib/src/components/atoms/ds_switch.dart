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
/// resting border colour and the thumb the form background colour; when `true`
/// the track fills with the form accent colour and the thumb turns white. The
/// thumb animates between the two positions and settles instantly when the user
/// has requested reduced motion.
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
class DsSwitch extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final enabled = onChanged != null;

    final trackColor = value ? tokens.formAccentColor : tokens.colorBorder;
    final thumbColor =
        value ? const Color(0xFFFFFFFF) : tokens.formBackgroundColor;

    final duration =
        DsMotion.durationOf(context, const Duration(milliseconds: 150));
    final curve = DsMotion.curveOf(context, Curves.easeInOut);

    final track = AnimatedContainer(
      duration: duration,
      curve: curve,
      width: _trackWidth,
      height: _trackHeight,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(_trackHeight / 2),
        border: Border.all(
          color: value ? tokens.formAccentColor : tokens.colorBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_thumbInset),
        child: AnimatedAlign(
          duration: duration,
          curve: curve,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: _thumbDiameter,
            height: _thumbDiameter,
            decoration: BoxDecoration(
              color: thumbColor,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final labelText = label;
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
            onTap: enabled ? () => onChanged!(!value) : null,
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
