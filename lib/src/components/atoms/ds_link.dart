import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../../tokens/ds_spacing.dart';

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
/// alone as a touch action, set [padded] to extend the tap target to the 48dp
/// accessible minimum; the extra area is invisible and takes no layout space,
/// so nothing around the link moves.
class DsLink extends StatefulWidget {
  /// Creates a textual hyperlink.
  const DsLink({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DsLinkVariant.primary,
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

  /// An optional trailing glyph rendered after the label.
  final IconData? trailingIcon;

  /// Whether the link opens an external destination. Appends an
  /// [DsIcons.externalLink] glyph and annotates the semantics as a link.
  final bool external;

  /// The maximum number of lines the label may occupy before it ellipsizes.
  ///
  /// Defaults to a single line.
  final int maxLines;

  /// Whether to extend the tap target to at least 48dp in each dimension.
  ///
  /// The visible link keeps its natural size and the surrounding layout does
  /// not shift; taps landing in the invisible surround are routed to the
  /// link. The extended area only responds where an ancestor's bounds reach,
  /// so it suits a link with breathing room rather than one packed inside a
  /// tight row.
  final bool padded;

  /// The minimum accessible tap target, applied when [padded] is set.
  static const double _minTapTarget = 48;

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

    final textStyle = tokens.bodyMd.toTextStyle(color: resolvedColor).copyWith(
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
          const SizedBox(width: DsSpacing.xs),
          Icon(widget.trailingIcon, size: DsIconSize.xs, color: resolvedColor),
        ],
        if (widget.external) ...[
          const SizedBox(width: DsSpacing.xs),
          Icon(DsIcons.externalLink, size: DsIconSize.xs, color: resolvedColor),
        ],
      ],
    );

    Widget link = Semantics(
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
          // A comfortable tap area without forcing a full 48dp block: inline
          // links live within running text.
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DsSpacing.xs,
              vertical: DsSpacing.xs,
            ),
            child: content,
          ),
        ),
      ),
    );

    if (widget.padded) {
      link = _MinHitTarget(
        minSize: const Size(DsLink._minTapTarget, DsLink._minTapTarget),
        child: link,
      );
    }
    return link;
  }
}

/// Extends a child's hit-test area to [minSize] without changing its layout.
///
/// The child keeps its natural laid-out size, so nothing around it moves. A
/// pointer landing in the invisible surround, centred on the child, is routed
/// to the child's centre, the same redirect Material's padded tap targets use.
class _MinHitTarget extends SingleChildRenderObjectWidget {
  const _MinHitTarget({required this.minSize, super.child});

  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMinHitTarget(minSize);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMinHitTarget renderObject,
  ) {
    renderObject.minSize = minSize;
  }
}

class _RenderMinHitTarget extends RenderProxyBox {
  _RenderMinHitTarget(this._minSize);

  Size _minSize;
  set minSize(Size value) {
    if (value == _minSize) return;
    _minSize = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      return super.hitTest(result, position: position);
    }
    final child = this.child;
    if (child == null) return false;
    final Rect zone = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: math.max(size.width, _minSize.width),
      height: math.max(size.height, _minSize.height),
    );
    if (!zone.contains(position)) return false;
    final Offset center = child.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (BoxHitTestResult result, Offset position) {
        return child.hitTest(result, position: position);
      },
    );
  }
}
