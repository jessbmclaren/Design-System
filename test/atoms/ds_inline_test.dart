import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders its text', (WidgetTester tester) async {
    await pumpDs(tester, const DsInline(text: 'important'));

    expect(find.text('important'), findsOneWidget);
  });

  testWidgets('bold applies a semi-bold weight', (WidgetTester tester) async {
    await pumpDs(tester, const DsInline(text: 'strong', bold: true));

    final Text text = tester.widget<Text>(find.text('strong'));
    expect(text.style?.fontWeight, FontWeight.w600);
  });

  testWidgets('italic and strikethrough are reflected in the style',
      (WidgetTester tester) async {
    await pumpDs(
      tester,
      const DsInline(text: 'styled', italic: true, strikethrough: true),
    );

    final Text text = tester.widget<Text>(find.text('styled'));
    expect(text.style?.fontStyle, FontStyle.italic);
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('code uses a monospace family and an explicit color wins',
      (WidgetTester tester) async {
    await pumpDs(
      tester,
      const DsInline(text: 'config', code: true, color: Color(0xFF112233)),
    );

    final Text text = tester.widget<Text>(find.text('config'));
    expect(text.style?.fontFamily, 'monospace');
    expect(text.style?.color, const Color(0xFF112233));
  });

  testWidgets('overflow and maxLines are forwarded', (WidgetTester tester) async {
    await pumpDs(
      tester,
      const DsInline(
        text: 'a very long run of copy that should be clipped',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final Text text = tester.widget<Text>(find.textContaining('very long'));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without exception on a small phone',
      (WidgetTester tester) async {
    await pumpDs(
      tester,
      const DsInline(text: 'responsive copy', bold: true, italic: true),
      surfaceSize: const Size(320, 900),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without exception on a large desktop',
      (WidgetTester tester) async {
    await pumpDs(
      tester,
      const DsInline(text: 'responsive copy', code: true),
      surfaceSize: const Size(1200, 900),
    );

    expect(tester.takeException(), isNull);
  });
}
