import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
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
/// tokens — colour and text decoration come from
/// [DsTokens.actionPrimaryColorText] and friends for
/// [DsLinkVariant.primary], or the matching `actionSecondary*` tokens for
/// [DsLinkVariant.secondary]. A null [onPressed] renders the link disabled and
/// removes it from the tap and focus order.
///
/// Set [external] to append an "open in new" glyph, signalling the link leaves
/// the current context. Provide a [trailingIcon] for any other trailing glyph
/// (for example a chevron); when both are set the [external] glyph is shown
/// after the custom [trailingIcon].
///
/// The label ellipsizes rather than overflowing, so the link is safe inside a
/// [Row], [Wrap] or other width-constrained layout from a 320dp phone up to a
/// wide desktop. Wrap the link in [Flexible] (or place it in a [Wrap]) when the
/// surrounding row may be narrower than the label's natural width.
class DsLink extends StatelessWidget {
  /// Creates a textual hyperlink.
  const DsLink({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DsLinkVariant.primary,
    this.trailingIcon,
    this.external = false,
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

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final enabled = onPressed != null;

    final (
      Color color,
      TextDecoration decorationLine,
      Color decorationColor,
      TextDecorationStyle decorationStyle,
      double decorationThickness,
    ) = switch (variant) {
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

    final transform = variant == DsLinkVariant.primary
        ? tokens.actionPrimaryTextTransform
        : tokens.actionSecondaryTextTransform;

    // Disabled links read as muted; dim colour and decoration together.
    final resolvedColor = enabled ? color : color.withValues(alpha: 0.45);
    final resolvedDecorationColor =
        enabled ? decorationColor : decorationColor.withValues(alpha: 0.45);

    final textStyle = tokens.bodyMd.toTextStyle(color: resolvedColor).copyWith(
          decoration: decorationLine,
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
            transform.apply(label),
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: DsSpacing.xs),
          Icon(trailingIcon, size: DsIconSize.xs, color: resolvedColor),
        ],
        if (external) ...[
          const SizedBox(width: DsSpacing.xs),
          Icon(DsIcons.externalLink, size: DsIconSize.xs, color: resolvedColor),
        ],
      ],
    );

    return Semantics(
      link: true,
      enabled: enabled,
      child: MouseRegion(
        cursor:
            enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: InkWell(
          onTap: onPressed,
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
  }
}
