import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

import '../helpers.dart';

void main() {
  group('DsContextView', () {
    testWidgets('renders title and body content', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 600,
          child: DsContextView(
            title: 'Details',
            child: Text('Body content'),
          ),
        ),
      );

      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Body content'), findsOneWidget);
    });

    testWidgets('shows close button and fires onClose when tapped',
        (tester) async {
      var closed = false;
      await pumpDs(
        tester,
        SizedBox(
          height: 600,
          child: DsContextView(
            title: 'Inspector',
            onClose: () => closed = true,
            child: const Text('Content'),
          ),
        ),
      );

      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('hides close button when onClose is null', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 600,
          child: DsContextView(
            title: 'Read only',
            child: Text('Content'),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('renders header actions and footer', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 600,
          child: DsContextView(
            title: 'With extras',
            actions: [Text('Edit')],
            footer: Text('Save'),
            child: Text('Content'),
          ),
        ),
      );

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('renders without overflow at a narrow phone size',
        (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 900,
          child: DsContextView(
            title: 'Responsive panel',
            actions: [Text('Action')],
            footer: Text('Footer action'),
            child: Text('Some supporting detail body content.'),
          ),
        ),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at a large desktop size',
        (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 900,
          child: DsContextView(
            title: 'Responsive panel',
            actions: [Text('Action')],
            footer: Text('Footer action'),
            child: Text('Some supporting detail body content.'),
          ),
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
