import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The "Do" / "Don't" guidance cards shown on a pattern page.
class DoDont extends StatelessWidget {
  const DoDont({super.key, required this.dos, required this.donts});

  final List<String> dos;
  final List<String> donts;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final cards = <Widget>[
      if (dos.isNotEmpty)
        _GuidanceCard(
          positive: true,
          title: 'Do',
          items: dos,
        ),
      if (donts.isNotEmpty)
        _GuidanceCard(
          positive: false,
          title: "Don't",
          items: donts,
        ),
    ];

    if (!wide) {
      return Column(
        children: [
          for (final c in cards)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: c,
            ),
        ],
      );
    }
    // IntrinsicHeight + stretch keeps both cards the same height as the taller
    // of the two, so the pair always lines up.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(child: cards[i]),
          ],
        ],
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({
    required this.positive,
    required this.title,
    required this.items,
  });

  final bool positive;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final accentBg = positive
        ? tokens.badgeSuccessColorBackground
        : tokens.badgeDangerColorBackground;
    final accentFg = positive
        ? tokens.badgeSuccessColorText
        : tokens.badgeDangerColorText;
    final accentBorder = positive
        ? tokens.badgeSuccessColorBorder
        : tokens.badgeDangerColorBorder;

    return Container(
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.colorBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: accentBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      positive ? Icons.check : Icons.close,
                      size: 14,
                      color: accentFg,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      title,
                      style: TextStyle(
                        color: accentFg,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 8),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: tokens.colorSecondaryText,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
