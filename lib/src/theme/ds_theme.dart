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
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        ),
      ),
    );
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
