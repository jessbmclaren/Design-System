import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../content/doc_registry.dart';
import '../content/pattern_page_content.dart';

/// The grouped navigation sidebar listing every documentation page.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key, required this.currentId, this.onNavigate});

  /// The id of the page currently being viewed.
  final String currentId;

  /// Called after navigation (used to close the drawer on narrow layouts).
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return Container(
      width: 272,
      decoration: BoxDecoration(
        color: tokens.offsetBackgroundColor,
        border: Border(right: BorderSide(color: tokens.colorBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Wordmark(),
          Divider(height: 1, color: tokens.colorBorder),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: DsSpacing.lg,
                horizontal: DsSpacing.md,
              ),
              children: [
                for (final group in orderedGroups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DsSpacing.md,
                      DsSpacing.md,
                      DsSpacing.md,
                      DsSpacing.sm,
                    ),
                    child: Text(
                      group.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: tokens.colorSecondaryText,
                      ),
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
                  const SizedBox(height: DsSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The brand lockup at the top of the sidebar: a tinted glyph, the product name
/// and a quiet subtitle.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: tokens.buttonPrimaryColorBackground,
              borderRadius: BorderRadius.circular(9),
              boxShadow: DsElevation.tinted(tokens.buttonPrimaryColorBackground),
            ),
            child: Icon(
              Icons.layers_rounded,
              size: 20,
              color: tokens.buttonPrimaryColorText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Design System',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: tokens.colorText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Component library',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: tokens.colorSecondaryText,
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
    final tokens = DsTokens.of(context);
    final accent = tokens.actionPrimaryColorText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected ? accent.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: tokens.colorText.withValues(alpha: 0.04),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                // An accent rail that grows in on the active item.
                AnimatedContainer(
                  duration: DsMotion.durationOf(context, DsMotion.fast),
                  curve: DsMotion.standard,
                  width: 3,
                  height: selected ? 16 : 0,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    page.navTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? accent : tokens.colorText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
