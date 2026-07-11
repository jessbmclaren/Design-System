import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// Groups related form fields together under an optional legend and
/// description, as an accessible fieldset.
///
/// [DsFormFieldGroup] is the layout primitive for a coherent block of inputs,
/// for example an address block (street, city, postal code) or a pair of
/// "first name" / "last name" fields. It renders, top to bottom:
///
/// 1. an optional [legend] (medium label in [DsTokens.strongLabelFontWeight]
///    and the primary text colour) that names the group;
/// 2. an optional [description] (small body text, in the secondary text colour)
///    that explains it; and
/// 3. the [children] fields, separated by [spacing].
///
/// The whole group is wrapped in a `Semantics(container: true)` node so
/// assistive technology announces it as a single grouping, mirroring the
/// semantics of an HTML `<fieldset>`/`<legend>`.
///
/// ## Responsiveness
///
/// The group adapts to the available width, never overflowing down to a 320dp
/// phone:
///
/// * When the group is narrower than [minRowWidth] the children stack
///   full-width, one per row.
/// * At [minRowWidth] and wider, when [columns] is `2` (the default), the
///   children flow two-per-row via a [Wrap], each taking half the available
///   width less the gutter. Set [columns] to `1` to keep a single stacked
///   column at every size.
///
/// The threshold tracks the group's own width, not the window, so a pair of
/// fields goes side by side inside a narrow card as soon as there is room.
///
/// The widget is purely declarative (it starts no timers or animations), so
/// it renders identically in screenshots and live use.
///
/// ```dart
/// DsFormFieldGroup(
///   legend: 'Shipping address',
///   description: 'Where should we send your order?',
///   children: [
///     DsTextField(label: 'Street'),
///     DsTextField(label: 'City'),
///     DsTextField(label: 'Postal code'),
///     DsTextField(label: 'Country'),
///   ],
/// )
/// ```
class DsFormFieldGroup extends StatelessWidget {
  /// Creates a group of related form fields.
  ///
  /// [children] is required; [legend] and [description] are optional.
  const DsFormFieldGroup({
    super.key,
    this.legend,
    this.description,
    required this.children,
    this.spacing,
    this.columns = 2,
    this.minRowWidth = 360,
  }) : assert(columns == 1 || columns == 2, 'columns must be 1 or 2');

  /// Optional heading that names the group. Rendered with the medium label
  /// token in [DsTokens.strongLabelFontWeight] and the primary text colour.
  final String? legend;

  /// Optional supporting text shown beneath the [legend], in the small body
  /// token and the secondary text colour.
  final String? description;

  /// The form fields to lay out within the group.
  final List<Widget> children;

  /// The gap, in logical pixels, between adjacent children (both the vertical
  /// gap between rows and the horizontal gutter between columns). When null,
  /// resolves to twice [DsTokens.spacingUnit], 16 with the default tokens, so
  /// the group re-spaces with the active skin.
  final double? spacing;

  /// The maximum number of columns to flow children into on medium and wider
  /// layouts. Either `1` (always stacked) or `2` (two-per-row when there is
  /// room). Defaults to `2`. Compact layouts always use a single column.
  final int columns;

  /// The minimum width, in logical pixels, at which the group lays two columns
  /// side by side. Below it the fields stack full-width. The threshold tracks
  /// the group's own width, not the window, so a pair of fields goes two-up
  /// inside a narrow card as soon as there is room. Defaults to `360`.
  final double minRowWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final double gap = spacing ?? tokens.spacingUnit * 2;

    final header = <Widget>[
      if (legend != null && legend!.isNotEmpty)
        Text(
          legend!,
          style: tokens.labelMd
              .copyWith(fontWeight: tokens.strongLabelFontWeight)
              .toTextStyle(color: tokens.colorText),
        ),
      if (description != null && description!.isNotEmpty) ...[
        if (legend != null && legend!.isNotEmpty)
          SizedBox(height: tokens.spacingUnit / 2),
        Text(
          description!,
          style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
        ),
      ],
    ];

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: (legend != null && legend!.isNotEmpty) ? legend : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Resolve a finite width so half-width children under a two-column
          // Wrap never receive unbounded constraints.
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final canRow = width >= minRowWidth;

          final Widget fields = (canRow && columns == 2 && children.length > 1)
              ? _buildTwoColumn(width, gap)
              : _buildStacked(gap);

          return SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (header.isNotEmpty) ...[
                  ...header,
                  SizedBox(height: tokens.spacingUnit * 1.5),
                ],
                fields,
              ],
            ),
          );
        },
      ),
    );
  }

  /// A single full-width column of children separated by [gap], the resolved
  /// [spacing].
  Widget _buildStacked(double gap) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(SizedBox(height: gap));
      rows.add(children[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }

  /// Children flowed two-per-row, each occupying half of [width] less the
  /// [gap] gutter, wrapping to new rows as needed.
  Widget _buildTwoColumn(double width, double gap) {
    // Half the available width, minus half the gutter, floored so rounding can
    // never push two items past the line and force an overflow.
    final itemWidth = ((width - gap) / 2).floorToDouble();
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final child in children)
          SizedBox(
            width: itemWidth > 0 ? itemWidth : width,
            child: child,
          ),
      ],
    );
  }
}
