import 'package:flutter/material.dart';

import '../tokens/ds_typography.dart';
import 'ds_tokens_extension.dart';

/// Optional, ready-made brand skins.
///
/// These presets **do not change the default appearance** and have no effect
/// on white-labelling — the core `DsTokens.light()` / `DsTokens.dark()` remain
/// the neutral defaults. A skin is simply a `DsTokens` value you opt into:
///
/// ```dart
/// MaterialApp(
///   theme: DsTheme.light(tokens: DsSkins.engenLight()),
///   darkTheme: DsTheme.dark(tokens: DsSkins.engenDark()),
/// );
/// ```
///
/// Because a skin is just data (a `DsTokens` built with `copyWith`), you can
/// define your own the same way; [engenLight] / [engenDark] are provided as a
/// worked example of a full re-brand (a deep-indigo fleet identity).
abstract final class DsSkins {
  // Engen indigo palette.
  static const Color _indigo = Color(0xFF15259B);
  static const Color _navyInk = Color(0xFF0B1B45);
  static const Color _slate = Color(0xFF5B6478);
  static const Color _border = Color(0xFFD8DCE5);
  static const Color _fill = Color(0xFFF5F6FB);
  static const Color _danger = Color(0xFFDF1B41);

  /// The light Engen skin — deep indigo brand, navy ink, roomier corners.
  static DsTokens engenLight() {
    return DsTokens.light().copyWith(
      // Brand
      colorPrimary: _indigo,
      buttonPrimaryColorBackground: _indigo,
      buttonPrimaryColorBorder: _indigo,
      actionPrimaryColorText: _indigo,
      actionPrimaryTextDecorationColor: _indigo,
      formAccentColor: _indigo,
      // Text & surfaces
      colorText: _navyInk,
      colorSecondaryText: _slate,
      colorBorder: _border,
      offsetBackgroundColor: _fill,
      colorDanger: _danger,
      buttonDangerColorBackground: _danger,
      buttonDangerColorBorder: _danger,
      // Badges (Engen container tones)
      badgeSuccessColorBackground: const Color(0xFFE4F3EB),
      badgeSuccessColorText: const Color(0xFF116B3C),
      badgeSuccessColorBorder: const Color(0xFFB6DEC6),
      badgeDangerColorBackground: const Color(0xFFFCE8EC),
      badgeDangerColorText: const Color(0xFFB01030),
      badgeDangerColorBorder: const Color(0xFFF3C6D0),
      // Shape — Engen uses roomier corners
      buttonBorderRadius: 10,
      formBorderRadius: 10,
      badgeBorderRadius: 8,
      overlayBorderRadius: 16,
      borderRadius: 16,
      // Type — larger display heading, semi-bold control labels
      headingXl: const DsTypeToken(
          fontSize: 32, fontWeight: DsTypography.bold, height: 1.2),
      buttonLabelFontSize: 15,
      buttonLabelFontWeight: DsTypography.semiBold,
    );
  }

  /// The dark Engen skin.
  static DsTokens engenDark() {
    return DsTokens.dark().copyWith(
      colorPrimary: const Color(0xFF5A6BE0),
      actionPrimaryColorText: const Color(0xFF9DA8F0),
      actionPrimaryTextDecorationColor: const Color(0xFF9DA8F0),
      formAccentColor: const Color(0xFF5A6BE0),
      buttonPrimaryColorBackground: const Color(0xFF3B49C4),
      buttonPrimaryColorBorder: const Color(0xFF3B49C4),
      buttonBorderRadius: 10,
      formBorderRadius: 10,
      badgeBorderRadius: 8,
      overlayBorderRadius: 16,
      borderRadius: 16,
      headingXl: const DsTypeToken(
          fontSize: 32, fontWeight: DsTypography.bold, height: 1.2),
      buttonLabelFontSize: 15,
      buttonLabelFontWeight: DsTypography.semiBold,
    );
  }
}
