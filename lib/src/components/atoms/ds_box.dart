import 'package:flutter/material.dart';

/// A lightweight, tokened layout wrapper around [Container].
///
/// [DsBox] is the design system's primitive for applying spacing, a
/// background, a border, a corner radius and elevation shadows to a subtree
/// without reaching for a raw [Container] and hand-writing a [BoxDecoration]
/// each time.
///
/// It is deliberately unopinionated about colour: every colour is `null` by
/// default (transparent background, no border) and callers are expected to
/// pass values read from the theme, for example:
///
/// ```dart
/// final tokens = DsTokens.of(context);
/// DsBox(
///   padding: const EdgeInsets.all(DsSpacing.md),
///   background: tokens.colorBackground,
///   borderColor: tokens.colorBorder,
///   borderRadius: tokens.borderRadius,
///   child: const Text('Hello'),
/// );
/// ```
///
/// The widget is purely declarative: it starts no timers or animations and is
/// therefore safe to render in screenshots and golden tests. With no explicit
/// [width] or [height] it takes the size of its child, and any content that
/// might overflow is the responsibility of the (caller-provided) child.
class DsBox extends StatelessWidget {
  /// Creates a tokened layout box.
  ///
  /// All colours default to `null` (transparent background, no border); pass
  /// theme token values via [background], [borderColor] and [shadow].
  const DsBox({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.background,
    this.borderColor,
    this.borderRadius = 0,
    this.borderWidth,
    this.width,
    this.height,
    this.alignment,
    this.shadow,
  });

  /// The widget placed inside the box.
  final Widget? child;

  /// Empty space to inset the [child] within the box.
  final EdgeInsetsGeometry? padding;

  /// Empty space to surround the box (outside its decoration).
  final EdgeInsetsGeometry? margin;

  /// The fill colour of the box. When `null` the box is transparent.
  ///
  /// Pass a theme token such as `DsTokens.of(context).colorBackground`.
  final Color? background;

  /// The border colour. When `null` no border is drawn.
  ///
  /// When set, the border uses [borderWidth] (or `1` if that is also `null`).
  final Color? borderColor;

  /// The corner radius applied to all four corners, in logical pixels.
  ///
  /// Defaults to `0` (square corners).
  final double borderRadius;

  /// The border stroke width. Only used when [borderColor] is non-null.
  ///
  /// Defaults to `1` when a [borderColor] is provided.
  final double? borderWidth;

  /// An explicit width for the box. When `null` the box sizes to its child.
  final double? width;

  /// An explicit height for the box. When `null` the box sizes to its child.
  final double? height;

  /// How to align the [child] within the box.
  ///
  /// When non-null and no [width] or [height] is given, the box will expand to
  /// fill the available space to honour the alignment (this mirrors
  /// [Container]'s behaviour).
  final AlignmentGeometry? alignment;

  /// Elevation shadows cast beneath the box.
  ///
  /// Pass a design system elevation such as `DsElevation.low`.
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final bool hasBorder = borderColor != null;
    final bool hasDecoration =
        background != null || hasBorder || borderRadius != 0 || shadow != null;

    final BorderRadius radius = BorderRadius.circular(borderRadius);

    // Only attach a decoration when something visual is requested, so an
    // otherwise-plain box stays as cheap as a Padding/Align.
    final Decoration? decoration = hasDecoration
        ? BoxDecoration(
            color: background,
            borderRadius: borderRadius != 0 ? radius : null,
            border: hasBorder
                ? Border.all(
                    color: borderColor!,
                    width: borderWidth ?? 1,
                  )
                : null,
            boxShadow: shadow,
          )
        : null;

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      // Clip child bleed to the rounded corners when a radius is present.
      clipBehavior: borderRadius != 0 ? Clip.antiAlias : Clip.none,
      decoration: decoration,
      child: child,
    );
  }
}
