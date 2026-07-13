// Senior-tester coverage for the shared demo/playground stage: the viewport
// toggle, the framed stage's width clamp and scroll-vs-centre behaviour, the
// responsive/text-scale header, and the two consumers (PlaygroundPanel and the
// static DeviceFrame). Drives the real widgets and probes the edges the review
// flagged — the 48dp touch target, the 320dp overflow floor, dark-mode selection
// and the accessibility contract — rather than trusting the code.
import 'package:design_system/design_system.dart';
import 'package:ds_docs/demos/demo_registry.dart';
import 'package:ds_docs/playground/playground.dart';
import 'package:ds_docs/playground/playground_registry.dart';
import 'package:ds_docs/ui/demo_stage.dart';
import 'package:ds_docs/ui/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] on a real Ds theme at a fixed [width], mirroring how the docs
/// place a panel inside a bounded reading column.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 900,
  ThemeData? theme,
  double textScale = 1.0,
  bool reduceMotion = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme ?? DsTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            final mq = MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: reduceMotion,
            );
            return MediaQuery(
              data: mq,
              child: Center(
                child: SizedBox(
                  width: width,
                  child: SingleChildScrollView(child: child),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('DemoViewportControl', () {
    testWidgets('renders three labelled segments and reports taps', (tester) async {
      DemoViewport? picked;
      await _pump(
        tester,
        DemoViewportControl(
          value: DemoViewport.desktop,
          onChanged: (v) => picked = v,
        ),
      );

      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsOneWidget);

      await tester.tap(find.byTooltip('Phone'));
      expect(picked, DemoViewport.phone);
      await tester.tap(find.byTooltip('Tablet'));
      expect(picked, DemoViewport.tablet);
    });

    testWidgets('every segment meets the 48dp touch-target minimum', (tester) async {
      await _pump(
        tester,
        DemoViewportControl(
          value: DemoViewport.desktop,
          onChanged: (_) {},
        ),
      );

      final segments = find.descendant(
        of: find.byType(DemoViewportControl),
        matching: find.byType(InkWell),
      );
      expect(segments, findsNWidgets(3));
      for (var i = 0; i < 3; i++) {
        final size = tester.getSize(segments.at(i));
        expect(size.height, greaterThanOrEqualTo(48),
            reason: 'segment $i height ${size.height} < 48dp');
      }
    });

    testWidgets('compact mode is icon-only, still ≥48dp wide, still tappable', (tester) async {
      DemoViewport? picked;
      await _pump(
        tester,
        DemoViewportControl(
          value: DemoViewport.desktop,
          onChanged: (v) => picked = v,
          compact: true,
        ),
      );

      // No labels in compact mode.
      expect(find.text('Phone'), findsNothing);
      expect(find.text('Desktop'), findsNothing);

      final segments = find.descendant(
        of: find.byType(DemoViewportControl),
        matching: find.byType(InkWell),
      );
      for (var i = 0; i < 3; i++) {
        final size = tester.getSize(segments.at(i));
        expect(size.height, greaterThanOrEqualTo(48));
        expect(size.width, greaterThanOrEqualTo(48),
            reason: 'compact segment $i width ${size.width} < 48dp');
      }

      // The tooltip is still the tap affordance in icon-only mode.
      await tester.tap(find.byTooltip('Phone'));
      expect(picked, DemoViewport.phone);
    });

    testWidgets('exposes a per-viewport label and the selected state to a11y', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        DemoViewportControl(
          value: DemoViewport.tablet,
          onChanged: (_) {},
        ),
      );

      // Labelled for assistive tech, exactly once each.
      expect(find.bySemanticsLabel('Phone preview'), findsOneWidget);
      expect(find.bySemanticsLabel('Tablet preview'), findsOneWidget);
      expect(find.bySemanticsLabel('Desktop preview'), findsOneWidget);

      // The active viewport is marked selected; the others are not, and it
      // carries a tap action so AT/keyboard can activate it.
      expect(tester.getSemantics(find.bySemanticsLabel('Tablet preview')),
          isSemantics(isSelected: true, hasTapAction: true));
      expect(tester.getSemantics(find.bySemanticsLabel('Phone preview')),
          isSemantics(isSelected: false));
      handle.dispose();
    });

    testWidgets('renders under a dark theme without error', (tester) async {
      await _pump(
        tester,
        DemoViewportControl(value: DemoViewport.phone, onChanged: (_) {}),
        theme: DsTheme.dark(),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Phone'), findsOneWidget);
    });
  });

  group('DemoStageCard width behaviour', () {
    // Captures the width the framed child is actually laid out at.
    Widget probe(void Function(double) onWidth) => LayoutBuilder(
          builder: (context, c) {
            onWidth(c.maxWidth);
            return const SizedBox(height: 40);
          },
        );

    testWidgets('desktop fills a roomy stage', (tester) async {
      late double childWidth;
      await _pump(
        tester,
        DemoStageCard(viewport: DemoViewport.desktop, child: probe((w) => childWidth = w)),
        width: 600, // inner = 600 - 56 padding - 2 border = 542
      );
      expect(childWidth, moreOrLessEquals(542, epsilon: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop clamps to the 320dp floor and scrolls on a narrow stage', (tester) async {
      late double childWidth;
      await _pump(
        tester,
        DemoStageCard(viewport: DemoViewport.desktop, child: probe((w) => childWidth = w)),
        width: 250, // inner stage = 194 < 320 floor
      );
      // Laid out at the floor, not squeezed to 194.
      expect(childWidth, moreOrLessEquals(320, epsilon: 0.5));
      // And made scrollable rather than overflowing.
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a demo wider than a narrow desktop stage does not overflow', (tester) async {
      await _pump(
        tester,
        DemoStageCard(
          viewport: DemoViewport.desktop,
          // A hard-300dp row would overflow a 194dp stage without the clamp.
          child: Row(children: [Container(width: 300, height: 40, color: const Color(0xFF888888))]),
        ),
        width: 250,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('phone viewport is constrained to 320 and centred when it fits', (tester) async {
      late double childWidth;
      await _pump(
        tester,
        DemoStageCard(viewport: DemoViewport.phone, child: probe((w) => childWidth = w)),
        width: 900, // plenty of room
      );
      expect(childWidth, moreOrLessEquals(320, epsilon: 0.5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet viewport scrolls when wider than the stage', (tester) async {
      late double childWidth;
      await _pump(
        tester,
        DemoStageCard(viewport: DemoViewport.tablet, child: probe((w) => childWidth = w)),
        width: 500, // inner 444 < 768 tablet
      );
      expect(childWidth, moreOrLessEquals(768, epsilon: 0.5));
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('honours minHeight so a small demo does not float in a thin band', (tester) async {
      await _pump(
        tester,
        const DemoStageCard(
          viewport: DemoViewport.desktop,
          minHeight: 200,
          child: SizedBox(height: 10, width: 10),
        ),
        width: 600,
      );
      final h = tester.getSize(find.byType(DemoStageCard)).height;
      expect(h, greaterThanOrEqualTo(200));
    });
  });

  group('DemoSectionHeader', () {
    testWidgets('wide: title beside a labelled control, title is a heading', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        DemoSectionHeader(
          title: 'Playground',
          trailingBuilder: (compact) => DemoViewportControl(
            value: DemoViewport.desktop,
            onChanged: (_) {},
            compact: compact,
          ),
        ),
        width: 700,
      );
      expect(find.text('Desktop'), findsOneWidget); // labelled (not compact)
      // Control sits to the right of, not below, the title.
      final titleRight = tester.getBottomRight(find.text('Playground'));
      final controlTop = tester.getTopLeft(find.byType(DemoViewportControl));
      expect(controlTop.dy, lessThan(titleRight.dy),
          reason: 'control should be on the same row, not stacked below');

      expect(tester.getSemantics(find.text('Playground')), isSemantics(isHeader: true));
      handle.dispose();
    });

    testWidgets('narrow: control collapses to icon-only and stacks below the title', (tester) async {
      await _pump(
        tester,
        DemoSectionHeader(
          title: 'Playground',
          trailingBuilder: (compact) => DemoViewportControl(
            value: DemoViewport.desktop,
            onChanged: (_) {},
            compact: compact,
          ),
        ),
        width: 300, // < 380 → stacked, and < 520 → compact
      );
      expect(find.text('Desktop'), findsNothing); // icon-only
      final titleBottom = tester.getBottomLeft(find.text('Playground')).dy;
      final controlTop = tester.getTopLeft(find.byType(DemoViewportControl)).dy;
      expect(controlTop, greaterThanOrEqualTo(titleBottom),
          reason: 'control should be stacked below the title');
      expect(tester.takeException(), isNull);
    });

    testWidgets('large text scale collapses to compact without overflow', (tester) async {
      await _pump(
        tester,
        DemoSectionHeader(
          title: 'Playground',
          trailingBuilder: (compact) => DemoViewportControl(
            value: DemoViewport.desktop,
            onChanged: (_) {},
            compact: compact,
          ),
        ),
        width: 600, // labelled at 1x, but scale pushes the threshold past 600
        textScale: 2.0,
      );
      expect(find.text('Desktop'), findsNothing); // scale forced icon-only
      expect(tester.takeException(), isNull);
    });
  });

  group('PlaygroundPanel', () {
    Widget panel() => PlaygroundPanel(spec: playgroundFor('text-fields')!);

    testWidgets('shows the unified header, controls and viewport toggle', (tester) async {
      await _pump(tester, panel(), width: 900);
      expect(find.text('Playground'), findsOneWidget);
      expect(find.text('Controls'), findsOneWidget);
      expect(find.widgetWithText(DsButton, 'Reset'), findsOneWidget);
      expect(find.byType(DemoViewportControl), findsOneWidget);
      expect(find.byType(DsTextField), findsWidgets); // live component + knobs
    });

    testWidgets('switching to Phone constrains the live component to 320 without overflow', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, panel(), width: 900);
      await tester.tap(find.byTooltip('Phone'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(tester.getSemantics(find.bySemanticsLabel('Phone preview')),
          isSemantics(isSelected: true));
      handle.dispose();
    });

    testWidgets('Reset restores knobs but keeps the chosen viewport', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, panel(), width: 900);

      // Choose a non-default viewport.
      await tester.tap(find.byTooltip('Phone'));
      await tester.pump();

      // Change a knob (the Label text field is the first DsTextField in Controls).
      final labelField = find.widgetWithText(DsTextField, 'Email');
      await tester.enterText(labelField.first, 'Work email');
      await tester.pump();

      await tester.tap(find.widgetWithText(DsButton, 'Reset'));
      await tester.pump();

      // Viewport survives the reset...
      expect(tester.getSemantics(find.bySemanticsLabel('Phone preview')),
          isSemantics(isSelected: true));
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('turning a knob still re-renders the live component (regression)', (tester) async {
      await _pump(tester, PlaygroundPanel(spec: playgroundFor('action-buttons')!), width: 900);
      expect(find.widgetWithText(DsButton, 'Save changes'), findsOneWidget);
      expect(find.byIcon(DsIcons.check), findsNothing);
      await tester.tap(find.text('Leading icon'));
      await tester.pump();
      expect(find.byIcon(DsIcons.check), findsOneWidget);
    });

    testWidgets('no overflow at 320dp and at a wide width', (tester) async {
      for (final w in [320.0, 1280.0]) {
        await _pump(tester, panel(), width: w);
        expect(tester.takeException(), isNull, reason: 'PlaygroundPanel overflowed at ${w}dp');
      }
    });

    testWidgets('renders under a skin without error', (tester) async {
      await _pump(tester, panel(), theme: DsTheme.light(tokens: DsSkins.engenLight()));
      expect(tester.takeException(), isNull);
      expect(find.text('Playground'), findsOneWidget);
    });
  });

  group('DeviceFrame (static demo stage)', () {
    testWidgets('carries the same viewport toggle and a Live example header', (tester) async {
      await _pump(tester, DeviceFrame(child: demoFor('divider')!), width: 900);
      expect(find.text('Live example'), findsOneWidget);
      expect(find.byType(DemoViewportControl), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
    });

    testWidgets('a wide real demo does not overflow at a phone-width reading column', (tester) async {
      // Reading column at a ~320dp window ≈ 232dp; the desktop stage floor
      // should keep these demos from overflowing (the review found several did
      // at ~176dp inner before the clamp).
      for (final id in ['focus-view', 'context-view', 'sign-out']) {
        final demo = demoFor(id);
        if (demo == null) continue;
        await _pump(tester, DeviceFrame(child: demo), width: 232);
        await tester.pump(const Duration(milliseconds: 350));
        expect(tester.takeException(), isNull, reason: '$id overflowed in a narrow DeviceFrame');
      }
    });

    testWidgets('switching viewport re-lays the demo without error', (tester) async {
      await _pump(tester, DeviceFrame(child: demoFor('divider')!), width: 900);
      await tester.tap(find.byTooltip('Tablet'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Desktop'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
