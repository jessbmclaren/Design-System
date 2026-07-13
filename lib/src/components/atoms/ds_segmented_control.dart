import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../util/ds_motion.dart';
import 'ds_icon.dart';

/// A single option in a [DsSegmentedControl].
@immutable
class DsSegment<T> {
  /// Creates a segment. An icon-only segment (no [label]) must carry a
  /// [semanticLabel] so assistive technology can name it.
  const DsSegment({
    required this.value,
    this.label,
    this.icon,
    this.semanticLabel,
  }) : assert(
          label != null || semanticLabel != null,
          'An icon-only segment needs a semanticLabel.',
        );

  /// The value this segment selects.
  final T value;

  /// The visible text. Omit for an icon-only segment.
  final String? label;

  /// An optional leading glyph.
  final IconData? icon;

  /// The name announced to assistive technology. Falls back to [label]; supply
  /// it when the segment shows only an icon.
  final String? semanticLabel;
}

/// A pick-one control: a rounded track of mutually exclusive [segments] where
/// the selected one fills with the accent colour.
///
/// Reach for it when a small, fixed set of alternatives share one axis: a sort
/// direction (Ascending / Descending), a boolean join (And / Or), a preview
/// width (Phone / Tablet / Desktop). For a longer or open-ended list use
/// [DsSelect] instead.
///
/// The control is controlled: the caller owns [value] and is told of a change
/// through [onChanged]. A null [onChanged] disables the control and drops it
/// from the focus order. Each segment is keyboard-focusable, activates on Enter
/// and Space and exposes its selected state to assistive technology. The fill
/// animates through the motion tokens and holds still under reduced motion.
class DsSegmentedControl<T> extends StatelessWidget {
  /// Creates a segmented control over [segments].
  const DsSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  }) : assert(
          segments.length >= 2,
          'A segmented control needs at least two segments.',
        );

  /// The mutually exclusive options, left to right.
  final List<DsSegment<T>> segments;

  /// The currently selected value.
  final T value;

  /// Called with a segment's value when it is chosen. A null callback disables
  /// the whole control.
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final bool enabled = onChanged != null;
    final radius = BorderRadius.circular(tokens.formBorderRadius);

    final Widget track = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tokens.colorBorder),
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final segment in segments)
              _Segment<T>(
                segment: segment,
                selected: segment.value == value,
                onTap: enabled ? () => onChanged!(segment.value) : null,
                tokens: tokens,
              ),
          ],
        ),
      ),
    );

    if (enabled) return track;
    // A disabled control dims and leaves the focus order.
    return Opacity(
      opacity: tokens.stateDisabledOpacity,
      child: IgnorePointer(child: track),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.selected,
    required this.onTap,
    required this.tokens,
  });

  final DsSegment<T> segment;
  final bool selected;
  final VoidCallback? onTap;
  final DsTokens tokens;

  @override
  Widget build(BuildContext context) {
    // The accent fill, not colour alone, carries the selection; the on-accent
    // token keeps the selected label readable on the fill in any skin.
    final Color foreground =
        selected ? tokens.buttonPrimaryColorText : tokens.colorSecondaryText;

    final content = <Widget>[
      if (segment.icon != null) ...<Widget>[
        DsIcon(icon: segment.icon!, size: DsIconSize.xs, color: foreground),
        if (segment.label != null) SizedBox(width: tokens.spacingUnit / 2),
      ],
      if (segment.label != null)
        Text(segment.label!, style: tokens.labelMd.toTextStyle(color: foreground)),
    ];

    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        label: segment.semanticLabel ?? segment.label,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: ExcludeSemantics(
              child: AnimatedContainer(
                duration:
                    DsMotion.durationOf(context, const Duration(milliseconds: 150)),
                curve: DsMotion.curveOf(context, Curves.easeInOut),
                // A 48dp minimum on both axes keeps every segment an accessible
                // touch target.
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                padding: EdgeInsets.symmetric(horizontal: tokens.spacingUnit),
                alignment: Alignment.center,
                color: selected ? tokens.formAccentColor : null,
                child: Row(mainAxisSize: MainAxisSize.min, children: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
