import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Expiry date page: a far-future date, a date within the
/// urgent window and an already-expired one, side by side. Deterministic —
/// every example is computed against the same fixed reference clock.
class ExpiryDateDemo extends StatelessWidget {
  const ExpiryDateDemo({super.key});

  /// Fixed reference clock so the relative hints never drift.
  static final DateTime _now = DateTime(2026, 7, 22);

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final captionStyle = tokens.labelSm.toTextStyle(
      color: tokens.colorSecondaryText,
    );

    Widget example(String caption, DsExpiryDate child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(caption, style: captionStyle),
          const SizedBox(height: 8),
          child,
        ],
      );
    }

    return Wrap(
      spacing: 40,
      runSpacing: 24,
      children: [
        example(
          'Far future',
          DsExpiryDate(date: DateTime(2028, 3, 15), now: _now),
        ),
        example(
          'Within 90 days',
          DsExpiryDate(date: DateTime(2026, 8, 30), now: _now),
        ),
        example(
          'Expired',
          DsExpiryDate(date: DateTime(2026, 6, 10), now: _now),
        ),
        example(
          'Dense, for table cells',
          DsExpiryDate(date: DateTime(2027, 1, 7), now: _now, dense: true),
        ),
      ],
    );
  }
}
