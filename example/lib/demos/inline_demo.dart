import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Inline page: the four standalone treatments, plus a
/// mixed-treatment paragraph built with `DsInline.span` and `Text.rich`.
class InlineDemo extends StatelessWidget {
  const InlineDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            DsInline(text: 'Bold', bold: true),
            DsInline(text: 'Italic', italic: true),
            DsInline(text: 'code', code: true),
            DsInline(text: 'Strikethrough', strikethrough: true),
          ],
        ),
        SizedBox(height: 20),
        _MixedParagraph(),
      ],
    );
  }
}

/// A single paragraph that combines several inline treatments via `Text.rich`.
class _MixedParagraph extends StatelessWidget {
  const _MixedParagraph();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Set '),
          DsInline.span(context: context, text: 'retry_limit', code: true),
          const TextSpan(text: ' to '),
          DsInline.span(context: context, text: '3', bold: true),
          const TextSpan(text: '. The old default of '),
          DsInline.span(context: context, text: '10', strikethrough: true),
          const TextSpan(text: ' is '),
          DsInline.span(context: context, text: 'deprecated', italic: true),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
