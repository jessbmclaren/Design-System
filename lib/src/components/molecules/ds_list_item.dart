import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// A single row within a `DsList`.
///
/// Renders an optional [leading] widget, a [title] with an optional
/// [subtitle], and an optional [trailing] widget. Use it for navigation
/// rows, settings entries, or any vertically stacked list content.
///
/// When [onTap] is provided the row becomes tappable and — unless you supply
/// your own [trailing] — a chevron is shown to signal navigation. The [title]
/// and [subtitle] ellipsize so a row never overflows on narrow screens.
class DsListItem extends StatelessWidget {
  const DsListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  /// An optional widget shown before the text, such as an icon or avatar.
  final Widget? leading;

  /// The primary text of the row.
  final String title;

  /// Optional secondary text shown beneath the [title].
  final String? subtitle;

  /// An optional widget shown at the end of the row, such as a control or
  /// value. When omitted and [onTap] is set, a chevron is shown instead.
  final Widget? trailing;

  /// Called when the row is tapped. A null callback renders a static,
  /// non-interactive row.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final Widget? resolvedTrailing = trailing ??
        (onTap != null
            ? Icon(Icons.chevron_right, color: tokens.colorSecondaryText)
            : null);

    final row = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: tokens.tableRowPaddingY + 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: tokens.colorText,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: tokens.colorSecondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (resolvedTrailing != null) ...[
            const SizedBox(width: 12),
            resolvedTrailing,
          ],
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: row,
      ),
    );
  }
}
