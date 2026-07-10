import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared harness for the Design System golden (visual regression) tests.
///
/// Goldens capture a component's *pixels* under a fixed theme, so a stray
/// padding, colour or radius change is caught even when behavioural tests stay
/// green. Regenerate them after an intentional visual change with:
///
/// ```sh
/// flutter test --update-goldens test/golden
/// ```
///
/// The reference PNGs live next to the tests in `test/golden/goldens/`.

const _boundaryKey = ValueKey('ds-golden-boundary');

bool _fontsLoaded = false;

/// Loads the fonts golden rendering needs: the four bundled Inter faces (so
/// text renders as real glyphs instead of the blank test font) and the Flutter
/// SDK's MaterialIcons font (so [DsIcon]/`Icons.*` render their glyphs rather
/// than the missing-glyph box). Idempotent and cheap after the first call.
Future<void> loadDsFonts() async {
  if (_fontsLoaded) return;

  final inter = FontLoader('packages/design_system/Inter');
  for (final path in const [
    'fonts/Inter-Regular.ttf',
    'fonts/Inter-Medium.ttf',
    'fonts/Inter-SemiBold.ttf',
    'fonts/Inter-Bold.ttf',
  ]) {
    inter.addFont(_fontBytes(File(path).readAsBytesSync()));
  }
  await inter.load();

  final materialIcons = FontLoader('MaterialIcons')
    ..addFont(_fontBytes(File(_materialIconsFontPath()).readAsBytesSync()));
  await materialIcons.load();

  _fontsLoaded = true;
}

Future<ByteData> _fontBytes(List<int> bytes) =>
    Future<ByteData>.value(ByteData.view(Uint8List.fromList(bytes).buffer));

/// Resolves `MaterialIcons-Regular.otf` inside the active Flutter SDK cache.
///
/// The font ships at `<sdk>/bin/cache/artifacts/material_fonts/`. We derive the
/// SDK root from the running Dart executable (`<sdk>/bin/cache/dart-sdk/bin/dart`)
/// and fall back to `FLUTTER_ROOT`, so this works under fvm, CI and plain
/// installs without a machine-specific path.
String _materialIconsFontPath() {
  const sep = '/';
  const rel = 'artifacts/material_fonts/MaterialIcons-Regular.otf';
  final exec = Platform.resolvedExecutable.replaceAll('\\', sep);
  const marker = '/bin/cache/';
  final idx = exec.indexOf(marker);
  final candidates = <String>[
    if (idx != -1) '${exec.substring(0, idx + marker.length)}$rel',
    if (Platform.environment['FLUTTER_ROOT'] != null)
      '${Platform.environment['FLUTTER_ROOT']!.replaceAll('\\', sep)}/bin/cache/$rel',
  ];
  for (final c in candidates) {
    if (File(c).existsSync()) return c;
  }
  throw StateError(
    'Could not locate MaterialIcons-Regular.otf in the Flutter SDK. Tried: '
    '${candidates.isEmpty ? '(none — could not derive SDK root)' : candidates.join(', ')}',
  );
}

/// A named theme a golden is captured under.
class DsGoldenTheme {
  const DsGoldenTheme(this.name, this.theme);

  /// Slug used in the golden filename (e.g. `light`, `dark`, `skin-engen`).
  final String name;

  /// The [ThemeData] the component is rendered with.
  final ThemeData theme;
}

/// The standard capture matrix: the default light and dark themes plus one
/// opt-in skin, so a re-branding regression (a token that stops flowing through
/// to a component) is caught alongside the defaults.
final List<DsGoldenTheme> dsGoldenThemes = [
  DsGoldenTheme('light', DsTheme.light()),
  DsGoldenTheme('dark', DsTheme.dark()),
  DsGoldenTheme('skin-engen', DsTheme.light(tokens: DsSkins.engenLight())),
];

/// Pumps [child] on a themed surface and compares the tight component bounds
/// against `goldens/<name>.png`.
///
/// A fixed-duration [pump] (rather than `pumpAndSettle`) advances any entrance
/// animation to a deterministic frame without hanging on components with a
/// continuous animation such as [DsSpinner].
Future<void> expectDsGolden(
  WidgetTester tester,
  Widget child, {
  required String name,
  required ThemeData theme,
  double width = 280,
}) async {
  await loadDsFonts();
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: RepaintBoundary(
            key: _boundaryKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      ),
    ),
  );
  // Build, then advance the fake clock a fixed amount so animated components
  // land on a reproducible frame.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 80));

  await expectLater(
    find.byKey(_boundaryKey),
    matchesGoldenFile('goldens/$name.png'),
  );
}

/// Registers one golden [testWidgets] per theme in [dsGoldenThemes] for the
/// component built by [build]. Produces files named `<group>__<name>__<theme>`.
void dsGoldenMatrix(
  String group,
  String name,
  Widget Function() build, {
  double width = 280,
}) {
  for (final variant in dsGoldenThemes) {
    testWidgets('$name · ${variant.name}', (tester) async {
      await expectDsGolden(
        tester,
        build(),
        name: '${group}__${name}__${variant.name}',
        theme: variant.theme,
        width: width,
      );
    });
  }
}
