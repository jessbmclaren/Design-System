import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

import '../helpers.dart';

void main() {
  group('DsImg', () {
    testWidgets('renders a placeholder when no image source is supplied',
        (tester) async {
      await pumpDs(
        tester,
        const DsImg(
          width: 96,
          height: 96,
          placeholder: Text('loading'),
        ),
      );
      await tester.pump();

      expect(find.text('loading'), findsOneWidget);
      expect(find.byType(DsImg), findsOneWidget);
    });

    testWidgets('renders a tokened skeleton box when no placeholder is given',
        (tester) async {
      await pumpDs(
        tester,
        const DsImg(width: 64, height: 64),
      );
      await tester.pump();

      // No Image widget is created without a source; only the fallback box.
      expect(find.byType(Image), findsNothing);
      expect(find.byType(ColoredBox), findsWidgets);
    });

    testWidgets('exposes the semanticLabel to assistive technologies',
        (tester) async {
      await pumpDs(
        tester,
        const DsImg(
          width: 48,
          height: 48,
          semanticLabel: 'Profile photo',
        ),
      );
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(DsImg)),
        matchesSemantics(label: 'Profile photo', isImage: true),
      );
    });

    testWidgets('creates an Image widget when an ImageProvider is provided',
        (tester) async {
      await pumpDs(
        tester,
        const DsImg(
          image: AssetImage('assets/none.png'),
          width: 80,
          height: 80,
          borderRadius: 12,
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ClipRRect), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a small phone surface',
        (tester) async {
      await pumpDs(
        tester,
        const DsImg(width: 96, height: 96, semanticLabel: 'a'),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a large desktop surface',
        (tester) async {
      await pumpDs(
        tester,
        const DsImg(width: 96, height: 96, semanticLabel: 'a'),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
