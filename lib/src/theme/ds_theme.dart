import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/ds_typography.dart';
import 'ds_tokens_extension.dart';

/// Builds the Design System [ThemeData].
///
/// Both factories produce a Material 3 theme (`useMaterial3: true`) seeded
/// from the Design System colour tokens, with the full set of appearance
/// variables attached as a [DsTokens] theme extension. Components read their
/// values from `DsTokens.of(context)`, so switching between
/// [DsTheme.light] and [DsTheme.dark] flips every component at once.
///
/// The system is white-label: pass your own [DsTokens] to re-brand every
/// component in one place, for example
///
/// ```dart
/// final brand = DsTokens.light().copyWith(
///   buttonPrimaryColorBackground: const Color(0xFF6D28D9),
///   actionPrimaryColorText: const Color(0xFF6D28D9),
/// );
/// MaterialApp(theme: DsTheme.light(tokens: brand));
/// ```
abstract final class DsTheme {
  /// The light theme.
  ///
  /// Supply [tokens] to override the default Design System appearance with
  /// your own brand. Supply [seedColor] to steer the generated Material 3
  /// palette (defaults to the primary action colour of [tokens]).
  static ThemeData light({DsTokens? tokens, Color? seedColor}) =>
      _build(Brightness.light, tokens ?? DsTokens.light(), seedColor);

  /// The dark theme.
  ///
  /// Supply [tokens] to override the default appearance with your own brand.
  static ThemeData dark({DsTokens? tokens, Color? seedColor}) =>
      _build(Brightness.dark, tokens ?? DsTokens.dark(), seedColor);

  static ThemeData _build(
    Brightness brightness,
    DsTokens tokens,
    Color? seedColor,
  ) {
    // A skin that breaks the accessibility contract fails fast in debug
    // rather than shipping unreadable text.
    assert(_debugContrastHolds(tokens));
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor ?? tokens.colorPrimary,
      brightness: brightness,
    ).copyWith(
      primary: tokens.colorPrimary,
      onPrimary: tokens.buttonPrimaryColorText,
      error: tokens.colorDanger,
      onError: tokens.buttonDangerColorText,
      surface: tokens.colorBackground,
      onSurface: tokens.colorText,
      outline: tokens.colorBorder,
      surfaceContainerHighest: tokens.colorSurfaceMuted,
    );

