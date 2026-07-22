import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_badge.dart';

/// One row of a [DsStatusLegend]: a status badge and what it means.
@immutable
class DsStatusLegendEntry {
  /// Creates a legend entry.
  const DsStatusLegendEntry({
    required this.label,
    required this.description,
    this.variant = DsBadgeVariant.neutral,
  });

  /// The status name, rendered as a [DsBadge].
  final String label;

  /// What the status means, in a short sentence.
  final String description;

  /// The badge colour tier for this status.
  final DsBadgeVariant variant;
}

/// A key that explains what each status badge in a table means.
///
/// Statuses carry meaning by colour and word ('Ready', 'Needs attention'), and
/// a legend keeps that meaning discoverable instead of tribal. Each entry
/// renders its badge beside a plain-language description, aligned in a column
/// so the badges read as a scannable rail. The description wraps freely, so
/// the legend holds together from a 320dp phone up to a wide desktop pane.
class DsStatusLegend extends StatelessWidget {
  /// Creates a status legend.
  ///
  /// [entries] must not be empty.
  const DsStatusLegend({
    super.key,
    this.title,
    required this.entries,
  }) : assert(entries.length > 0, 'a legend needs at least one entry');

  /// An optional heading above the entries, e.g. 'Statuses explained'.
  final String? title;

  /// The statuses being explained, in display order.
  final List<DsStatusLegendEntry> entries;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: tokens.labelMd
                  .toTextStyle(color: tokens.colorText)
                  .copyWith(fontWeight: tokens.strongLabelFontWeight),
            ),
            const SizedBox(height: DsSpacing.md),
          ],
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(height: DsSpacing.sm),
            MergeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flexible + scale-down so a long status name gives way to
                  // the description instead of overflowing a narrow pane.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: DsBadge(
                        label: entries[i].label,
                        variant: entries[i].variant,
                      ),
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      // Optically centres the first description line against
                      // the badge pill without pinning later lines.
                      padding: const EdgeInsets.only(top: DsSpacing.xxs),
                      child: Text(
                        entries[i].description,
                        style: tokens.bodySm
                            .toTextStyle(color: tokens.colorSecondaryText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
