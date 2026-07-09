import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';

import '../content/doc_registry.dart';
import '../content/pattern_page_content.dart';
import '../demos/demo_registry.dart';
import 'code_block.dart';
import 'device_frame.dart';
import 'do_dont.dart';
import 'markdown_pane.dart';
import 'variable_table.dart';

/// Renders one [PatternPage]: title, lead description, extra blocks, the live
/// example, guidance, the code sample, and a "View as Markdown" pane.
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(page.group.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: tokens.actionPrimaryColorText,
                    )),
                const SizedBox(height: 8),
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
                if (page.hasLiveDemo && demo != null) ...[
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

/// The thin action bar under the page description. We keep a single action —
/// "View as Markdown" — which reveals the page's raw markdown source.
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

class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.page});
  final PatternPage page;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return SizedBox(
      width: 240,
      child: Material(
        color: tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go('/patterns/${page.id}'),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tokens.colorBorder),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(page.group.label,
                    style: TextStyle(
                        fontSize: 11,
                        color: tokens.colorSecondaryText,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(page.navTitle,
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    Icon(Icons.arrow_forward,
                        size: 15, color: tokens.actionPrimaryColorText),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
