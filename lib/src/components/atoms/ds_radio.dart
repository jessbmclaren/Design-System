import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../util/ds_motion.dart';

/// A labelled radio button for choosing one option from a mutually exclusive
/// group.
///
/// [DsRadio] is generic over the type [T] of the group's value. Give every
/// radio in a group the same [groupValue] and a distinct [value]; the control
/// paints itself selected when `value == groupValue`. Tapping an unselected
/// radio calls [onChanged] with this radio's [value] so the parent can update
/// the shared group value.
///
/// ```dart
/// DsRadio<Plan>(
///   value: Plan.basic,
///   groupValue: selectedPlan,
///   label: 'Basic',
///   onChanged: (plan) => setState(() => selectedPlan = plan),
/// );
/// ```
///
/// The whole row (indicator plus [label]) is one tap target, at least 48dp
/// tall for comfortable, accessible touch. Colours come entirely from
/// [DsTokens]: the resting ring uses `colorBorder`, the selected ring and inner
/// dot use `formAccentColor`, and [isError] swaps both for `colorDanger`.
/// Passing a null [onChanged] disables the control, dimming it and removing it
/// from the focus traversal.
class DsRadio<T> extends StatelessWidget {
  /// Creates a labelled radio button.
  const DsRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.isError = false,
  });

  /// The value this radio represents within its group.
  final T value;

  /// The currently selected value of the group. This radio is selected when
  /// [value] equals [groupValue].
  final T? groupValue;

  /// Called with [value] when this radio is tapped while unselected.
  ///
  /// A null callback disables the control.
  final ValueChanged<T?>? onChanged;

  /// Optional text shown to the right of the indicator.
  ///
  /// Long labels wrap across lines rather than overflowing.
  final String? label;

  /// Whether to render the error appearance, tinting the indicator with the
  /// theme's danger colour.
  final bool isError;

  /// The diameter of the radio indicator, in logical pixels.
  static const double _indicatorSize = 18;

  /// The diameter of the filled inner dot shown when selected.
  static const double _dotSize = 8;

  /// The minimum interactive dimension required for an accessible tap target.
  static const double _minTapTarget = 48;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final bool selected = value == groupValue;
    final bool enabled = onChanged != null;

    // Resolve the accent used for the selected ring and dot.
    final Color accent = isError ? tokens.colorDanger : tokens.formAccentColor;
    final Color restingBorder =
        isError ? tokens.colorDanger : tokens.colorBorder;
    final Color ringColor = selected ? accent : restingBorder;

    // Disabled controls read at reduced opacity so the state is visible.
    final double opacity = enabled ? 1 : 0.5;

    final Widget indicator = AnimatedContainer(
      duration: DsMotion.durationOf(context, const Duration(milliseconds: 150)),
      curve: DsMotion.curveOf(context, Curves.easeOut),
      width: _indicatorSize,
      height: _indicatorSize,
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: ringColor,
          width: selected ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        duration: DsMotion.durationOf(context, const Duration(milliseconds: 150)),
        curve: DsMotion.curveOf(context, Curves.easeOut),
        scale: selected ? 1 : 0,
        child: Container(
          width: _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        indicator,
        if (label != null) ...[
          SizedBox(width: tokens.inputFieldPaddingX),
          Flexible(
            child: Text(
              label!,
              style: tokens.bodyMd.toTextStyle(
                color: isError ? tokens.colorDanger : tokens.colorText,
              ),
            ),
          ),
        ],
      ],
    );

    final Widget control = Semantics(
      container: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: opacity,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minTapTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.inputFieldPaddingY),
            child: Align(
              alignment: Alignment.centerLeft,
              child: content,
            ),
          ),
        ),
      ),
    );

    if (!enabled) return control;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => onChanged!(value),
        borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        focusColor: accent.withValues(alpha: 0.12),
        hoverColor: accent.withValues(alpha: 0.06),
        splashColor: accent.withValues(alpha: 0.12),
        child: control,
      ),
    );
  }
}
