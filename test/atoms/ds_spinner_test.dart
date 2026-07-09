import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsSpinner', () {
    testWidgets('renders a CircularProgressIndicator immediately with zero '
        'delay', (tester) async {
      await pumpDs(tester, const DsSpinner());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is not visible before the delay elapses', (tester) async {
      await pumpDs(
        tester,
        const DsSpinner(delay: Duration(milliseconds: 300)),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('becomes visible after pumping past the delay',
        (tester) async {
      await pumpDs(
        tester,
        const DsSpinner(delay: Duration(milliseconds: 300)),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('each size renders at its dimension', (tester) async {
      for (final size in DsSpinnerSize.values) {
        await pumpDs(tester, DsSpinner(size: size));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        final box = tester.getSize(find.byType(SizedBox).first);
        expect(box.width, size.dimension);
        expect(box.height, size.dimension);
      }
    });

    testWidgets('applies the provided semantic label', (tester) async {
      await pumpDs(
        tester,
        const DsSpinner(semanticLabel: 'Fetching results'),
      );
      await tester.pump();

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.semanticsLabel, 'Fetching results');
    });
  });
}
