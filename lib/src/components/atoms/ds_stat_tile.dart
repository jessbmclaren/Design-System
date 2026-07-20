import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../util/ds_motion.dart';

/// A metric card: a label above a large value, optionally selectable.
///
/// [DsStatTile] states one number plainly, the way a list header summarises
/// the set it filters. Give it [onTap] and it becomes a choice: selected
/// tiles carry the brand accent on their label, border and
/// a brand-tinted fill, and announce themselves as selected, so a row of
/// tiles reads as one set of options rather than three separate cards.
///
/// A row of tiles is just a `Row` of `Expanded` tiles, so they share the
/// width evenly; below a comfortable width, wrap them instead so each keeps a
/// readable measure.
///
/// ```dart
/// Row(
///   children: [
///     Expanded(child: DsStatTile(label: 'Total', value: '128', onTap: showAll)),
///     const SizedBox(width: 12),
///     Expanded(
///       child: DsStatTile(
///         label: 'Open',
///         value: '96',
///         selected: true,
///         onTap: showOpen,
///       ),
///     ),
///   ],
/// )
/// ```
class DsStatTile extends StatefulWidget {
  /// Creates a metric card.
  const DsStatTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.selected = false,
    this.onTap,
  });

  /// What the number counts, shown above it.
  final String label;

  /// The metric itself, already formatted by the caller.
  final String value;

  /// Optional supporting line beneath the value, such as a comparison.
  final String? caption;

  /// Whether this tile is the current choice. Only meaningful alongside
  /// [onTap], which is what makes the tile a choice at all.
  final bool selected;

  /// Called when the tile is chosen. Null renders a plain, static card.
  final VoidCallback? onTap;

  @override
  State<DsStatTile> createState() => _DsStatTileState();
}

class _DsStatTileState extends State<DsStatTile> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;
    final bool interactive = widget.onTap != null;
    final bool selected = widget.selected && interactive;

    final Color border = selected
        ? tokens.formAccentColor
        : _focused
            ? tokens.formAccentColor
            : tokens.colorBorder;
    final Color fill = selected
        ? tokens.brandTintColor
        : _hovered && interactive
            ? tokens.colorText.withValues(alpha: tokens.stateHoverOpacity)
            : tokens.formBackgroundColor;
    final Color labelInk =
        selected ? tokens.actionPrimaryColorText : tokens.colorSecondaryText;
    final Color valueInk =
        selected ? tokens.actionPrimaryColorText : tokens.colorText;

    final Widget card = AnimatedContainer(
      duration: DsMotion.durationOf(context, DsMotion.fast),
      curve: DsMotion.curveOf(context, DsMotion.standard),
      padding: EdgeInsets.symmetric(horizontal: unit * 2, vertical: unit * 1.5),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        border: Border.all(
          color: border,
          // The selected and focused rings are heavier so the state reads at
          // a glance, without moving the tile's layout.
          width: selected || _focused
              ? tokens.focusRingWidth
              : tokens.inputBorderWidth,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.label,
            style: tokens.labelMd.toTextStyle(color: labelInk),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: unit / 2),
          Text(
            widget.value,
            style: tokens.headingMd.toTextStyle(color: valueInk),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.caption != null) ...<Widget>[
            SizedBox(height: unit / 4),
            Text(
              widget.caption!,
              style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    if (!interactive) {
      return Semantics(
        container: true,
        label: _announcement(),
        child: ExcludeSemantics(child: card),
      );
    }

    return Semantics(
      button: true,
      selected: widget.selected,
      label: _announcement(),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onHover: (bool value) => setState(() => _hovered = value),
          onFocusChange: (bool value) => setState(() => _focused = value),
          child: ExcludeSemantics(child: card),
        ),
      ),
    );
  }

  /// The tile reads as one thing: what it counts, then the number, then any
  /// caption.
  String _announcement() {
    final String caption =
        widget.caption == null ? '' : ', ${widget.caption}';
    return '${widget.label}, ${widget.value}$caption';
  }
}
