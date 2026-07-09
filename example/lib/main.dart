import 'package:flutter/material.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

import 'app.dart';
import 'ui/code_block.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the Dart grammar and both code themes once at startup.
  await Highlighter.initialize(['dart']);
  CodeHighlighters.instance = CodeHighlighters(
    light: Highlighter(
      language: 'dart',
      theme: await HighlighterTheme.loadLightTheme(),
    ),
    dark: Highlighter(
      language: 'dart',
      theme: await HighlighterTheme.loadDarkTheme(),
    ),
  );

  runApp(const DocsApp());
}
