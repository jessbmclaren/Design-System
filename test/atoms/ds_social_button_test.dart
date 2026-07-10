import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsSocialButton', () {
    testWidgets('renders the label and provider icon and taps through',
        (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsSocialButton(
          icon: DsIcons.user,
          label: 'Continue with Google',
          onPressed: () => taps++,
        ),
      );

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.byIcon(DsIcons.user), findsOneWidget);

      await tester.tap(find.byType(DsSocialButton));
      expect(taps, 1);
    });

    testWidgets('pending shows a spinner and blocks taps', (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsSocialButton(
          icon: DsIcons.user,
          label: 'Continue',
          pending: true,
          onPressed: () => taps++,
        ),
      );

      await tester.tap(find.byType(DsSocialButton), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });
  });
}
