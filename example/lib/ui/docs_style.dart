import 'package:flutter/material.dart';

/// Styling language for the documentation web app *only*.
///
/// The docs shell (sidebar, top bar, page chrome, demo stage, cards) wears its
/// own quiet, product-neutral surface so the components on display are never
/// confused with the frame around them. This module deliberately does not read
/// the Design System's own `DsTokens`: every live demo still renders with the
/// real tokens, and only the chrome uses these values. Change the frame here;
/// never reach into `lib/` to restyle the docs.
///
/// The look is a calm, layered light-grey canvas with white surfaces, hairline
/// separators, soft shadows, tight display type and a single blue accent, then
/// a true-black canvas with raised dark surfaces in dark mode.
class DocsColors {
  const DocsColors({
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.separator,
    required this.separatorStrong,
    required this.fill,
    required this.fillStrong,
    required this.accent,
    required this.accentSoft,
    required this.link,
    required this.codeInk,
    required this.positive,
    required this.positiveSoft,
    required this.negative,
    required this.negativeSoft,
  });

  /// The app background behind everything.
  final Color canvas;

  /// Cards, bars and the sidebar surface.
  final Color surface;

  /// Popovers and the selected-row pill.
  final Color surfaceElevated;

  /// Primary reading colour, near-black.
  final Color textPrimary;

  /// Secondary copy, captions and lead paragraphs.
  final Color textSecondary;

  /// Faintest labels, section headers.
  final Color textTertiary;

  /// Hairline borders and dividers.
  final Color separator;

  /// A slightly firmer hairline for emphasis.
  final Color separatorStrong;

  /// Subtle control tracks (segmented control, hover).
  final Color fill;

  /// A firmer fill for pressed or nested surfaces.
  final Color fillStrong;

  /// The primary action / active colour.
  final Color accent;

  /// A tinted wash of [accent] for selected rows and eyebrows.
  final Color accentSoft;

  /// Inline links in running text.
  final Color link;

  /// Inline code text, kept as calm ink rather than a loud accent.
  final Color codeInk;

  /// The "Do" / affirmative colour.
  final Color positive;

  /// A tinted wash of [positive].
  final Color positiveSoft;

  /// The "Don't" / negative colour.
  final Color negative;

  /// A tinted wash of [negative].
  final Color negativeSoft;

  static const DocsColors light = DocsColors(
    canvas: Color(0xFFF5F5F7),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1D1D1F),
    textSecondary: Color(0xFF6E6E73),
    // Darkened from #86868B so the small 11-12px labels that consume it clear
    // 4.5:1 on both the white surface and the grey canvas.
    textTertiary: Color(0xFF6B6B70),
    separator: Color(0xFFD2D2D7),
    separatorStrong: Color(0xFFC6C6C8),
    fill: Color(0xFFEDEDF0),
    fillStrong: Color(0xFFE3E3E8),
    accent: Color(0xFF0071E3),
    accentSoft: Color(0x140071E3),
    link: Color(0xFF0066CC),
    codeInk: Color(0xFF1D1D1F),
    positive: Color(0xFF147A33),
    positiveSoft: Color(0x1A34C759),
    negative: Color(0xFFD70015),
    negativeSoft: Color(0x1AFF3B30),
  );

  static const DocsColors dark = DocsColors(
    canvas: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    surfaceElevated: Color(0xFF2C2C2E),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFFA1A1A6),
    textTertiary: Color(0xFF86868B),
    separator: Color(0xFF38383A),
    separatorStrong: Color(0xFF48484A),
    fill: Color(0xFF2C2C2E),
    fillStrong: Color(0xFF3A3A3C),
    accent: Color(0xFF2997FF),
    accentSoft: Color(0x1F2997FF),
    link: Color(0xFF2997FF),
    codeInk: Color(0xFFF5F5F7),
    positive: Color(0xFF30D158),
    positiveSoft: Color(0x2630D158),
    negative: Color(0xFFFF453A),
    negativeSoft: Color(0x26FF453A),
  );

  /// Resolves the palette for the docs chrome from the ambient brightness.
  static DocsColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Corner radii for the docs chrome. Larger, softer corners than the components
/// so the frame reads as a distinct, calmer layer.
abstract final class DocsRadii {
  /// 6dp: pills, swatches, segmented-control thumbs.
  static const double xs = 6;

  /// 8dp: small controls, segmented-control track.
  static const double sm = 8;

  /// 12dp: chips, code block, table.
  static const double md = 12;

  /// 18dp: cards and the demo stage.
  static const double lg = 18;

  /// 22dp: hero surfaces.
  static const double xl = 22;

  /// Fully rounded.
  static const double pill = 980;
}

/// Very soft, low-contrast shadows in the spirit of a light, layered surface.
abstract final class DocsShadows {
  /// A resting card lift.
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// A hovered or floating element.
  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 28, offset: Offset(0, 14)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
  ];

  /// A tight lift for a small pill (segmented-control thumb) so the shadow
  /// stays inside its track rather than spilling like a full card.
  static const List<BoxShadow> thumb = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> none = [];
}

/// Layout metrics for the docs shell.
abstract final class DocsMetrics {
  static const double sidebarWidth = 264;
  static const double topBarHeight = 52;

  /// Symmetric left/right gutter for the full-width top bar.
  static const double barGutter = 32;

  /// Horizontal inset of the sidebar wordmark; the top bar's right controls
  /// share it so the two line up at the same margin.
  static const double wordmarkInset = 18;

  static const double readingMaxWidth = 820;
  static const double pagePaddingX = 44;
  static const double pagePaddingY = 52;

  /// Uniform icon-catalogue cell so the grid is a perfect matrix.
  static const double iconCellWidth = 120;
  static const double iconCellHeight = 104;
}

/// The docs type ramp: tight, semibold display type over a comfortable body,
/// echoing a premium marketing/documentation voice. Font family is inherited
/// from the ambient theme (Inter), so only size, weight, tracking and colour
/// are set here.
abstract final class DocsType {
  static TextStyle hero(Color c) => TextStyle(
        fontSize: 44,
        height: 1.06,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.1,
        color: c,
      );

  static TextStyle title1(Color c) => TextStyle(
        fontSize: 30,
        height: 1.12,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: c,
      );

  static TextStyle title2(Color c) => TextStyle(
        fontSize: 22,
        height: 1.18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.35,
        color: c,
      );

  static TextStyle title3(Color c) => TextStyle(
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: c,
      );

  static TextStyle headline(Color c) => TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: c,
      );

  static TextStyle lead(Color c) => TextStyle(
        fontSize: 19,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        color: c,
      );

  static TextStyle body(Color c) => TextStyle(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        color: c,
      );

  static TextStyle callout(Color c) => TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.05,
        color: c,
      );

  static TextStyle footnote(Color c) => TextStyle(
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: c,
      );

  static TextStyle caption(Color c) => TextStyle(
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w500,
        color: c,
      );

  /// The small accent label above a page title.
  static TextStyle eyebrow(Color c) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: c,
      );

  /// Sidebar group headers.
  static TextStyle sectionHeader(Color c) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.7,
        color: c,
      );

  /// Sidebar navigation items.
  static TextStyle navItem(Color c, {bool selected = false}) => TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        letterSpacing: -0.1,
        color: c,
      );

  /// Monospace, for code, variable pills and the raw markdown source. Keeps the
  /// family and default size in one place so call sites don't drift.
  static TextStyle mono(Color c, {double size = 13, double height = 1.5}) =>
      TextStyle(fontFamily: 'monospace', fontSize: size, height: height, color: c);
}
