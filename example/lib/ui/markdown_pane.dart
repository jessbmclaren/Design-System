import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../content/doc_registry.dart';
import '../content/pattern_page_content.dart';
import '../markdown/emitter.dart';

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
    final tokens = DsTokens.of(context);
    final markdown = emitMarkdown(page, index: pageIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: tokens.colorBorder)),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Back to page'),
                style: TextButton.styleFrom(
                  foregroundColor: tokens.actionPrimaryColorText,
                ),
              ),
              const Spacer(),
              Icon(Icons.description_outlined,
                  size: 15, color: tokens.colorSecondaryText),
              const SizedBox(width: 6),
              Text(
                '${page.id}.md',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: tokens.colorSecondaryText,
                ),
              ),
              const Spacer(),
              _CopyButton(text: markdown),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: tokens.offsetBackgroundColor,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                markdown,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.65,
                  color: tokens.colorText,
                ),
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
    return TextButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: widget.text));
        if (!mounted) return;
        setState(() => _copied = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _copied = false);
        });
      },
      icon: Icon(_copied ? Icons.check : Icons.copy_outlined, size: 15),
      label: Text(_copied ? 'Copied' : 'Copy'),
    );
  }
}
