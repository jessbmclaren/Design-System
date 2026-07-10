import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsFieldLabel', () {
    testWidgets('renders its label text', (tester) async {
      await pumpDs(tester, const DsFieldLabel(label: 'Password'));
      expect(find.text('Password'), findsOneWidget);
    });
  });
}
