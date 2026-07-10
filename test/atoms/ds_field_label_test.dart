import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsFieldLabel', () {
    testWidgets('renders its label text', (tester) async {
      await pumpDs(tester, const DsFieldLabel(label: 'Password'));
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Optional'), findsNothing);
    });

    testWidgets('optional appends a subdued marker', (tester) async {
      await pumpDs(
        tester,
        const DsFieldLabel(label: 'Company', optional: true),
      );

      expect(find.text('Company'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);

      final tokens = DsTokens.of(tester.element(find.byType(DsFieldLabel)));
      final marker = tester.widget<Text>(find.text('Optional'));
      // The marker is quieter than the label: secondary colour, small size.
      expect(marker.style!.color, tokens.colorSecondaryText);
      expect(marker.style!.fontSize, tokens.labelSm.fontSize);
    });
  });
}
