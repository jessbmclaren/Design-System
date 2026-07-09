import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// The system must not overflow when the user turns text size up. This matrix
/// pumps representative components at 1.3x text scale on a 320dp phone and
/// asserts no render exceptions.
void main() {
  final samples = <String, Widget>{
    'DsButton': DsButton(label: 'Continue to the next step', onPressed: () {}),
    'DsBadge': const DsBadge(label: 'Pending review', variant: DsBadgeVariant.warning),
    'DsBanner': const DsBanner(
      variant: DsBannerVariant.danger,
      title: 'We could not verify your business',
      message: 'Check the details and try again in a few minutes.',
    ),
    'DsEmptyState': const DsEmptyState(
      icon: Icons.inbox_outlined,
      title: 'No records yet',
      message: 'Anything you create will show up right here.',
    ),
    'DsTextField': const DsTextField(
      label: 'Work email address',
      hintText: 'you@company.com',
      helperText: 'We will only use this to sign you in.',
    ),
    'DsCheckbox': const DsCheckbox(
      value: true,
      onChanged: null,
      label: 'I agree to the terms and the privacy policy',
    ),
    'DsSwitch': const DsSwitch(
      value: true,
      onChanged: null,
      label: 'Email me product updates and occasional tips',
    ),
    'DsListItem': const DsListItem(
      title: 'A fairly long primary row title that must not overflow',
      subtitle: 'And a supporting subtitle line beneath it',
    ),
  };

  for (final entry in samples.entries) {
    testWidgets('${entry.key} survives 1.3x text scale at 320dp',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(width: 320, child: entry.value),
        surfaceSize: const Size(320, 1200),
        textScale: 1.3,
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: entry.key);
    });
  }
}
