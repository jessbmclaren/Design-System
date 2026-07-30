import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
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
    this.dense = false,
    this.reserveErrorSpace = false,
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

  /// Whether to render compactly, without the 48dp minimum tap target. Use in
  /// dense contexts such as a data-table selection cell, where the row sets its
  /// own height; leave it false for a standalone control so touch stays
  /// accessible.
  final bool dense;

  /// Whether to hold a blank caption line while there is no [errorText], so the
  /// control's height does not change when a single-line error appears or
  /// clears — whatever sits below (a submit button, say) then stays put.
  /// Reserves one line; a wrapping, multi-line error still grows past it.
  final bool reserveErrorSpace;

  static const double _boxSize = 18;
  static const double _labelGap = 8;

  @override
  State<DsCheckbox> createState() => _DsCheckboxState();
}

class _DsCheckboxState extends State<DsCheckbox> {
  bool _focused = false;
  bool _hovered = false;

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

    // Keyboard focus draws the ring around the box, separated by a thin
    // surface-coloured gap so it stays visible on a checked, accent-filled
    // box. Shadows take no layout space, so the ring never shifts the row.
    final List<BoxShadow>? focusRing = _focused
        ? <BoxShadow>[
            BoxShadow(
              color: tokens.focusRingColor,
              spreadRadius: tokens.focusRingWidth + tokens.focusRingGap,
            ),
            BoxShadow(
              color: tokens.colorBackground,
              spreadRadius: tokens.focusRingGap,
            ),
          ]
        : null;

    final box = AnimatedContainer(
      duration: DsMotion.durationOf(context, DsMotion.control),
      curve: DsMotion.curveOf(context, DsMotion.standard),
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
          ? Icon(DsIcons.check,
              size: tokens.iconSizeXs, color: Colors.white)
          : null,
    );

    final Widget? labelChild =
        widget.labelWidget ??
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
      final double boxTopPadding = math.max(
        0,
        (lineHeight - DsCheckbox._boxSize) / 2,
      );
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

    // Hover paints a rounded state layer behind the whole row — box and label
    // together — inset from the spacing unit on every side, so the highlight has
    // breathing room rather than sitting flush against the box. It is a
    // Positioned overlay, so the content keeps its place (the box still aligns
    // to the form's left edge) and the layer is invisible until hovered.
    final double stateInsetX = tokens.spacingUnit;
    final double stateInsetY = tokens.spacingUnit * 0.75;
    final Widget hoverable = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -stateInsetX,
          right: -stateInsetX,
          top: -stateInsetY,
          bottom: -stateInsetY,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: enabled && _hovered
                  ? tokens.colorText.withValues(alpha: tokens.stateHoverOpacity)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(tokens.formBorderRadius),
            ),
          ),
        ),
        content,
      ],
    );

    // A standalone checkbox keeps a comfortable 48dp tap target; a dense one (a
    // table selection cell, say) drops it so the row can set its own height.
    // The state layer and focus ring still overflow the compact bounds, so they
    // read the same in either mode.
    Widget padded = widget.dense
        ? hoverable
        : ConstrainedBox(
            constraints: BoxConstraints(minHeight: tokens.minTapTarget),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: tokens.spacingUnit * 0.5,
                ),
                child: hoverable,
              ),
            ),
          );
    final control = Opacity(
      opacity: enabled ? 1 : tokens.stateDisabledOpacity,
      child: padded,
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
      // The row stays one tap target and keyboard-focusable, but its own ink is
      // suppressed: the visible hover is the box's state layer above and focus
      // is the box's ring. A MouseRegion lets a hover anywhere on the row light
      // that box layer, so the whole row still reads as interactive.
      child: MouseRegion(
        onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
        onExit: enabled ? (_) => setState(() => _hovered = false) : null,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled ? () => widget.onChanged!(!widget.value) : null,
            onFocusChange: (focused) => setState(() => _focused = focused),
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            borderRadius: BorderRadius.circular(tokens.formBorderRadius),
            child: control,
          ),
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
          )
        else if (widget.reserveErrorSpace)
          // A blank caption line the same height as a one-line error, so the
          // control keeps its height as the error appears and clears.
          ExcludeSemantics(
            child: Padding(
              padding: EdgeInsets.only(
                left: labelChild != null
                    ? DsCheckbox._boxSize + DsCheckbox._labelGap
                    : 0,
              ),
              child: Text(
                ' ',
                style: tokens.bodySm.toTextStyle(
                  color: tokens.colorSecondaryText,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
