import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'docs_style.dart';

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
        _GuidanceCard(positive: true, title: 'Do', items: dos),
      if (donts.isNotEmpty)
        _GuidanceCard(positive: false, title: "Don't", items: donts),
    ];

    if (!wide) {
      return Column(
        children: [
          for (final c in cards)
            Padding(padding: const EdgeInsets.only(bottom: 14), child: c),
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
    final docs = DocsColors.of(context);
    final accent = positive ? docs.positive : docs.negative;
    final accentSoft = positive ? docs.positiveSoft : docs.negativeSoft;
    final glyph = positive ? LucideIcons.check : LucideIcons.x;

    return Container(
      decoration: BoxDecoration(
        color: docs.surface,
        borderRadius: BorderRadius.circular(DocsRadii.lg),
        border: Border.all(color: docs.separator),
        boxShadow: DocsShadows.card,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(DocsRadii.sm),
                ),
                child: Icon(glyph, size: 15, color: accent),
              ),
              const SizedBox(width: 10),
              Text(title, style: DocsType.headline(accent)),
            ],
          ),
          const SizedBox(height: 16),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 10),
                    child: Icon(glyph, size: 15, color: accent),
                  ),
                  Expanded(
                    child: Text(item, style: DocsType.callout(docs.textSecondary)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
