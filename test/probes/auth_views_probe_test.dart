// Probe tests for DsSignUpView and DsSignInView, the auth organisms.
//
// These probes target the edges the component tests do not cover: very long
// content, 320dp and short viewports, 1.3x and 2x text scale, dark and Engen
// themes, reduced motion, keyboard-only operation, rapid state flapping,
// disposal mid-animation and semantics. A probe that demonstrates a defect
// asserts the CURRENT behaviour and carries a // BUG comment so the suite
// stays green while the defect is on record.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _shotDir =
    '/private/tmp/claude-501/-Users-jessica-mclaren-Code-Design-System/f87ea458-8d16-4535-8814-86f674a8cb0f/scratchpad';

const Key _shotKey = Key('auth-views-probe-shot');

/// A 300-character German compound word, no break opportunities at all.
final String _longGermanWord =
    ('Kraftfahrzeughaftpflichtversicherungsanmeldungsbestaetigung'
            'Donaudampfschifffahrtsgesellschaftskapitaensanwaerterposten')
        .padRight(1, '') *
        3;

/// A 100-character email address.
final String _longEmail = '${'a' * 88}@example.com';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(800, 900),
  ThemeData? theme,
  double textScale = 1.0,
  bool disableAnimations = false,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? DsTheme.light(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: Scaffold(
            body: RepaintBoundary(key: _shotKey, child: child),
          ),
        ),
      ),
    ),
  );
}

/// Saves the pumped surface as a PNG in the scratchpad. Must run after a pump.
Future<void> _saveShot(WidgetTester tester, String name) async {
  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(_shotKey));
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_shotDir/auth_views_$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// The glyph boxes of a text widget, in global coordinates. Unlike the render
/// box rect these describe where ink is actually painted.
List<Rect> _glyphRects(WidgetTester tester, Finder textFinder) {
  final paragraph = tester.renderObject(textFinder) as RenderParagraph;
  final plain = paragraph.text.toPlainText();
  final transform = paragraph.getTransformTo(null);
  return paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: plain.length),
      )
      .map((b) => MatrixUtils.transformRect(transform, b.toRect()))
      .toList();
}

/// The visible 40dp circle of the corner close button (its render box is the
/// padded 48dp tap target with the circle centred inside).
Rect _closeVisibleRect(WidgetTester tester) {
  final target = tester.getRect(find.byType(IconButton));
  return Rect.fromCenter(center: target.center, width: 40, height: 40);
}

bool _meaningfullyIntersects(Rect a, Rect b) {
  final r = a.intersect(b);
  return r.width > 1 && r.height > 1;
}

/// Names the control that currently holds primary focus, for traversal order
/// probes. The composition under test must avoid nested ambiguous controls.
String _focusedControl() {
  final BuildContext? context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return 'none';
  if (context.findAncestorWidgetOfExactType<IconButton>() != null) {
    return 'close';
  }
  final field = context.findAncestorWidgetOfExactType<TextField>();
  if (field != null) return 'field:${field.decoration?.hintText ?? ''}';
  if (context.findAncestorWidgetOfExactType<FilledButton>() != null) {
    return 'submit';
  }
  final link = context.findAncestorWidgetOfExactType<DsLink>();
  if (link != null) return 'link:${link.label}';
  return context.widget.runtimeType.toString();
}

/// Collects a node and every descendant.
List<SemanticsNode> _descendants(SemanticsNode root) {
  final nodes = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    nodes.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(root);
  return nodes;
}

/// WCAG relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// WCAG contrast ratio (1..21).
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Matches the sign-in footer band by its structural signature, a container
/// whose border is drawn on the top edge only. The card body uses Border.all,
/// so this cannot match it.
bool _isFooterBand(Widget w) {
  if (w is! Container) return false;
  final decoration = w.decoration;
  if (decoration is! BoxDecoration) return false;
  final border = decoration.border;
  return border is Border &&
      border.top != BorderSide.none &&
      border.bottom == BorderSide.none &&
      border.left == BorderSide.none &&
      border.right == BorderSide.none;
}

