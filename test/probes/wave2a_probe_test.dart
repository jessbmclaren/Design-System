// Edge probes for the wave-2A surface: DsTakeover, DsWaitingScreen,
// DsBusinessVerification, DsFooterActions, DsUploadField,
// DsAddressFieldGroup, DsVerificationRail and DsSelect.
//
// Each probe drives the real behaviour and observes it. The defects these
// probes originally pinned have been fixed, so every probe now asserts the
// correct behaviour; behaviour that is by design (and documented) is marked
// as such in its comment.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _scratch =
    '/private/tmp/claude-501/-Users-jessica-mclaren-Code-Design-System/'
    'f87ea458-8d16-4535-8814-86f674a8cb0f/scratchpad';

/// A 300-character German compound word, built from a real 63-character one.
final String longGermanWord =
    ('Rindfleischetikettierungsueberwachungsaufgabenuebertragungsgesetz' * 5)
        .substring(0, 300);

/// A 100-character email address.
final String longEmail =
    '${'a' * 60}.${'b' * 27}@example.com'.padRight(100, 'x').substring(0, 100);

/// Pumps [child] inside a themed app with a controllable viewport, text scale
/// and animation setting. The whole app sits in a [RepaintBoundary] keyed with
/// [shotKey] so probes can capture screenshots.
final GlobalKey shotKey = GlobalKey();

Future<void> pumpProbe(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(800, 600),
  ThemeData? theme,
  double textScale = 1.0,
  bool disableAnimations = false,
  bool wrapInScaffold = true,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? DsTheme.light(),
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: RepaintBoundary(key: shotKey, child: app!),
      ),
      home: wrapInScaffold ? Scaffold(body: child) : child,
    ),
  );
}

/// Runs [body] while collecting every FlutterError (layout overflows report
/// through FlutterError.onError, and several can land in a single pump).
Future<List<FlutterErrorDetails>> recordErrors(
  Future<void> Function() body,
) async {
  final errors = <FlutterErrorDetails>[];
  final oldOnError = FlutterError.onError;
  FlutterError.onError = errors.add;
  try {
    await body();
  } finally {
    FlutterError.onError = oldOnError;
  }
  return errors;
}

bool _isOverflow(FlutterErrorDetails details) =>
    details.exceptionAsString().contains('overflowed');

/// Whether the primary focus currently sits inside the subtree of [finder].
bool focusWithin(WidgetTester tester, Finder finder) {
  final focusedContext = tester.binding.focusManager.primaryFocus?.context;
  if (focusedContext == null) return false;
  bool within = false;
  for (final element in finder.evaluate()) {
    void visit(Element e) {
      if (within) return;
      if (identical(e, focusedContext)) {
        within = true;
        return;
      }
      e.visitChildren(visit);
    }

    visit(element);
    if (within) return true;
  }
  return false;
}

/// Presses Tab until the focus lands inside [finder]. Returns false when it
/// never does within [maxTabs] presses.
Future<bool> tabTo(WidgetTester tester, Finder finder,
    {int maxTabs = 25}) async {
  if (focusWithin(tester, finder)) return true;
  for (var i = 0; i < maxTabs; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    if (focusWithin(tester, finder)) return true;
  }
  return false;
}

