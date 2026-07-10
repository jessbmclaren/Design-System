import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

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

/// A syntax-highlighted, copyable Dart code block.
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF15171C) : const Color(0xFF1E2230);
    final highlighters = CodeHighlighters.instance;

    final Widget codeText;
    if (highlighters != null) {
      // Always use the dark code theme for contrast on the dark surface.
      codeText = Text.rich(
        highlighters.dark.highlight(widget.code),
        style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5),
      );
    } else {
      codeText = SelectableText(
        widget.code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.5,
          color: Color(0xFFE6E8EF),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
            child: Row(
              children: [
                Text(
                  'Dart',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
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
                    _copied ? Icons.check : Icons.copy_outlined,
                    size: 15,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  label: Text(
                    _copied ? 'Copied' : 'Copy',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  ),
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
