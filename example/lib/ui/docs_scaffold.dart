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
      backgroundColor: tokens.colorBackground,
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
                SizedBox(width: 8),
                _ThemeToggle(),
                SizedBox(width: 12),
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
                  Expanded(
                    child: DecoratedBox(
                      // A faint brand-tinted glow at the top gives the reading
                      // column a sense of depth without a heavy background.
                      decoration: BoxDecoration(
                        color: tokens.colorBackground,
                        gradient: RadialGradient(
                          center: const Alignment(0, -1.2),
                          radius: 1.1,
                          colors: [
                            tokens.colorPrimary.withValues(alpha: 0.06),
                            tokens.colorBackground.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      child: PatternPageView(page: page),
                    ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.page});
  final PatternPage page;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: tokens.colorBackground,
        border: Border(bottom: BorderSide(color: tokens.colorBorder)),
        boxShadow: DsElevation.low,
      ),
      child: Row(
        children: [
          Text(
            page.group.label,
            style: TextStyle(
              fontSize: 13,
              color: tokens.colorSecondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.chevron_right,
                size: 16, color: tokens.colorSecondaryText),
          ),
          Text(
            page.navTitle,
            style: TextStyle(
              fontSize: 13,
              color: tokens.colorText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const _SkinSwitcher(),
          const SizedBox(width: 10),
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
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: tokens.formBackgroundColor,
          border: Border.all(color: tokens.colorBorder),
          borderRadius: BorderRadius.circular(tokens.buttonBorderRadius + 4),
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

/// The light/dark switch. The glyph swaps with a small rotate-and-fade so the
/// change reads as a physical flip rather than a hard cut.
class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.of(context);
    final tokens = DsTokens.of(context);
    final isDark = controller.mode == ThemeMode.dark;
    final radius = BorderRadius.circular(tokens.buttonBorderRadius + 4);
    return Tooltip(
      message: isDark ? 'Switch to light' : 'Switch to dark',
      child: Material(
        color: tokens.formBackgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: tokens.colorBorder),
          borderRadius: radius,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: controller.toggle,
          child: SizedBox(
            width: 36,
            height: 36,
            child: AnimatedSwitcher(
              duration: DsMotion.durationOf(context, DsMotion.base),
              switchInCurve: DsMotion.standard,
              switchOutCurve: DsMotion.standard,
              transitionBuilder: (child, anim) => RotationTransition(
                turns: Tween<double>(begin: 0.6, end: 1).animate(anim),
                child: FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(scale: anim, child: child),
                ),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey<bool>(isDark),
                size: 18,
                color: tokens.colorText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
