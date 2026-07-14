import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsCheckbox', () {
    testWidgets('renders its label', (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(value: false, onChanged: (_) {}, label: 'Accept terms'),
      );

      expect(find.text('Accept terms'), findsOneWidget);
    });

    testWidgets('shows a check icon when checked', (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(value: true, onChanged: (_) {}, label: 'Subscribe'),
      );

      expect(find.byIcon(DsIcons.check), findsOneWidget);
    });

    testWidgets('does not show a check icon when unchecked', (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(value: false, onChanged: (_) {}, label: 'Subscribe'),
      );

      expect(find.byIcon(DsIcons.check), findsNothing);
    });

    testWidgets('tapping calls onChanged with the negated value',
        (tester) async {
      bool? reported;
      await pumpDs(
        tester,
        DsCheckbox(
          value: false,
          onChanged: (v) => reported = v,
          label: 'Remember me',
        ),
      );

      await tester.tap(find.text('Remember me'));
      await tester.pump();

      expect(reported, isTrue);
    });

    testWidgets('null onChanged suppresses interaction', (tester) async {
      await pumpDs(
        tester,
        const DsCheckbox(value: false, onChanged: null, label: 'Disabled'),
      );

      // Tapping a disabled control must not throw and there is nothing to fire.
      await tester.tap(find.text('Disabled'));
      await tester.pump();

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byType(AnimatedContainer),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.5);
    });

    testWidgets('isError renders the danger border colour', (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(
          value: false,
          onChanged: (_) {},
          label: 'Invalid',
          isError: true,
        ),
      );

      final tokens = DsTokens.of(
        tester.element(find.byType(DsCheckbox)),
      );
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border!.top.color, tokens.colorDanger);
    });

    testWidgets('renders a rich labelWidget and toggles from it',
        (tester) async {
      bool? reported;
      await pumpDs(
        tester,
        DsCheckbox(
          value: false,
          onChanged: (v) => reported = v,
          labelWidget: Text.rich(
            TextSpan(
              text: 'I agree to the ',
              children: [TextSpan(text: 'terms')],
            ),
          ),
        ),
      );

      expect(find.textContaining('I agree to the'), findsOneWidget);

      await tester.tap(find.byType(DsCheckbox));
      await tester.pump();
      expect(reported, isTrue);
    });

    testWidgets('errorText renders beneath in the danger colour and applies '
        'the error border', (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(
          value: false,
          onChanged: (_) {},
          label: 'Accept terms',
          errorText: 'You must accept the terms',
        ),
      );

      final tokens = DsTokens.of(tester.element(find.byType(DsCheckbox)));

      final errorFinder = find.text('You must accept the terms');
      expect(errorFinder, findsOneWidget);
      expect(tester.widget<Text>(errorFinder).style!.color,
          tokens.colorDanger);

      // The error sits below the row, not beside it.
      final boxRect = tester.getRect(find.byType(AnimatedContainer));
      expect(tester.getRect(errorFinder).top,
          greaterThan(boxRect.bottom));

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border!.top.color, tokens.colorDanger);
    });

    testWidgets('errorText is announced with the control', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsCheckbox(
          value: false,
          onChanged: (_) {},
          label: 'Accept terms',
          errorText: 'You must accept the terms',
        ),
      );

      // One node carries both the label and the error, and the visible error
      // text is not announced a second time.
      expect(
        find.bySemanticsLabel('Accept terms, You must accept the terms'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('You must accept the terms'),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('semanticLabel overrides the announced name', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsCheckbox(
          value: false,
          onChanged: (_) {},
          label: 'Remember me',
          semanticLabel: 'Keep me signed in',
        ),
      );

      expect(find.bySemanticsLabel('Keep me signed in'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('keyboard focus shows a ring and space toggles the value',
        (tester) async {
      bool? reported;
      await pumpDs(
        tester,
        DsCheckbox(
          value: false,
          onChanged: (v) => reported = v,
          label: 'Accept terms',
        ),
      );

      BoxDecoration boxDecoration() {
        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        return container.decoration! as BoxDecoration;
      }

      expect(boxDecoration().boxShadow, isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final tokens = DsTokens.of(tester.element(find.byType(DsCheckbox)));
      final ring = boxDecoration().boxShadow;
      expect(ring, isNotNull);
      expect(ring!.first.color, tokens.formAccentColor);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(reported, isTrue);
    });

    testWidgets('adding errorText while focused keeps focus so Space still '
        'toggles', (tester) async {
      bool? reported;
      String? error;
      late StateSetter rebuild;
      await pumpDs(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return DsCheckbox(
              value: false,
              onChanged: (v) => reported = v,
              label: 'Accept terms',
              errorText: error,
            );
          },
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Validation fires while the control is focused. The tree keeps its
      // shape (the Column is always the root), so the InkWell survives the
      // rebuild and keyboard focus stays on the control.
      rebuild(() => error = 'You must accept the terms');
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(reported, isTrue);

      // The focus ring still reflects a genuinely focused control.
      final container =
          tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect((container.decoration! as BoxDecoration).boxShadow, isNotNull);
    });

    testWidgets('keeps the box centred on a single-line label',
        (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(value: false, onChanged: (_) {}, label: 'Short'),
      );

      final boxRect = tester.getRect(find.byType(AnimatedContainer));
      final textRect = tester.getRect(find.text('Short'));
      expect(
        boxRect.center.dy,
        moreOrLessEquals(textRect.center.dy, epsilon: 0.25),
      );
    });

    testWidgets('top-aligns the box against a multiline label',
        (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(
          value: false,
          onChanged: (_) {},
          label: 'A long consent sentence that certainly wraps across '
              'several lines on a narrow phone viewport',
        ),
        surfaceSize: const Size(320, 640),
      );

      final textRect = tester.getRect(find.textContaining('A long consent'));
      // The label wraps: bodyMd renders 24dp lines.
      expect(textRect.height, greaterThan(24));

      // The 18dp box sits centred within the first 24dp line.
      final boxRect = tester.getRect(find.byType(AnimatedContainer));
      expect(
        boxRect.center.dy,
        moreOrLessEquals(textRect.top + 12, epsilon: 0.25),
      );
    });

    testWidgets('does not overflow at 320dp with a labelWidget and errorText',
        (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(
          value: true,
          onChanged: (_) {},
          labelWidget: const Text(
            'A wrapping rich label that carries its own widget subtree and '
            'must stay inside a narrow viewport',
          ),
          errorText: 'A validation message that also wraps without overflow',
          semanticLabel: 'Consent',
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at a 320x640 surface', (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(
          value: true,
          onChanged: (_) {},
          label: 'A reasonably long label that should wrap without overflowing',
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a standalone checkbox holds a 48dp tap target', (tester) async {
      await pumpDs(tester, DsCheckbox(value: false, onChanged: (_) {}));

      expect(
        tester.getSize(find.byType(DsCheckbox)).height,
        greaterThanOrEqualTo(kMinInteractiveDimension),
      );
    });

    testWidgets('dense drops the tap-target minimum for compact rows', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsCheckbox(value: false, onChanged: (_) {}, dense: true),
      );

      // A dense box shrinks to its own height so a table row can stay compact.
      expect(
        tester.getSize(find.byType(DsCheckbox)).height,
        lessThan(kMinInteractiveDimension),
      );
    });
  });
}
