import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsPasswordField', () {
    testWidgets('starts obscured and the eye toggle reveals the value',
        (tester) async {
      await pumpDs(tester, const DsPasswordField(label: 'Password'));

      // While obscured, the control offers to reveal (an open eye).
      expect(find.byIcon(DsIcons.visibility), findsOneWidget);
      expect(find.byIcon(DsIcons.visibilityOff), findsNothing);

      await tester.tap(find.byIcon(DsIcons.visibility));
      await tester.pump();

      expect(find.byIcon(DsIcons.visibilityOff), findsOneWidget);
    });

    testWidgets('reports changes through onChanged', (tester) async {
      String? latest;
      await pumpDs(
        tester,
        DsPasswordField(label: 'Password', onChanged: (v) => latest = v),
      );

      await tester.enterText(find.byType(TextField), 'hunter2');
      expect(latest, 'hunter2');
    });
  });
}
