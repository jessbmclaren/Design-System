import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';

/// The visual emphasis of a [DsLink].
enum DsLinkVariant {
  /// A primary, high-emphasis hyperlink using the primary action tokens.
  primary,

  /// A supporting, lower-emphasis hyperlink using the secondary action tokens.
  secondary,
}

/// A textual hyperlink.
///
/// [DsLink] renders inline, tappable text styled from the theme's `action*`
/// tokens. Colour and text decoration come from
/// [DsTokens.actionPrimaryColorText] and friends for
/// [DsLinkVariant.primary], or the matching `actionSecondary*` tokens for
/// [DsLinkVariant.secondary]. A null [onPressed] renders the link disabled and
/// removes it from the tap and focus order.
///
/// Hovering or keyboard-focusing the link underlines it, on top of whatever
/// resting decoration the theme's tokens define, so both pointer and keyboard
/// users get the same affordance.
///
/// Set [external] to append an "open in new" glyph, signalling the link leaves
/// the current context. Provide a [trailingIcon] for any other trailing glyph
/// (for example a chevron); when both are set the [external] glyph is shown
/// after the custom [trailingIcon].
///
/// The label ellipsizes rather than overflowing once it exceeds [maxLines], so
/// the link is safe inside a [Row], [Wrap] or other width-constrained layout
/// from a 320dp phone up to a wide desktop. Wrap the link in [Flexible] (or
/// place it in a [Wrap]) when the surrounding row may be narrower than the
/// label's natural width.
///
/// A link inside running text keeps a compact tap area. When the link stands
/// alone as a touch action, set [padded] to reserve a row at least 48dp tall
/// for the tap target, the accessible minimum. The reserved height is real
/// layout space, so the target survives lists and tight columns instead of
/// bleeding into or being clipped by neighbouring rows.
class DsLink extends StatefulWidget {
  /// Creates a textual hyperlink.
  const DsLink({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DsLinkVariant.primary,
    this.small = false,
    this.trailingIcon,
    this.external = false,
    this.maxLines = 1,
    this.padded = false,
  });

  /// The link text.
  final String label;

  /// Called when the link is tapped. A null callback disables the link.
  final VoidCallback? onPressed;

  /// The visual emphasis of the link.
  final DsLinkVariant variant;

  /// Whether the link sets in the smaller body size, for a link inside dense
  /// content (a table row, a card footer) rather than running prose.
  final bool small;

  /// An optional trailing glyph rendered after the label.
  final IconData? trailingIcon;

  /// Whether the link opens an external destination. Appends an
  /// [DsIcons.externalLink] glyph and annotates the semantics as a link.
  final bool external;

  /// The maximum number of lines the label may occupy before it ellipsizes.
  ///
  /// Defaults to a single line.
  final int maxLines;

  /// Whether to reserve a tap target at least 48dp tall.
  ///
  /// The visible text keeps its natural size and centres vertically within
  /// the reserved row, so the link occupies real layout space, as DsCheckbox
  /// does. The whole row responds to taps wherever it sits, including inside
  /// a ListView. Two limits remain: only the height is reserved, so a very
  /// short label can still present a target narrower than 48dp, and the
  /// extra height shifts the surrounding layout, so [padded] suits a link
  /// standing alone rather than one inline with running text.
  final bool padded;


  @override
  State<DsLink> createState() => _DsLinkState();
}

class _DsLinkState extends State<DsLink> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final enabled = widget.onPressed != null;

    final (
      Color color,
      TextDecoration decorationLine,
      Color decorationColor,
      TextDecorationStyle decorationStyle,
      double decorationThickness,
    ) = switch (widget.variant) {
      DsLinkVariant.primary => (
          tokens.actionPrimaryColorText,
          tokens.actionPrimaryTextDecorationLine,
          tokens.actionPrimaryTextDecorationColor,
          tokens.actionPrimaryTextDecorationStyle,
          tokens.actionPrimaryTextDecorationThickness,
        ),
      DsLinkVariant.secondary => (
          tokens.actionSecondaryColorText,
          tokens.actionSecondaryTextDecorationLine,
          tokens.actionSecondaryTextDecorationColor,
          tokens.actionSecondaryTextDecorationStyle,
          tokens.actionSecondaryTextDecorationThickness,
        ),
    };

    final transform = widget.variant == DsLinkVariant.primary
        ? tokens.actionPrimaryTextTransform
        : tokens.actionSecondaryTextTransform;

    // Disabled links read as muted; dim colour and decoration together.
    final resolvedColor = enabled ? color : color.withValues(alpha: 0.45);
    final resolvedDecorationColor =
        enabled ? decorationColor : decorationColor.withValues(alpha: 0.45);

    // Hover and keyboard focus underline the link on top of the resting
    // token decoration, so the affordance survives a theme that rests plain.
    final bool underline = enabled && (_hovered || _focused);
    final TextDecoration resolvedLine = underline
        ? TextDecoration.combine(
            <TextDecoration>[decorationLine, TextDecoration.underline],
          )
        : decorationLine;

    // The primary link carries the emphasised weight, so it reads as the
    // action in a paragraph without relying on colour alone.
    final textStyle = (widget.small ? tokens.bodySm : tokens.bodyMd)
        .toTextStyle(color: resolvedColor)
        .copyWith(
          fontWeight: widget.variant == DsLinkVariant.primary
              ? tokens.mediumLabelFontWeight
              : null,
          decoration: resolvedLine,
          decorationColor: resolvedDecorationColor,
          decorationStyle: decorationStyle,
          decorationThickness: decorationThickness,
        );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            transform.apply(widget.label),
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: widget.maxLines,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          SizedBox(width: tokens.spacingUnit / 2),
          Icon(widget.trailingIcon, size: DsIconSize.xs, color: resolvedColor),
        ],
        if (widget.external) ...[
          SizedBox(width: tokens.spacingUnit / 2),
          Icon(DsIcons.externalLink, size: DsIconSize.xs, color: resolvedColor),
        ],
      ],
    );

    // A comfortable tap area without forcing a full 48dp block: inline links
    // live within running text.
    Widget target = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingUnit / 2,
        vertical: tokens.spacingUnit / 2,
      ),
      child: content,
    );

    if (widget.padded) {
      // Reserve real layout space for the accessible minimum, as DsCheckbox
      // does: the row is at least 48dp tall and every point of it hits the
      // link, so the target holds inside lists and columns. The width hugs
      // the label under loose constraints, so the link does not claim taps
      // across the whole row unless the parent stretches it.
      target = ConstrainedBox(
        constraints: BoxConstraints(minHeight: tokens.minTapTarget),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: target,
        ),
      );
    }

    return Semantics(
      link: true,
      enabled: enabled,
      child: MouseRegion(
        cursor:
            enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: widget.onPressed,
          onFocusChange: (focused) => setState(() => _focused = focused),
          borderRadius: BorderRadius.circular(tokens.borderRadius),
          child: target,
        ),
      ),
    );
  }
}
