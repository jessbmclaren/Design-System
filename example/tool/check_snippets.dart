// Compile-guard for the copyable code in the docs.
//
// Every pattern page ships a `code:` snippet that a developer is meant to copy
// straight into their product. This tool proves each one still resolves against
// the real design-system API, so a renamed parameter, a deleted class or a
// dropped enum value breaks the build here instead of silently rotting into
// broken copy-paste.
//
// How it works: each snippet is split into its top-level units (the docs often
// show two or three independent examples in one block), and each unit is wrapped
// in a tiny widget and handed to `dart analyze`. Symbols the reader supplies
// (their own controllers, rows, domain enums) are absorbed — reader values as
// `dynamic`, a reader enum used with named constants as a synthesised enum — so
// they never fail the check. Only a genuine design-system symbol that no longer
// resolves survives as an error. Any undefined `Ds*` / `ds*` name, or a member
// missing on a `Ds*` receiver, is treated as real breakage and never absorbed.
//
// Snippets are read from the generated twins in `docs/patterns/*.md`, so run
// `dart run tool/generate_markdown.dart --check` first to guarantee the twins
// match the content model.
//
// Usage (from example/):
//   dart run tool/check_snippets.dart
// Exits 0 when every checked snippet resolves, 1 (with a report) when one does
// not.

import 'dart:io';

/// A hidden scratch dir under `.dart_tool`, which the analyzer excludes from
/// ordinary package-wide runs, so these probes never pollute `flutter analyze`.
const probeDirRel = '.dart_tool/snippet_probe';

/// Pages whose snippet intentionally references a caller-defined type that the
/// design system does not export and that cannot be synthesised (e.g. a bare
/// type with no telltale constructor or constant). Kept explicit and reported,
/// never silently dropped. Empty today — every snippet is fully checked.
const skips = <String, String>{};

void main() {
  final repoRoot = Directory.current.path;
  final patternsDir = Directory('$repoRoot/../docs/patterns');
  if (!patternsDir.existsSync()) {
    stderr.writeln('Run this from the example/ directory (docs/patterns not found).');
    exit(2);
  }

  final probes = _buildProbes(patternsDir);
  final probeDir = Directory(probeDirRel);
  var exitCode = 0;
  try {
    final failures = _resolve(probes, probeDir);
    _report(probes, failures);
    exitCode = failures.isEmpty ? 0 : 1;
  } finally {
    // Clean up before exit(): exit() would skip a finally, so we tidy here and
    // exit last.
    if (probeDir.existsSync()) probeDir.deleteSync(recursive: true);
  }
  exit(exitCode);
}

/// One top-level unit of one snippet, plus the reader symbols absorbed for it.
class _Probe {
  _Probe(this.pageId, this.index, this.code);
  final String pageId;
  final int index;
  final String code;
  final Set<String> dynamics = {};
  final Map<String, Set<String>> enums = {};
  String get name => '${pageId}_$index';
}

List<_Probe> _buildProbes(Directory patternsDir) {
  final probes = <_Probe>[];
  final files = patternsDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final id = file.uri.pathSegments.last.replaceAll('.md', '').replaceAll('-', '_');
    if (skips.containsKey(id)) continue;
    final match = RegExp(r'```dart\n([\s\S]*?)```').firstMatch(file.readAsStringSync());
    if (match == null) continue;
    var index = 0;
    for (final unit in _topLevelUnits(match.group(1)!)) {
      final code = _prepare(unit);
      if (_stripComments(code).trim().isEmpty) continue;
      probes.add(_Probe(id, index++, code));
    }
  }
  return probes;
}

/// Split a snippet into top-level statements. A blank line only starts a new
/// unit when the next code line is unindented (a genuine new top-level
/// statement), so blank lines *inside* a widget tree do not fragment it.
List<String> _topLevelUnits(String code) {
  final lines = code.split('\n');
  final units = <String>[];
  var current = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isEmpty) {
      var j = i + 1;
      while (j < lines.length && lines[j].trim().isEmpty) {
        j++;
      }
      final nextUnindented = j < lines.length && !lines[j].startsWith(RegExp(r'\s'));
      if (nextUnindented && current.any((l) => l.trim().isNotEmpty)) {
        units.add(current.join('\n'));
        current = <String>[];
      } else {
        current.add(line);
      }
    } else {
      current.add(line);
    }
  }
  if (current.any((l) => l.trim().isNotEmpty)) units.add(current.join('\n'));
  return units;
}

String _stripComments(String s) => s.replaceAll(RegExp(r'//[^\n]*'), '');

/// Drop imports, neutralise `const` (we check name/type resolution, not
/// const-evaluation) and terminate the trailing expression so the unit is a
/// valid statement.
String _prepare(String unit) {
  var u = unit
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('import '))
      .join('\n')
      .replaceAll(RegExp(r'\bconst\b'), '')
      .trimRight();
  final tail = _stripComments(u).trimRight();
  if (tail.endsWith(';') || tail.endsWith('}')) return u;
  if (tail.endsWith(',')) {
    final k = u.lastIndexOf(',');
    return '${u.substring(0, k)};';
  }
  return '$u;';
}

String _render(_Probe p) {
  final enums = p.enums.entries
      .map((e) => 'enum ${e.key} { ${e.value.join(', ')} }')
      .join('\n');
  final dynamics = p.dynamics.map((n) => '    dynamic $n;').join('\n');
  return '''
// ignore_for_file: unused_local_variable, unused_import, unused_element, dead_code
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';

$enums

class _Probe_${p.name} extends StatelessWidget {
  const _Probe_${p.name}();
  void setState(void Function() fn) {}
  @override
  Widget build(BuildContext context) {
$dynamics
${p.code}
    return const SizedBox.shrink();
  }
}
''';
}

