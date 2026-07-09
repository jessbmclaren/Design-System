import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsBox', () {
    testWidgets('renders its child content', (tester) async {
      await pumpDs(
        tester,
        const DsBox(child: Text('Hello box')),
      );

      expect(find.text('Hello box'), findsOneWidget);
    });

    testWidgets('applies decoration when a background is provided',
        (tester) async {
      await pumpDs(
        tester,
        const DsBox(
          background: Color(0xFF112233),
          borderColor: Color(0xFF445566),
          borderRadius: 8,
          padding: EdgeInsets.all(12),
          child: Text('Decorated'),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Decorated'),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, const Color(0xFF112233));
      expect(decoration.borderRadius, BorderRadius.circular(8));
      expect(decoration.border, isNotNull);
      // Rounded corners should be clipped.
      expect(container.clipBehavior, Clip.antiAlias);
    });

    testWidgets('has no decoration and no clip when purely a layout box',
        (tester) async {
      await pumpDs(
        tester,
        const DsBox(
          padding: EdgeInsets.all(4),
          child: Text('Plain'),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Plain'),
          matching: find.byType(Container),
        ),
      );
      expect(container.decoration, isNull);
      expect(container.clipBehavior, Clip.none);
    });

    testWidgets('honours explicit width and height', (tester) async {
      await pumpDs(
        tester,
        const DsBox(
          width: 120,
          height: 80,
          child: SizedBox.shrink(),
        ),
      );

      final size = tester.getSize(find.byType(DsBox));
      expect(size.width, 120);
      expect(size.height, 80);
    });

    testWidgets('renders without overflow on a small phone surface',
        (tester) async {
      await pumpDs(
        tester,
        const DsBox(
          background: Color(0xFF223344),
          borderRadius: 12,
          padding: EdgeInsets.all(16),
          child: Text('Responsive'),
        ),
        surfaceSize: const Size(320, 900),
      );

      expect(find.text('Responsive'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a large desktop surface',
        (tester) async {
      await pumpDs(
        tester,
        const DsBox(
          background: Color(0xFF223344),
          borderRadius: 12,
          padding: EdgeInsets.all(16),
          child: Text('Responsive'),
        ),
        surfaceSize: const Size(1200, 900),
      );

      expect(find.text('Responsive'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
