// Probe tests for DsPasswordStrength (model + widgets) and DsPasswordField.
//
// These probes target edges the component tests do not cover: unicode and
// emoji input, whitespace, 10k-character values, tier boundaries, 320dp with
// a 2x text scale, unbounded and very narrow widths, dark and skinned themes,
// reduced motion, keyboard-only operation, rapid flapping, disposal mid
// animation and semantics. The defects these probes originally pinned have
// been fixed, so every probe now asserts the correct behaviour.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _shotDir =
    '/private/tmp/claude-501/-Users-jessica-mclaren-Code-Design-System/'
    'f87ea458-8d16-4535-8814-86f674a8cb0f/scratchpad';

const Key _boundaryKey = Key('probe-boundary');

/// Pumps [child] inside a Design System [MaterialApp] with full control over
/// viewport, theme, text scale and reduced motion, wrapped in a
/// [RepaintBoundary] so probes can capture screenshots.
Future<void> pumpProbe(
  WidgetTester tester,
  Widget child, {
  Size? surfaceSize,
  ThemeData? theme,
  double textScale = 1.0,
  bool disableAnimations = false,
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
        body: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: disableAnimations,
            ),
            child: Center(
              child: RepaintBoundary(key: _boundaryKey, child: child),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Captures the probe boundary to a PNG under the scratchpad directory.
Future<void> saveShot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_boundaryKey),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_shotDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

/// The containers that make up the meter bar.
Finder _meterSegments() => find.descendant(
  of: find.descendant(
    of: find.byType(DsPasswordStrength),
    matching: find.byType(ExcludeSemantics),
  ),
  matching: find.byType(Container),
);

int _segmentsPainted(WidgetTester tester, Color color) => tester
    .widgetList<Container>(_meterSegments())
    .where((c) => (c.decoration as BoxDecoration?)?.color == color)
    .length;

/// A 300-character German compound password (ASCII plus umlauts).
final String longGermanWord =
    '${('Rindfleischetikettierungsueberwachungsaufgabenuebertragungsgesetz' * 5).substring(0, 299)}1';

void main() {
  group('model: unicode and whitespace', () {
    test(
      'Cyrillic capitals are recognised as uppercase and letters never '
      'count as special characters',
      () {
        // 'Пароль12' has a capital П, lowercase 'ароль' and two digits. The
        // unicode-aware classes recognise both letter cases, and the special
        // character rule (neither letter nor number) rejects every letter.
        final rules = dsPasswordRules('Пароль12');
        expect(rules[0].met, isTrue, reason: '8 characters');
        expect(rules[1].met, isTrue, reason: 'П is an uppercase letter');
        expect(rules[2].met, isTrue, reason: "'ароль' is lowercase");
        expect(rules[3].met, isTrue, reason: 'digits');
        expect(
          rules[4].met,
          isFalse,
          reason: 'letters and digits are not special characters',
        );
      },
    );

    test(
      'the model is consistent for an all-Cyrillic password',
      () {
        // Four rules met (length, uppercase, lowercase, number) clears the
        // gate, and the caption agrees with the checklist: the one missing
        // class is a special character.
        expect(dsPasswordTier('Пароль12'), DsPasswordTier.weak);
        expect(
          dsFirstUnmetPasswordRule('Пароль12'),
          'Please use at least one special character',
        );
      },
    );

    test('length rule counts grapheme clusters, not UTF-16 code units', () {
      // Four emoji are eight code units but four user-perceived characters,
      // so a four-glyph password does not pass the "At least 8 characters"
      // rule. The tier length thresholds count the same way.
      expect('😀😀😀😀'.length, 8);
      expect(dsPasswordRules('😀😀😀😀')[0].met, isFalse);
      expect(dsPasswordRules('😀😀😀😀' * 2)[0].met, isTrue);
    });

    test('emoji satisfy only the special character rule', () {
      final rules = dsPasswordRules('😀😀😀😀');
      expect(rules[1].met, isFalse);
      expect(rules[2].met, isFalse);
      expect(rules[3].met, isFalse);
      expect(rules[4].met, isTrue);
      expect(dsPasswordTier('😀😀😀😀'), DsPasswordTier.tooWeak);
    });

    test('whitespace-only input is not treated as empty', () {
      // Documented behaviour: whitespace is a character like any other, so
      // eight spaces pass the length rule and the special character rule.
      // The gate still holds (only two rules met), and the caption asks for
      // a capital letter rather than saying the password is required.
      final rules = dsPasswordRules('        ');
      expect(rules[0].met, isTrue);
      expect(rules[4].met, isTrue);
      expect(dsPasswordTier('        '), DsPasswordTier.tooWeak);
      expect(
        dsFirstUnmetPasswordRule('        '),
        'Please use at least one capital letter',
      );
    });
  });

  group('model: tier boundaries and brand words', () {
    test('tier flips exactly between 7 and 8 characters with all classes', () {
      expect(dsPasswordTier('Aa1!Aa1'), DsPasswordTier.tooWeak); // 7 chars
      expect(dsPasswordTier('Aa1!Aa1!'), DsPasswordTier.fair); // 8 chars
    });

    test('length score steps flip exactly at 12 and 16', () {
      expect(dsPasswordTier('Aa1!Aa1!Aa1'), DsPasswordTier.fair); // 11
      expect(dsPasswordTier('Aa1!Aa1!Aa1!'), DsPasswordTier.good); // 12
      expect(dsPasswordTier('Aa1!Aa1!Aa1!Aa1'), DsPasswordTier.good); // 15
      expect(dsPasswordTier('Aa1!Aa1!Aa1!Aa1!'), DsPasswordTier.strong); // 16
    });

    test('guessable recovery flips exactly at 14 characters', () {
      // Common word, all five rules met.
      expect(dsPasswordTier('Password1!xyz'), DsPasswordTier.tooWeak); // 13
      expect(dsPasswordTier('Password1!xyzA'), DsPasswordTier.weak); // 14
    });

    test('brand words match case-insensitively with unicode accents', () {
      expect(
        dsPasswordTier('xcafé19!Abzq', brandWords: {'CAFÉ'}),
        DsPasswordTier.tooWeak,
      );
    });

    test(
      'brand words need spelling variants listed for locale case-folding '
      'pairs such as straße and STRASSE',
      () {
        // Documented behaviour: matching lowercases both sides, which cannot
        // round-trip locale-specific uppercasings. 'STRASSE' lowercases to
        // 'strasse', which does not contain 'straße', so brands are told to
        // list both spellings as separate entries.
        expect(
          dsPasswordTier('xSTRASSE19!ab', brandWords: {'straße'}),
          DsPasswordTier.good,
        );
        // The variant spelt with ss is caught.
        expect(
          dsPasswordTier('xSTRASSE19!ab', brandWords: {'strasse'}),
          DsPasswordTier.tooWeak,
        );
        // Listing both variants covers either way the user types it.
        expect(
          dsPasswordTier('xSTRASSE19!ab', brandWords: {'straße', 'strasse'}),
          DsPasswordTier.tooWeak,
        );
      },
    );
  });

  group('model: performance', () {
    test('10k-character input grades quickly enough for per-keystroke use',
        () {
      final long = 'Aa1!' * 2500; // 10,000 characters
      // Warm up.
      dsPasswordTier(long);
      final sw = Stopwatch()..start();
      for (var i = 0; i < 200; i++) {
        dsPasswordRules(long);
        dsFirstUnmetPasswordRule(long);
        dsPasswordTier(long, brandWords: {'engen', 'acme'});
      }
      sw.stop();
      // 200 simulated keystrokes should stay well under 4 seconds even on a
      // slow CI machine; a pathological regex would blow far past this.
      expect(sw.elapsedMilliseconds, lessThan(4000));
    });

    test('10k letters with no digit does not trigger regex backtracking',
        () {
      final letters = 'aB' * 5000;
      final sw = Stopwatch()..start();
      dsPasswordTier(letters);
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('DsPasswordStrength widget: layout edges', () {
    testWidgets(
      'fits a 320x640 viewport at a 2x text scale by collapsing to one '
      'column',
      (tester) async {
        await pumpProbe(
          tester,
          const DsPasswordStrength(value: 'Aa1!aaaa'),
          surfaceSize: const Size(320, 640),
          textScale: 2.0,
        );
        await tester.pump();
        // At 320dp with a 2x accessibility text scale each two-column item
        // would be far too narrow for a rule label, so the checklist falls
        // back to a single column and the readout stays flat. See
        // password_checklist_320_scale2.png.
        expect(tester.takeException(), isNull);
        await saveShot(tester, 'password_checklist_320_scale2');
      },
    );

    testWidgets(
      'checklist collapses to one column when the scaled item width is too '
      'narrow',
      (tester) async {
        await pumpProbe(
          tester,
          const SingleChildScrollView(
            child: SizedBox(
              width: 320,
              child: DsPasswordStrength(value: 'Aa1!aaaa'),
            ),
          ),
          surfaceSize: const Size(320, 640),
          textScale: 2.0,
        );
        // In a single column every rule label starts at the same x position
        // and spans the full width, rather than wrapping inside a ~128dp
        // sliver, so the whole readout fits a short viewport.
        final starts = <double>{
          for (final rule in dsPasswordRules('Aa1!aaaa'))
            tester.getTopLeft(find.text(rule.label)).dx,
        };
        expect(starts, hasLength(1));
        final total = tester.getSize(find.byType(DsPasswordStrength));
        expect(total.height, lessThan(640));
      },
    );

    testWidgets(
      'unbounded width falls back to a fixed-width readout instead of '
      'crashing',
      (tester) async {
        // In an unbounded-width host (a Row, a horizontal ListView) the
        // whole readout falls back to a fixed width, so the meter's Expanded
        // segments and the rule rows have something to fill.
        await pumpProbe(
          tester,
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[DsPasswordStrength(value: 'Aa1!aaaa')],
          ),
        );
        expect(tester.takeException(), isNull);
        final size = tester.getSize(find.byType(DsPasswordStrength));
        expect(size.width.isFinite, isTrue);
        expect(find.text('Weak'), findsOneWidget);
      },
    );

    testWidgets('checklist rows survive below 64dp of width', (
      tester,
    ) async {
      // At 60dp a two-column item would be narrower than the dot and gap
      // alone, so the checklist collapses to one column and each label wraps
      // within its row instead of overflowing it. The heavily wrapped labels
      // make the readout tall, so the host provides the vertical scrolling,
      // as anywhere else in the library.
      await pumpProbe(
        tester,
        const SingleChildScrollView(
          child: SizedBox(
            width: 60,
            child: DsPasswordStrength(value: 'Aa1!aa'),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a 300-character password value without overflow', (
      tester,
    ) async {
      await pumpProbe(
        tester,
        DsPasswordStrength(value: longGermanWord),
        surfaceSize: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
      // The word+number+symbol penalty only applies up to a 24-letter word,
      // so a 300-character unique compound word ending in a digit is graded
      // on its length and variety (four classes met, 16 plus characters)
      // rather than being pinned to the bottom tier forever.
      expect(find.text('Good'), findsOneWidget);
    });
  });

  group('DsPasswordStrength widget: themes and motion', () {
    testWidgets('dark theme paints the meter from dark tokens', (tester) async {
      await pumpProbe(
        tester,
        const DsPasswordStrength(value: 'Axcr1935!kdz', showChecklist: false),
        theme: DsTheme.dark(),
      );
      final tokens = DsTokens.of(
        tester.element(find.byType(DsPasswordStrength)),
      );
      expect(_segmentsPainted(tester, tokens.colorSuccess), 3);
      expect(find.text('Good'), findsOneWidget);
    });

    testWidgets('engen skin paints the meter from skin tokens', (tester) async {
      await pumpProbe(
        tester,
        const DsPasswordStrength(value: 'Axcr1935!kdz', showChecklist: false),
        theme: DsTheme.light(tokens: DsSkins.engenLight()),
      );
      final tokens = DsTokens.of(
        tester.element(find.byType(DsPasswordStrength)),
      );
      expect(_segmentsPainted(tester, tokens.colorSuccess), 3);
    });

    testWidgets('reduced motion: renders and updates with animations off', (
      tester,
    ) async {
      await pumpProbe(
        tester,
        const DsPasswordStrength(value: 'Aa1!aaaa'),
        disableAnimations: true,
      );
      await pumpProbe(
        tester,
        const DsPasswordStrength(value: 'Axcr1935!kdz'),
        disableAnimations: true,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Good'), findsOneWidget);
    });

    testWidgets('survives a new value every frame across every tier', (
      tester,
    ) async {
      const values = <String>[
        '',
        'a',
        'Aa1!aaaa',
        'Abcd1234!xyz',
        'Axcr1935!kdz',
        'Password1!',
        r'Xk9#mPq2$vLz7!Qw',
      ];
      for (var i = 0; i < 42; i++) {
        await pumpProbe(
          tester,
          DsPasswordStrength(value: values[i % values.length]),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('DsPasswordStrength and hint: semantics', () {
    testWidgets(
      'the strength word is a live region, so tier changes are announced',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpProbe(
          tester,
          const DsPasswordStrength(value: 'Aa1!aaaa', showChecklist: false),
        );
        final node = tester.getSemantics(find.text('Weak'));
        // The meter bar is excluded from semantics; the strength word
        // genuinely carries the state because a screen reader user typing a
        // password hears it change.
        expect(node.flagsCollection.isLiveRegion, isTrue);
        handle.dispose();
      },
    );

    testWidgets(
      'checklist rows expose their met state as a checked flag',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpProbe(tester, const DsPasswordStrength(value: ''));
        final unmet = tester.getSemantics(find.text('One number'));
        final unmetLabel = unmet.label;
        expect(unmet.flagsCollection.isChecked, ui.CheckedState.isFalse);

        await pumpProbe(tester, const DsPasswordStrength(value: 'Aa1!aaaa'));
        final met = tester.getSemantics(find.text('One number'));
        // The label stays the same; the met state is carried by the checked
        // flag, so assistive technology can tell the rows apart.
        expect(met.label, unmetLabel);
        expect(met.flagsCollection.isChecked, ui.CheckedState.isTrue);
        handle.dispose();
      },
    );

    testWidgets(
      'hint is a live region and resizes through AnimatedSize',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpProbe(
          tester,
          const DsPasswordStrengthHint(value: 'Password1!'),
        );
        final visible = tester.getSize(find.byType(DsPasswordStrengthHint));
        expect(visible.height, greaterThan(0));
        final node = tester.getSemantics(
          find.textContaining("isn't strong enough"),
        );
        // An inline warning that swaps in as the user types is announced
        // without stealing focus.
        expect(node.flagsCollection.isLiveRegion, isTrue);
        expect(find.byType(AnimatedSize), findsOneWidget);

        await pumpProbe(
          tester,
          const DsPasswordStrengthHint(value: 'Axcr1935!kdz'),
        );
        // The collapse is animated, so the form below does not jump within a
        // single frame; once settled the hint takes no space.
        await tester.pumpAndSettle();
        final hidden = tester.getSize(find.byType(DsPasswordStrengthHint));
        expect(hidden.height, 0);
        handle.dispose();
      },
    );

    testWidgets(
      'hint collapses in a single frame under reduced motion',
      (tester) async {
        await pumpProbe(
          tester,
          const DsPasswordStrengthHint(value: 'Password1!'),
          disableAnimations: true,
        );
        expect(
          tester.getSize(find.byType(DsPasswordStrengthHint)).height,
          greaterThan(0),
        );
        // Reduced motion skips the AnimatedSize wrapper entirely, so the
        // resize is immediate.
        expect(find.byType(AnimatedSize), findsNothing);
        await pumpProbe(
          tester,
          const DsPasswordStrengthHint(value: 'Axcr1935!kdz'),
          disableAnimations: true,
        );
        expect(tester.getSize(find.byType(DsPasswordStrengthHint)).height, 0);
      },
    );
  });

  group('DsPasswordField: toggle behaviour', () {
    testWidgets('eye toggle preserves text, cursor position and focus', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Passw0rd!');
      addTearDown(controller.dispose);
      await pumpProbe(
        tester,
        DsPasswordField(label: 'Password', controller: controller),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      controller.selection = const TextSelection.collapsed(offset: 4);
      await tester.pump();

      await tester.tap(find.byIcon(DsIcons.visibility));
      await tester.pump();

      expect(controller.text, 'Passw0rd!');
      expect(controller.selection, const TextSelection.collapsed(offset: 4));
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.focusNode.hasFocus, isTrue);
      expect(editable.obscureText, isFalse);

      await tester.tap(find.byIcon(DsIcons.visibilityOff));
      await tester.pump();
      expect(controller.selection, const TextSelection.collapsed(offset: 4));
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );
    });

    testWidgets('eye toggle preserves an active IME composing region', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpProbe(
        tester,
        DsPasswordField(label: 'Password', controller: controller),
      );
      await tester.showKeyboard(find.byType(EditableText));
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'Passwort',
          selection: TextSelection.collapsed(offset: 8),
          composing: TextRange(start: 0, end: 8),
        ),
      );
      await tester.pump();
      expect(controller.value.composing, const TextRange(start: 0, end: 8));

      await tester.tap(find.byIcon(DsIcons.visibility));
      await tester.pump();
      expect(controller.text, 'Passwort');
      expect(controller.value.composing, const TextRange(start: 0, end: 8));
    });

    testWidgets('toggle still works while errorText is set and keeps it', (
      tester,
    ) async {
      await pumpProbe(
        tester,
        const DsPasswordField(
          label: 'Password',
          errorText: 'Wrong password',
        ),
      );
      expect(find.text('Wrong password'), findsOneWidget);
      await tester.tap(find.byIcon(DsIcons.visibility));
      await tester.pump();
      expect(find.byIcon(DsIcons.visibilityOff), findsOneWidget);
      expect(find.text('Wrong password'), findsOneWidget);
    });

    testWidgets(
      'a failing validator wins over errorText, so exactly one error shows',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        await pumpProbe(
          tester,
          Form(
            key: formKey,
            child: DsPasswordField(
              label: 'Password',
              errorText: 'From errorText',
              validator: (_) => 'From validator',
            ),
          ),
        );
        formKey.currentState!.validate();
        await tester.pump();
        // The decorator owns the single caption slot: while the validator is
        // failing its message replaces the errorText prop, so the user never
        // sees two stacked errors.
        expect(find.text('From validator'), findsOneWidget);
        expect(find.text('From errorText'), findsNothing);
      },
    );

    testWidgets(
      'declares password autofill and keeps the value out of the keyboard '
      'suggestion engine',
      (tester) async {
        await pumpProbe(tester, const DsPasswordField(label: 'Password'));
        final field = tester.widget<TextField>(find.byType(TextField));
        // The field declares autofillHints: [AutofillHints.password] so
        // password managers can fill and save it, and turns off autocorrect
        // and suggestions so the value never reaches the keyboard's
        // suggestion engine.
        expect(field.autofillHints, <String>[AutofillHints.password]);
        expect(field.autocorrect, isFalse);
        expect(field.enableSuggestions, isFalse);
      },
    );

    testWidgets(
      'newPassword switches the autofill hint for sign-up flows',
      (tester) async {
        await pumpProbe(
          tester,
          const DsPasswordField(label: 'Password', newPassword: true),
        );
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.autofillHints, <String>[AutofillHints.newPassword]);
      },
    );

    testWidgets('accepts and reveals a 300-character value', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpProbe(
        tester,
        DsPasswordField(label: 'Password', controller: controller),
        surfaceSize: const Size(320, 640),
      );
      await tester.enterText(find.byType(EditableText), longGermanWord);
      await tester.pump();
      expect(controller.text.length, 300);
      await tester.tap(find.byIcon(DsIcons.visibility));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(controller.text, longGermanWord);
    });

    testWidgets('no overflow at 320dp with a 2x scale and a long error', (
      tester,
    ) async {
      await pumpProbe(
        tester,
        const DsPasswordField(
          label: 'Password',
          errorText: 'Use at least 8 characters with upper- and lower-case '
              'letters, a number and a symbol.',
        ),
        surfaceSize: const Size(320, 640),
        textScale: 2.0,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives toggling the eye every frame', (tester) async {
      await pumpProbe(tester, const DsPasswordField(label: 'Password'));
      for (var i = 0; i < 21; i++) {
        final icon = i.isEven ? DsIcons.visibility : DsIcons.visibilityOff;
        await tester.tap(find.byIcon(icon));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.takeException(), isNull);
      // 21 taps from obscured: an odd count ends revealed.
      expect(find.byIcon(DsIcons.visibilityOff), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('disposal mid ink splash does not throw', (tester) async {
      await pumpProbe(tester, const DsPasswordField(label: 'Password'));
      await tester.tap(find.byIcon(DsIcons.visibility));
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion: toggle works with animations disabled', (
      tester,
    ) async {
      await pumpProbe(
        tester,
        const DsPasswordField(label: 'Password'),
        disableAnimations: true,
      );
      await tester.tap(find.byIcon(DsIcons.visibility));
      await tester.pump();
      expect(find.byIcon(DsIcons.visibilityOff), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('DsPasswordField: keyboard and semantics', () {
    testWidgets('Tab reaches the eye toggle and Space activates it', (
      tester,
    ) async {
      final fieldFocus = FocusNode();
      addTearDown(fieldFocus.dispose);
      await pumpProbe(
        tester,
        DsPasswordField(label: 'Password', focusNode: fieldFocus),
      );
      fieldFocus.requestFocus();
      await tester.pump();
      expect(fieldFocus.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(fieldFocus.hasPrimaryFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(find.byIcon(DsIcons.visibilityOff), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.byIcon(DsIcons.visibility), findsOneWidget);
      // Let any focus tooltip timers run down.
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('disabled field ignores taps on the eye and is unfocusable', (
      tester,
    ) async {
      final fieldFocus = FocusNode();
      addTearDown(fieldFocus.dispose);
      await pumpProbe(
        tester,
        DsPasswordField(
          label: 'Password',
          enabled: false,
          focusNode: fieldFocus,
        ),
      );
      await tester.tap(
        find.byIcon(DsIcons.visibility),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(find.byIcon(DsIcons.visibility), findsOneWidget);
      expect(find.byIcon(DsIcons.visibilityOff), findsNothing);
      fieldFocus.requestFocus();
      await tester.pump();
      expect(fieldFocus.hasPrimaryFocus, isFalse);
    });

    testWidgets('toggle is a labelled button and the field reports obscured', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpProbe(tester, const DsPasswordField(label: 'Password'));

      // The accessible name arrives through the semantics tooltip attribute
      // (IconButton.tooltip), not the label.
      final toggle = tester.getSemantics(find.byIcon(DsIcons.visibility));
      expect(toggle.tooltip, 'Show password');
      expect(toggle.flagsCollection.isButton, isTrue);
      expect(toggle.flagsCollection.isEnabled, ui.Tristate.isTrue);

      final field = tester.getSemantics(find.byType(EditableText));
      expect(field.flagsCollection.isObscured, isTrue);

      await tester.tap(find.byIcon(DsIcons.visibility));
      await tester.pump();
      expect(
        tester.getSemantics(find.byIcon(DsIcons.visibilityOff)).tooltip,
        'Hide password',
      );
      expect(
        tester
            .getSemantics(find.byType(EditableText))
            .flagsCollection
            .isObscured,
        isFalse,
      );
      handle.dispose();
    });
  });
}
