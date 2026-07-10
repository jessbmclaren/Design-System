import 'package:design_system/design_system.dart';
import 'package:ds_docs/playground/playground.dart';
import 'package:ds_docs/playground/playground_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: DsTheme.light(),
      home: Scaffold(
        body: SizedBox(
          width: 1000,
          // The panel lives in a scroll view in the app; mirror that here.
          child: SingleChildScrollView(child: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('the action-buttons page has a playground', (tester) async {
    expect(playgroundFor('action-buttons'), isNotNull);
    expect(playgroundFor('nonexistent'), isNull);
  });

  testWidgets('turning a knob re-renders the live component', (tester) async {
    await _pump(tester, PlaygroundPanel(spec: playgroundFor('action-buttons')!));

    // The live button renders; no leading icon until the knob is turned on.
    expect(find.widgetWithText(DsButton, 'Save changes'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);

    // Flip the "Leading icon" toggle (its label is inside the switch's tap area).
    await tester.tap(find.text('Leading icon'));
    await tester.pump();
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
