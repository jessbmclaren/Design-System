// Edge probes for the wave-1 control upgrades: DsButton, DsIconButton,
// DsCheckbox, DsSwitch, DsSpinner, DsLink, DsTextField and DsFieldLabel.
//
// Each probe drives the real behaviour at an edge the component tests do not
// cover: rapid state flapping, disposal mid-animation, keyboard-only races,
// extreme content, tight viewports, scaled text, skins and semantics. A probe
// that asserts a defective behaviour keeps the suite green by pinning the
// CURRENT behaviour and carries a BUG comment describing the defect.

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _scratch =
    '/private/tmp/claude-501/-Users-jessica-mclaren-Code-Design-System/'
    'f87ea458-8d16-4535-8814-86f674a8cb0f/scratchpad';

/// A 300-character unbroken German compound, to force mid-word wrapping.
final String longGermanWord =
    ('Rindfleischetikettierungsueberwachungsaufgabenuebertragungsgesetz' * 5)
        .substring(0, 300);

/// A 100-character email address.
final String longEmail = '${'a' * 88}@example.com';

/// A 200-character button label.
final String longLabel =
    ('Continue to the next step of your onboarding journey now ' * 4)
        .substring(0, 200);

/// Pumps [child] inside a themed app with full control of the viewport, the
/// text scale and the reduce-motion flag. Wraps the child in a
/// [RepaintBoundary] keyed by [shotKey] so probes can capture screenshots.
Future<void> pumpProbe(
  WidgetTester tester,
  Widget child, {
  Size? surfaceSize,
  ThemeData? theme,
  double textScale = 1.0,
  bool disableAnimations = false,
  GlobalKey? shotKey,
}) async {
  if (surfaceSize != null) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = surfaceSize;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? DsTheme.light(),
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: Center(
            child: RepaintBoundary(key: shotKey, child: child),
          ),
        ),
      ),
    ),
  );
}

/// Saves a PNG of the [shotKey] boundary to the scratchpad. Best effort: a
/// failure to write is never a test failure.
Future<void> saveShot(WidgetTester tester, GlobalKey shotKey, String name) {
  return tester.runAsync(() async {
    try {
      final boundary =
          shotKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      Directory(_scratch).createSync(recursive: true);
      File('$_scratch/wave1_controls_$name.png')
          .writeAsBytesSync(data!.buffer.asUint8List());
      image.dispose();
    } on Object {
      // Screenshots are evidence for the audit, not assertions.
    }
  });
}

