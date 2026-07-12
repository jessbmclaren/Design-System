import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../../util/ds_motion.dart';

/// A labelled checkbox.
///
/// Use a [DsCheckbox] for an independent on/off choice, such as accepting terms
/// or toggling a single option. For a set of mutually exclusive options prefer a
/// radio group instead.
///
/// The control renders a small square that is empty when unchecked and filled
/// with the theme's [DsTokens.formAccentColor] and a white check when checked.
/// Provide a [label] to render tappable text beside the box, or a [labelWidget]
/// when the label needs rich content such as an inline link; the entire row is
/// then a single tap target that toggles the value. The box aligns with the
/// first line of the label, so a label that wraps across lines keeps the box at
/// the top rather than floating in the middle.
///
/// A null [onChanged] disables the control and dims it. Set [isError] to
/// colour the border with [DsTokens.colorDanger] when the surrounding form
/// field is invalid, or pass an [errorText] to also render the message beneath
/// the row and announce it with the control. Keyboard focus draws a ring
/// around the box in the accent colour.
///
/// The whole control exposes a semantics node describing its checked, enabled
/// and label state, and always presents at least a 48dp tap target for
/// accessible touch. Pass a [semanticLabel] to override the announced name,
/// which is essential when [labelWidget] carries no plain text of its own.
class DsCheckbox extends StatefulWidget {
  /// Creates a labelled checkbox.
  const DsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.labelWidget,
    this.errorText,
    this.semanticLabel,
    this.isError = false,
  }) : assert(
          label == null || labelWidget == null,
          'Provide a label or a labelWidget, not both.',
        );

  /// Whether the checkbox is currently checked.
  final bool value;

  /// Called with the new value when the control is tapped. A null callback
  /// disables the checkbox.
  final ValueChanged<bool>? onChanged;

  /// Optional text rendered to the right of the box. The whole row is tappable.
  final String? label;

  /// Optional widget rendered to the right of the box instead of [label], for
  /// rich content such as a consent sentence with an inline link. The whole
  /// row is tappable and the widget keeps its own semantics, so links inside
  /// it stay reachable. Provide a [semanticLabel] when the widget carries no
  /// readable text.
  final Widget? labelWidget;

  /// Validation message rendered beneath the row in the danger colour and
  /// announced together with the control. Setting it also applies the error
  /// border, as [isError] does.
  final String? errorText;

  /// Overrides the name announced to assistive technology. Defaults to
  /// [label].
  final String? semanticLabel;

  /// Whether the field is in an error state, which colours the box border with
  /// the theme's danger colour.
  final bool isError;

  static const double _boxSize = 18;
  static const double _labelGap = 8;

  /// Focus ring geometry: an accent ring of this width, held off the box by a
  /// surface-coloured gap. There is no dedicated focus-ring token yet, so the
  /// widths are fixed here and the colours come from existing tokens.
  static const double _focusRingWidth = 2;
  static const double _focusRingGap = 1;

  @override
  State<DsCheckbox> createState() => _DsCheckboxState();
}

class _DsCheckboxState extends State<DsCheckbox> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final enabled = widget.onChanged != null;
    final hasError = widget.isError || widget.errorText != null;

    final Color borderColor;
    if (hasError) {
      borderColor = tokens.colorDanger;
    } else if (widget.value) {
      borderColor = tokens.formAccentColor;
    } else {
      borderColor = tokens.colorBorder;
    }

    // Keyboard focus draws an accent ring around the box, separated by a thin
    // surface-coloured gap so it stays visible on a checked, accent-filled
    // box. Shadows take no layout space, so the ring never shifts the row.
    final List<BoxShadow>? focusRing = _focused
        ? <BoxShadow>[
            BoxShadow(
              color: tokens.formAccentColor,
              spreadRadius:
                  DsCheckbox._focusRingWidth + DsCheckbox._focusRingGap,
            ),
            BoxShadow(
              color: tokens.colorBackground,
              spreadRadius: DsCheckbox._focusRingGap,
            ),
          ]
        : null;

    final box = AnimatedContainer(
      duration: DsMotion.durationOf(context, const Duration(milliseconds: 150)),
      curve: DsMotion.curveOf(context, Curves.easeOut),
      width: DsCheckbox._boxSize,
      height: DsCheckbox._boxSize,
      decoration: BoxDecoration(
        color: widget.value
            ? tokens.formAccentColor
            : tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
        boxShadow: focusRing,
      ),
      child: widget.value
          ? const Icon(
              DsIcons.check,
              size: DsIconSize.xs,
              color: Colors.white,
            )
          : null,
    );

    final Widget? labelChild = widget.labelWidget ??
        (widget.label != null
            ? Text(
                widget.label!,
                style: tokens.bodyMd.toTextStyle(color: tokens.colorText),
              )
            : null);

    Widget content = box;
    if (labelChild != null) {
      // Top-align the box against the label so a wrapping label keeps the box
      // on its first line. The top padding centres the box within that first
      // line, which leaves a single-line row rendered exactly as before.
      final double lineHeight =
          tokens.bodyMd.fontSize * (tokens.bodyMd.height ?? 1);
      final double boxTopPadding =
          math.max(0, (lineHeight - DsCheckbox._boxSize) / 2);
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: boxTopPadding),
            child: box,
          ),
          const SizedBox(width: DsCheckbox._labelGap),
          Flexible(child: labelChild),
        ],
      );
    }

    final control = Opacity(
      opacity: enabled ? 1 : 0.5,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: tokens.minTapTarget),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: content,
          ),
        ),
      ),
    );

    // The announced name is the override, falling back to the plain label, and
    // the error is appended so assistive technology hears it with the control
    // rather than as a detached line of text.
    final String? announcedName = widget.semanticLabel ?? widget.label;
    final String? announced = widget.errorText == null
        ? announcedName
        : (announcedName == null
            ? widget.errorText
            : '$announcedName, ${widget.errorText}');

    final interactive = Semantics(
      container: true,
      checked: widget.value,
      enabled: enabled,
      label: announced,
      // A plain-text label is spoken through the node itself; a rich label
      // keeps its descendants so inline links stay reachable.
      excludeSemantics: widget.labelWidget == null,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: enabled ? () => widget.onChanged!(!widget.value) : null,
          onFocusChange: (focused) => setState(() => _focused = focused),
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          child: control,
        ),
      ),
    );

    // The Column is always the root, whether or not an error shows, so
    // toggling errorText only adds or removes the error line. A stable tree
    // shape keeps the InkWell element alive across the rebuild, which
    // preserves keyboard focus and lets the focus ring track reality.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        interactive,
        if (widget.errorText != null)
          // Spoken through the control's semantics node above, so the visible
          // text is excluded to avoid a double announcement.
          ExcludeSemantics(
            child: Padding(
              padding: EdgeInsets.only(
                left: labelChild != null
                    ? DsCheckbox._boxSize + DsCheckbox._labelGap
                    : 0,
              ),
              child: Text(
                widget.errorText!,
                style: tokens.bodySm.toTextStyle(color: tokens.colorDanger),
              ),
            ),
          ),
      ],
    );
  }
}
