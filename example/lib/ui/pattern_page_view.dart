import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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
import 'docs_style.dart';
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
    final docs = DocsColors.of(context);
    final demo = demoFor(page.id);
    final playground = playgroundFor(page.id);

    if (_showMarkdown) {
      return MarkdownView(
        page: page,
        onClose: () => setState(() => _showMarkdown = false),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: DocsMetrics.pagePaddingX,
        vertical: DocsMetrics.pagePaddingY,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: DocsMetrics.readingMaxWidth),
            // Replays a gentle fade-and-rise each time the page changes,
            // through the system's own entrance component so the docs move
            // exactly like the library they document.
            child: DsFadeSlideIn(
              key: ValueKey(page.id),
              duration: DsMotion.slow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Eyebrow(label: page.group.label),
                  const SizedBox(height: 16),
                  // Scales the tight display title down on very narrow columns
                  // (a long single word at 320dp) rather than wrapping or clipping.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      page.title,
                      maxLines: 1,
                      softWrap: false,
                      style: DocsType.hero(docs.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Prose(page.description, large: true),
                  const SizedBox(height: 20),
                  _ActionBar(
                    onViewMarkdown: () => setState(() => _showMarkdown = true),
                  ),
                  const SizedBox(height: 32),
                  for (final block in page.blocks) ...[
                    _block(block),
                    const SizedBox(height: DocsMetrics.proseGap),
                  ],
                  if (playground != null) ...[
                    const SizedBox(height: 6),
                    PlaygroundPanel(
                      key: ValueKey('pg-${page.id}'),
                      spec: playground,
                    ),
                    const SizedBox(height: DocsMetrics.sectionGap),
                  ] else if (page.hasLiveDemo && demo != null) ...[
                    const SizedBox(height: 6),
                    DeviceFrame(child: demo),
                    const SizedBox(height: DocsMetrics.sectionGap),
                  ],
                  if (page.dos.isNotEmpty || page.donts.isNotEmpty) ...[
                    Text('Guidelines', style: DocsType.title2(docs.textPrimary)),
                    const SizedBox(height: DocsMetrics.sectionHeaderGap),
                    DoDont(dos: page.dos, donts: page.donts),
                    const SizedBox(height: DocsMetrics.sectionGap),
                  ],
                  if (page.code != null) ...[
                    Text('Example', style: DocsType.title2(docs.textPrimary)),
                    const SizedBox(height: DocsMetrics.sectionHeaderGap),
                    CodeBlock(code: page.code!.trim()),
                    const SizedBox(height: DocsMetrics.sectionGap),
                  ],
                  if (page.related.isNotEmpty) ...[
                    // This footer follows a major section (a live demo,
                    // Guidelines or Example), whose trailing sectionGap supplies
                    // the space above the divider, so it adds no leading gap of
                    // its own and avoids a doubled gap.
                    Divider(color: docs.separator, height: 1),
                    const SizedBox(height: 24),
                    Text('See also', style: DocsType.title3(docs.textPrimary)),
                    const SizedBox(height: DocsMetrics.sectionHeaderGap),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Cards keep their comfortable width on wide layouts and
                        // shrink to the column when it is narrower than one card.
                        final w = constraints.maxWidth < 264
                            ? constraints.maxWidth
                            : 264.0;
                        return Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            for (final id in page.related)
                              if (pageIndex[id] != null)
                                _RelatedCard(page: pageIndex[id]!, width: w),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _block(ContentBlock block) {
    final docs = DocsColors.of(context);
    return switch (block) {
      ProseBlock(:final text) => _Prose(text),
      SubheadingBlock(:final text) => Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Text(text, style: DocsType.title3(docs.textPrimary)),
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
    final docs = DocsColors.of(context);
    final base = large
        ? DocsType.lead(docs.textSecondary)
        : DocsType.body(docs.textPrimary);
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: base,
        a: TextStyle(color: docs.link, decoration: TextDecoration.none),
        // Inline code stays calm ink on a whisper-subtle fill so the paragraph
        // reads as one block rather than scattered accent colour.
        code: DocsType.mono(docs.codeInk, size: large ? 15 : 13.5, height: 1.4)
            .copyWith(backgroundColor: docs.fill),
        codeblockDecoration: BoxDecoration(
          color: docs.fill,
          borderRadius: BorderRadius.circular(DocsRadii.sm),
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
    final docs = DocsColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onViewMarkdown,
          borderRadius: BorderRadius.circular(DocsRadii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.file_text, size: 15, color: docs.link),
                const SizedBox(width: 7),
                Text(
                  'View as Markdown',
                  style: DocsType.callout(docs.link)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: docs.separator, height: 1),
      ],
    );
  }
}

/// The small accent label above a page title. Borderless and quiet, letting the
/// title carry the weight.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    return Text(
      label.toUpperCase(),
      style: DocsType.eyebrow(docs.textSecondary),
    );
  }
}

/// A "See also" link. Fixed height so a row of these always lines up, with a
/// small lift on hover.
class _RelatedCard extends StatefulWidget {
  const _RelatedCard({required this.page, this.width = 264});
  final PatternPage page;
  final double width;

  @override
  State<_RelatedCard> createState() => _RelatedCardState();
}

class _RelatedCardState extends State<_RelatedCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    final page = widget.page;
    final radius = BorderRadius.circular(DocsRadii.lg);
    return SizedBox(
      width: widget.width,
      height: 92,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: DsMotion.durationOf(context, DsMotion.fast),
          curve: DsMotion.curveOf(context, DsMotion.standard),
          transform: _hover
              ? Matrix4.translationValues(0, -3, 0)
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: docs.surface,
            borderRadius: radius,
            border: Border.all(
              color: _hover ? docs.separatorStrong : docs.separator,
            ),
            boxShadow: _hover ? DocsShadows.card : DocsShadows.none,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: radius,
              onTap: () => context.go('/patterns/${page.id}'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(page.group.label.toUpperCase(),
                        style: DocsType.sectionHeader(docs.textTertiary)),
                    Row(
                      children: [
                        Expanded(
                          child: Text(page.navTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DocsType.headline(docs.textPrimary)),
                        ),
                        AnimatedSlide(
                          duration: DsMotion.durationOf(context, DsMotion.fast),
                          curve: DsMotion.curveOf(context, DsMotion.standard),
                          offset: _hover ? const Offset(0.2, 0) : Offset.zero,
                          child: Icon(LucideIcons.arrow_right,
                              size: 16, color: docs.accent),
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
