import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Walks a rendered [RichText] tree and returns the first [TextSpan] whose text
/// equals [text].
TextSpan _spanWithText(WidgetTester tester, String text) {
  TextSpan? found;
  void visit(InlineSpan span) {
    if (found != null) return;
    if (span is TextSpan) {
      if (span.text == text) found = span;
      for (final child in span.children ?? const <InlineSpan>[]) {
        visit(child);
      }
    }
  }

  for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
    visit(rich.text);
    if (found != null) break;
  }
  return found!;
}

void main() {
  group('DsInlineNotice', () {
    testWidgets('renders the message and a toned icon', (tester) async {
      await pumpDs(
        tester,
        const DsInlineNotice(message: 'Something needs a look.'),
      );

      expect(find.textContaining('Something needs a look.'), findsOneWidget);
      expect(find.byIcon(DsIcons.error), findsOneWidget); // danger default
    });

    testWidgets('tapping the inline action fires onAction', (tester) async {
      var tapped = false;
      await pumpDs(
        tester,
        DsInlineNotice(
          message: 'An account already exists. ',
          actionLabel: 'Sign in',
          onAction: () => tapped = true,
          trailingMessage: ' instead.',
        ),
      );

      final span = _spanWithText(tester, 'Sign in');
      (span.recognizer! as TapGestureRecognizer).onTap!();
      expect(tapped, isTrue);
    });

    testWidgets('the tone selects the icon', (tester) async {
      await pumpDs(
        tester,
        const DsInlineNotice(
          message: 'All good.',
          tone: DsInlineNoticeTone.success,
        ),
      );
      expect(find.byIcon(DsIcons.success), findsOneWidget);
    });

    testWidgets('the decorative icon is excluded from assistive technology',
        (tester) async {
      await pumpDs(
        tester,
        const DsInlineNotice(message: 'Read me, not the glyph.'),
      );
      // The message stays readable; the glyph is kept out of the reading order.
      expect(find.textContaining('Read me, not the glyph.'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ExcludeSemantics),
          matching: find.byIcon(DsIcons.error),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a long message wraps without overflow at 320dp',
        (tester) async {
      await pumpDs(
        tester,
        DsInlineNotice(
          message: 'An account already exists with this email address. ',
          actionLabel: 'Sign in',
          onAction: () {},
          trailingMessage:
              ' instead, or use a different work email address to continue.',
        ),
        surfaceSize: const Size(320, 600),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
