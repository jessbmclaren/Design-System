import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsBanner', () {
    testWidgets('renders title and message for each variant', (tester) async {
      for (final variant in DsBannerVariant.values) {
        await pumpDs(
          tester,
          DsBanner(
            variant: variant,
            title: 'Title ${variant.name}',
            message: 'Message ${variant.name}',
          ),
        );
        await tester.pump();

        expect(find.text('Title ${variant.name}'), findsOneWidget);
        expect(find.text('Message ${variant.name}'), findsOneWidget);
      }
    });

    testWidgets('omits the message when none is provided', (tester) async {
      await pumpDs(
        tester,
        const DsBanner(
          variant: DsBannerVariant.info,
          title: 'Heads up',
        ),
      );
      await tester.pump();

      expect(find.text('Heads up'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byIcon(DsIcons.close), findsNothing);
    });

    testWidgets('fires the action callback on tap', (tester) async {
      var tapped = false;
      await pumpDs(
        tester,
        DsBanner(
          variant: DsBannerVariant.warning,
          title: 'Verification pending',
          message: 'Confirm your details to continue.',
          action: DsBannerAction(
            label: 'Review',
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Review'), findsOneWidget);
      await tester.tap(find.text('Review'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows a close button that fires onDismiss', (tester) async {
      var dismissed = false;
      await pumpDs(
        tester,
        DsBanner(
          variant: DsBannerVariant.danger,
          title: 'Payment failed',
          onDismiss: () => dismissed = true,
        ),
      );
      await tester.pump();

      expect(find.byIcon(DsIcons.close), findsOneWidget);
      await tester.tap(find.byIcon(DsIcons.close));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('does not overflow at 320dp with a long message and action',
        (tester) async {
      var tapped = false;
      await pumpDs(
        tester,
        DsBanner(
          variant: DsBannerVariant.success,
          title: 'Your account is almost ready',
          message:
              'We have received your documents and are reviewing them now. '
              'This usually takes a couple of minutes but can occasionally '
              'take longer during busy periods.',
          action: DsBannerAction(
            label: 'View status',
            onPressed: () => tapped = true,
          ),
          onDismiss: () {},
        ),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Your account is almost ready'), findsOneWidget);

      await tester.tap(find.text('View status'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