Future<void> saveScreenshot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary =
        tester.renderObject<RenderRepaintBoundary>(find.byKey(shotKey));
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory(_scratch).createSync(recursive: true);
    File('$_scratch/$name').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  group('DsTakeover probes', () {
    testWidgets(
        'a focused background field is unfocused when a takeover mounts',
        (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final fieldKey = GlobalKey();

      Widget page() => Scaffold(
            body: Center(
              child: TextField(
                key: fieldKey,
                focusNode: focusNode,
                controller: controller,
              ),
            ),
          );

      await tester.pumpWidget(
        MaterialApp(theme: DsTheme.light(), home: page()),
      );
      await tester.tap(find.byKey(fieldKey));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
      await tester.enterText(find.byKey(fieldKey), 'before');

      // Swap the page for a takeover over the same page subtree, the way a
      // caller swaps the page body. The GlobalKey preserves the field state.
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: DsTakeover(
            background: page(),
            child: Material(
              child: SizedBox(
                width: 240,
                height: 120,
                child: Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('card'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // The takeover releases focus caught inside the background on its
      // first frame, honouring the doc's promise that the background cannot
      // be reached by keyboard.
      expect(focusNode.hasPrimaryFocus, isFalse);

      // The IME connection closed with the focus, so keyboard input typed
      // after the takeover is up never reaches the inert background field.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'typed after the takeover mounted',
          selection: TextSelection.collapsed(offset: 32),
        ),
      );
      await tester.pump();
      expect(controller.text, 'before');

      // Tab moves focus into the card, and the background never regains it.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);
      expect(
        focusWithin(tester, find.widgetWithText(TextButton, 'card')),
        isTrue,
      );
    });

    testWidgets('a second takeover stacked over a first silences the first card',
        (tester) async {
      var card1Taps = 0;
      var card2Taps = 0;

      Widget card(String label, VoidCallback onTap) => Material(
            child: SizedBox(
              width: 240,
              height: 80,
              child: Center(
                child: TextButton(onPressed: onTap, child: Text(label)),
              ),
            ),
          );

      final first = DsTakeover(
        background: const Scaffold(body: Center(child: Text('page'))),
        child: card('card one', () => card1Taps++),
      );
      final second = DsTakeover(
        background: first,
        child: Align(
          alignment: Alignment.topCenter,
          child: card('card two', () => card2Taps++),
        ),
      );

      await pumpProbe(tester, second, wrapInScaffold: false);

      await tester.tap(find.text('card two'));
      await tester.pump();
      expect(card2Taps, 1);

      // The first card is inert underneath, even where it is not covered.
      await tester.tap(find.text('card one'), warnIfMissed: false);
      await tester.pump();
      expect(card1Taps, 0);
      // And it is gone from semantics too.
      expect(find.bySemanticsLabel('card one'), findsNothing);
    });

    testWidgets(
        'a takeover nested as the CHILD of a takeover fails layout, as documented',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          DsTakeover(
            background: const ColoredBox(color: Colors.white),
            child: DsTakeover(
              background: const ColoredBox(color: Colors.black12),
              child: const Material(child: Text('inner card')),
            ),
          ),
          wrapInScaffold: false,
        );
      });

      // By design (documented): a takeover cannot be hosted inside another
      // takeover's child slot. The card slot is a SingleChildScrollView, so
      // the inner Stack(fit: StackFit.expand) receives an unbounded height
      // and layout fails. The class doc directs callers to nest through the
      // background slot instead (background: firstTakeover), which works.
      expect(errors, isNotEmpty);
      final messages = errors.map((e) => e.exceptionAsString()).join('\n');
      expect(
        messages,
        anyOf(
          contains('unbounded'),
          contains('infinite'),
          contains('RenderBox was not laid out'),
        ),
      );
      // Clear the broken tree so the teardown does not re-report.
      await recordErrors(() async {
        await tester.pumpWidget(const SizedBox());
      });
    });

    testWidgets('a scroll-drag that ends outside the card does not dismiss',
        (tester) async {
      var dismissed = 0;
      await pumpProbe(
        tester,
        DsTakeover(
          background: const Scaffold(body: Center(child: Text('page'))),
          barrierDismissible: true,
          onDismiss: () => dismissed++,
          child: const Material(
            child: SizedBox(width: 220, height: 120, child: Center(child: Text('card'))),
          ),
        ),
        wrapInScaffold: false,
      );

      // Drag starting on the card and ending outside it: the scroll view
      // claims the drag, so no barrier tap fires.
      await tester.drag(find.text('card'), const Offset(0, -250));
      await tester.pump();
      expect(dismissed, 0);

      // Drag starting on the scrim: still no dismiss.
      await tester.dragFrom(const Offset(700, 60), const Offset(0, 200));
      await tester.pump();
      expect(dismissed, 0);

      // A clean tap on the scrim does dismiss.
      await tester.tapAt(const Offset(700, 60));
      await tester.pump();
      expect(dismissed, 1);
    });

    testWidgets(
        'a tap in a transparent gap INSIDE the card does not dismiss',
        (tester) async {
      var dismissed = 0;
      final topKey = GlobalKey();
      final bottomKey = GlobalKey();
      await pumpProbe(
        tester,
        DsTakeover(
          background: const Scaffold(body: SizedBox.expand()),
          barrierDismissible: true,
          onDismiss: () => dismissed++,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                key: topKey,
                color: Colors.white,
                child: const SizedBox(width: 240, height: 80),
              ),
              const SizedBox(height: 48),
              Material(
                key: bottomKey,
                color: Colors.white,
                child: const SizedBox(width: 240, height: 80),
              ),
            ],
          ),
        ),
        wrapInScaffold: false,
      );

      // Tap in the 48dp gap between the card's two surfaces, horizontally
      // centred on the card itself.
      final top = tester.getBottomLeft(find.byKey(topKey));
      final bottom = tester.getTopLeft(find.byKey(bottomKey));
      final gapCentre = Offset(top.dx + 120, (top.dy + bottom.dy) / 2);
      await tester.tapAt(gapCentre);
      await tester.pump();

      // The inner tap-absorber is opaque over the card's whole footprint, so
      // a tap visually "on the card" (between its stacked surfaces) never
      // falls through to the barrier.
      expect(dismissed, 0);

      // A genuine barrier tap outside the card still dismisses.
      await tester.tapAt(const Offset(700, 60));
      await tester.pump();
      expect(dismissed, 1);
    });
  });

  group('DsWaitingScreen probes', () {
    testWidgets(
        '300-char headline at 320dp, 2x scale, engen skin: no overflow',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          DsWaitingScreen(
            headline: longGermanWord,
            supportingText: longEmail,
            header: const Text(
              'brand',
              style: TextStyle(fontSize: 14, color: Color(0xFF0B1B45)),
            ),
          ),
          size: const Size(320, 568),
          textScale: 2.0,
          theme: DsTheme.light(tokens: DsSkins.engenLight()),
          wrapInScaffold: false,
        );
        // Let the entrance and the ellipsis animate a few explicit frames;
        // never pumpAndSettle on this looping surface.
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 120));
        }
      });
      expect(errors.where(_isOverflow), isEmpty);
      await saveScreenshot(tester, 'wave2a_waiting_320_2x.png');
    });

    testWidgets('the header slot ellipsises within a 320dp screen',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          const DsWaitingScreen(
            headline: 'Signing you in',
            header: Text(
              'averyverylongbrandwordmarkline',
              style: TextStyle(fontSize: 24, color: Color(0xFF0B1B45)),
            ),
          ),
          size: const Size(320, 568),
          wrapInScaffold: false,
        );
        await tester.pump(const Duration(milliseconds: 200));
      });

      final headerRect =
          tester.getRect(find.text('averyverylongbrandwordmarkline'));
      // The header band spans left and right inside the safe area, so wide
      // content is bounded to the viewport and ellipsises on one line rather
      // than walking silently off the right edge.
      expect(headerRect.left, greaterThan(0));
      expect(headerRect.right, lessThanOrEqualTo(320));
      expect(errors.where(_isOverflow), isEmpty);
    });

    testWidgets('the animated ellipsis scales exactly once under a 2x textScaler',
        (tester) async {
      await pumpProbe(
        tester,
        const DsWaitingScreen(headline: 'Signing you in'),
        size: const Size(320, 568),
        textScale: 2.0,
        wrapInScaffold: false,
      );
      await tester.pump(const Duration(milliseconds: 100));

      // The dots should occupy exactly one headline line at the 2x scale:
      // fontSize * height * 2.
      final ellipsisTexts = find.descendant(
        of: find.byType(DsAnimatedEllipsis),
        matching: find.byType(Text),
      );
      expect(ellipsisTexts, findsWidgets);
      final style = tester.widget<Text>(ellipsisTexts.first).style!;
      final oneLine = style.fontSize! * (style.height ?? 1.0) * 2.0;

      final painted = tester.getRect(find.byType(DsAnimatedEllipsis));
      // RichText wraps every WidgetSpan child in an auto-scaling transform
      // (the textScaler applied as a scale), so the ellipsis's own texts do
      // not scale themselves. Under a 2x textScaler the dots render at
      // exactly one 2x headline line, in step with the sentence they trail.
      expect(painted.height, moreOrLessEquals(oneLine, epsilon: 1));
      await saveScreenshot(tester, 'wave2a_waiting_ellipsis_2x.png');
    });

    testWidgets('very short viewport, dark theme, reduced motion: no overflow',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          const DsWaitingScreen(
            headline: 'Preparing your workspace',
            supportingText: 'This will only take a moment.',
          ),
          size: const Size(320, 180),
          textScale: 1.3,
          theme: DsTheme.dark(),
          disableAnimations: true,
          wrapInScaffold: false,
        );
        await tester.pump(const Duration(milliseconds: 400));
      });
      expect(errors.where(_isOverflow), isEmpty);
      // The headline carries a trailing WidgetSpan, so exact-text matching
      // fails; match on the containing rich text instead.
      expect(
        find.textContaining('Preparing your workspace', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('disposal mid-entrance leaves no dangling animation',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          const DsWaitingScreen(headline: 'Signing you in'),
          wrapInScaffold: false,
        );
        // Part-way through the entrance and mid ellipsis cycle, rip it away.
        await tester.pump(const Duration(milliseconds: 60));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 500));
      });
      expect(errors, isEmpty);
    });
  });

  group('DsFooterActions probes', () {
    testWidgets('layout at exactly minRowWidth is a row; 1dp below stacks',
        (tester) async {
      Widget cluster() => DsFooterActions(
            primaryLabel: 'Continue',
            onPrimary: () {},
            backLabel: 'Back',
            onBack: () {},
          );

      await pumpProbe(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 480, child: cluster()),
        ),
        size: const Size(800, 600),
      );
      var primary = tester.getCenter(find.text('Continue'));
      var back = tester.getCenter(find.text('Back'));
      expect(primary.dy, moreOrLessEquals(back.dy, epsilon: 1),
          reason: 'at exactly minRowWidth the cluster must lay out as a row');
      expect(primary.dx, greaterThan(back.dx));

      await pumpProbe(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 479, child: cluster()),
        ),
        size: const Size(800, 600),
      );
      primary = tester.getCenter(find.text('Continue'));
      back = tester.getCenter(find.text('Back'));
      expect(primary.dy, lessThan(back.dy),
          reason: '1dp under minRowWidth the cluster stacks, primary first');
    });

    testWidgets(
        'long labels above minRowWidth fall back to the stacked layout',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          SizedBox(
            width: 600,
            child: DsFooterActions(
              primaryLabel:
                  'Verifizierungsunterlagen hochladen und fortfahren',
              onPrimary: () {},
              backLabel: 'Zurueck zur vorherigen Angabe',
              onBack: () {},
              leading: const Text('Schritt 2 von 4'),
            ),
          ),
          size: const Size(800, 600),
          textScale: 1.3,
        );
      });

      // The cluster measures the row's intrinsic width before committing to
      // it: long (e.g. German) labels at 1.3x text scale cannot fit 600dp,
      // so it stacks (primary first) instead of overflowing the row.
      expect(errors.where(_isOverflow), isEmpty);
      final primaryY = tester
          .getCenter(
              find.text('Verifizierungsunterlagen hochladen und fortfahren'))
          .dy;
      final backY =
          tester.getCenter(find.text('Zurueck zur vorherigen Angabe')).dy;
      expect(primaryY, lessThan(backY));
      await saveScreenshot(tester, 'wave2a_footer_row_overflow.png');
    });

    testWidgets('stacked order keeps the caption last, beneath the actions',
        (tester) async {
      await pumpProbe(
        tester,
        SizedBox(
          width: 320,
          child: DsFooterActions(
            primaryLabel: 'Continue',
            onPrimary: () {},
            backLabel: 'Back',
            onBack: () {},
            tertiaryLabel: 'Save and finish later',
            onTertiary: () {},
            leading: const Text('Step 2 of 4'),
          ),
        ),
        size: const Size(360, 700),
      );

      final primaryY = tester.getCenter(find.text('Continue')).dy;
      final backY = tester.getCenter(find.text('Back')).dy;
      final leadingY = tester.getCenter(find.text('Step 2 of 4')).dy;
      final tertiaryY = tester.getCenter(find.text('Save and finish later')).dy;

      expect(primaryY, lessThan(backY));
      // The stacked layout keeps the action cluster together, matching the
      // documented order: primary, back, then the tertiary action beneath
      // the cluster, with the "Step 2 of 4" caption last.
      expect(backY, lessThan(tertiaryY));
      expect(tertiaryY, lessThan(leadingY));
    });

    testWidgets(
        'unbounded width with minRowWidth infinity stacks instead of crashing',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DsFooterActions(
              primaryLabel: 'Continue',
              onPrimary: () {},
              minRowWidth: double.infinity,
            ),
          ),
          size: const Size(800, 600),
        );
      });

      // The doc promises "pass double.infinity to always stack" and defines
      // the unbounded-width behaviour: with nothing to measure against the
      // cluster sizes itself to its content, stacking at the width of its
      // widest piece, so a horizontal scroll view hosts it without a crash.
      expect(errors, isEmpty);
      expect(find.text('Continue'), findsOneWidget);
    });
  });

  group('DsUploadField probes', () {
    testWidgets('flapping idle-uploading-error-uploading every frame is safe',
        (tester) async {
      const cycle = <DsUploadFieldState>[
        DsUploadFieldState.idle,
        DsUploadFieldState.uploading,
        DsUploadFieldState.error,
        DsUploadFieldState.uploading,
      ];
      late StateSetter setProbeState;
      var tick = 0;

      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          StatefulBuilder(
            builder: (context, setState) {
              setProbeState = setState;
              return DsUploadField(
                state: cycle[tick % cycle.length],
                progress: (tick % 10) / 10,
                fileName: 'passport.pdf',
                errorText: 'The upload failed.',
                onPick: () {},
                onRetry: () {},
                onRemove: () {},
              );
            },
          ),
        );
        for (var i = 0; i < 40; i++) {
          setProbeState(() => tick++);
          await tester.pump();
        }
      });
      expect(errors, isEmpty);
      // 40 flaps end on tick 40 -> idle again.
      expect(find.text('Choose a file to upload'), findsOneWidget);
    });

    testWidgets('progress 1.0 while uploading still reads as uploading',
        (tester) async {
      await pumpProbe(
        tester,
        const DsUploadField(
          state: DsUploadFieldState.uploading,
          progress: 1.0,
          fileName: 'passport.pdf',
        ),
      );
      expect(find.text('Uploading passport.pdf'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 1.0);

      // Out-of-range progress is clamped, not asserted.
      await pumpProbe(
        tester,
        const DsUploadField(
          state: DsUploadFieldState.uploading,
          progress: 1.5,
          fileName: 'passport.pdf',
        ),
      );
      expect(
        tester
            .widget<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator))
            .value,
        1.0,
      );
    });

    testWidgets('the error row merges into one live-region button node',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpProbe(
        tester,
        DsUploadField(
          state: DsUploadFieldState.error,
          errorText: 'File too large. Maximum size is 10 MB.',
          onRetry: () {},
        ),
      );

      // The InkWell merges the whole row into a single node: the live region
      // therefore announces the status AND the reason, and the node is an
      // enabled button, so keyboard users can retry. No orphan live regions.
      final node = tester.getSemantics(find.text('Upload failed'));
      expect(node.flagsCollection.isLiveRegion, isTrue);
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      expect(node.label, contains('Upload failed'));
      expect(node.label, contains('File too large. Maximum size is 10 MB.'));

      final caption = tester
          .getSemantics(find.text('File too large. Maximum size is 10 MB.'));
      expect(caption.id, node.id,
          reason: 'title and reason share the merged node');
      handle.dispose();
    });

    testWidgets('keyboard-only: Tab reaches the field, Space and Enter fire it',
        (tester) async {
      var picks = 0;
      await pumpProbe(
        tester,
        DsUploadField(state: DsUploadFieldState.idle, onPick: () => picks++),
      );
      expect(await tabTo(tester, find.byType(DsUploadField)), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(picks, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picks, 2);

      var retries = 0;
      await pumpProbe(
        tester,
        DsUploadField(
            state: DsUploadFieldState.error, onRetry: () => retries++),
      );
      expect(await tabTo(tester, find.byType(DsUploadField)), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(retries, 1);
    });

    testWidgets('a 100-char email file name at 320dp and 2x scale ellipsizes',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          DsUploadField(
            state: DsUploadFieldState.success,
            fileName: longEmail,
            onRemove: () {},
          ),
          size: const Size(320, 568),
          textScale: 2.0,
        );
      });
      expect(errors.where(_isOverflow), isEmpty);
      final title = tester.widget<Text>(
        find.textContaining('added', findRichText: false),
      );
      expect(title.overflow, TextOverflow.ellipsis);
      expect(title.maxLines, 1);
    });
  });

  group('DsAddressFieldGroup probes', () {
    const countries = <DsSelectOption<String>>[
      DsSelectOption(value: 'DE', label: 'Germany'),
      DsSelectOption(value: 'BE', label: 'Belgium'),
    ];

    testWidgets(
        'an external value replacing a focused field snaps the caret to the end',
        (tester) async {
      var value = const DsAddressValue();
      late StateSetter setProbeState;
      await pumpProbe(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setProbeState = setState;
            return SizedBox(
              width: 500,
              child: DsAddressFieldGroup(
                value: value,
                countries: countries,
                onChanged: (v) => setState(() => value = v),
              ),
            );
          },
        ),
        size: const Size(600, 1000),
      );

      final street = find.byType(TextFormField).first;
      await tester.enterText(street, '10 downing');
      await tester.pump();
      final controller = tester.widget<TextFormField>(street).controller!;
      expect(controller.selection.baseOffset, 10,
          reason: 'the caret sits at the end of what was typed');

      // An address-lookup style replacement arrives from outside while the
      // street field is still focused.
      setProbeState(() {
        value = value.copyWith(street: '10 Downing Street, London');
      });
      await tester.pump();

      expect(controller.text, '10 Downing Street, London');
      // The sync assigns controller.text, which invalidates the selection;
      // the focused EditableText then snaps the caret to the END of the new
      // text. No crash and no feedback loop; a caret mid-word does move to
      // the end, which is the standard Flutter trade-off for a programmatic
      // rewrite.
      expect(
        controller.selection.baseOffset,
        '10 Downing Street, London'.length,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('an echoing parent does not feed back extra onChanged calls',
        (tester) async {
      var value = const DsAddressValue();
      var changes = 0;
      await pumpProbe(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 500,
            child: DsAddressFieldGroup(
              value: value,
              countries: countries,
              onChanged: (v) {
                changes++;
                setState(() => value = v);
              },
            ),
          ),
        ),
        size: const Size(600, 1000),
      );

      await tester.enterText(find.byType(TextFormField).first, '1 A St');
      await tester.pump();
      expect(changes, 1);
      await tester.enterText(find.byType(TextFormField).at(2), 'Berlin');
      await tester.pump();
      expect(changes, 2);
      expect(value.street, '1 A St');
      expect(value.city, 'Berlin');
    });

    testWidgets('config hiding every optional field leaves street and city',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          DsAddressFieldGroup(
            config: const DsAddressFieldConfig(
              showUnit: false,
              showRegion: false,
              showPostalCode: false,
              showCountry: false,
            ),
            countries: countries,
            onChanged: (_) {},
          ),
          size: const Size(320, 700),
        );
      });
      expect(errors.where(_isOverflow), isEmpty);
      expect(find.text('Street address'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Unit or building'), findsNothing);
      expect(find.text('Region'), findsNothing);
      expect(find.text('Postal code'), findsNothing);
      expect(find.text('Country'), findsNothing);
    });

    testWidgets('enabled: false dims and blocks every field', (tester) async {
      var changes = 0;
      await pumpProbe(
        tester,
        SizedBox(
          width: 500,
          child: DsAddressFieldGroup(
            enabled: false,
            countries: countries,
            onChanged: (_) => changes++,
          ),
        ),
        size: const Size(600, 1000),
      );
      final field = tester.widget<TextFormField>(
        find.byType(TextFormField).first,
      );
      expect(field.enabled, isFalse);
      await tester.tap(find.text('Country'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('Germany'), findsNothing);
      expect(changes, 0);
    });
  });

  group('DsVerificationRail probes', () {
    List<DsVerificationSection> sections(int count, {int active = 4}) => [
          for (var i = 0; i < count; i++)
            DsVerificationSection(
              label: 'Section ${i + 1}',
              state: i < active
                  ? DsVerificationSectionState.done
                  : i == active
                      ? DsVerificationSectionState.active
                      : DsVerificationSectionState.upcoming,
            ),
        ];

    testWidgets(
        '12 sections in the compact fallback summarise without overflow',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 180,
              child: DsVerificationRail(sections: sections(12)),
            ),
          ),
          size: const Size(320, 568),
        );
      });

      // The compact fallback shows the active section's marker and label
      // with a "Step n of N" caption, so its single line holds however many
      // sections the flow has.
      expect(errors.where(_isOverflow), isEmpty);
      expect(find.text('Section 5'), findsOneWidget);
      expect(find.text('Step 5 of 12'), findsOneWidget);
      await saveScreenshot(tester, 'wave2a_rail_compact_overflow.png');
    });

    testWidgets('12 sections overflow a phone-height viewport vertically',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 280,
              child: DsVerificationRail(
                sections: sections(12),
                onSectionSelected: (_) {},
              ),
            ),
          ),
          size: const Size(320, 568),
        );
      });

      // By design (documented): the rail renders at its natural height and
      // never scrolls itself, like the library's other list-like components.
      // 12 sections (~660dp) therefore overflow a fixed 568dp body; the docs
      // direct callers to give the rail a scrollable parent.
      expect(errors.where(_isOverflow), isNotEmpty);
    });

    testWidgets('an out-of-range activeSubStep renders without an active dot',
        (tester) async {
      final errors = await recordErrors(() async {
        await pumpProbe(
          tester,
          SizedBox(
            width: 280,
            child: DsVerificationRail(
              activeSubStep: 99,
              sections: const [
                DsVerificationSection(
                  label: 'Business',
                  state: DsVerificationSectionState.active,
                  subSteps: ['Type', 'Details'],
                ),
                DsVerificationSection(label: 'Identity'),
              ],
            ),
          ),
          size: const Size(320, 568),
        );
      });
      expect(errors, isEmpty);
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });
  });

  group('DsSelect probes', () {
    const options = <DsSelectOption<String>>[
      DsSelectOption(value: 'a', label: 'Alpha'),
      DsSelectOption(value: 'b', label: 'Beta'),
    ];

    testWidgets('a DISABLED select neither validates nor saves',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      var savedCalls = 0;
      await pumpProbe(
        tester,
        Form(
          key: formKey,
          child: DsSelect<String>(
            label: 'Country',
            value: null,
            options: options,
            enabled: false,
            onChanged: (_) {},
            validator: (v) => v == null ? 'Choose a country' : null,
            onSaved: (_) => savedCalls++,
          ),
        ),
      );

      final valid = formKey.currentState!.validate();
      await tester.pump();

      // A disabled select sits the form out: its validator never runs, so
      // Form.validate() cannot be blocked by an error on a control the user
      // cannot operate, and Form.save() skips it too.
      expect(valid, isTrue);
      expect(find.text('Choose a country'), findsNothing);

      formKey.currentState!.save();
      expect(savedCalls, 0);
    });

    testWidgets('a programmatic value change updates the closed field',
        (tester) async {
      String? value = 'a';
      late StateSetter setProbeState;
      await pumpProbe(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setProbeState = setState;
            return DsSelect<String>(
              label: 'Letter',
              value: value,
              options: options,
              onChanged: (v) => setState(() => value = v),
            );
          },
        ),
      );
      expect(find.text('Alpha'), findsOneWidget);

      setProbeState(() => value = 'b');
      await tester.pump();
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Alpha'), findsNothing);
    });

    testWidgets('keyboard-only: Tab focuses, Enter opens and picks an option',
        (tester) async {
      String? picked;
      await pumpProbe(
        tester,
        DsSelect<String>(
          label: 'Letter',
          value: null,
          hintText: 'Pick one',
          options: options,
          onChanged: (v) => picked = v,
        ),
      );

      expect(await tabTo(tester, find.byType(DsSelect<String>)), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The menu opens with the first item focused; arrow to the second and
      // choose it.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(picked, 'b');
    });
  });

  group('DsBusinessVerification probes', () {
    testWidgets('backing out of step 0 fires onCancel', (tester) async {
      var cancelled = 0;
      await pumpProbe(
        tester,
        DsBusinessVerification(onCancel: () => cancelled++),
        size: const Size(800, 900),
      );

      // With an onCancel, step 0 keeps its back affordance and routes it to
      // the callback, so an embedding screen can dismiss the flow.
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Business type'), findsWidgets);

      await tester.tap(find.text('Back'));
      await tester.pump();
      expect(cancelled, 1);
      expect(find.text('Business type'), findsWidgets,
          reason: 'cancelling does not advance or reset the flow');

      // Without an onCancel there is nothing to back out to, so step 0 shows
      // no back affordance, as before.
      await pumpProbe(
        tester,
        const DsBusinessVerification(),
        size: const Size(800, 900),
      );
      expect(find.text('Back'), findsNothing);
    });

    testWidgets(
        'a stepBodyBuilder that replaces the identity step keeps the flow alive',
        (tester) async {
      await pumpProbe(
        tester,
        DsBusinessVerification(
          stepBodyBuilder: (context, index, body) =>
              index == 2 ? const Text('custom identity step') : body,
        ),
        size: const Size(800, 900),
      );

      // Walk to the identity step.
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('custom identity step'), findsOneWidget);

      // The consent gate applies only while the identity step shows its
      // stock body. A replaced body has no stock checkbox to tick, so the
      // gate lifts and the flow advances; callers gate a custom body through
      // canAdvance instead.
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('custom identity step'), findsNothing);
      expect(find.text('Review your details'), findsOneWidget);
    });

    testWidgets('keyboard-only end-to-end run, receipt included',
        (tester) async {
      var submitted = 0;
      var uploadPicks = 0;
      var uploadState = DsUploadFieldState.idle;
      late StateSetter setProbeState;

      await pumpProbe(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setProbeState = setState;
            return DsBusinessVerification(
              onSubmitted: () => submitted++,
              showReceipt: true,
              receiptContinueLabel: 'Go to dashboard',
              uploadState: uploadState,
              uploadFileName: 'passport.pdf',
              onUploadPick: () {
                uploadPicks++;
                setState(() => uploadState = DsUploadFieldState.success);
              },
              addressCountries: const [
                DsSelectOption(value: 'DE', label: 'Germany'),
              ],
            );
          },
        ),
        size: const Size(800, 900),
      );

      final continueButton = find.widgetWithText(DsButton, 'Continue');

      // Step 0: pick the business type entirely from the keyboard.
      expect(await tabTo(tester, find.byType(DsSelect<String>)), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      // Let the closing menu route finish animating away.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Sole trader'), findsWidgets);

      expect(await tabTo(tester, continueButton), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.text('Legal name'), findsOneWidget);

      // Step 1: type the details (text entry is keyboard input) and continue.
      await tester.enterText(
        find
            .descendant(
              of: find.widgetWithText(DsTextField, 'Legal name'),
              matching: find.byType(TextFormField),
            )
            .first,
        'Acme GmbH',
      );
      await tester.pump();
      expect(await tabTo(tester, continueButton), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.text('Verify identity'), findsWidgets);

      // Step 2: upload via Space on the upload field, consent via Space on
      // the checkbox.
      expect(await tabTo(tester, find.byType(DsUploadField)), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(uploadPicks, 1);
      expect(find.text('passport.pdf added'), findsOneWidget);

      expect(await tabTo(tester, find.byType(DsCheckbox)), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(await tabTo(tester, continueButton), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.text('Review your details'), findsOneWidget);
      expect(find.text('Sole trader'), findsOneWidget);
      expect(find.text('Acme GmbH'), findsOneWidget);
      expect(find.text('passport.pdf'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);

      // Step 3: submit; the receipt defers onSubmitted to its continue.
      final submitButton = find.widgetWithText(DsButton, 'Submit');
      expect(await tabTo(tester, submitButton), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.text('Verification submitted'), findsOneWidget);
      expect(submitted, 0,
          reason: 'with showReceipt, submission waits for the continue');

      final receiptContinue = find.widgetWithText(DsButton, 'Go to dashboard');
      expect(await tabTo(tester, receiptContinue), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(submitted, 1);

      // Keep the analyzer honest about the captured setter.
      setProbeState(() {});
      await tester.pump();
    });
  });
}
