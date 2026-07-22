import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_icon.dart';

/// A calendar date paired with a relative hint that turns urgent as the date
/// approaches.
///
/// Renders the absolute date ('12 Aug 2027') with a calendar glyph and, below
/// it, how far away it is ('in 11 months'). Once the date falls within
/// [urgentWithin] — or has passed — the hint switches to the danger colour, so
/// an expiring licence or document reads as needing attention without relying
/// on colour alone (the hint text itself carries the urgency).
///
/// The relative hint is computed against [now], which defaults to the wall
/// clock; tests and previews pass a fixed [now] to stay deterministic.
class DsExpiryDate extends StatelessWidget {
  /// Creates an expiry date display.
  const DsExpiryDate({
    super.key,
    required this.date,
    this.now,
    this.urgentWithin = const Duration(days: 90),
    this.showIcon = true,
    this.dense = false,
  });

  /// The date being counted down to.
  final DateTime date;

  /// The reference clock the relative hint is computed against. Defaults to
  /// `DateTime.now()`; pass a fixed value for deterministic rendering.
  final DateTime? now;

  /// How close [date] must be before the hint renders in the danger colour.
  /// A date in the past is always urgent.
  final Duration urgentWithin;

  /// Whether the calendar glyph is shown beside the date.
  final bool showIcon;

  /// Compact type for use inside table cells.
  final bool dense;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// '12 Aug 2027' — locale-neutral day-first format used across the system.
  static String formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// The relative hint for [date] seen from [now]: 'today', 'in 17 days',
  /// 'in 2 months', 'in 2 years', or 'expired 3 days ago' once past.
  static String relativeLabel(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final days = target.difference(today).inDays;
    if (days == 0) return 'today';
    final magnitude = _magnitude(days.abs());
    return days > 0 ? 'in $magnitude' : 'expired $magnitude ago';
  }

  static String _magnitude(int days) {
    if (days < 30) return days == 1 ? '1 day' : '$days days';
    if (days < 548) {
      final months = (days / 30.44).round().clamp(1, 17);
      return months == 1 ? '1 month' : '$months months';
    }
    final years = (days / 365.25).round();
    return years == 1 ? '1 year' : '$years years';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final target = DateTime(date.year, date.month, date.day);
    final untilTarget = target.difference(today);
    final urgent = untilTarget.isNegative || untilTarget <= urgentWithin;

    final dateStyle = (dense ? tokens.bodySm : tokens.bodyMd)
        .toTextStyle(color: tokens.colorText);
    final hintStyle = (dense ? tokens.labelSm : tokens.bodySm).toTextStyle(
      color: urgent ? tokens.colorDanger : tokens.colorSecondaryText,
    );

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  formatDate(date),
                  style: dateStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showIcon) ...[
                const SizedBox(width: DsSpacing.xs),
                DsIcon(
                  icon: DsIcons.calendar,
                  size: DsIconSize.sm,
                  color: tokens.colorSecondaryText,
                ),
              ],
            ],
          ),
          const SizedBox(height: DsSpacing.xxs),
          Text(
            relativeLabel(date, reference),
            style: hintStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
