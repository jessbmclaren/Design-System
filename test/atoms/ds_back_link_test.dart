import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';
import '../helpers.dart';

void main() {
  group('DsBackLink', () {
    // The label may be case-transformed by the primary action text transform,
    // so match on the normalised text rather than an exact string.
    Finder labelFinder(String label) => find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.toLowerCase() == label.toLowerCase(),
        );

    testWidgets('renders the label', (tester) async {
      await pumpDs(
        tester,
        const DsBackLink(label: 'Back to customers'),
      );

      expect(labelFinder('Back to customers'), findsOneWidget);
    });

    testWidgets('shows a back arrow icon', (tester) async {
      await pumpDs(
        tester,
        const DsBackLink(label: 'Back to customers'),
      );

      expect(find.byIcon(DsIcons.arrowBack), findsOneWidget);
    });

    testWidgets('onPressed fires on tap', (tester) async {
      var tapped = false;
      await pumpDs(
        tester,
        DsBackLink(
          label: 'Back to customers',
          onPressed: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(DsBackLink));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('is non-interactive when onPressed is null', (tester) async {
      await pumpDs(
        tester,
        const DsBackLink(label: 'Back to customers'),
      );

      // Tapping without a handler must not throw.
      await tester.tap(find.byType(DsBackLink));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        const DsBackLink(
          label: 'Back to a very long originating collection name',
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
