import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'content/doc_registry.dart';
import 'ui/docs_scaffold.dart';
import 'ui/docs_skins.dart';

/// Inherited controller for the docs chrome's theming: the light/dark mode and
/// the active brand [DocsSkin]. These are orthogonal axes — a brand can be
/// viewed in either mode.
class ThemeController extends InheritedWidget {
  const ThemeController({
    super.key,
    required this.mode,
    required this.toggle,
    required this.skin,
    required this.selectSkin,
    required super.child,
  });

  /// The active light/dark mode.
  final ThemeMode mode;

  /// Flips between light and dark.
  final VoidCallback toggle;

  /// The active brand skin.
  final DocsSkin skin;

  /// Selects a brand skin.
  final ValueChanged<DocsSkin> selectSkin;

  static ThemeController of(BuildContext context) {
    final controller =
        context.dependOnInheritedWidgetOfExactType<ThemeController>();
    assert(controller != null, 'ThemeController is missing from the tree.');
    return controller!;
  }

  @override
  bool updateShouldNotify(ThemeController oldWidget) =>
      mode != oldWidget.mode || skin != oldWidget.skin;
}

/// The documentation application.
class DocsApp extends StatefulWidget {
  const DocsApp({super.key});

  @override
  State<DocsApp> createState() => _DocsAppState();
}

class _DocsAppState extends State<DocsApp> {
  ThemeMode _mode = ThemeMode.light;
  DocsSkin _skin = kDocsSkins.first;

  late final GoRouter _router = GoRouter(
    initialLocation: '/patterns/${allPages.first.id}',
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, _) => '/patterns/${allPages.first.id}',
      ),
      GoRoute(
        path: '/patterns/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final page = pageIndex[id] ?? allPages.first;
          return DocsScaffold(page: page);
        },
      ),
    ],
  );

  void _toggle() {
    setState(() {
      _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _selectSkin(DocsSkin skin) {
    if (skin == _skin) return;
    setState(() => _skin = skin);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeController(
      mode: _mode,
      toggle: _toggle,
      skin: _skin,
      selectSkin: _selectSkin,
      child: MaterialApp.router(
        title: 'Design System',
        debugShowCheckedModeBanner: false,
        // Brand is a token override on the same themes; light/dark still works
        // for every skin.
        theme: DsTheme.light(tokens: _skin.lightTokens()),
        darkTheme: DsTheme.dark(tokens: _skin.darkTokens()),
        themeMode: _mode,
        routerConfig: _router,
      ),
    );
  }
}
