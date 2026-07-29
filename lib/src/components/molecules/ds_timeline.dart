import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// One thing that happened, on a [DsTimeline].
@immutable
class DsTimelineEntry {
  /// Creates a timeline entry.
  const DsTimelineEntry({
    required this.title,
    this.meta,
    this.detail,
    this.tone,
  });

  /// What happened, in the past tense — "Tank capacity changed".
  ///
  /// Written as a statement rather than a field name, because a log that reads
  /// `tankCapacity: 80 → 90` is a diff, and a diff is something you decode
  /// rather than read.
  final String title;

  /// When, and who — "18 Jul 2026 · Jess McLaren".
  ///
  /// One muted line rather than two columns: on a narrow panel a date column
  /// costs a third of the width to say something nobody scans down.
  final String? meta;

  /// An optional third line for what actually changed.
  final String? detail;

  /// Tints the marker where an entry means something stronger than "a change
  /// happened" — a deactivation, a failure. Null uses the quiet default.
  final Color? tone;
}

/// A record's history, newest first: what happened, when, and who did it.
///
/// The shape an audit trail takes when it is meant to be read by the person
/// who owns the record rather than exported to an auditor. Each entry is a
/// sentence with its provenance under it, connected by a rule down the left so
/// the eye can follow the sequence without the entries needing to be a table.
///
/// **The rule stops at the last entry.** A line that runs past the final marker
/// implies more below the fold, which is the one thing a history must never lie
/// about — someone deciding whether a vehicle was tampered with needs to know
/// they have reached the end.
///
/// The oldest entry is the record's creation, so a timeline is never empty for
/// a record that exists. Callers that can be empty should render their own
/// empty state rather than an empty rule.
///
/// ```dart
/// DsTimeline(entries: [
///   DsTimelineEntry(title: 'Status changed to Active',
///                   meta: '24 Jul 2026 · Jess McLaren'),
///   DsTimelineEntry(title: 'Vehicle created', meta: '03 Jul 2026 · Sam Nkosi'),
/// ])
/// ```
class DsTimeline extends StatelessWidget {
  /// Creates a timeline.
  const DsTimeline({super.key, required this.entries});

  /// The entries, newest first — the order a history is read in.
  final List<DsTimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;
    if (entries.isEmpty) return const SizedBox.shrink();

    const double markerSize = 10;
    final double gutter = unit * 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < entries.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: gutter,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: unit * 0.5),
                      Container(
                        width: markerSize,
                        height: markerSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: entries[i].tone ?? tokens.colorPrimary,
                        ),
                      ),
                      // The rule joins this entry to the next one, so the last
                      // marker ends the sequence rather than trailing off.
                      if (i < entries.length - 1)
                        Expanded(
                          child: Container(
                            width: 1,
                            margin: EdgeInsets.symmetric(vertical: unit * 0.5),
                            color: tokens.colorBorder,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < entries.length - 1 ? unit * 2.5 : 0,
                    ),
                    child: MergeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            entries[i].title,
                            style: tokens.labelSm.toTextStyle(
                              color: tokens.colorText,
                            ),
                          ),
                          if (entries[i].meta != null) ...<Widget>[
                            SizedBox(height: unit * 0.25),
                            Text(
                              entries[i].meta!,
                              style: tokens.bodySm.toTextStyle(
                                color: tokens.colorSecondaryText,
                              ),
                            ),
                          ],
                          if (entries[i].detail != null) ...<Widget>[
                            SizedBox(height: unit * 0.25),
                            Text(
                              entries[i].detail!,
                              style: tokens.bodySm.toTextStyle(
                                color: tokens.colorSecondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
