import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../content/pattern_page_content.dart';
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
              actions: const [_ThemeToggle()],
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
          const _ThemeToggle(),
        ],
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
