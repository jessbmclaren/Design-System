import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

import 'docs_style.dart';

/// Holds the light and dark Dart highlighters, initialised once in `main`.
class CodeHighlighters {
  CodeHighlighters({required this.light, required this.dark});

  /// The process-wide instance, set in `main` after
  /// [Highlighter.initialize].
  static CodeHighlighters? instance;

  final Highlighter light;
  final Highlighter dark;

  Highlighter forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// A syntax-highlighted, copyable Dart code block. The surface follows the
/// docs theme: a calm light panel in light mode, a near-black panel in dark.
class CodeBlock extends StatefulWidget {
  const CodeBlock({super.key, required this.code});

  /// The Dart source to display.
  final String code;

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFBFBFD);
    final border = docs.separator;
    final muted = docs.textSecondary;
    final highlighters = CodeHighlighters.instance;
    final highlighter =
        highlighters == null ? null : (isDark ? highlighters.dark : highlighters.light);

    final Widget codeText;
    if (highlighter != null) {
      codeText = Text.rich(
        highlighter.highlight(widget.code),
        style: DocsType.mono(docs.textPrimary),
      );
    } else {
      codeText = SelectableText(
        widget.code,
        style: DocsType.mono(docs.textPrimary),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(DocsRadii.md),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 0),
            child: Row(
              children: [
                Text('Dart', style: DocsType.caption(muted)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: widget.code));
                    if (!mounted) return;
                    setState(() => _copied = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _copied = false);
                    });
                  },
                  icon: Icon(
                    _copied ? LucideIcons.check : LucideIcons.copy,
                    size: 14,
                    color: muted,
                  ),
                  label: Text(_copied ? 'Copied' : 'Copy',
                      style: DocsType.footnote(muted)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: codeText,
            ),
          ),
        ],
      ),
    );
  }
}
