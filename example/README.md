# Design System — documentation app

A Flutter app that documents the Design System: grouped navigation, live
component examples, copyable Dart code, and a "View as Markdown" pane for every
pattern.

## Run

```sh
flutter run -d chrome     # or: -d macos
```

## Regenerate the docs artifacts

```sh
# Write docs/patterns/*.md from the shared content model
dart run tool/generate_markdown.dart
dart run tool/generate_markdown.dart --check   # fail if any twin is stale

# Prove every copyable snippet still compiles against the live API
dart run tool/check_snippets.dart              # fail if a snippet no longer resolves

# Regenerate the screenshots embedded in the markdown twins
flutter test test/screenshots/screenshots.dart --update-goldens
```

The content model (`lib/content/`) and markdown emitter (`lib/markdown/`) are
pure Dart with no Flutter imports, so the generator runs on the plain Dart VM
and the app and the committed markdown can never disagree.
