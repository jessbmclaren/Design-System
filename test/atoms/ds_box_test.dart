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

    testWidgets('applies margin outside the decorated box', (tester) async {
      await pumpDs(
        tester,
        const DsBox(
          width: 100,
          height: 50,
          margin: EdgeInsets.all(10),
          background: Color(0xFF112233),
          child: SizedBox.shrink(),
        ),
      );

      // The margin surrounds the 100x50 decorated area, so the widget as a
      // whole takes 120x70.
      expect(tester.getSize(find.byType(DsBox)), const Size(120, 70));
    });

    testWidgets('honours alignment within an explicit size', (tester) async {
      const childKey = Key('aligned-child');
      await pumpDs(
        tester,
        const DsBox(
          width: 100,
          height: 100,
          alignment: Alignment.bottomRight,
          child: SizedBox(key: childKey, width: 20, height: 20),
        ),
      );

      final box = tester.getRect(find.byType(DsBox));
      final child = tester.getRect(find.byKey(childKey));
      expect(child.bottomRight, box.bottomRight);
    });

    testWidgets('draws the border at the requested width, defaulting to 1',
        (tester) async {
      Border border() {
        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('Bordered'),
            matching: find.byType(Container),
          ),
        );
        return (container.decoration! as BoxDecoration).border! as Border;
      }

      await pumpDs(
        tester,
        const DsBox(
          borderColor: Color(0xFF445566),
          borderWidth: 3,
          child: Text('Bordered'),
        ),
      );
      expect(border().top.color, const Color(0xFF445566));
      expect(border().top.width, 3);

      await pumpDs(
        tester,
        const DsBox(
          borderColor: Color(0xFF445566),
          child: Text('Bordered'),
        ),
      );
      expect(border().top.width, 1);
    });

    testWidgets('the default border width follows the boxBorderWidth token',
        (tester) async {
      await pumpDs(
        tester,
        const DsBox(
          borderColor: Color(0xFF445566),
          child: Text('Bordered'),
        ),
        theme: DsTheme.light(
          tokens: DsTokens.light().copyWith(boxBorderWidth: 4),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Bordered'),
          matching: find.byType(Container),
        ),
      );
      final border =
          (container.decoration! as BoxDecoration).border! as Border;
      expect(border.top.width, 4);
    });

    testWidgets('casts the provided shadows', (tester) async {
      await pumpDs(
        tester,
        const DsBox(
          shadow: DsElevation.low,
          child: Text('Raised'),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Raised'),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.boxShadow, DsElevation.low);
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
