import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import '../content/doc_registry.dart';
import '../content/pattern_page_content.dart';
import 'docs_style.dart';

/// The grouped navigation sidebar listing every documentation page.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key, required this.currentId, this.onNavigate});

  /// The id of the page currently being viewed.
  final String currentId;

  /// Called after navigation (used to close the drawer on narrow layouts).
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);

    return Container(
      width: DocsMetrics.sidebarWidth,
      decoration: BoxDecoration(
        color: docs.surface,
        border: Border(right: BorderSide(color: docs.separator)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Wordmark(),
          Divider(height: 1, color: docs.separator),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
              children: [
                for (final group in orderedGroups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                    child: Text(
                      group.label.toUpperCase(),
                      style: DocsType.sectionHeader(docs.textTertiary),
                    ),
                  ),
                  for (final page in pagesInGroup(group))
                    _NavItem(
                      page: page,
                      selected: page.id == currentId,
                      onTap: () {
                        context.go('/patterns/${page.id}');
                        onNavigate?.call();
                      },
                    ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The brand lockup at the top of the sidebar: a tinted Lucide glyph, the
/// product name and a quiet subtitle.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    // Match the content-area top bar height so the sidebar's hairline lines up
    // with the top bar's bottom border at the seam.
    return SizedBox(
      height: DocsMetrics.topBarHeight,
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: DocsMetrics.wordmarkInset),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: docs.accent,
              borderRadius: BorderRadius.circular(DocsRadii.sm),
            ),
            child: const Icon(LucideIcons.layers, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Design System',
                  overflow: TextOverflow.ellipsis,
                  style: DocsType.headline(docs.textPrimary),
                ),
                const SizedBox(height: 1),
                Text(
                  'Component library',
                  overflow: TextOverflow.ellipsis,
                  style: DocsType.caption(docs.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final PatternPage page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected ? docs.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(DocsRadii.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(DocsRadii.sm),
          hoverColor: docs.fill,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Text(
              page.navTitle,
              style: DocsType.navItem(
                // link (not accent) clears 4.5:1 over the accentSoft wash.
                selected ? docs.link : docs.textPrimary,
                selected: selected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
