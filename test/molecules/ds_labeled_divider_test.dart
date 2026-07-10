import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsLabeledDivider', () {
    testWidgets('renders the label between two dividers', (tester) async {
      await pumpDs(tester, const DsLabeledDivider(label: 'Or sign in with'));

      expect(find.text('Or sign in with'), findsOneWidget);
      expect(find.byType(DsDivider), findsNWidgets(2));
    });

    testWidgets('does not overflow at 320dp with a long label', (tester) async {
      await pumpDs(
        tester,
        const DsLabeledDivider(label: 'Or continue with one of these providers'),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
