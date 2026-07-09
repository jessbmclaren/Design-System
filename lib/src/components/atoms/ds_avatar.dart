import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// A circular avatar that represents a person or entity.
///
/// [DsAvatar] resolves what to paint by priority so it always renders
/// something, even offline:
///
/// 1. [imageUrl] — a network image. If it fails to load (or while it loads),
///    the avatar falls back to the initials/icon content below, so a demo or
///    screenshot never shows a broken image.
/// 2. [name] — up to two initials derived from the first letters of the first
///    two words, upper-cased.
/// 3. [icon] — a caller-supplied glyph.
/// 4. A default person glyph.
///
/// The avatar is a circle of diameter [size]. Colours default to the theme:
/// the background is [DsTokens.buttonPrimaryColorBackground] at a low alpha and
/// the foreground is [DsTokens.colorPrimary], both overridable via
/// [backgroundColor] and [foregroundColor].
///
/// The whole widget is exposed to assistive technology as an image labelled by
/// [name] (or `'Avatar'`), so screen readers announce who it represents.
class DsAvatar extends StatelessWidget {
  /// Creates a circular avatar.
  const DsAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.icon,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// An optional network image URL, shown at highest priority.
  ///
  /// If the image fails to load, the avatar gracefully falls back to the
  /// initials derived from [name], then [icon], then a default person glyph.
  final String? imageUrl;

  /// The name used to derive initials and to label the avatar for assistive
  /// technology.
  final String? name;

  /// An optional glyph, shown when there is no image and no [name].
  final IconData? icon;

  /// The diameter of the circular avatar, in logical pixels. Defaults to 40.
  final double size;

  /// Overrides the background fill. Defaults to
  /// [DsTokens.buttonPrimaryColorBackground] at low alpha.
  final Color? backgroundColor;

  /// Overrides the colour of the initials or glyph. Defaults to
  /// [DsTokens.colorPrimary].
  final Color? foregroundColor;

  /// Derives up to two upper-cased initials from a name.
  ///
  /// Uses the first letter of the first two whitespace-separated words. Returns
  /// an empty string when no usable letters are found.
  static String _initialsFrom(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return '';
    }
    final buffer = StringBuffer();
    for (final word in words.take(2)) {
      buffer.write(word.characters.first);
    }
    return buffer.toString().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final Color background =
        backgroundColor ??
        tokens.buttonPrimaryColorBackground.withValues(alpha: 0.12);
    final Color foreground = foregroundColor ?? tokens.colorPrimary;

    final String initials = name == null ? '' : _initialsFrom(name!);

    // The content painted when there is no usable network image.
    final Widget fallback = _buildFallback(
      tokens: tokens,
      initials: initials,
      foreground: foreground,
    );

    Widget content = fallback;
    final String? url = imageUrl;
    if (url != null && url.isNotEmpty) {
      content = ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Keep the fallback visible until the image is ready, and restore it
          // if the image ever errors — no broken-image glyph, ever.
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child;
            }
            return fallback;
          },
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      );
    }

    return Semantics(
      label: name ?? 'Avatar',
      image: true,
      container: true,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
          ),
          // Exclude the visual initials/glyph so only the name is announced.
          child: Center(child: ExcludeSemantics(child: content)),
        ),
      ),
    );
  }

  /// Builds the non-image content: initials, then [icon], then a person glyph.
  Widget _buildFallback({
    required DsTokens tokens,
    required String initials,
    required Color foreground,
  }) {
    if (initials.isNotEmpty) {
      // Scale the glyph to the circle so initials stay legible at every size.
      final double fontSize = size * 0.4;
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(size * 0.12),
          child: Text(
            initials,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
            style: tokens.labelMd.toTextStyle(color: foreground).copyWith(
              fontSize: fontSize,
              height: 1,
            ),
          ),
        ),
      );
    }

    return Icon(
      icon ?? Icons.person,
      size: size * 0.56,
      color: foreground,
    );
  }
}
