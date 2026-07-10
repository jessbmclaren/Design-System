import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';

/// Displays an image with theme-aware loading and error states.
///
/// [DsImg] wraps a single [ImageProvider] (or a network [src]) in a clipped,
/// rounded container and guarantees it always renders something sensible:
///
/// * While an image loads, it shows the [placeholder] you provide, or a
///   tokened skeleton box tinted with `offsetBackgroundColor`.
/// * If an image fails to load — including when there is no network at all —
///   it shows a tokened box containing a broken-image glyph in
///   `colorSecondaryText`, and never throws.
/// * If neither [image] nor [src] is supplied, it renders the same
///   placeholder/skeleton box so demos and golden tests need no network.
///
/// All colors and the fallback radius are read from [DsTokens], so the widget
/// automatically adopts the active white-label theme. It starts no timers or
/// indefinite animations, making it safe to render directly in screenshots.
///
/// The image is exposed to assistive technologies via [semanticLabel]; when
/// none is given the image is treated as decorative and hidden from the
/// semantics tree.
///
/// Example:
/// ```dart
/// DsImg(
///   src: 'https://example.com/avatar.png',
///   width: 96,
///   height: 96,
///   borderRadius: 12,
///   semanticLabel: 'Profile photo',
/// )
/// ```
class DsImg extends StatelessWidget {
  /// Creates an image.
  ///
  /// Provide either [image] (any [ImageProvider]) or [src] (a network URL that
  /// is wrapped in a [NetworkImage]). If both are given, [image] wins. If
  /// neither is given, the [placeholder] or a tokened skeleton box is shown.
  const DsImg({
    super.key,
    this.image,
    this.src,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.semanticLabel,
    this.placeholder,
  });

  /// The image to display.
  ///
  /// Takes precedence over [src] when both are provided.
  final ImageProvider? image;

  /// A network URL to load the image from.
  ///
  /// Used only when [image] is null; it is wrapped in a [NetworkImage].
  final String? src;

  /// The width of the image box, in logical pixels.
  ///
  /// When null the image sizes to the incoming constraints.
  final double? width;

  /// The height of the image box, in logical pixels.
  ///
  /// When null the image sizes to the incoming constraints.
  final double? height;

  /// How the image should be inscribed into its box. Defaults to
  /// [BoxFit.cover].
  final BoxFit fit;

  /// The corner radius applied to the clipped image, in logical pixels.
  final double borderRadius;

  /// A description of the image for assistive technologies.
  ///
  /// When null the image is treated as decorative and excluded from the
  /// semantics tree.
  final String? semanticLabel;

  /// A widget shown while the image loads and when no image source is
  /// available.
  ///
  /// When null a tokened skeleton box is used instead.
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final radius = BorderRadius.circular(borderRadius);

    final resolvedImage = image ?? (src != null ? NetworkImage(src!) : null);

    final Widget content;
    if (resolvedImage == null) {
      // No source at all — render the placeholder or skeleton directly.
      content = _fallback(tokens);
    } else {
      content = Image(
        image: resolvedImage,
        width: width,
        height: height,
        fit: fit,
        // The label is applied by the outer [Semantics]; avoid duplication.
        excludeFromSemantics: true,
        gaplessPlayback: true,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _fallback(tokens);
        },
        errorBuilder: (context, error, stackTrace) => _error(tokens),
      );
    }

    return Semantics(
      image: true,
      label: semanticLabel,
      // Hide purely-decorative images from the semantics tree.
      excludeSemantics: semanticLabel == null,
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: width,
          height: height,
          child: content,
        ),
      ),
    );
  }

  /// The skeleton/placeholder shown while loading or when no source exists.
  Widget _fallback(DsTokens tokens) {
    if (placeholder != null) {
      return SizedBox(
        width: width,
        height: height,
        child: placeholder,
      );
    }
    return _Box(
      width: width,
      height: height,
      color: tokens.offsetBackgroundColor,
    );
  }

  /// The error state shown when an image fails to load.
  Widget _error(DsTokens tokens) {
    return _Box(
      width: width,
      height: height,
      color: tokens.offsetBackgroundColor,
      child: Center(
        child: Icon(
          DsIcons.brokenImage,
          size: DsIconSize.xl,
          color: tokens.colorSecondaryText,
        ),
      ),
    );
  }
}

/// A solid tokened box used for the skeleton and error states.
class _Box extends StatelessWidget {
  const _Box({
    required this.color,
    this.width,
    this.height,
    this.child,
  });

  final Color color;
  final double? width;
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: color,
        // Guarantee a minimum footprint so the box is visible even when the
        // widget is laid out with no explicit size.
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: width ?? 0,
            minHeight: height ?? DsIconSize.xl * 2,
          ),
          child: child,
        ),
      ),
    );
  }
}
