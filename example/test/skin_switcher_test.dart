import 'package:design_system/design_system.dart';
import 'package:ds_docs/app.dart';
import 'package:ds_docs/ui/docs_skins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('brand switcher flips every component to the selected skin tokens',
      (tester) async {
    // A wide surface so the top bar (which hosts the switcher) renders.
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const DocsApp());
    await tester.pump(const Duration(milliseconds: 400));

    DsTokens activeTokens() =>
        DsTokens.of(tester.element(find.byType(Scaffold).first));
    const engenIndigo = Color(0xFF15259B);

    // Default brand is active — primary is the neutral default, not engen.
    expect(activeTokens().colorPrimary, isNot(engenIndigo));
    expect(find.text('Default'), findsWidgets);

    // Open the brand switcher and choose Engen.
    await tester.tap(find.byType(PopupMenuButton<DocsSkin>),
        warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Engen').last, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The whole app now themes to the engen brand's tokens.
    expect(activeTokens().colorPrimary, engenIndigo);
    expect(find.text('Engen'), findsWidgets);
  });
}
