import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../content/pattern_page_content.dart';
import 'docs_skins.dart';
import 'pattern_page_view.dart';
import 'sidebar.dart';

/// The top-level docs layout: a persistent sidebar on wide screens (a drawer
/// on narrow ones), a slim top bar with the light/dark toggle, and the
/// selected pattern page.
class DocsScaffold extends StatelessWidget {
  const DocsScaffold({super.key, required this.page});

  final PatternPage page;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      drawer: wide
          ? null
          : Drawer(
              child: SafeArea(
                child: Sidebar(
                  currentId: page.id,
                  onNavigate: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
      appBar: wide
          ? null
          : AppBar(
              backgroundColor: tokens.offsetBackgroundColor,
              surfaceTintColor: Colors.transparent,
              title: Text(page.navTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              actions: const [
                _SkinSwitcher(),
                SizedBox(width: 4),
                _ThemeToggle(),
                SizedBox(width: 4),
              ],
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (wide) Sidebar(currentId: page.id),
            Expanded(
              child: Column(
                children: [
                  if (wide) _TopBar(page: page),
                  Expanded(child: PatternPageView(page: page)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.page});
  final PatternPage page;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.colorBorder)),
      ),
      child: Row(
        children: [
          Text(
            '${page.group.label}  /  ${page.navTitle}',
            style: TextStyle(
              fontSize: 13,
              color: tokens.colorSecondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const _SkinSwitcher(),
          const SizedBox(width: 8),
          const _ThemeToggle(),
        ],
      ),
    );
  }
}

/// A brand switcher: flips the active [DocsSkin] so every component re-renders
/// under the selected brand's tokens. Distinct axis from light/dark.
class _SkinSwitcher extends StatelessWidget {
  const _SkinSwitcher();

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.of(context);
    final tokens = DsTokens.of(context);
    return PopupMenuButton<DocsSkin>(
      tooltip: 'Switch brand',
      position: PopupMenuPosition.under,
      onSelected: controller.selectSkin,
      itemBuilder: (context) => [
        for (final skin in kDocsSkins)
          CheckedPopupMenuItem<DocsSkin>(
            value: skin,
            checked: skin == controller.skin,
            child: Text(skin.name),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: tokens.colorBorder),
          borderRadius: BorderRadius.circular(tokens.buttonBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.palette_outlined,
                size: 16, color: tokens.colorSecondaryText),
            const SizedBox(width: 6),
            Text(
              controller.skin.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: tokens.colorText,
              ),
            ),
            Icon(Icons.arrow_drop_down,
                size: 18, color: tokens.colorSecondaryText),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.of(context);
    final isDark = controller.mode == ThemeMode.dark;
    return IconButton(
      tooltip: isDark ? 'Switch to light' : 'Switch to dark',
      onPressed: controller.toggle,
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
    );
  }
}
