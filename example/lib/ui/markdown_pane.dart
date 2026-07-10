import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../content/doc_registry.dart';
import '../content/pattern_page_content.dart';
import '../markdown/emitter.dart';
import 'docs_style.dart';

/// The full-page "View as Markdown" view.
///
/// Shows the exact committed `docs/patterns/{id}.md` source as selectable
/// plain text (the same string [emitMarkdown] writes to disk), so what you
/// read here is byte-identical to the file. A back affordance returns to the
/// rendered page.
class MarkdownView extends StatelessWidget {
  const MarkdownView({super.key, required this.page, required this.onClose});

  final PatternPage page;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    final markdown = emitMarkdown(page, index: pageIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: docs.surface,
            border: Border(bottom: BorderSide(color: docs.separator)),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: onClose,
                icon: const Icon(LucideIcons.arrow_left, size: 15),
                label: const Text('Back to page'),
                style: TextButton.styleFrom(foregroundColor: docs.link),
              ),
              const Spacer(),
              Icon(LucideIcons.file_text, size: 14, color: docs.textTertiary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${page.id}.md',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DocsType.mono(docs.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              _CopyButton(text: markdown),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: docs.canvas,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: SelectableText(
                markdown,
                style: DocsType.mono(docs.textPrimary, height: 1.65),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.text});
  final String text;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    return TextButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: widget.text));
        if (!mounted) return;
        setState(() => _copied = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _copied = false);
        });
      },
      icon: Icon(_copied ? LucideIcons.check : LucideIcons.copy, size: 15),
      label: Text(_copied ? 'Copied' : 'Copy'),
      style: TextButton.styleFrom(foregroundColor: docs.textSecondary),
    );
  }
}
