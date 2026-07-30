import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const options = <DsSelectOption<String>>[
    DsSelectOption(value: 'us', label: 'United States'),
    DsSelectOption(value: 'be', label: 'Belgium'),
  ];

  testWidgets('renders label and hint when no value selected', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        hintText: 'Select a country',
        options: options,
        onChanged: (_) {},
      ),
    );

    expect(find.text('Country'), findsOneWidget);
    expect(find.text('Select a country'), findsOneWidget);
  });

  testWidgets('shows the selected option label in the closed field', (
    tester,
  ) async {
    await pumpDs(
      tester,
      DsSelect<String>(value: 'be', options: options, onChanged: (_) {}),
    );

    expect(find.text('Belgium'), findsOneWidget);
  });

  testWidgets('reports the picked value through onChanged', (tester) async {
    String? picked;
    await pumpDs(
      tester,
      DsSelect<String>(
        value: null,
        hintText: 'Select a country',
        options: options,
        onChanged: (value) => picked = value,
      ),
    );

    await tester.tap(find.byType(DsSelect<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('United States').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(picked, 'us');
  });

  testWidgets('disabled select suppresses interaction', (tester) async {
    var changed = false;
    await pumpDs(
      tester,
      DsSelect<String>(
        value: null,
        hintText: 'Select a country',
        options: options,
        enabled: false,
        onChanged: (_) => changed = true,
      ),
    );

    await tester.tap(find.byType(DsSelect<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The menu never opens, so no second copy of the option text appears.
    expect(find.text('United States'), findsNothing);
    expect(changed, isFalse);
  });

  testWidgets('a disabled select does not validate', (tester) async {
    final formKey = GlobalKey<FormState>();
    await pumpDs(
      tester,
      Form(
        key: formKey,
        child: DsSelect<String>(
          label: 'Country',
          value: null,
          options: options,
          enabled: false,
          onChanged: (_) {},
          validator: (value) => value == null ? 'Country is required' : null,
        ),
      ),
    );

    // The user cannot operate a disabled control, so its validator must not
    // be able to block the form with an unfixable error.
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Country is required'), findsNothing);
  });

  testWidgets('a disabled select does not save', (tester) async {
    final formKey = GlobalKey<FormState>();
    var savedCalls = 0;
    await pumpDs(
      tester,
      Form(
        key: formKey,
        child: DsSelect<String>(
          value: 'be',
          options: options,
          enabled: false,
          onChanged: (_) {},
          onSaved: (_) => savedCalls++,
        ),
      ),
    );

    formKey.currentState!.save();
    expect(savedCalls, 0);
  });

  testWidgets('renders the error message', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        value: null,
        hintText: 'Select a country',
        errorText: 'Country is required',
        options: options,
        onChanged: (_) {},
      ),
    );

    expect(find.text('Country is required'), findsOneWidget);
  });

  testWidgets('renders helperText beneath the field', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        hintText: 'Select a country',
        helperText: 'Where the business is registered',
        options: options,
        onChanged: (_) {},
      ),
    );

    expect(find.text('Where the business is registered'), findsOneWidget);
  });

  testWidgets('errorText replaces helperText', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        hintText: 'Select a country',
        helperText: 'Where the business is registered',
        errorText: 'Country is required',
        options: options,
        onChanged: (_) {},
      ),
    );

    expect(find.text('Country is required'), findsOneWidget);
    expect(find.text('Where the business is registered'), findsNothing);
  });

  testWidgets('validator reports its message when the form validates', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await pumpDs(
      tester,
      Form(
        key: formKey,
        child: DsSelect<String>(
          label: 'Country',
          value: null,
          hintText: 'Select a country',
          options: options,
          onChanged: (_) {},
          validator: (value) => value == null ? 'Country is required' : null,
        ),
      ),
    );

    expect(find.text('Country is required'), findsNothing);

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Country is required'), findsOneWidget);
  });

  testWidgets('validates on user interaction when asked to', (tester) async {
    await pumpDs(
      tester,
      Form(
        child: DsSelect<String>(
          label: 'Country',
          value: null,
          hintText: 'Select a country',
          options: options,
          onChanged: (_) {},
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) =>
              value == 'us' ? 'Not available in that country' : null,
        ),
      ),
    );

    await tester.tap(find.byType(DsSelect<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('United States').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Not available in that country'), findsOneWidget);
  });

  testWidgets('onSaved receives the value when the form saves', (tester) async {
    final formKey = GlobalKey<FormState>();
    String? saved;
    await pumpDs(
      tester,
      Form(
        key: formKey,
        child: DsSelect<String>(
          label: 'Country',
          value: 'be',
          options: options,
          onChanged: (_) {},
          onSaved: (value) => saved = value,
        ),
      ),
    );

    formKey.currentState!.save();
    expect(saved, 'be');
  });

  testWidgets('does not overflow at 320x640', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        hintText: 'Select a country',
        options: options,
        onChanged: (_) {},
      ),
      surfaceSize: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the focused border matches the field family emphasis', (
    tester,
  ) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        options: options,
        onChanged: (_) {},
      ),
    );

    final InputDecorator decorator = tester.widget(find.byType(InputDecorator));
    OutlineInputBorder outline(InputBorder? border) =>
        border! as OutlineInputBorder;

    // Aligned with the rest of the field family: 1.6, not the 2 the select
    // once drew.
    expect(outline(decorator.decoration.focusedBorder).borderSide.width, 1.6);
    expect(
      outline(decorator.decoration.focusedErrorBorder).borderSide.width,
      1.6,
    );
    expect(outline(decorator.decoration.enabledBorder).borderSide.width, 1);
  });

  testWidgets('border widths re-style with the skin', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        options: options,
        onChanged: (_) {},
      ),
      theme: DsTheme.light(
        tokens: DsTokens.light().copyWith(
          inputBorderWidth: 3,
          inputFocusBorderWidth: 5,
        ),
      ),
    );

    final InputDecorator decorator = tester.widget(find.byType(InputDecorator));
    OutlineInputBorder outline(InputBorder? border) =>
        border! as OutlineInputBorder;

    expect(outline(decorator.decoration.enabledBorder).borderSide.width, 3);
    expect(outline(decorator.decoration.focusedBorder).borderSide.width, 5);
    // Error carries the focus emphasis, as it does on DsTextField, so a
    // mistake is never drawn more quietly than a focus ring.
    expect(outline(decorator.decoration.errorBorder).borderSide.width, 5);
    expect(
      outline(decorator.decoration.focusedErrorBorder).borderSide.width,
      5,
    );
  });

  testWidgets('the label gap reads the fieldLabelGap token', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        options: options,
        onChanged: (_) {},
      ),
      theme: DsTheme.light(
        tokens: DsTokens.light().copyWith(fieldLabelGap: 14),
      ),
    );

    final labelBottom = tester.getBottomLeft(find.text('Country')).dy;
    final fieldTop = tester.getTopLeft(find.byType(InputDecorator)).dy;
    expect(fieldTop - labelBottom, 14);
  });

  group('the open menu', () {
    Future<void> openMenu(WidgetTester tester) async {
      await tester.tap(find.byType(DsSelect<String>), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('drops beneath the field instead of covering it', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsSelect<String>(
          label: 'Country',
          value: 'be',
          options: options,
          onChanged: (_) {},
        ),
      );

      final fieldBottom = tester.getRect(find.byType(InputDecorator)).bottom;
      await openMenu(tester);

      // Every row sits below the closed field, so the question stays readable
      // while the answer is chosen.
      for (final option in options) {
        final row = find.widgetWithText(MenuItemButton, option.label);
        expect(
          tester.getRect(row).top,
          greaterThanOrEqualTo(fieldBottom),
          reason: '${option.label} should sit below the field',
        );
      }
    });

    testWidgets('lines its labels up with the closed field', (tester) async {
      await pumpDs(
        tester,
        DsSelect<String>(
          value: null,
          hintText: 'Select a country',
          options: options,
          onChanged: (_) {},
        ),
      );

      final hintLeft = tester.getTopLeft(find.text('Select a country')).dx;
      await openMenu(tester);
      final rowLeft = tester.getTopLeft(find.text('Belgium')).dx;

      // Within the hair's breadth the focus border adds, the label does not
      // shift sideways as the menu opens.
      expect((rowLeft - hintLeft).abs(), lessThanOrEqualTo(1));
    });

    testWidgets('matches the width of the field', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 420,
          child: DsSelect<String>(
            value: 'be',
            options: options,
            onChanged: (_) {},
          ),
        ),
      );

      await openMenu(tester);
      expect(
        tester.getRect(find.widgetWithText(MenuItemButton, 'Belgium')).width,
        420,
      );
    });

    testWidgets('marks the current choice with more than colour', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsSelect<String>(value: 'be', options: options, onChanged: (_) {}),
      );
      await openMenu(tester);

      final selectedRow = find.widgetWithText(MenuItemButton, 'Belgium');
      // A tick rides the current row, so the choice does not rest on colour.
      expect(
        find.descendant(of: selectedRow, matching: find.byIcon(DsIcons.check)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.widgetWithText(MenuItemButton, 'United States'),
          matching: find.byIcon(DsIcons.check),
        ),
        findsNothing,
      );
    });

    testWidgets('reports the current choice as selected to assistive tech', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsSelect<String>(value: 'be', options: options, onChanged: (_) {}),
      );
      await openMenu(tester);

      expect(
        tester.getSemantics(find.widgetWithText(MenuItemButton, 'Belgium')),
        isSemantics(isSelected: true, label: 'Belgium'),
      );
      expect(
        tester.getSemantics(
          find.widgetWithText(MenuItemButton, 'United States'),
        ),
        isSemantics(isSelected: false, label: 'United States'),
      );
      handle.dispose();
    });

    testWidgets('opens on the current choice for the keyboard', (tester) async {
      String? picked;
      await pumpDs(
        tester,
        DsSelect<String>(
          value: 'be',
          options: options,
          onChanged: (value) => picked = value,
        ),
      );
      await openMenu(tester);

      // Enter takes the row the menu opened on, so a keyboard user is not
      // dropped at the top of a list they have already answered.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(picked, 'be');
    });

    testWidgets('scrolls a long list inside a capped surface', (tester) async {
      await pumpDs(
        tester,
        DsSelect<String>(
          value: 'v20',
          options: <DsSelectOption<String>>[
            for (var i = 0; i < 30; i++)
              DsSelectOption<String>(value: 'v$i', label: 'Option $i'),
          ],
          onChanged: (_) {},
        ),
      );
      await openMenu(tester);

      // Thirty options open a menu, not a wall: the surface stays capped and
      // scrolls, rather than running the height of the viewport.
      final menu = tester.getRect(
        find
            .ancestor(
              of: find.byType(MenuItemButton).first,
              matching: find.byType(SingleChildScrollView),
            )
            .first,
      );
      expect(menu.height, lessThanOrEqualTo(320));

      // The current choice is scrolled into view rather than left for the user
      // to hunt down.
      final current = tester.getRect(
        find.widgetWithText(MenuItemButton, 'Option 20'),
      );
      expect(
        menu.contains(current.center),
        isTrue,
        reason: 'the selected row should be within the visible menu',
      );
    });
  });

  testWidgets('the closed field follows the value the caller owns', (
    tester,
  ) async {
    Widget build(String? value) => DsSelect<String>(
      label: 'Country',
      value: value,
      hintText: 'Select a country',
      options: options,
      onChanged: (_) {},
    );

    await pumpDs(tester, build('be'));
    expect(find.text('Belgium'), findsOneWidget);

    await pumpDs(tester, build('us'));
    expect(find.text('United States'), findsOneWidget);
    expect(find.text('Belgium'), findsNothing);

    await pumpDs(tester, build(null));
    expect(find.text('Select a country'), findsOneWidget);
  });

  testWidgets('an external value change reaches the form without touching it', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    String? saved;

    Widget build(String? value) => Form(
      key: formKey,
      child: DsSelect<String>(
        label: 'Country',
        value: value,
        options: options,
        onChanged: (_) {},
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (v) => v == null ? 'Country is required' : null,
        onSaved: (v) => saved = v,
      ),
    );

    await pumpDs(tester, build(null));
    await pumpDs(tester, build('be'));
    await tester.pump();

    // Setting the value from outside is not the user interacting, so no
    // required error springs on someone who has chosen nothing.
    expect(find.text('Country is required'), findsNothing);

    formKey.currentState!.save();
    expect(saved, 'be');
  });

  testWidgets('escape closes the menu and returns focus to the field', (
    tester,
  ) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        hintText: 'Select a country',
        options: options,
        onChanged: (_) {},
      ),
    );

    await tester.tap(find.byType(DsSelect<String>), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(MenuItemButton), findsWidgets);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MenuItemButton), findsNothing);
    // Focus lands back on the field, not at the root of the page.
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'DsSelect');
  });

  testWidgets('the chevron holds still under reduced motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DsTheme.light(),
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Center(
              child: DsSelect<String>(
                value: null,
                hintText: 'Select a country',
                options: options,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DsSelect<String>), warnIfMissed: false);
    await tester.pump();

    expect(
      tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).duration,
      Duration.zero,
    );
  });

  testWidgets('the field keeps its tap target while a message shows', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await pumpDs(
      tester,
      Form(
        key: formKey,
        child: DsSelect<String>(
          label: 'Country',
          value: null,
          hintText: 'Select a country',
          options: options,
          onChanged: (_) {},
          validator: (value) => value == null ? 'Country is required' : null,
        ),
      ),
    );

    expect(
      tester.getRect(find.byType(InputDecorator)).height,
      greaterThanOrEqualTo(48),
    );

    formKey.currentState!.validate();
    await tester.pump();

    // The message renders beneath the control, so it cannot squeeze the
    // control below an accessible target.
    expect(find.text('Country is required'), findsOneWidget);
    expect(
      tester.getRect(find.byType(InputDecorator)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('an empty option list disables the control', (tester) async {
    var changed = false;
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: null,
        hintText: 'Select a country',
        options: const <DsSelectOption<String>>[],
        onChanged: (_) => changed = true,
      ),
    );

    await tester.tap(find.byType(DsSelect<String>), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MenuItemButton), findsNothing);
    expect(changed, isFalse);
  });

  testWidgets('a disabled select leaves the focus order', (tester) async {
    await pumpDs(
      tester,
      Column(
        children: <Widget>[
          DsSelect<String>(
            label: 'Country',
            value: null,
            options: options,
            enabled: false,
            onChanged: (_) {},
          ),
          const DsTextField(label: 'After'),
        ],
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    // Tab skips the disabled select and lands on the next control.
    expect(find.byType(MenuItemButton), findsNothing);
    expect(
      FocusManager.instance.primaryFocus?.context?.widget,
      isNot(isA<DsSelect<String>>()),
    );
    expect(find.byType(EditableText), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
  });

  testWidgets('reserveErrorSpace keeps the caption line allocated', (
    tester,
  ) async {
    Widget build({String? errorText}) => DsSelect<String>(
      label: 'Country',
      value: null,
      hintText: 'Select a country',
      options: options,
      errorText: errorText,
      reserveErrorSpace: true,
      onChanged: (_) {},
    );

    await pumpDs(tester, build());
    final quiet = tester.getRect(find.byType(MergeSemantics)).height;

    await pumpDs(tester, build(errorText: 'Country is required'));
    final erroring = tester.getRect(find.byType(MergeSemantics)).height;

    // The field does not shove the layout as an error appears.
    expect(erroring, quiet);
  });

  testWidgets('renders in dark and under a skin', (tester) async {
    for (final theme in <ThemeData>[
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
    ]) {
      await pumpDs(
        tester,
        DsSelect<String>(
          label: 'Country',
          value: 'be',
          options: options,
          onChanged: (_) {},
        ),
        theme: theme,
      );
      await tester.tap(find.byType(DsSelect<String>), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Belgium'), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('does not overflow at 320dp with the menu open', (tester) async {
    await pumpDs(
      tester,
      DsSelect<String>(
        label: 'Country',
        value: 'x',
        options: const <DsSelectOption<String>>[
          DsSelectOption<String>(
            value: 'x',
            label: 'A very long option label that will not fit on a phone',
          ),
          DsSelectOption<String>(value: 'y', label: 'Short'),
        ],
        onChanged: (_) {},
      ),
      surfaceSize: const Size(320, 640),
    );

    await tester.tap(find.byType(DsSelect<String>), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });
}
