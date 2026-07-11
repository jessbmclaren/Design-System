import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const sections = <DsVerificationSection>[
    DsVerificationSection(
      label: 'Business',
      state: DsVerificationSectionState.done,
    ),
    DsVerificationSection(
      label: 'Identity',
      state: DsVerificationSectionState.active,
      subSteps: <String>['Your details', 'Your document'],
    ),
    DsVerificationSection(label: 'Review'),
  ];

  group('DsVerificationRail', () {
    testWidgets('renders every section label', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          width: 280,
          child: DsVerificationRail(sections: sections),
        ),
      );

      expect(find.text('Business'), findsOneWidget);
      expect(find.text('Identity'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
    });

    testWidgets('shows sub-steps only for the active section', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          width: 280,
          child: DsVerificationRail(sections: sections, activeSubStep: 1),
        ),
      );

      expect(find.text('Your details'), findsOneWidget);
      expect(find.text('Your document'), findsOneWidget);
    });

    testWidgets('hides sub-steps on sections that are not active',
        (tester) async {
      const railSections = <DsVerificationSection>[
        DsVerificationSection(
          label: 'Business',
          state: DsVerificationSectionState.done,
          subSteps: <String>['Type', 'Details'],
        ),
        DsVerificationSection(
          label: 'Identity',
          state: DsVerificationSectionState.active,
        ),
      ];
      await pumpDs(
        tester,
        const SizedBox(
          width: 280,
          child: DsVerificationRail(sections: railSections),
        ),
      );

      expect(find.text('Type'), findsNothing);
      expect(find.text('Details'), findsNothing);
    });

    testWidgets('tapping a done section fires onSectionSelected',
        (tester) async {
      int? selected;
      await pumpDs(
        tester,
        SizedBox(
          width: 280,
          child: DsVerificationRail(
            sections: sections,
            onSectionSelected: (index) => selected = index,
          ),
        ),
      );

      await tester.tap(find.text('Business'));
      await tester.pump();
      expect(selected, 0);
    });

    testWidgets('active and upcoming sections are not selectable',
        (tester) async {
      int? selected;
      await pumpDs(
        tester,
        SizedBox(
          width: 280,
          child: DsVerificationRail(
            sections: sections,
            onSectionSelected: (index) => selected = index,
          ),
        ),
      );

      await tester.tap(find.text('Identity'));
      await tester.tap(find.text('Review'));
      await tester.pump();
      expect(selected, isNull);
    });

    testWidgets('announces each section with its position and state',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const SizedBox(
          width: 280,
          child: DsVerificationRail(sections: sections),
        ),
      );

      expect(
        find.bySemanticsLabel('Business, section 1 of 3, complete'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Identity, section 2 of 3, current section'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Review, section 3 of 3, not started'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('falls back to the compact horizontal form when narrow',
        (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          width: 180,
          child: DsVerificationRail(sections: sections),
        ),
      );

      // Only the active section's label survives; sub-steps and the other
      // labels are dropped in the compact form.
      expect(find.text('Identity'), findsOneWidget);
      expect(find.text('Business'), findsNothing);
      expect(find.text('Your details'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the compact form shows a Step n of N caption',
        (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          width: 180,
          child: DsVerificationRail(sections: sections),
        ),
      );

      expect(find.text('Step 2 of 3'), findsOneWidget);
    });

    testWidgets('the compact form survives many sections without overflow',
        (tester) async {
      final manySections = <DsVerificationSection>[
        for (var i = 0; i < 12; i++)
          DsVerificationSection(
            label: 'Section ${i + 1}',
            state: i < 4
                ? DsVerificationSectionState.done
                : i == 4
                    ? DsVerificationSectionState.active
                    : DsVerificationSectionState.upcoming,
          ),
      ];
      await pumpDs(
        tester,
        SizedBox(
          width: 180,
          child: DsVerificationRail(sections: manySections),
        ),
        surfaceSize: const Size(320, 568),
      );

      // The summary is one marker, the active label and a caption, so the
      // section count no longer decides whether the fallback fits.
      expect(tester.takeException(), isNull);
      expect(find.text('Section 5'), findsOneWidget);
      expect(find.text('Step 5 of 12'), findsOneWidget);
    });

    testWidgets('summarises progress accessibly in the compact form',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const SizedBox(
          width: 180,
          child: DsVerificationRail(sections: sections),
        ),
      );

      expect(
        find.bySemanticsLabel('Identity, 1 of 3 sections complete'),
        findsOneWidget,
      );
      handle.dispose();
    });

    for (final width in <double>[320, 1440]) {
      testWidgets('does not overflow at ${width.toInt()}dp', (tester) async {
        await pumpDs(
          tester,
          SizedBox(
            width: width,
            child: const DsVerificationRail(sections: sections),
          ),
          surfaceSize: Size(width, 900),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
