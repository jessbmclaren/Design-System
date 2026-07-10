// Pure Dart, no Flutter imports. Shared by the docs app and the CLI.

import '../content/pattern_page_content.dart';

/// Renders [page] as a GitHub-flavoured markdown document.
///
/// The same function powers the in-app "View as Markdown" pane and the
/// committed `docs/patterns/*.md` twins, so the two are guaranteed to match.
///
/// Pass [index] (id → page) so "See also" links can use each related page's
/// title.
String emitMarkdown(PatternPage page, {Map<String, PatternPage> index = const {}}) {
  final b = StringBuffer();

  b.writeln('# ${page.title}');
  b.writeln();
  b.writeln(page.description);
  b.writeln();

  for (final block in page.blocks) {
    _writeBlock(b, block);
  }

  if (page.shots.isNotEmpty) {
    for (final shot in page.shots) {
      final caption = shot.caption ?? shot.size.label;
      b.writeln('![$caption](${shot.path})');
      b.writeln();
      b.writeln('*$caption*');
      b.writeln();
    }
  }

  if (page.dos.isNotEmpty || page.donts.isNotEmpty) {
    b.writeln('## Guidelines');
    b.writeln();
    if (page.dos.isNotEmpty) {
      b.writeln('**Do**');
      b.writeln();
      for (final item in page.dos) {
        b.writeln('- $item');
      }
      b.writeln();
    }
    if (page.donts.isNotEmpty) {
      b.writeln("**Don't**");
      b.writeln();
      for (final item in page.donts) {
        b.writeln('- $item');
      }
      b.writeln();
    }
  }

  if (page.code != null && page.code!.trim().isNotEmpty) {
    b.writeln('## Example');
    b.writeln();
    b.writeln('```dart');
    b.writeln(page.code!.trimRight());
    b.writeln('```');
    b.writeln();
  }

  if (page.related.isNotEmpty) {
    b.writeln('## See also');
    b.writeln();
    for (final id in page.related) {
      final title = index[id]?.navTitle ?? id;
      b.writeln('- [$title]($id.md)');
    }
    b.writeln();
  }

  return '${b.toString().trimRight()}\n';
}

void _writeBlock(StringBuffer b, ContentBlock block) {
  switch (block) {
    case ProseBlock(:final text):
      b.writeln(text);
      b.writeln();
    case SubheadingBlock(:final text):
      b.writeln('## $text');
      b.writeln();
    case VariablesBlock(:final title, :final rows):
      if (title != null) {
        b.writeln('### $title');
        b.writeln();
      }
      b.writeln('| Name | Type | Example value | Description |');
      b.writeln('| --- | --- | --- | --- |');
      for (final r in rows) {
        final desc = r.description.replaceAll('|', r'\|');
        b.writeln('| `${r.name}` | ${r.type} | `${r.example}` | $desc |');
      }
      b.writeln();
  }
}
