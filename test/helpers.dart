import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] inside a Design System themed [MaterialApp] + [Scaffold].
///
/// Pass [surfaceSize] to exercise a specific viewport (e.g. a 320dp phone) and
/// assert that a component does not overflow. Pass [theme] to test a
/// white-labelled or dark theme.
Future<void> pumpDs(
  WidgetTester tester,
  Widget child, {
  Size? surfaceSize,
  ThemeData? theme,
  double textScale = 1.0,
}) async {
  if (surfaceSize != null) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = surfaceSize;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? DsTheme.light(),
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Center(child: child),
        ),
      ),
    ),
  );
}
