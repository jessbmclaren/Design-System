import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsStepHeader', () {
    testWidgets('renders the title and the lead as separate paragraphs',
        (tester) async {
      await pumpDs(
        tester,
        const DsStepHeader(
          title: 'Create your workspace',
          lead: 'A workspace keeps your team and its data together.',
        ),
      );

      expect(find.text('Create your workspace'), findsOneWidget);
      expect(
        find.text('A workspace keeps your team and its data together.'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(DsStepHeader),
          matching: find.byType(Text),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('omits the lead when none is given', (tester) async {
      await pumpDs(tester, const DsStepHeader(title: 'Verify your email'));

      expect(find.text('Verify your email'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DsStepHeader),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders an inline lead as one flowing paragraph',
        (tester) async {
      await pumpDs(
        tester,
        const DsStepHeader(
          title: 'Describe your business in a few words.',
          lead: 'This helps us recommend the best setup.',
          inlineLead: true,
        ),
      );

      // One rich text carrying both sentences, not two stacked paragraphs.
      expect(
        find.descendant(
          of: find.byType(DsStepHeader),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Describe your business in a few words. '
          'This helps us recommend the best setup.',
          findRichText: true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('sizes the title from the type ramp', (tester) async {
      final tokens = DsTheme.light().extension<DsTokens>()!;

      await pumpDs(tester, const DsStepHeader(title: 'Medium'));
      expect(
        tester.widget<Text>(find.text('Medium')).style!.fontSize,
        tokens.headingLg.fontSize,
      );

      await pumpDs(
        tester,
        const DsStepHeader(title: 'Small', size: DsStepHeaderSize.small),
      );
      expect(
        tester.widget<Text>(find.text('Small')).style!.fontSize,
        tokens.headingMd.fontSize,
      );

      await pumpDs(
        tester,
        const DsStepHeader(title: 'Large', size: DsStepHeaderSize.large),
      );
      expect(
        tester.widget<Text>(find.text('Large')).style!.fontSize,
        tokens.headingXl.fontSize,
      );
    });

    testWidgets('renders the lead in the secondary text colour',
        (tester) async {
      final tokens = DsTheme.light().extension<DsTokens>()!;

      await pumpDs(
        tester,
        const DsStepHeader(
          title: 'Add your first teammate',
          lead: 'You can invite more people later.',
        ),
      );

      expect(
        tester
            .widget<Text>(find.text('You can invite more people later.'))
            .style!
            .color,
        tokens.colorSecondaryText,
      );
    });

    testWidgets('centres both lines when asked to', (tester) async {
      await pumpDs(
        tester,
        const DsStepHeader(
          title: 'Centred',
          lead: 'Both lines follow the alignment.',
          alignment: DsHeadingAlignment.center,
        ),
      );

      expect(
        tester.widget<Text>(find.text('Centred')).textAlign,
        TextAlign.center,
      );
      expect(
        tester
            .widget<Text>(find.text('Both lines follow the alignment.'))
            .textAlign,
        TextAlign.center,
      );
    });

    testWidgets('marks the title as a header for assistive technology',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(tester, const DsStepHeader(title: 'Verify your email'));

      expect(
        tester.getSemantics(find.text('Verify your email')),
        isSemantics(isHeader: true, label: 'Verify your email'),
      );
      handle.dispose();
    });

    testWidgets('does not overflow at 320dp with long copy', (tester) async {
      await pumpDs(
        tester,
        const DsStepHeader(
          title: 'Tell us about the organisation you are setting up today',
          lead: 'The answers shape the defaults you see later and every one '
              'of them can be changed again from settings.',
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at a wide width', (tester) async {
      await pumpDs(
        tester,
        const DsStepHeader(
          title: 'Describe your business in a few words.',
          lead: 'This helps us recommend the best setup.',
          inlineLead: true,
        ),
        surfaceSize: const Size(1920, 800),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
