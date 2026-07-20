import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Widget _task({
  VoidCallback? onBack,
  VoidCallback? onPrimary,
  bool pending = false,
  String? secondaryLabel,
  VoidCallback? onSecondary,
  Widget? banner,
  Widget? headerTrailing,
  bool scrollable = true,
}) {
  return DsTaskView(
    title: 'Add a vehicle',
    subtitle: 'Step 2 of 3',
    onBack: onBack,
    headerTrailing: headerTrailing,
    banner: banner,
    scrollable: scrollable,
    body: const Text('Vehicle form'),
    primaryLabel: 'Save vehicle',
    onPrimary: onPrimary,
    primaryPending: pending,
    secondaryLabel: secondaryLabel,
    onSecondary: onSecondary,
    footerBackLabel: 'Back',
    onFooterBack: () {},
  );
}

void main() {
  testWidgets('renders the header, body and pinned actions', (tester) async {
    await pumpDs(
      tester,
      _task(onBack: () {}, onPrimary: () {}, secondaryLabel: 'Save draft'),
      surfaceSize: const Size(900, 700),
    );

    expect(find.text('Add a vehicle'), findsOneWidget);
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(find.text('Vehicle form'), findsOneWidget);
    expect(find.text('Save vehicle'), findsOneWidget);
    expect(find.text('Save draft'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  testWidgets('the actions fire', (tester) async {
    String? fired;
    await pumpDs(
      tester,
      _task(
        onBack: () => fired = 'back',
        onPrimary: () => fired = 'primary',
        secondaryLabel: 'Save draft',
        onSecondary: () => fired = 'secondary',
      ),
      surfaceSize: const Size(900, 700),
    );

    await tester.tap(find.text('Save vehicle'));
    await tester.pump();
    expect(fired, 'primary');

    await tester.tap(find.text('Save draft'));
    await tester.pump();
    expect(fired, 'secondary');

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    expect(fired, 'back');
  });

  testWidgets('a null onBack hides the header affordance', (tester) async {
    await pumpDs(
      tester,
      _task(onPrimary: () {}),
      surfaceSize: const Size(900, 700),
    );
    expect(find.byTooltip('Back'), findsNothing);
  });

  testWidgets('a pending primary action shows its spinner', (tester) async {
    await pumpDs(
      tester,
      _task(onPrimary: () {}, pending: true),
      surfaceSize: const Size(900, 700),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(DsSpinner), findsOneWidget);
  });

  testWidgets('the banner and header trailing slots render', (tester) async {
    await pumpDs(
      tester,
      _task(
        onPrimary: () {},
        banner: const DsBanner(
          variant: DsBannerVariant.info,
          title: 'Draft saved',
        ),
        headerTrailing: const DsBadge(label: 'Draft'),
      ),
      surfaceSize: const Size(900, 700),
    );
    expect(find.text('Draft saved'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('the body scrolls only when asked', (tester) async {
    await pumpDs(
      tester,
      _task(onPrimary: () {}),
      surfaceSize: const Size(900, 700),
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    await pumpDs(
      tester,
      _task(onPrimary: () {}, scrollable: false),
      surfaceSize: const Size(900, 700),
    );
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('holds 320dp and 1440dp without overflow, in every theme', (
    tester,
  ) async {
    for (final ThemeData theme in <ThemeData>[
      DsTheme.light(),
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
    ]) {
      for (final Size size in <Size>[Size(320, 640), Size(1440, 900)]) {
        await pumpDs(
          tester,
          _task(
            onBack: () {},
            onPrimary: () {},
            secondaryLabel: 'Save draft',
            onSecondary: () {},
          ),
          surfaceSize: size,
          theme: theme,
        );
        expect(tester.takeException(), isNull,
            reason: 'at ${size.width.toInt()}dp');
      }
    }
  });

  testWidgets('survives 1.3x text scale at 320dp', (tester) async {
    await pumpDs(
      tester,
      _task(onBack: () {}, onPrimary: () {}, secondaryLabel: 'Save draft'),
      surfaceSize: const Size(320, 640),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });
}
