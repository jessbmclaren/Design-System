// Generates (or checks) the docs/patterns/*.md twins from the shared content
// model. Pure Dart — run with `dart run tool/generate_markdown.dart` from the
// example directory.
//
//   dart run tool/generate_markdown.dart          # write the .md files
//   dart run tool/generate_markdown.dart --check   # fail if any is stale
//
// Because the app's "View as Markdown" pane and these files both call
// emitMarkdown(), they are guaranteed to match.

import 'dart:io';

import 'package:ds_docs/content/doc_registry.dart';
import 'package:ds_docs/markdown/emitter.dart';

void main(List<String> args) {
  final check = args.contains('--check');

  // repoRoot/example/tool/generate_markdown.dart -> repoRoot
  final scriptFile = File.fromUri(Platform.script);
  final repoRoot = scriptFile.parent.parent.parent;
  final outDir = Directory('${repoRoot.path}/docs/patterns');
  outDir.createSync(recursive: true);

  var stale = 0;
  for (final page in allPages) {
    final markdown = emitMarkdown(page, index: pageIndex);
    final file = File('${outDir.path}/${page.id}.md');
    final existing = file.existsSync() ? file.readAsStringSync() : null;

    if (check) {
      if (existing != markdown) {
        stale++;
        stderr.writeln('STALE: docs/patterns/${page.id}.md');
      }
    } else {
      file.writeAsStringSync(markdown);
      stdout.writeln('wrote docs/patterns/${page.id}.md');
    }
  }

  if (check) {
    if (stale > 0) {
      stderr.writeln(
          '\n$stale markdown file(s) out of date. Run: dart run tool/generate_markdown.dart');
      exit(1);
    }
    stdout.writeln('All ${allPages.length} markdown files up to date.');
  } else {
    stdout.writeln('\nGenerated ${allPages.length} markdown files.');
  }
}
