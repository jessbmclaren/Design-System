import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'content/doc_registry.dart';
import 'ui/docs_scaffold.dart';

/// Inherited controller for the light/dark toggle in the docs chrome.
class ThemeController extends InheritedWidget {
  const ThemeController({
    super.key,
    required this.mode,
    required this.toggle,
    required super.child,
  });

  final ThemeMode mode;
  final VoidCallback toggle;

  static ThemeController of(BuildContext context) {
    final controller =
        context.dependOnInheritedWidgetOfExactType<ThemeController>();
    assert(controller != null, 'ThemeController is missing from the tree.');
    return controller!;
  }

  @override
  bool updateShouldNotify(ThemeController oldWidget) => mode != oldWidget.mode;
}

/// The documentation application.
class DocsApp extends StatefulWidget {
  const DocsApp({super.key});

  @override
  State<DocsApp> createState() => _DocsAppState();
}

class _DocsAppState extends State<DocsApp> {
  ThemeMode _mode = ThemeMode.light;

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

  @override
  Widget build(BuildContext context) {
    return ThemeController(
      mode: _mode,
      toggle: _toggle,
      child: MaterialApp.router(
        title: 'Design System',
        debugShowCheckedModeBanner: false,
        theme: DsTheme.light(),
        darkTheme: DsTheme.dark(),
        themeMode: _mode,
        routerConfig: _router,
      ),
    );
  }
}
