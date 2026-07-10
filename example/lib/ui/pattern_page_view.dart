import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';

import '../content/doc_registry.dart';
import '../content/pattern_page_content.dart';
import '../demos/demo_registry.dart';
import '../playground/playground.dart';
import '../playground/playground_registry.dart';
import 'code_block.dart';
import 'device_frame.dart';
import 'do_dont.dart';
import 'markdown_pane.dart';
import 'variable_table.dart';

/// Renders one [PatternPage]: title, lead description, extra blocks, the live
/// example, guidance, the code sample and a "View as Markdown" pane.
class PatternPageView extends StatefulWidget {
  const PatternPageView({super.key, required this.page});

  final PatternPage page;

  @override
  State<PatternPageView> createState() => _PatternPageViewState();
}

class _PatternPageViewState extends State<PatternPageView> {
  bool _showMarkdown = false;

  @override
  void didUpdateWidget(PatternPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.id != widget.page.id) {
      _showMarkdown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    final theme = Theme.of(context);
    final tokens = DsTokens.of(context);
    final demo = demoFor(page.id);
    final playground = playgroundFor(page.id);

    if (_showMarkdown) {
      return MarkdownView(
        page: page,
        onClose: () => setState(() => _showMarkdown = false),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            // Replays a gentle fade-and-rise each time the page changes.
            child: _EntranceTransition(
              key: ValueKey(page.id),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Eyebrow(label: page.group.label),
                const SizedBox(height: 12),
                Text(page.title, style: theme.textTheme.displaySmall),
                const SizedBox(height: 16),
                _Prose(page.description, large: true),
                const SizedBox(height: 16),
                _ActionBar(
                  onViewMarkdown: () => setState(() => _showMarkdown = true),
                ),
                const SizedBox(height: 28),
                for (final block in page.blocks) ...[
                  _block(block),
                  const SizedBox(height: 20),
                ],
                if (playground != null) ...[
                  const SizedBox(height: 4),
                  PlaygroundPanel(
                    key: ValueKey('pg-${page.id}'),
                    spec: playground,
                  ),
                  const SizedBox(height: 32),
                ] else if (page.hasLiveDemo && demo != null) ...[
                  const SizedBox(height: 4),
                  DeviceFrame(child: demo),
                  const SizedBox(height: 32),
                ],
                if (page.dos.isNotEmpty || page.donts.isNotEmpty) ...[
                  Text('Guidelines', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  DoDont(dos: page.dos, donts: page.donts),
                  const SizedBox(height: 32),
                ],
                if (page.code != null) ...[
                  Text('Example', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  CodeBlock(code: page.code!.trim()),
                  const SizedBox(height: 32),
                ],
                if (page.related.isNotEmpty) ...[
                  const SizedBox(height: 40),
                  Divider(color: tokens.colorBorder),
                  const SizedBox(height: 16),
                  Text('See also', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final id in page.related)
                        if (pageIndex[id] != null)
                          _RelatedCard(page: pageIndex[id]!),
                    ],
                  ),
                ],
                const SizedBox(height: 60),
              ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _block(ContentBlock block) {
    return switch (block) {
      ProseBlock(:final text) => _Prose(text),
      SubheadingBlock(:final text) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
        ),
      VariablesBlock() => VariableTable(block: block),
    };
  }
}

class _Prose extends StatelessWidget {
  const _Prose(this.text, {this.large = false});
  final String text;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final base = large
        ? Theme.of(context).textTheme.bodyLarge
        : Theme.of(context).textTheme.bodyMedium;
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: base?.copyWith(
          color: large ? tokens.colorSecondaryText : tokens.colorText,
          height: 1.55,
          fontSize: large ? 17 : null,
        ),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13.5,
          backgroundColor: tokens.offsetBackgroundColor,
          color: tokens.actionPrimaryColorText,
        ),
      ),
    );
  }
}

/// The thin action bar under the page description. We keep a single action,
/// "View as Markdown", which reveals the page's raw markdown source.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onViewMarkdown});
  final VoidCallback onViewMarkdown;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onViewMarkdown,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.description_outlined,
                    size: 16, color: tokens.actionPrimaryColorText),
                const SizedBox(width: 6),
                Text(
                  'View as Markdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: tokens.actionPrimaryColorText,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: tokens.colorBorder, height: 1),
      ],
    );
  }
}

/// The small uppercase tag above a page title.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final accent = tokens.actionPrimaryColorText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: accent,
        ),
      ),
    );
  }
}

/// Fades and lifts its child into place once, on first build. Give it a
/// [ValueKey] tied to the page id so navigation replays the entrance.
class _EntranceTransition extends StatelessWidget {
  const _EntranceTransition({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: DsMotion.durationOf(context, DsMotion.slow),
      curve: DsMotion.emphasized,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 12),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// A "See also" link. Fixed height so a row of these always lines up, with a
/// small lift on hover.
class _RelatedCard extends StatefulWidget {
  const _RelatedCard({required this.page});
  final PatternPage page;

  @override
  State<_RelatedCard> createState() => _RelatedCardState();
}

class _RelatedCardState extends State<_RelatedCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final page = widget.page;
    final radius = BorderRadius.circular(10);
    return SizedBox(
      width: 262,
      height: 86,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: DsMotion.durationOf(context, DsMotion.fast),
          curve: DsMotion.standard,
          transform: _hover
              ? Matrix4.translationValues(0, -3, 0)
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: tokens.formBackgroundColor,
            borderRadius: radius,
            border: Border.all(
              color: _hover
                  ? tokens.actionPrimaryColorText.withValues(alpha: 0.45)
                  : tokens.colorBorder,
            ),
            boxShadow: _hover ? DsElevation.medium : DsElevation.none,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: radius,
              onTap: () => context.go('/patterns/${page.id}'),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(page.group.label.toUpperCase(),
                        style: TextStyle(
                            fontSize: 10.5,
                            letterSpacing: 0.6,
                            color: tokens.colorSecondaryText,
                            fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        Expanded(
                          child: Text(page.navTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall),
                        ),
                        AnimatedSlide(
                          duration: DsMotion.durationOf(context, DsMotion.fast),
                          offset: _hover ? const Offset(0.2, 0) : Offset.zero,
                          child: Icon(Icons.arrow_forward,
                              size: 16, color: tokens.actionPrimaryColorText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
