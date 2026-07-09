import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// A compact pill shell used to present chip-like content.
///
/// [DsChip] is the low-level building block behind `DsFilterChip`: a rounded,
/// bordered container holding a [label] and an optional [trailing] widget. Use
/// it directly when you need the same pill shape for a non-interactive tag, or
/// pass [onTap] to make the whole pill tappable.
///
/// The chip keeps itself compact and never forces its parent to overflow: the
/// label is constrained with [TextOverflow.ellipsis] so a long value truncates
/// rather than pushing the trailing widget off-screen.
class DsChip extends StatelessWidget {
  /// Creates a pill shell.
  const DsChip({
    super.key,
    required this.label,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  /// The text shown inside the pill.
  final String label;

  /// An optional widget rendered after the label, such as an icon.
  final Widget? trailing;

  /// Called when the pill is tapped. A null callback leaves the pill inert.
  final VoidCallback? onTap;

  /// The fill colour. Defaults to transparent.
  final Color? backgroundColor;

  /// The border colour. Defaults to the theme border colour.
  final Color? borderColor;

  /// The label colour. Defaults to the theme secondary text colour.
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final resolvedText = textColor ?? tokens.colorSecondaryText;
    final radius = BorderRadius.circular(tokens.badgeBorderRadius + 100);

    final pill = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor ?? tokens.colorBorder),
        borderRadius: radius,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: tokens.badgePaddingX + 6,
        vertical: tokens.badgePaddingY + 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: tokens.badgeLabelFontSize,
                fontWeight: tokens.badgeLabelFontWeight,
                color: resolvedText,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 4),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) return pill;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: pill,
      ),
    );
  }
}