/// A resolution failure that survived absorption: a real design-system break.
///
/// Value equality (not identity) so the report's `.toSet()` collapses the same
/// break reported twice — e.g. a dropped enum value used twice in one snippet.
class _Failure {
  _Failure(this.pageId, this.code, this.message);
  final String pageId;
  final String code;
  final String message;

  @override
  bool operator ==(Object other) =>
      other is _Failure &&
      other.pageId == pageId &&
      other.code == code &&
      other.message == message;

  @override
  int get hashCode => Object.hash(pageId, code, message);
}

/// Run the analyzer, absorbing reader-supplied symbols, until only genuine
/// design-system failures remain (a two-pass fixed point in practice).
List<_Failure> _resolve(List<_Probe> probes, Directory probeDir) {
  final byName = {for (final p in probes) p.name: p};
  var failures = <_Failure>[];
  for (var pass = 0; pass < 6; pass++) {
    _writeProbes(probes, probeDir);
    var absorbed = 0;
    failures = [];
    for (final error in _analyzeErrors(probeDir)) {
      final probe = byName[error.probeName];
      final name = error.symbol;
      // A member missing on a real design-system receiver (a dropped enum value
      // or renamed getter, e.g. `DsButtonVariant.ghost`) is always drift,
      // regardless of the member's own casing — never absorb it.
      final dsReceiver = error.receiver != null &&
          (error.receiver!.startsWith('Ds') || error.receiver!.startsWith('ds'));
      if (probe == null ||
          name == null ||
          dsReceiver ||
          name.startsWith('Ds') ||
          name.startsWith('ds')) {
        failures.add(_Failure(
            probe?.pageId ?? error.probeName ?? 'unknown', error.code, error.message));
        continue;
      }
      if (RegExp(r'^[A-Z]').hasMatch(name)) {
        final members = RegExp('\\b$name\\.([a-z]\\w*)')
            .allMatches(probe.code)
            .map((m) => m.group(1)!)
            .toSet();
        if (members.isNotEmpty) {
          probe.enums[name] = members;
          absorbed++;
          continue;
        }
      }
      probe.dynamics.add(name);
      absorbed++;
    }
    if (absorbed == 0) break;
  }
  return failures;
}

void _writeProbes(List<_Probe> probes, Directory probeDir) {
  if (probeDir.existsSync()) probeDir.deleteSync(recursive: true);
  probeDir.createSync(recursive: true);
  for (final p in probes) {
    File('${probeDir.path}/s_${p.name}.dart').writeAsStringSync(_render(p));
  }
}

class _AnalyzerError {
  _AnalyzerError(this.code, this.probeName, this.message, this.symbol, this.receiver);
  final String code;
  final String? probeName;
  final String message;

  /// The undefined identifier, if the message names one.
  final String? symbol;

  /// The receiver type a missing member was accessed on, e.g. the
  /// `DsButtonVariant` in "no constant named 'x' in 'DsButtonVariant'".
  final String? receiver;
}

List<_AnalyzerError> _analyzeErrors(Directory probeDir) {
  final result = Process.runSync(
    'dart',
    ['analyze', '--format=machine', probeDir.path],
    workingDirectory: Directory.current.path,
  );
  final errors = <_AnalyzerError>[];
  for (final line in (result.stdout as String).split('\n')) {
    if (!line.startsWith('ERROR')) continue;
    final parts = line.split('|');
    if (parts.length < 8) continue;
    final code = parts[2];
    final probeName = RegExp(r's_(\w+)\.dart').firstMatch(parts[3])?.group(1);
    final message = parts[7].trim();
    final symbol = (RegExp(r"(?:Undefined name|Undefined class|The name) '(\w+)'")
                .firstMatch(message) ??
            RegExp(r"The (?:method|getter|setter|function) '(\w+)' isn't defined")
                .firstMatch(message))
        ?.group(1);
    final receiver = (RegExp(
                    r"isn't defined for the (?:type|enum|class|extension|mixin|extension type) '(\w+)'")
                .firstMatch(message) ??
            RegExp(r"no constant named '\w+' in '(\w+)'").firstMatch(message))
        ?.group(1);
    errors.add(_AnalyzerError(code, probeName, message, symbol, receiver));
  }
  return errors;
}

void _report(List<_Probe> probes, List<_Failure> failures) {
  final pages = probes.map((p) => p.pageId).toSet().length;
  if (failures.isEmpty) {
    stdout.writeln('All ${probes.length} snippet units from $pages pages resolve '
        'against the live API.');
    for (final entry in skips.entries) {
      stdout.writeln('  skipped ${entry.key.replaceAll('_', '-')}: ${entry.value}');
    }
    return;
  }
  stdout.writeln('Broken doc snippets — the copyable code no longer compiles:\n');
  final byPage = <String, List<_Failure>>{};
  for (final f in failures.toSet()) {
    byPage.putIfAbsent(f.pageId, () => []).add(f);
  }
  for (final entry in byPage.entries) {
    stdout.writeln('  docs/patterns/${entry.key.replaceAll('_', '-')}.md');
    for (final f in entry.value) {
      stdout.writeln('    ${f.code}: ${f.message}');
    }
  }
  stdout.writeln('\nFix the `code:` snippet in the matching '
      'example/lib/content/pages/*.dart, then regenerate the docs.');
}
