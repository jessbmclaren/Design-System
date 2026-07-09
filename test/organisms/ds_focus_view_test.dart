import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsFocusView', () {
    testWidgets('renders the title and the child content', (tester) async {
      await pumpDs(
        tester,
        const DsFocusView(
          title: 'Confirm change',
          child: Text('Body content'),
        ),
      );

      expect(find.text('Confirm change'), findsOneWidget);
      expect(find.text('Body content'), findsOneWidget);
    });

    testWidgets('renders the footer when provided', (tester) async {
      await pumpDs(
        tester,
        const DsFocusView(
          title: 'Details',
          footer: Text('Footer action'),
          child: Text('Body'),
        ),
      );

      expect(find.text('Footer action'), findsOneWidget);
    });

    testWidgets('shows no close button when onClose is null', (tester) async {
      await pumpDs(
        tester,
        const DsFocusView(
          title: 'No close',
          child: Text('Body'),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('shows a close button that fires onClose on tap',
        (tester) async {
      var closed = false;
      await pumpDs(
        tester,
        DsFocusView(
          title: 'Closable',
          onClose: () => closed = true,
          child: const Text('Body'),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        DsFocusView(
          title: 'A rather long focus view title that should ellipsize',
          onClose: () {},
          footer: const DsButton(label: 'Continue'),
          child: const Text(
            'Some reasonably long body content that fills the panel.',
          ),
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
