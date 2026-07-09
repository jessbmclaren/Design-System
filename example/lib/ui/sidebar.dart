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
      width: 268,
      decoration: BoxDecoration(
        color: tokens.offsetBackgroundColor,
        border: Border(right: BorderSide(color: tokens.colorBorder)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: tokens.buttonPrimaryColorBackground,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(Icons.layers_rounded,
                      size: 18, color: tokens.buttonPrimaryColorText),
                ),
                const SizedBox(width: 10),
                Text(
                  'Design System',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          for (final group in orderedGroups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Text(
                group.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
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
          ],
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
    return Material(
      color: selected
          ? tokens.buttonPrimaryColorBackground.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            page.navTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? tokens.actionPrimaryColorText
                  : tokens.colorText,
            ),
          ),
        ),
      ),
    );
  }
}