/// WCAG relative luminance of an sRGB colour.
double _luminance(Color c) {
  double channel(double v) {
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// WCAG contrast ratio between two colours (1..21).
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

bool _focusIsInside<T extends Widget>(WidgetTester tester) {
  final BuildContext? focusContext =
      FocusManager.instance.primaryFocus?.context;
  if (focusContext == null) return false;
  return focusContext.findAncestorWidgetOfExactType<T>() != null ||
      focusContext.widget is T;
}

void main() {
  group('DsButton edges', () {
    testWidgets('pending flapped every frame keeps the width stable and '
        'leaves no running spinner behind', (tester) async {
      bool pending = false;
      late StateSetter flip;
      await pumpProbe(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            flip = setState;
            return DsButton(
              label: 'Create account',
              pending: pending,
              onPressed: () {},
            );
          },
        ),
      );
      final double restingWidth =
          tester.getSize(find.byType(FilledButton)).width;

      for (var i = 0; i < 24; i++) {
        flip(() => pending = !pending);
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: 'flap frame $i threw');
        expect(
          tester.getSize(find.byType(FilledButton)).width,
          restingWidth,
          reason: 'width moved on flap frame $i',
        );
      }

      // End at rest: the spinner and its ticker must be gone.
      if (pending) {
        flip(() => pending = false);
        await tester.pump();
      }
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('pending with a trailing icon keeps the width and hides the '
        'icon beneath the spinner', (tester) async {
      Widget build({required bool pending}) => DsButton(
            label: 'Continue',
            trailingIcon: Icons.arrow_forward,
            pending: pending,
            onPressed: () {},
          );

      await pumpProbe(tester, build(pending: false));
      final Size resting = tester.getSize(find.byType(FilledButton));

      await pumpProbe(tester, build(pending: true));
      await tester.pump();

      expect(tester.getSize(find.byType(FilledButton)), resting);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // The trailing icon stays mounted but fully transparent.
      final Opacity opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byIcon(Icons.arrow_forward),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0);
    });

    testWidgets('social factory with a null onPressed renders disabled and '
        'swallows taps', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpProbe(
        tester,
        DsButton.social(
          icon: Icons.g_mobiledata,
          label: 'Continue with Google',
          onPressed: null,
        ),
      );

      final FilledButton inner =
          tester.widget<FilledButton>(find.byType(FilledButton));
      expect(inner.onPressed, isNull);
      expect(
        tester.getSemantics(find.byType(DsButton)),
        isSemantics(isButton: true, isEnabled: false),
      );

      await tester.tap(find.byType(DsButton), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('tertiary focus ring clears 3.0:1 against the page background '
        'in every shipped theme', (tester) async {
      final themes = <String, DsTokens>{
        'light': DsTokens.light(),
        'dark': DsTokens.dark(),
        'engenLight': DsSkins.engenLight(),
        'engenDark': DsSkins.engenDark(),
      };
      for (final entry in themes.entries) {
        // The tertiary focus ring is drawn in actionPrimaryColorText.
        final ratio = _contrast(
          entry.value.actionPrimaryColorText,
          entry.value.colorBackground,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'tertiary focus ring on ${entry.key} page: '
              '${ratio.toStringAsFixed(2)}:1',
        );
      }

      // And the focused side really resolves to that colour.
      await pumpProbe(
        tester,
        DsButton(
          label: 'Skip',
          variant: DsButtonVariant.tertiary,
          onPressed: () {},
        ),
        theme: DsTheme.light(tokens: DsSkins.engenLight()),
      );
      final style =
          tester.widget<FilledButton>(find.byType(FilledButton)).style!;
      final tokens = DsTokens.of(tester.element(find.byType(DsButton)));
      expect(
        style.side!.resolve({WidgetState.focused})!.color,
        tokens.actionPrimaryColorText,
      );
    });

    testWidgets('a 200-char label at 320dp fullWidth ellipsizes on a single '
        'line', (tester) async {
      await pumpProbe(
        tester,
        DsButton(label: longLabel, fullWidth: true, onPressed: () {}),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      // The ellipsis without maxLines truncates at the first line, so the
      // control keeps its single-line height.
      final double height = tester.getSize(find.byType(FilledButton)).height;
      expect(height, lessThan(60));
    });

    testWidgets('a 200-char fullWidth label at 320dp and 2x text scale does '
        'not overflow', (tester) async {
      await pumpProbe(
        tester,
        DsButton(label: longLabel, fullWidth: true, onPressed: () {}),
        surfaceSize: const Size(320, 900),
        textScale: 2.0,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty label still renders a full-height control',
        (tester) async {
      await pumpProbe(tester, DsButton(label: '', onPressed: () {}));
      expect(tester.getSize(find.byType(FilledButton)).height,
          greaterThanOrEqualTo(40));
    });

    testWidgets('disposal while the pointer is down does not throw in '
        '_onStatesChanged', (tester) async {
      await pumpProbe(tester, DsButton(label: 'Save', onPressed: () {}));

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(DsButton)));
      await tester.pump(const Duration(milliseconds: 40));

      // Remove the button while the press-scale animation is running and the
      // pointer is still down.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Unmounting cancels the tap and the InkWell flips the pressed state on
      // the shared WidgetStatesController, but _onStatesChanged reads the
      // reduce-motion flag cached in didChangeDependencies rather than the
      // deactivated element's MediaQuery, so the removal is clean.
      expect(tester.takeException(), isNull);

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion pins the press scale at 1.0', (tester) async {
      await pumpProbe(
        tester,
        DsButton(label: 'Save', onPressed: () {}),
        disableAnimations: true,
      );

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(DsButton)));
      await tester.pump(const Duration(milliseconds: 60));
      final scale = tester
          .widget<ScaleTransition>(
            find
                .descendant(
                  of: find.byType(DsButton),
                  matching: find.byType(ScaleTransition),
                )
                .first,
          )
          .scale;
      expect(scale.value, 1.0);
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('keyboard: Tab reaches the button, Enter and Space activate',
        (tester) async {
      var taps = 0;
      await pumpProbe(tester, DsButton(label: 'Save', onPressed: () => taps++));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusIsInside<DsButton>(tester), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(milliseconds: 400));
      expect(taps, 2);
    });
  });

  group('DsIconButton edges', () {
    testWidgets('a disabled icon button is skipped by Tab traversal',
        (tester) async {
      var taps = 0;
      await pumpProbe(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DsIconButton(
              icon: Icons.close,
              semanticLabel: 'Close',
              onPressed: null,
            ),
            DsButton(label: 'Next', onPressed: () => taps++),
          ],
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      // The first Tab lands on the enabled button, not the disabled icon.
      expect(_focusIsInside<DsIconButton>(tester), isFalse);
      expect(_focusIsInside<DsButton>(tester), isTrue);
    });

    testWidgets('carries its accessible name only in the tooltip attribute, '
        'not the semantics label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpProbe(
        tester,
        DsIconButton(
          icon: Icons.close,
          semanticLabel: 'Close',
          onPressed: () {},
        ),
      );
      // The name rides the semantics tooltip attribute, the stock Material
      // Tooltip pattern, which screen readers announce; the label field
      // itself stays empty. The doc comment describes exactly this.
      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(
          isButton: true,
          isEnabled: true,
          tooltip: 'Close',
          label: '',
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('DsCheckbox edges', () {
    testWidgets('a tap on an inline link inside labelWidget fires the link '
        'only, not the checkbox', (tester) async {
      var linkTaps = 0;
      bool? toggled;
      await pumpProbe(
        tester,
        DsCheckbox(
          value: false,
          onChanged: (v) => toggled = v,
          semanticLabel: 'Accept the terms',
          labelWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('I agree to the '),
              DsLink(label: 'terms', onPressed: () => linkTaps++),
            ],
          ),
        ),
      );

      await tester.tap(find.text('terms'));
      await tester.pump();
      expect(linkTaps, 1);
      expect(toggled, isNull,
          reason: 'a link tap must not also toggle the box');

      // A tap on the plain part of the label still toggles.
      await tester.tap(find.text('I agree to the '));
      await tester.pump();
      expect(toggled, isTrue);
      expect(linkTaps, 1);
    });

    testWidgets('adding errorText while focused keeps keyboard focus and the '
        'ring tracks it', (tester) async {
      final shotKey = GlobalKey();
      bool? toggled;
      String? error;
      late StateSetter rebuild;
      await pumpProbe(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return DsCheckbox(
              value: false,
              onChanged: (v) => toggled = v,
              label: 'Accept terms',
              errorText: error,
            );
          },
        ),
        shotKey: shotKey,
      );

      BoxDecoration boxDecoration() => tester
          .widget<AnimatedContainer>(find.byType(AnimatedContainer))
          .decoration! as BoxDecoration;

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusIsInside<DsCheckbox>(tester), isTrue);
      expect(boxDecoration().boxShadow, isNotNull);

      // Validation kicks in while the user is focused on the control. The
      // Column is always the tree root, so adding the error line does not
      // recreate the InkWell and focus stays put.
      rebuild(() => error = 'You must accept the terms');
      await tester.pump();
      expect(_focusIsInside<DsCheckbox>(tester), isTrue);
      expect(boxDecoration().boxShadow, isNotNull);
      expect(find.text('You must accept the terms'), findsOneWidget);
      await saveShot(tester, shotKey, 'checkbox_error_keeps_focus');

      // Clearing the error keeps focus too.
      rebuild(() => error = null);
      await tester.pump();
      expect(_focusIsInside<DsCheckbox>(tester), isTrue);
      expect(boxDecoration().boxShadow, isNotNull);

      // Space still toggles: the control never lost focus.
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(toggled, isTrue);
    });

    testWidgets('a 300-char German compound label wraps at 320dp and 1.3x '
        'scale without overflow', (tester) async {
      await pumpProbe(
        tester,
        DsCheckbox(
          value: true,
          onChanged: (_) {},
          label: longGermanWord,
          errorText: 'Bitte bestaetigen',
        ),
        surfaceSize: const Size(320, 900),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('value flapped every frame animates without throwing',
        (tester) async {
      bool value = false;
      late StateSetter flip;
      await pumpProbe(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            flip = setState;
            return DsCheckbox(
              value: value,
              onChanged: (_) {},
              label: 'Flap',
            );
          },
        ),
      );

      for (var i = 0; i < 20; i++) {
        flip(() => value = !value);
        await tester.pump(const Duration(milliseconds: 8));
        expect(tester.takeException(), isNull, reason: 'flap frame $i threw');
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  });

  group('DsSwitch edges', () {
    testWidgets('disabling a focused switch mid-flight makes Space inert '
        'without a crash', (tester) async {
      final List<bool> changes = <bool>[];
      bool enabled = true;
      bool value = false;
      late StateSetter rebuild;
      await pumpProbe(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return DsSwitch(
              value: value,
              label: 'Sync',
              onChanged: enabled
                  ? (next) {
                      changes.add(next);
                      setState(() => value = next);
                    }
                  : null,
            );
          },
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusIsInside<DsSwitch>(tester), isTrue);

      // Toggle, then disable while the 150ms thumb animation is mid-flight.
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(milliseconds: 75));
      rebuild(() => enabled = false);
      await tester.pump(const Duration(milliseconds: 75));
      expect(changes, [true]);

      // Space on the now-disabled control must not fire or crash.
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(milliseconds: 200));
      expect(changes, [true]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposal mid thumb animation does not throw', (tester) async {
      bool value = false;
      late StateSetter rebuild;
      await pumpProbe(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return DsSwitch(
              value: value,
              label: 'Sync',
              onChanged: (next) => setState(() => value = next),
            );
          },
        ),
      );
      rebuild(() => value = true);
      await tester.pump(const Duration(milliseconds: 75));

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('announces its label once, and semanticLabel names an '
        'unlabelled switch', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpProbe(
        tester,
        DsSwitch(value: true, label: 'Email alerts', onChanged: (_) {}),
      );
      // The visible Text is excluded from semantics (as DsCheckbox does for a
      // plain label), so the outer node carries the name exactly once.
      expect(
        tester.getSemantics(find.byType(DsSwitch)),
        isSemantics(
          isToggled: true,
          label: 'Email alerts',
          hasTapAction: true,
        ),
      );

      // A switch without a visible label takes its accessible name from
      // semanticLabel, mirroring DsCheckbox.
      await pumpProbe(
        tester,
        DsSwitch(
          value: false,
          semanticLabel: 'Marketing emails',
          onChanged: (_) {},
        ),
      );
      final SemanticsNode bare = tester.getSemantics(find.byType(DsSwitch));
      expect(bare.label, 'Marketing emails');
      handle.dispose();
    });
  });

  group('DsSpinner edges', () {
    testWidgets('a label added after mount creates the live region, and '
        'removing it leaves no orphan', (tester) async {
      final handle = tester.ensureSemantics();
      String? label;
      late StateSetter rebuild;
      await pumpProbe(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return DsSpinner(label: label);
          },
        ),
      );
      await tester.pump();
      expect(find.bySemanticsLabel('Loading results'), findsNothing);

      rebuild(() => label = 'Loading results');
      await tester.pump();
      expect(
        tester.getSemantics(find.bySemanticsLabel('Loading results')),
        isSemantics(isLiveRegion: true),
      );

      rebuild(() => label = null);
      await tester.pump();
      expect(find.bySemanticsLabel('Loading results'), findsNothing);
      handle.dispose();
    });

    testWidgets('disposal before a delayed reveal cancels the timer',
        (tester) async {
      await pumpProbe(
        tester,
        const DsSpinner(delay: Duration(milliseconds: 300)),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tear the spinner down before the delay elapses. A leaked timer would
      // fail the test on teardown.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a pending button under reduced motion shows a still '
        'three-quarter ring', (tester) async {
      await pumpProbe(
        tester,
        const DsButton(label: 'Saving', pending: true),
        disableAnimations: true,
      );
      await tester.pump();

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, 0.75);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.transientCallbackCount, 0);
    });
  });

  group('DsLink edges', () {
    testWidgets('in a Column the padded link reserves its own 48dp row and '
        'never claims taps from the neighbouring row', (tester) async {
      var linkTaps = 0;
      await pumpProbe(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsLink(label: 'Open', padded: true, onPressed: () => linkTaps++),
            const SizedBox(height: 4, width: 320),
            const SizedBox(height: 20, width: 320),
          ],
        ),
      );

      // The target is real layout space, at least 48dp tall.
      final Rect linkRect = tester.getRect(find.byType(DsLink));
      expect(linkRect.height, greaterThanOrEqualTo(48));

      // A tap near the row's own bottom edge, well past the visible text,
      // fires.
      await tester.tapAt(Offset(linkRect.center.dx, linkRect.bottom - 2));
      await tester.pump();
      expect(linkTaps, 1);

      // A tap 2dp inside the spacer row beneath stays in that row.
      await tester.tapAt(Offset(linkRect.center.dx, linkRect.bottom + 2));
      await tester.pump();
      expect(linkTaps, 1);
    });

    testWidgets('in a default ListView the padded row keeps its full 48dp '
        'target', (tester) async {
      var linkTaps = 0;
      await pumpProbe(
        tester,
        SizedBox(
          width: 320,
          height: 240,
          child: ListView(
            children: [
              DsLink(label: 'Open', padded: true, onPressed: () => linkTaps++),
              const SizedBox(height: 20),
              const Text('Neighbouring row'),
            ],
          ),
        ),
      );

      // The row itself is 48dp tall, so the list's per-row clipping cannot
      // shrink the target.
      final Rect linkRect = tester.getRect(find.byType(DsLink));
      expect(linkRect.height, greaterThanOrEqualTo(48));

      await tester.tapAt(linkRect.center);
      await tester.pump();
      expect(linkTaps, 1);

      // Near the bottom edge of the reserved row, still inside the target.
      await tester.tapAt(Offset(linkRect.center.dx, linkRect.bottom - 2));
      await tester.pump();
      expect(linkTaps, 2);
    });

    testWidgets('a disabled link is skipped by Tab and Enter activates an '
        'enabled one', (tester) async {
      var taps = 0;
      await pumpProbe(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DsLink(label: 'Disabled link'),
            DsLink(label: 'Enabled link', onPressed: () => taps++),
          ],
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.text('Enabled link'), findsOneWidget);
      expect(_focusIsInside<DsLink>(tester), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('DsTextField edges', () {
    testWidgets('a validator firing while errorText is set shows only the '
        'validator message', (tester) async {
      final shotKey = GlobalKey();
      final formKey = GlobalKey<FormState>();
      await pumpProbe(
        tester,
        Form(
          key: formKey,
          child: DsTextField(
            label: 'Email',
            errorText: 'Enter a valid email',
            validator: (_) => 'Email is required',
          ),
        ),
        shotKey: shotKey,
      );

      formKey.currentState!.validate();
      // One frame to rebuild with the validator's message, then a longer one
      // to let the decoration's error fade-in finish before capturing.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // The decorator owns the single caption slot: while the validator is
      // failing its message replaces the errorText prop, so the user sees
      // exactly one error message for the field.
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Enter a valid email'), findsNothing);
      // The message must also be fully painted, not just laid out.
      final FadeTransition fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.text('Email is required'),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, 1.0);
      await saveShot(tester, shotKey, 'textfield_double_error');
    });

    testWidgets('helperText is suppressed while a validator error shows',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpProbe(
        tester,
        Form(
          key: formKey,
          child: DsTextField(
            label: 'Email',
            helperText: 'We never share it.',
            validator: (_) => 'Email is required',
          ),
        ),
      );

      formKey.currentState!.validate();
      // Let the decorator's helper-to-error fade finish: the outgoing helper
      // stays in the tree until the transition completes.
      await tester.pumpAndSettle();

      // The decorator shows the helper only while no error shows, so the
      // field never mixes guidance with an error.
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('We never share it.'), findsNothing);
    });

    testWidgets('optional marker and a required validator render a '
        'contradiction without any guard', (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpProbe(
        tester,
        Form(
          key: formKey,
          child: DsTextField(
            label: 'Company',
            optional: true,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Company is required' : null,
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      // BUG (API guard): the field happily shows Optional above a required
      // error. An assert (or documentation) should rule the pairing out.
      expect(find.text('Optional'), findsOneWidget);
      expect(find.text('Company is required'), findsOneWidget);
    });

    testWidgets('maxLength counter, an error and 2x text scale fit at 320dp',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpProbe(
        tester,
        DsTextField(
          label: 'Code',
          controller: controller,
          maxLength: 4,
          errorText: 'Code not recognised',
        ),
        surfaceSize: const Size(320, 900),
        textScale: 2.0,
      );

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      expect(controller.text, '1234');
      expect(find.text('4/4'), findsOneWidget);
      expect(find.text('Code not recognised'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('inputFormatters rejecting everything leave the field empty '
        'and fire no onChanged', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final List<String> changes = <String>[];
      await pumpProbe(
        tester,
        DsTextField(
          label: 'Blocked',
          controller: controller,
          onChanged: changes.add,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp('.'))],
        ),
      );

      await tester.enterText(find.byType(TextField), 'hello world 123');
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(changes, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a 100-char email fits a 320dp single-line field',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpProbe(
        tester,
        DsTextField(label: 'Email', controller: controller),
        surfaceSize: const Size(320, 640),
      );

      await tester.enterText(find.byType(TextField), longEmail);
      await tester.pump();
      expect(controller.text.length, 100);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adding errorText while focused keeps focus in the field',
        (tester) async {
      String? error;
      late StateSetter rebuild;
      await pumpProbe(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return DsTextField(label: 'Email', errorText: error);
          },
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(_focusIsInside<TextField>(tester), isTrue);

      rebuild(() => error = 'Enter a valid email');
      await tester.pump();
      expect(_focusIsInside<TextField>(tester), isTrue);
      expect(find.text('Enter a valid email'), findsOneWidget);
    });
  });

  group('DsFieldLabel edges', () {
    testWidgets('a 300-char label with the optional marker wraps at 320dp '
        'and 2x scale without overflow', (tester) async {
      await pumpProbe(
        tester,
        DsFieldLabel(label: longGermanWord, optional: true),
        surfaceSize: const Size(320, 900),
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Optional'), findsOneWidget);
    });
  });

  group('theme sweep', () {
    Widget allControls() {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DsButton(label: 'Saving', pending: true, fullWidth: true),
            DsIconButton(
              icon: Icons.close,
              semanticLabel: 'Close',
              onPressed: () {},
            ),
            DsCheckbox(
              value: true,
              onChanged: (_) {},
              label: 'Accept terms',
              errorText: 'You must accept the terms',
            ),
            DsSwitch(value: true, label: 'Email alerts', onChanged: (_) {}),
            const DsSpinner(label: 'Loading results'),
            DsLink(label: 'Open the docs', external: true, onPressed: () {}),
            const DsTextField(
              label: 'Email',
              optional: true,
              helperText: 'We never share it.',
              maxLength: 60,
            ),
            const DsFieldLabel(label: 'Bespoke control', optional: true),
          ],
        ),
      );
    }

    testWidgets('every control renders on the dark theme at 320dp and 1.3x',
        (tester) async {
      await pumpProbe(
        tester,
        allControls(),
        theme: DsTheme.dark(),
        surfaceSize: const Size(320, 900),
        textScale: 1.3,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('every control renders on the Engen light skin at 320dp and '
        '1.3x', (tester) async {
      await pumpProbe(
        tester,
        allControls(),
        theme: DsTheme.light(tokens: DsSkins.engenLight()),
        surfaceSize: const Size(320, 900),
        textScale: 1.3,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
