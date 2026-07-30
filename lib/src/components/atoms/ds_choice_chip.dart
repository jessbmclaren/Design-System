import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../../util/ds_motion.dart';
import 'ds_icon.dart';

/// A selectable pill: the interactive counterpart to the static `DsChip`.
///
/// [DsChoiceChip] is how a set of small choices is offered inline, the way a
/// filter row or a form offers days, capabilities or tags. It is controlled:
/// the caller holds [selected] and applies each [onSelected]. A selected chip
/// carries the brand tint, the brand ink and a leading check, so the state
/// survives a colour-blind reading rather than resting on hue alone.
///
/// The chip is a checkbox to assistive technology, reporting its checked
/// state, and activates on Enter and Space like any other control. Give it
/// [onRemoved] and it grows a remove affordance with its own accessible name,
/// for a chip that represents something the user added.
///
/// ```dart
/// DsChoiceChip(
///   label: 'Monday',
///   selected: days.contains(Day.monday),
///   onSelected: (next) => toggle(Day.monday, next),
/// )
/// ```
class DsChoiceChip extends StatefulWidget {
  /// Creates a selectable pill.
  const DsChoiceChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onRemoved,
    this.enabled = true,
    this.tooltip,
  });

  /// The choice's name. Ellipsizes rather than wrapping, so a row of chips
  /// keeps its rhythm.
  final String label;

  /// Whether this choice is currently chosen.
  final bool selected;

  /// Called with the next state when the chip is toggled. Null leaves the
  /// chip inert (still readable, but not a control).
  final ValueChanged<bool>? onSelected;

  /// Called when the trailing remove affordance is pressed. Null hides it.
  final VoidCallback? onRemoved;

  /// Whether the chip accepts interaction. A disabled chip is dimmed and
  /// leaves the focus order.
  final bool enabled;

  /// Optional hover and long-press tooltip, for a label that abbreviates.
  final String? tooltip;

  @override
  State<DsChoiceChip> createState() => _DsChoiceChipState();
}

class _DsChoiceChipState extends State<DsChoiceChip> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;
    final bool enabled = widget.enabled && widget.onSelected != null;
    final bool selected = widget.selected;

    final Color ink = selected
        ? tokens.actionPrimaryColorText
        : tokens.colorText;
    final Color border = _focused
        ? tokens.actionPrimaryColorText
        : selected
            ? tokens.actionPrimaryColorText
            : tokens.colorBorder;
    final Color fill = selected
        ? tokens.brandTintColor
        : _hovered && enabled
            ? tokens.colorText.withValues(alpha: tokens.stateHoverOpacity)
            : tokens.formBackgroundColor;
    final double disabled = tokens.stateDisabledOpacity;

    final Widget body = AnimatedContainer(
      duration: DsMotion.durationOf(context, DsMotion.fast),
      curve: DsMotion.curveOf(context, DsMotion.standard),
      padding: EdgeInsets.symmetric(horizontal: unit * 1.75, vertical: unit),
      decoration: BoxDecoration(
        color: enabled ? fill : tokens.offsetBackgroundColor,
        borderRadius: BorderRadius.circular(tokens.radiusFull),
        border: Border.all(
          color: enabled
              ? border
              : tokens.colorBorder.withValues(alpha: disabled),
          width: _focused ? tokens.focusRingWidth : tokens.inputBorderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // The check carries the selected state alongside the tint, so the
          // state never rests on colour alone.
          if (selected) ...<Widget>[
            DsIcon(
              icon: DsIcons.check,
              size: tokens.iconSizeXs,
              color: enabled ? ink : ink.withValues(alpha: disabled),
            ),
            SizedBox(width: unit / 2),
          ],
          Flexible(
            child: ExcludeSemantics(
              child: Text(
                widget.label,
                style: (selected ? tokens.labelMd : tokens.bodySm)
                    .toTextStyle(
                      color: enabled ? ink : tokens.colorTextDisabled,
                    )
                    .copyWith(fontSize: tokens.bodySm.fontSize),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (widget.onRemoved != null) ...<Widget>[
            SizedBox(width: unit / 2),
            Semantics(
              button: true,
              label: 'Remove ${widget.label}',
              child: InkWell(
                onTap: widget.enabled ? widget.onRemoved : null,
                borderRadius: BorderRadius.circular(tokens.radiusFull),
                child: Padding(
                  padding: EdgeInsets.all(unit / 4),
                  child: DsIcon(
                    icon: DsIcons.close,
                    size: tokens.iconSizeXs,
                    color: enabled
                        ? tokens.colorSecondaryText
                        : tokens.colorSecondaryText.withValues(alpha: disabled),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    Widget chip = ConstrainedBox(
      // The pill stays visually compact while its target meets the minimum:
      // the box grows to the tap target and the pill centres inside it.
      constraints: BoxConstraints(minHeight: tokens.minTapTarget),
      child: Align(
        alignment: Alignment.center,
        // Hug the label horizontally. Without a width factor an Align expands
        // to the widest its constraints allow, which makes every chip as wide
        // as its container: a row of chips becomes one chip per line with the
        // label floating in the middle. The height is left to expand, which is
        // what lifts the pill to the tap-target minimum.
        widthFactor: 1,
        child: body,
      ),
    );

    if (enabled) {
      chip = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => widget.onSelected!(!selected),
          borderRadius: BorderRadius.circular(tokens.radiusFull),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onHover: (bool value) => setState(() => _hovered = value),
          onFocusChange: (bool value) => setState(() => _focused = value),
          child: chip,
        ),
      );
    }

    if (widget.tooltip != null) {
      chip = Tooltip(message: widget.tooltip!, child: chip);
    }

    // The chip is a checkbox carrying its own name and state; the remove
    // affordance keeps its separate node inside it, as an input chip does.
    return Semantics(
      checked: selected,
      enabled: enabled,
      label: widget.label,
      child: chip,
    );
  }
}