/// Flattens [over] (possibly translucent) onto an opaque [under].
Color _flatten(Color over, Color under) {
  final a = over.a;
  return Color.from(
    alpha: 1,
    red: over.r * a + under.r * (1 - a),
    green: over.g * a + under.g * (1 - a),
    blue: over.b * a + under.b * (1 - a),
  );
}

DsSignUpView _signUp({
  String title = 'Create your account',
  String? description,
  Widget? header,
  DsHeadingAlignment headingAlignment = DsHeadingAlignment.start,
  Widget? aboveForm,
  Widget form = const SizedBox(height: 80),
  String primaryActionLabel = 'Create account',
  VoidCallback? onSubmit,
  bool submitPending = false,
  Widget? footer,
  Widget? aside,
  VoidCallback? onClose,
}) {
  return DsSignUpView(
    title: title,
    description: description,
    header: header,
    headingAlignment: headingAlignment,
    aboveForm: aboveForm,
    form: form,
    primaryActionLabel: primaryActionLabel,
    onSubmit: onSubmit,
    submitPending: submitPending,
    footer: footer,
    aside: aside,
    onClose: onClose,
  );
}

void main() {
  group('DsSignUpView probes', () {
    testWidgets('corner close button presents a 48dp tap target and its '
        'corners route taps', (tester) async {
      var closed = 0;
      await _pump(
        tester,
        _signUp(onSubmit: () {}, onClose: () => closed++),
        size: const Size(320, 800),
      );

      final target = tester.getSize(find.byType(IconButton));
      expect(target.width, greaterThanOrEqualTo(48));
      expect(target.height, greaterThanOrEqualTo(48));

      // A tap just inside the padded corner must still reach the button.
      final rect = tester.getRect(find.byType(IconButton));
      await tester.tapAt(rect.topLeft + const Offset(2, 2));
      await tester.pump();
      await tester.tapAt(rect.bottomRight - const Offset(2, 2));
      await tester.pump();
      expect(closed, 2);
    });

    testWidgets('start-aligned title stays clear of the corner close button',
        (tester) async {
      // The heading block gives up its trailing edge to the close affordance,
      // so even a title long enough to fill the card cannot paint glyphs
      // under the icon.
      await _pump(
        tester,
        _signUp(
          title: 'Kraftfahrzeugflottenverwaltungskonto anlegen',
          onSubmit: () {},
          onClose: () {},
        ),
        size: const Size(320, 800),
      );

      final close = _closeVisibleRect(tester);
      final overlap = _glyphRects(
        tester,
        find.text('Kraftfahrzeugflottenverwaltungskonto anlegen'),
      ).any((glyphs) => _meaningfullyIntersects(glyphs, close));

      expect(overlap, isFalse);
      await _saveShot(tester, 'signup_title_clears_close');
    });

    testWidgets(
        'demo composition (wordmark header, centred heading, close, aside) '
        'stacks the aside below the card at 320dp and 2x text scale',
        (tester) async {
      await _pump(
        tester,
        _signUp(
          header: const DsWordmark(primary: 'acme', accent: 'id', fontSize: 28),
          headingAlignment: DsHeadingAlignment.center,
          title: 'Seconds to sign up',
          aboveForm: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Already have an account?'),
              DsLink(label: 'Sign in', onPressed: () {}),
            ],
          ),
          onSubmit: () {},
          onClose: () {},
          footer: const Text('Terms apply'),
          aside: const Text('Benefits panel'),
        ),
        size: const Size(320, 900),
        textScale: 2.0,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      // The aside must stack beneath the primary action, never beside it.
      final asideFinder = find.text('Benefits panel');
      await tester.ensureVisible(asideFinder);
      await tester.pump();
      expect(
        tester.getTopLeft(asideFinder).dy,
        greaterThan(tester.getBottomLeft(find.byType(DsButton)).dy),
      );

      // Record whether the centred wordmark collides with the close button.
      // The wordmark is a Text.rich with a semantics label, so the paragraph
      // is its RichText descendant.
      final close = _closeVisibleRect(tester);
      final wordmarkText = find
          .descendant(of: find.byType(DsWordmark), matching: find.byType(RichText))
          .first;
      final wordmarkHitsClose = _glyphRects(tester, wordmarkText)
          .any((r) => _meaningfullyIntersects(r, close));
      expect(wordmarkHitsClose, isFalse,
          reason: 'centred wordmark should clear the close button at 2x');
    });

    testWidgets('300-character centred title does not overflow at 320dp, '
        'at 1x and 2x scale', (tester) async {
      final title = _longGermanWord.substring(0, 300);
      for (final scale in [1.0, 2.0]) {
        await _pump(
          tester,
          _signUp(
            title: title,
            headingAlignment: DsHeadingAlignment.center,
            onSubmit: () {},
            onClose: () {},
          ),
          size: const Size(320, 600),
          textScale: scale,
        );
        await tester.pump();
        expect(tester.takeException(), isNull,
            reason: '300-char title must hard-wrap at ${scale}x');
      }
    });

    testWidgets('every field in error at once fits a 320dp phone',
        (tester) async {
      await _pump(
        tester,
        _signUp(
          header: const DsWordmark(primary: 'acme', accent: 'id', fontSize: 28),
          headingAlignment: DsHeadingAlignment.center,
          title: 'Seconds to sign up',
          form: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              DsFormFieldGroup(
                children: [
                  DsTextField(hintText: 'Name', errorText: 'Enter your name.'),
                  DsTextField(
                      hintText: 'Surname', errorText: 'Enter your surname.'),
                ],
              ),
              SizedBox(height: DsSpacing.lg),
              DsTextField(
                hintText: 'Company name',
                errorText: 'Enter your company name.',
              ),
              SizedBox(height: DsSpacing.lg),
              DsTextField(
                hintText: 'Work email',
                errorText: 'This email is invalid',
              ),
              SizedBox(height: DsSpacing.lg),
              DsPasswordField(
                hintText: 'Password',
                errorText: 'Use at least 12 characters.',
              ),
            ],
          ),
          onSubmit: null,
          onClose: () {},
        ),
        size: const Size(320, 700),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Each error is present, and the disabled submit stays rendered.
      expect(find.text('Enter your name.'), findsOneWidget);
      expect(find.text('Enter your surname.'), findsOneWidget);
      expect(find.text('This email is invalid'), findsOneWidget);
      await tester.ensureVisible(find.byType(DsButton));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a 100-character email does not overflow a 320dp card',
        (tester) async {
      final controller = TextEditingController(text: _longEmail);
      addTearDown(controller.dispose);
      await _pump(
        tester,
        _signUp(
          form: DsTextField(hintText: 'Work email', controller: controller),
          onSubmit: () {},
        ),
        size: const Size(320, 700),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('submitPending with onSubmit null shows a busy, disabled '
        'button and taps are no-ops', (tester) async {
      await _pump(
        tester,
        _signUp(onSubmit: null, submitPending: true),
        size: const Size(400, 800),
      );

      expect(find.byType(DsSpinner), findsOneWidget);
      await tester.tap(find.byType(DsButton), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);

      final handle = tester.ensureSemantics();
      final node = tester.getSemantics(find.byType(DsButton));
      expect(
        node,
        isSemantics(
          isButton: true,
          isEnabled: false,
          label: 'Create account, busy',
        ),
      );
      handle.dispose();
    });

    testWidgets('pending spinner sits on the enabled fill and holds the '
        '3:1 graphic contrast in the default light theme', (tester) async {
      await _pump(
        tester,
        _signUp(onSubmit: () {}, submitPending: true),
      );

      final tokens = DsTokens.of(tester.element(find.byType(DsSignUpView)));
      // While pending the button is busy, not disabled: it keeps the enabled
      // background so the variant-coloured spinner clears the 3:1 non-text
      // minimum.
      final fill = _flatten(
        tokens.buttonPrimaryColorBackground,
        tokens.formBackgroundColor,
      );
      final spinner = tester.widget<DsSpinner>(find.byType(DsSpinner));
      final ratio = _contrast(spinner.color!, fill);
      expect(ratio, greaterThanOrEqualTo(3.0));

      final engen = DsSkins.engenLight();
      final engenFill = _flatten(
        engen.buttonPrimaryColorBackground,
        engen.formBackgroundColor,
      );
      expect(
        _contrast(engen.buttonPrimaryColorText, engenFill),
        greaterThanOrEqualTo(3.0),
      );
    });

    testWidgets('reduced motion: the pending spinner is static and the view '
        'settles', (tester) async {
      await _pump(
        tester,
        _signUp(onSubmit: () {}, submitPending: true),
        disableAnimations: true,
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, isNotNull,
          reason: 'the spinner must not spin under reduced motion');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('tab traversal reaches the close button before the form and '
        'Enter and Space both activate it', (tester) async {
      var closed = 0;
      await _pump(
        tester,
        _signUp(
          aboveForm: DsLink(label: 'Sign in instead', onPressed: () {}),
          form: const Column(
            children: [
              DsTextField(hintText: 'Name'),
              SizedBox(height: DsSpacing.lg),
              DsTextField(hintText: 'Work email'),
            ],
          ),
          onSubmit: () {},
          footer: DsLink(label: 'Terms', onPressed: () {}),
          onClose: () => closed++,
        ),
        size: const Size(600, 900),
      );

      final order = <String>[];
      for (var i = 0; i < 6; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        order.add(_focusedControl());
      }
      expect(
        order,
        [
          'close',
          'link:Sign in instead',
          'field:Name',
          'field:Work email',
          'submit',
          'link:Terms',
        ],
        reason: 'reading-order traversal: corner close first, then the body '
            'top to bottom',
      );

      // One more Tab wraps around to the close button; activate it from the
      // keyboard.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedControl(), 'close');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(closed, 2);
    });

    testWidgets('submitPending flapped every frame never throws',
        (tester) async {
      var pending = false;
      late StateSetter setSt;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, set) {
            setSt = set;
            return _signUp(
              onSubmit: pending ? null : () {},
              submitPending: pending,
            );
          },
        ),
      );

      for (var i = 0; i < 24; i++) {
        setSt(() => pending = !pending);
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: 'flap $i');
      }
      setSt(() => pending = false);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(DsSpinner), findsNothing);
    });

    testWidgets('disposal mid-animation: spring-back and a held press both '
        'survive', (tester) async {
      await _pump(tester, _signUp(onSubmit: () {}));

      // Held press: the scale-down animation is running.
      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(DsButton)));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      // Spring-back is now in flight; dispose the whole view under it.
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);

      // And once more with the pointer still down at disposal time. The
      // button's states listener must not look up MediaQuery through the
      // deactivated element, so disposing the view mid-press (a route popping
      // under the user's finger) raises no framework error.
      await _pump(tester, _signUp(onSubmit: () {}));
      final held =
          await tester.startGesture(tester.getCenter(find.byType(DsButton)));
      await tester.pump(const Duration(milliseconds: 40));
      await tester.pumpWidget(const SizedBox());
      await held.up();
      expect(tester.takeException(), isNull);
    });

    testWidgets('semantics: title is a header, every tappable node is named '
        'and no live region is left behind', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _signUp(
          aboveForm: DsLink(label: 'Sign in instead', onPressed: () {}),
          form: const DsTextField(hintText: 'Work email'),
          onSubmit: () {},
          submitPending: true,
          footer: DsLink(label: 'Terms', onPressed: () {}),
          onClose: () {},
        ),
      );

      expect(
        tester.getSemantics(find.text('Create your account')),
        isSemantics(isHeader: true),
      );
      // The close button carries its name as a tooltip rather than a label;
      // assistive technology reads the tooltip when no label is present.
      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(isButton: true, hasTapAction: true, tooltip: 'Close'),
      );

      final nodes =
          _descendants(tester.getSemantics(find.byType(DsSignUpView)));
      final unnamedTappable = nodes.where((node) {
        final data = node.getSemanticsData();
        if (!data.hasAction(SemanticsAction.tap)) return false;
        if (data.flagsCollection.isTextField) return false;
        return data.label.isEmpty &&
            data.value.isEmpty &&
            data.hint.isEmpty &&
            data.tooltip.isEmpty;
      });
      expect(unnamedTappable, isEmpty,
          reason: 'every tappable node must have an accessible name');

      final liveRegions = nodes.where(
        (n) => n.getSemanticsData().flagsCollection.isLiveRegion,
      );
      expect(liveRegions, isEmpty,
          reason: 'the pending spinner must not leave an orphan live region');
      handle.dispose();
    });
  });

  group('DsSignInView probes', () {
    DsSignInView signIn({
      String title = 'Sign in to your account',
      String? description,
      DsHeadingAlignment headingAlignment = DsHeadingAlignment.start,
      Widget? form,
      Widget? footer,
      Widget? footerBand,
      String? additionalContextLabel,
      Widget? additionalContext,
      VoidCallback? onClose,
      VoidCallback? onPressed,
    }) {
      return DsSignInView(
        title: title,
        description: description,
        headingAlignment: headingAlignment,
        form: form,
        primaryAction:
            DsSignInAction(label: 'Sign in', onPressed: onPressed ?? () {}),
        footer: footer,
        footerBand: footerBand,
        additionalContextLabel: additionalContextLabel,
        additionalContext: additionalContext,
        onClose: onClose,
      );
    }

    testWidgets('start-aligned title at 2x stays clear of the close button '
        'at 320dp', (tester) async {
      await _pump(
        tester,
        signIn(onClose: () {}),
        size: const Size(320, 800),
        textScale: 2.0,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      final close = _closeVisibleRect(tester);
      final overlap = _glyphRects(
        tester,
        find.text('Sign in to your account'),
      ).any((r) => _meaningfullyIntersects(r, close));

      // The heading block is inset at its trailing edge while the close
      // button is shown, so even at 2x on a small phone the first line wraps
      // before the icon instead of colliding with it.
      expect(overlap, isFalse);
      await _saveShot(tester, 'signin_title_clears_close_2x');
    });

    testWidgets('footer band swallows a very long prompt at 320dp',
        (tester) async {
      final prompt = 'New here? Creating an account takes less than a minute '
          'and brings your fleet, billing and driver records together in one '
          'place with no card required for the first fourteen days.';
      await _pump(
        tester,
        signIn(
          footerBand: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(prompt),
              DsLink(label: 'Create an account', onPressed: () {}),
            ],
          ),
        ),
        size: const Size(320, 800),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text(prompt));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('description null with footerBand and expanded '
        'additionalContext coexist at 320dp', (tester) async {
      await _pump(
        tester,
        signIn(
          headingAlignment: DsHeadingAlignment.center,
          additionalContextLabel: 'More sign-in options',
          additionalContext: const Text('Use your enterprise identity.'),
          footerBand: const Text('New here? Create an account.'),
        ),
        size: const Size(320, 600),
      );

      expect(find.text('Use your enterprise identity.'), findsNothing);
      await tester.ensureVisible(find.text('More sign-in options'));
      await tester.pump();
      await tester.tap(find.text('More sign-in options'));
      await tester.pump();
      expect(find.text('Use your enterprise identity.'), findsOneWidget);
      expect(find.text('New here? Create an account.'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // The expanded context must sit above the band, inside the body.
      await tester.ensureVisible(find.text('New here? Create an account.'));
      await tester.pump();
      expect(
        tester.getTopLeft(find.text('New here? Create an account.')).dy,
        greaterThan(
          tester.getBottomLeft(find.text('Use your enterprise identity.')).dy,
        ),
      );
    });

    testWidgets('a reveal label without content toggles harmlessly',
        (tester) async {
      await _pump(
        tester,
        signIn(additionalContextLabel: 'More options'),
      );
      await tester.tap(find.text('More options'));
      await tester.pump();
      await tester.tap(find.text('More options'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('reveal control flapped every frame never throws',
        (tester) async {
      await _pump(
        tester,
        signIn(
          additionalContextLabel: 'More options',
          additionalContext: const Text('Enterprise SSO.'),
        ),
      );
      for (var i = 0; i < 12; i++) {
        await tester.tap(find.text('More options'));
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: 'flap $i');
      }
    });

    testWidgets('reveal control announces its role, name and expanded state '
        'on one node', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        signIn(
          additionalContextLabel: 'More options',
          additionalContext: const Text('Enterprise SSO.'),
        ),
      );

      expect(
        tester.getSemantics(find.text('More options')),
        isSemantics(
          isButton: true,
          hasTapAction: true,
          hasExpandedState: true,
          isExpanded: false,
          label: 'More options',
        ),
      );

      await tester.tap(find.text('More options'));
      await tester.pump();
      expect(
        tester.getSemantics(find.text('More options')),
        isSemantics(isExpanded: true),
      );
      handle.dispose();
    });

    testWidgets('sign-in title carries header semantics, matching sign-up',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, signIn());

      // Both auth views mark their title as a header for assistive
      // technology, so screen reader users can jump to the heading.
      expect(
        tester.getSemantics(find.text('Sign in to your account')),
        isSemantics(isHeader: true),
      );
      handle.dispose();
    });

    testWidgets('demo composition holds at 320dp under 1.3x and 2x scale',
        (tester) async {
      for (final scale in [1.3, 2.0]) {
        final email = TextEditingController(text: _longEmail);
        final password = TextEditingController(text: 'correct-horse-battery');
        addTearDown(email.dispose);
        addTearDown(password.dispose);
        await _pump(
          tester,
          signIn(
            form: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DsTextField(
                  label: 'Email',
                  hintText: 'you@company.com',
                  controller: email,
                ),
                const SizedBox(height: DsSpacing.lg),
                // Mirrors the fixed sign-in demo: both halves of the label
                // row are flexible, so the row holds 320dp at a 2x scale.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: DefaultTextStyle.merge(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: const DsFieldLabel(label: 'Password'),
                      ),
                    ),
                    const SizedBox(width: DsSpacing.sm),
                    Flexible(
                      child: DsLink(
                        label: 'Forgot your password?',
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DsSpacing.xs),
                DsPasswordField(controller: password),
                const SizedBox(height: DsSpacing.md),
                DsCheckbox(
                  value: true,
                  onChanged: (_) {},
                  label: 'Remember me on this device',
                ),
              ],
            ),
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const DsLabeledDivider(label: 'Or sign in with'),
                const SizedBox(height: DsSpacing.lg),
                DsButton.social(
                  icon: DsIcons.web,
                  label: 'Google',
                  onPressed: () {},
                ),
              ],
            ),
            footerBand: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text('New here? '),
                DsLink(label: 'Create an account', onPressed: () {}),
              ],
            ),
          ),
          size: const Size(320, 800),
          textScale: scale,
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'scale ${scale}x');
      }
    });

    testWidgets('footer band tint holds text contrast in dark and Engen',
        (tester) async {
      // The band renders colorSecondaryText and links over
      // offsetBackgroundColor. Both must stay AA in every shipped theme.
      final themes = <String, DsTokens>{
        'light': DsTokens.light(),
        'dark': DsTokens.dark(),
        'engenLight': DsSkins.engenLight(),
        'engenDark': DsSkins.engenDark(),
      };
      themes.forEach((name, t) {
        expect(
          _contrast(t.colorSecondaryText, t.offsetBackgroundColor),
          greaterThanOrEqualTo(4.5),
          reason: '$name: secondary text on the band tint',
        );
        expect(
          _contrast(t.actionPrimaryColorText, t.offsetBackgroundColor),
          greaterThanOrEqualTo(4.5),
          reason: '$name: link text on the band tint',
        );
      });

      // The band's top border is drawn with the standard border tier, not
      // the subtle hairline: in the Engen light skin the hairline sits below
      // 1.1:1 against the band tint, so it would vanish exactly where the
      // band needs an edge. The standard tier reads against the tint.
      final engen = DsSkins.engenLight();
      expect(
        _contrast(engen.colorBorder, engen.offsetBackgroundColor),
        greaterThan(
          _contrast(engen.colorBorderSubtle, engen.offsetBackgroundColor),
        ),
      );

      // The band actually renders in both non-default themes without error,
      // and its top border uses colorBorder in each.
      for (final theme in [
        DsTheme.dark(),
        DsTheme.light(tokens: DsSkins.engenLight()),
      ]) {
        await _pump(
          tester,
          signIn(footerBand: const Text('New here? Create an account.')),
          theme: theme,
          size: const Size(400, 700),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('New here? Create an account.'), findsOneWidget);

        final tokens = DsTokens.of(tester.element(find.byType(DsSignInView)));
        final decoration = tester
            .widget<Container>(find.byWidgetPredicate(_isFooterBand))
            .decoration! as BoxDecoration;
        expect((decoration.border! as Border).top.color, tokens.colorBorder);
      }
    });
  });
}
