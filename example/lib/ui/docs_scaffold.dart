import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../app.dart';
import '../content/pattern_page_content.dart';
import 'docs_skins.dart';
import 'docs_style.dart';
import 'pattern_page_view.dart';
import 'sidebar.dart';

/// The top-level docs layout: a persistent sidebar on wide screens (a drawer
/// on narrow ones), a slim top bar with the brand switcher and light/dark
/// toggle, and the selected pattern page. The chrome wears the docs styling
/// language; the pattern's live demos still render the real Design System.
class DocsScaffold extends StatelessWidget {
  const DocsScaffold({super.key, required this.page});

  final PatternPage page;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      backgroundColor: docs.canvas,
      drawer: wide
          ? null
          : Drawer(
              backgroundColor: docs.surface,
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
              backgroundColor: docs.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              shape: Border(bottom: BorderSide(color: docs.separator)),
              iconTheme: IconThemeData(color: docs.textPrimary),
              title: Text(page.navTitle, style: DocsType.headline(docs.textPrimary)),
              actions: const [
                _SkinSwitcher(compact: true),
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
                    child: ColoredBox(
                      color: docs.canvas,
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
    final docs = DocsColors.of(context);
    return Container(
      width: double.infinity,
      height: DocsMetrics.topBarHeight,
      // A full-width chrome bar: breadcrumb at the left gutter, global controls
      // at a right margin matching the sidebar wordmark's inset.
      padding: const EdgeInsets.fromLTRB(
          DocsMetrics.barGutter, 0, DocsMetrics.wordmarkInset, 0),
      decoration: BoxDecoration(
        color: docs.surface,
        border: Border(bottom: BorderSide(color: docs.separator)),
      ),
      child: Row(
        children: [
          // The breadcrumb takes all the spare width, so the controls stay
          // pinned to the right edge no matter how long it is. A single Spacer
          // would split the space with the title's own Flexible and let the
          // controls drift as the breadcrumb changes length between pages.
          Expanded(
            child: Row(
              children: [
                Text(page.group.label,
                    style: DocsType.footnote(docs.textSecondary)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(LucideIcons.chevron_right,
                      size: 14, color: docs.textTertiary),
                ),
                Flexible(
                  child: Text(
                    page.navTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DocsType.footnote(docs.textPrimary)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
  const _SkinSwitcher({this.compact = false});

  /// On narrow layouts the switcher collapses to an icon-only button so the
  /// AppBar title keeps its room.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.of(context);
    final docs = DocsColors.of(context);
    return PopupMenuButton<DocsSkin>(
      tooltip: 'Switch brand',
      position: PopupMenuPosition.under,
      // Open on the system's motion tokens, and not at all under reduced
      // motion (the framework default is a fixed fade that ignores it).
      popUpAnimationStyle: DsMotion.reduced(context)
          ? AnimationStyle.noAnimation
          : AnimationStyle(
              duration: DsMotion.base,
              curve: DsMotion.decelerate,
            ),
      color: docs.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DocsRadii.md),
        side: BorderSide(color: docs.separator),
      ),
      onSelected: controller.selectSkin,
      itemBuilder: (context) => [
        for (final skin in kDocsSkins)
          PopupMenuItem<DocsSkin>(
            value: skin,
            child: Row(
              children: [
                Expanded(
                  child: Text(skin.name, style: DocsType.callout(docs.textPrimary)),
                ),
                if (skin == controller.skin) ...[
                  const SizedBox(width: 16),
                  Icon(LucideIcons.check, size: 16, color: docs.accent),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        height: 34,
        width: compact ? 34 : null,
        padding: compact
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: docs.surface,
          border: Border.all(color: docs.separator),
          borderRadius: BorderRadius.circular(DocsRadii.sm),
        ),
        child: compact
            ? Icon(LucideIcons.swatch_book, size: 16, color: docs.textSecondary)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.swatch_book,
                      size: 15, color: docs.textSecondary),
                  const SizedBox(width: 7),
                  Text(controller.skin.name,
                      style: DocsType.callout(docs.textPrimary)),
                  const SizedBox(width: 3),
                  Icon(LucideIcons.chevron_down,
                      size: 15, color: docs.textTertiary),
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
    final docs = DocsColors.of(context);
    final isDark = controller.mode == ThemeMode.dark;
    final radius = BorderRadius.circular(DocsRadii.sm);
    return Tooltip(
      message: isDark ? 'Switch to light' : 'Switch to dark',
      child: Material(
        color: docs.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: docs.separator),
          borderRadius: radius,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: controller.toggle,
          child: SizedBox(
            width: 34,
            height: 34,
            child: AnimatedSwitcher(
              duration: DsMotion.durationOf(context, DsMotion.base),
              // Entrances decelerate, exits accelerate: the motion law.
              // AnimatedSwitcher runs switchOutCurve un-mirrored against the
              // falling animation, so the accelerate curve must be flipped to
              // actually accelerate the exit.
              switchInCurve: DsMotion.curveOf(context, DsMotion.emphasized),
              switchOutCurve:
                  DsMotion.curveOf(context, DsMotion.accelerate.flipped),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: Tween<double>(begin: 0.6, end: 1).animate(anim),
                child: FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(scale: anim, child: child),
                ),
              ),
              child: Icon(
                isDark ? LucideIcons.sun : LucideIcons.moon,
                key: ValueKey<bool>(isDark),
                size: 16,
                color: docs.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
