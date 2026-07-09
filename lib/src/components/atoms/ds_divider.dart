import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// The orientation of a [DsDivider].
enum DsDividerAxis {
  /// A rule that runs left-to-right, separating stacked content.
  horizontal,

  /// A rule that runs top-to-bottom, separating side-by-side content.
  vertical,
}

/// A hairline rule used to visually separate content.
///
/// The divider draws a single line coloured with the active theme's
/// [DsTokens.colorBorder]. A [DsDividerAxis.horizontal] divider fills the
/// available width and reserves a fixed height equal to [thickness]; a
/// [DsDividerAxis.vertical] divider fills the available height and reserves a
/// fixed width equal to [thickness].
///
/// Use [indent] / [endIndent] to inset the rule from the leading / trailing
/// edge (respecting the ambient text direction for horizontal dividers), and
/// [length] to constrain the divider to a fixed extent along its main axis.
///
/// The divider is purely decorative, so it is hidden from assistive
/// technologies via [Semantics].
///
/// ```dart
/// const DsDivider();
///
/// const SizedBox(
///   height: 24,
///   child: DsDivider(axis: DsDividerAxis.vertical),
/// );
/// ```
class DsDivider extends StatelessWidget {
  /// Creates a hairline rule.
  const DsDivider({
    super.key,
    this.axis = DsDividerAxis.horizontal,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.length,
    this.color,
  })  : assert(thickness >= 0, 'thickness must be non-negative'),
        assert(indent >= 0, 'indent must be non-negative'),
        assert(endIndent >= 0, 'endIndent must be non-negative'),
        assert(length == null || length >= 0, 'length must be non-negative');

  /// Whether the rule runs horizontally or vertically.
  ///
  /// Defaults to [DsDividerAxis.horizontal].
  final DsDividerAxis axis;

  /// The stroke width of the rule, in logical pixels.
  ///
  /// This is the height of a horizontal divider and the width of a vertical
  /// one. Defaults to `1`.
  final double thickness;

  /// Empty space inset before the rule along its main axis.
  ///
  /// For a horizontal divider this insets the leading edge (left in
  /// left-to-right, right in right-to-left); for a vertical divider it insets
  /// the top. Defaults to `0`.
  final double indent;

  /// Empty space inset after the rule along its main axis.
  ///
  /// For a horizontal divider this insets the trailing edge; for a vertical
  /// divider it insets the bottom. Defaults to `0`.
  final double endIndent;

  /// An optional fixed extent for the rule along its main axis.
  ///
  /// When `null` (the default) the divider expands to fill the available space
  /// on its main axis. Provide a value to cap the rule at a fixed length; the
  /// divider then sizes to `indent + length + endIndent` (clamped to the
  /// available space) and centres within any surplus space.
  final double? length;

  /// Overrides the rule colour. Defaults to [DsTokens.colorBorder].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final Color lineColor = color ?? tokens.colorBorder;
    final bool isHorizontal = axis == DsDividerAxis.horizontal;

    // The painted rule, inset from the edges of its main axis.
    final Widget line = Padding(
      padding: isHorizontal
          ? EdgeInsetsDirectional.only(start: indent, end: endIndent)
          : EdgeInsets.only(top: indent, bottom: endIndent),
      child: SizedBox(
        width: isHorizontal ? double.infinity : thickness,
        height: isHorizontal ? thickness : double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(color: lineColor),
        ),
      ),
    );

    // When a fixed length is requested we bound the main axis so the divider
    // does not expand to fill its parent, and centre it within any surplus.
    Widget content = line;
    if (length != null) {
      final double mainExtent = indent + length! + endIndent;
      content = Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isHorizontal ? mainExtent : thickness,
            maxHeight: isHorizontal ? thickness : mainExtent,
          ),
          child: line,
        ),
      );
    }

    // A horizontal divider needs a resolved height; a vertical divider needs a
    // resolved width. The cross-axis extent is exactly [thickness]; the main
    // axis is left to the parent (or bounded above by [length]).
    return Semantics(
      excludeSemantics: true,
      child: SizedBox(
        width: isHorizontal ? null : thickness,
        height: isHorizontal ? thickness : null,
        child: content,
      ),
    );
  }
}