    // Resolve the effective font. When the caller keeps the default family we
    // use the bundled Inter directly (so it renders identically everywhere);
    // when they override it we use their family and fall back to bundled
    // Inter. A null family passes straight through, so the platform system
    // font renders with no bundled fallback.
    final usesDefaultFont = tokens.fontFamily == DsTypography.fontFamily;
    final effectiveFamily =
        usesDefaultFont ? DsTypography.packagedFontFamily : tokens.fontFamily;
    final effectiveFallback = usesDefaultFont || tokens.fontFamily == null
        ? const <String>[]
        : const [DsTypography.packagedFontFamily];

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.colorBackground,
      fontFamily: effectiveFamily,
      fontFamilyFallback: effectiveFallback,
      extensions: [tokens],
    );

    // The general border radius drives the default surface shapes. The
    // per-component radius tokens (button/badge/form/overlay) still override it
    // where a component sets its own.
    final generalRadius = BorderRadius.circular(tokens.borderRadius);
    final generalShape = RoundedRectangleBorder(borderRadius: generalRadius);

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, tokens, effectiveFamily, effectiveFallback),
      // Flat interactions: the system never splashes; hover, focus and press
      // read as tints, not ripples.
      splashFactory: NoSplash.splashFactory,
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: tokens.colorInverseSurface,
          borderRadius: BorderRadius.circular(tokens.tooltipBorderRadius),
        ),
        textStyle: tokens.labelSm
            .copyWith(height: 1.3)
            .toTextStyle(color: tokens.colorOnInverse),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dividerTheme: DividerThemeData(
        // The hairline tier, so a plain Divider matches DsDivider under a
        // skin that lightens its hairlines.
        color: tokens.colorBorderSubtle,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: tokens.formBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: generalRadius,
          side: BorderSide(color: tokens.colorBorder),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          shape: WidgetStatePropertyAll(generalShape),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(shape: generalShape),
      dialogTheme: DialogThemeData(shape: generalShape),
      // The full field recipe, so a bare TextField inside the theme already
      // renders as a Ds field: filled white, all six border states and the
      // token hint and error styling.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.formBackgroundColor,
        isDense: false,
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.inputFieldPaddingX,
          vertical: tokens.textFieldPaddingY,
        ),
        hintStyle: tokens.bodyMd
            .copyWith(height: 1.3)
            .toTextStyle(color: tokens.formPlaceholderTextColor),
        errorStyle: tokens.bodySm.toTextStyle(color: tokens.colorDanger),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          borderSide: BorderSide(
            color: tokens.colorBorder,
            width: tokens.inputBorderWidth,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          borderSide: BorderSide(
            color: tokens.colorBorderSubtle,
            width: tokens.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          borderSide: BorderSide(
            color: tokens.formHighlightColorBorder,
            width: tokens.inputFocusBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          borderSide: BorderSide(
            color: tokens.colorDanger,
            width: tokens.inputBorderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          borderSide: BorderSide(
            color: tokens.colorDanger,
            width: tokens.inputFocusBorderWidth,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          borderSide: BorderSide(
            color: tokens.colorBorder,
            width: tokens.inputBorderWidth,
          ),
        ),
      ),
    );
  }

  /// WCAG relative luminance of an sRGB colour.
  static double _luminance(Color c) {
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  /// WCAG contrast ratio between two colours (1..21).
  static double _contrast(Color a, Color b) {
    final la = _luminance(a);
    final lb = _luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// The debug-only contrast guard: asserts the core text pairs clear AA
  /// (4.5:1) so a skin that breaks the contract fails at construction with a
  /// named pair instead of shipping unreadable text. Always returns true in
  /// release builds.
  static bool _debugContrastHolds(DsTokens t) {
    void checkAt(String pair, Color fg, Color bg, double minimum) {
      final ratio = _contrast(fg, bg);
      assert(
        ratio >= minimum,
        'DsTheme contrast: $pair is ${ratio.toStringAsFixed(2)}:1, '
        'needs $minimum:1',
      );
    }

    void check(String pair, Color fg, Color bg) => checkAt(pair, fg, bg, 4.5);

    check('colorText on colorBackground', t.colorText, t.colorBackground);
    check('colorSecondaryText on colorBackground', t.colorSecondaryText,
        t.colorBackground);
    check('primary button label on its fill', t.buttonPrimaryColorText,
        t.buttonPrimaryColorBackground);
    // A gradient fill replaces that flat colour, so every stop carries the
    // label and every stop has to clear AA. The label crosses all of them.
    for (int i = 0; i < t.buttonPrimaryGradient.length; i++) {
      check('primary button label on gradient stop $i',
          t.buttonPrimaryColorText, t.buttonPrimaryGradient[i]);
    }
    check('danger button label on its fill', t.buttonDangerColorText,
        t.buttonDangerColorBackground);
    check('neutral badge ink on its fill', t.badgeNeutralColorText,
        t.badgeNeutralColorBackground);
    check('info badge ink on its fill', t.badgeInfoColorText,
        t.badgeInfoColorBackground);
    check('success badge ink on its fill', t.badgeSuccessColorText,
        t.badgeSuccessColorBackground);
    check('warning badge ink on its fill', t.badgeWarningColorText,
        t.badgeWarningColorBackground);
    check('danger badge ink on its fill', t.badgeDangerColorText,
        t.badgeDangerColorBackground);
    // Placeholder on a labelled field is supplementary hint text, held to
    // WCAG's non-text tier (3.0:1) rather than the body-text bar, so a skin
    // never has to darken its hints to body-ink depth.
    checkAt('placeholder on the field fill', t.formPlaceholderTextColor,
        t.formBackgroundColor, 3.0);
    check('inverse ink on the inverse surface', t.colorOnInverse,
        t.colorInverseSurface);
    return true;
  }

  static TextTheme _textTheme(
    TextTheme base,
    DsTokens tokens,
    String? family,
    List<String> fallback,
  ) {
    final onSurface = tokens.colorText;
    // Scale the ramp by the base font size so overriding fontSizeBase rescales
    // the whole system's typography (16 is the reference base).
    final scale = tokens.fontSizeBase / 16.0;
    TextStyle style(DsTypeToken token) => token
        .copyWith(fontSize: token.fontSize * scale)
        .toTextStyle(color: onSurface);
    // Stamp the resolved brand family onto every ramp entry so overriding
    // DsTokens.fontFamily re-fonts the whole system.
    return base
        .copyWith(
          displaySmall: style(tokens.headingXl),
          headlineMedium: style(tokens.headingLg),
          headlineSmall: style(tokens.headingMd),
          titleLarge: style(tokens.headingMd),
          titleMedium: style(tokens.headingSm),
          titleSmall: style(tokens.headingXs),
          bodyLarge: style(tokens.bodyMd),
          bodyMedium: style(tokens.bodySm),
          labelLarge: style(tokens.labelMd),
          labelSmall: style(tokens.labelSm),
        )
        .apply(fontFamily: family, fontFamilyFallback: fallback);
  }
}
