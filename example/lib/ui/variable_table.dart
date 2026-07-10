import 'package:flutter/material.dart';

import '../content/pattern_page_content.dart';
import 'docs_style.dart';

/// Renders a [VariablesBlock] as a NAME / TYPE / EXAMPLE VALUE table with a
/// per-row description: a light monospace pill for the name (hugging its text),
/// plain type text, a value pill and the description on its own line beneath.
class VariableTable extends StatelessWidget {
  const VariableTable({super.key, required this.block});

  final VariablesBlock block;

  // Column proportions: a wide name column, a narrower type column and a value
  // column.
  static const int _nameFlex = 5;
  static const int _typeFlex = 3;
  static const int _valueFlex = 4;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.title != null) ...[
          Text(block.title!, style: DocsType.title3(docs.textPrimary)),
          const SizedBox(height: 10),
        ],
        Container(
          decoration: BoxDecoration(
            color: docs.surface,
            border: Border.all(color: docs.separator),
            borderRadius: BorderRadius.circular(DocsRadii.md),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const _HeaderRow(),
              for (var i = 0; i < block.rows.length; i++)
                _VariableRowView(
                  row: block.rows[i],
                  last: i == block.rows.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    // Primary ink so the small uppercase labels clear 4.5:1 on the fill panel.
    final style = DocsType.sectionHeader(docs.textPrimary);
    return Container(
      color: docs.fill,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Expanded(flex: VariableTable._nameFlex, child: Text('NAME', style: style)),
          Expanded(flex: VariableTable._typeFlex, child: Text('TYPE', style: style)),
          Expanded(
              flex: VariableTable._valueFlex,
              child: Text('EXAMPLE VALUE', style: style)),
        ],
      ),
    );
  }
}

class _VariableRowView extends StatelessWidget {
  const _VariableRowView({required this.row, required this.last});

  final VariableRow row;
  final bool last;

  bool get _isColor => row.example.startsWith('#');

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);

    return Container(
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: docs.separator)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // NAME: a pill that hugs its text on the left.
              Expanded(
                flex: VariableTable._nameFlex,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _Pill(text: row.name),
                ),
              ),
              // TYPE: plain text. Ellipsised so a long single-word type can't
              // char-wrap into a tall cell at narrow widths.
              Expanded(
                flex: VariableTable._typeFlex,
                child: Text(
                  row.type,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: DocsType.footnote(docs.textPrimary),
                ),
              ),
              // EXAMPLE VALUE: a pill, with a colour swatch for hex values.
              Expanded(
                flex: VariableTable._valueFlex,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isColor) ...[
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _parseHex(row.example),
                            borderRadius: BorderRadius.circular(DocsRadii.xs),
                            border: Border.all(color: docs.separator),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(child: _Pill(text: row.example)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Description: its own line, full width, in secondary text.
          Text(row.description, style: DocsType.footnote(docs.textSecondary)),
        ],
      ),
    );
  }
}

/// A light monospace pill used for variable names and example values.
class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: docs.fill,
        borderRadius: BorderRadius.circular(DocsRadii.xs),
        border: Border.all(color: docs.separator),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: DocsType.mono(docs.textPrimary, size: 12.5),
      ),
    );
  }
}

Color? _parseHex(String hex) {
  var h = hex.replaceAll('#', '').trim();
  if (h.length == 6) h = 'FF$h';
  final value = int.tryParse(h, radix: 16);
  return value == null ? null : Color(value);
}
