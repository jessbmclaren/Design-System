import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_icon.dart';

/// A visual file drop-target surface with a browse affordance.
///
/// [DsDropzone] renders the familiar "drop a file here, or browse" panel used at
/// the start of an import flow: a bordered, dashed surface with an upload glyph,
/// a primary [title] prompt, an accepted-types [acceptHint] and a browse
/// [DsButton]. Tapping anywhere on the surface (or the browse button) invokes
/// [onBrowse].
///
/// ## Scope — it does not do file IO
///
/// Real operating-system drag-and-drop needs platform plumbing that lives in the
/// host application, so this widget is deliberately a *visual* drop target plus a
/// browse trigger. It never reads a file itself: the host application picks and
/// parses the file (for example into an `ImportSource`) and drives this widget
/// through [onBrowse], [selectedFileName] and [onClear].
///
/// Once a file has been chosen the host passes its name through
/// [selectedFileName]; the surface then shows a removable file chip whose clear
/// affordance calls [onClear].
///
/// ## Accessibility & responsiveness
///
/// The surface exposes button semantics labelled with [title] and is keyboard
/// operable (focus, then Enter/Space). All colours, radii, spacing and
/// typography read from [DsTokens], and the content is centred and wraps so it
/// never overflows down to a 320dp phone. The widget runs no timers or
/// animations, so it is safe to capture in golden tests and screenshots.
class DsDropzone extends StatelessWidget {
  /// Creates a drop-target surface.
  const DsDropzone({
    super.key,
    this.onBrowse,
    this.acceptHint = 'CSV or Excel, up to 10 MB',
    this.title = 'Drop a file here, or browse',
    this.selectedFileName,
    this.onClear,
    this.enabled = true,
  });

  /// Called when the surface — or the browse button — is activated to pick a
  /// file. A null callback (or [enabled] false) makes the surface
  /// non-interactive.
  final VoidCallback? onBrowse;

  /// A short hint listing the accepted file types and size limit, shown beneath
  /// the [title].
  final String acceptHint;

  /// The primary prompt shown on the surface and used as its accessible label.
  final String title;

  /// The name of the file the host application has already selected. When
  /// non-null the surface shows a removable file chip instead of the browse
  /// button.
  final String? selectedFileName;

  /// Called when the file chip's clear affordance is activated. Only shown when
  /// [selectedFileName] is non-null.
  final VoidCallback? onClear;

  /// Whether the control is interactive. When false the surface is dimmed and
  /// cannot be activated. Defaults to true.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final radius = BorderRadius.circular(tokens.formBorderRadius);
    final bool interactive = enabled && onBrowse != null;
    final hasFile = selectedFileName != null;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.xl,
        vertical: DsSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DsIcon(
            icon: Icons.cloud_upload_outlined,
            size: DsIconSize.xl,
            color: tokens.colorSecondaryText,
          ),
          const SizedBox(height: DsSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tokens.headingSm.toTextStyle(color: tokens.colorText),
          ),
          const SizedBox(height: DsSpacing.xs),
          Text(
            acceptHint,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
          ),
          const SizedBox(height: DsSpacing.lg),
          if (hasFile)
            _FileChip(
              tokens: tokens,
              name: selectedFileName!,
              onClear: enabled ? onClear : null,
            )
          else
            // The surface already announces the browse action, so the visual
            // button is excluded from semantics to avoid a duplicate node.
            ExcludeSemantics(
              child: DsButton(
                label: 'Browse',
                variant: DsButtonVariant.secondary,
                icon: Icons.folder_open_outlined,
                onPressed: interactive ? onBrowse : null,
              ),
            ),
        ],
      ),
    );

    final surface = Semantics(
      button: true,
      enabled: interactive,
      label: title,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: interactive ? onBrowse : null,
          borderRadius: radius,
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: tokens.colorBorder,
              radius: tokens.formBorderRadius,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.offsetBackgroundColor,
                borderRadius: radius,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );

    return Opacity(opacity: enabled ? 1 : 0.5, child: surface);
  }
}

/// A removable pill showing the currently selected file.
class _FileChip extends StatelessWidget {
  const _FileChip({
    required this.tokens,
    required this.name,
    required this.onClear,
  });

  final DsTokens tokens;
  final String name;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(tokens.formBorderRadius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        borderRadius: radius,
        border: Border.all(color: tokens.colorBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: DsSpacing.md,
          top: DsSpacing.xs,
          bottom: DsSpacing.xs,
          right: DsSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsIcon(
              icon: Icons.insert_drive_file_outlined,
              size: DsIconSize.sm,
              color: tokens.colorSecondaryText,
            ),
            const SizedBox(width: DsSpacing.sm),
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tokens.bodySm.toTextStyle(color: tokens.colorText),
              ),
            ),
            const SizedBox(width: DsSpacing.xs),
            Semantics(
              button: true,
              enabled: onClear != null,
              label: 'Remove file',
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onClear,
                  child: const Padding(
                    padding: EdgeInsets.all(DsSpacing.xs),
                    child: DsIcon(icon: Icons.close, size: DsIconSize.sm),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Strokes a dashed rounded-rectangle border just inside [size].
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double strokeWidth = 1.5;
  static const double dash = 6;
  static const double gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      math.max(0, size.width - strokeWidth),
      math.max(0, size.height - strokeWidth),
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final source = Path()..addRRect(rrect);
    canvas.drawPath(_dash(source), paint);
  }

  Path _dash(Path source) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(dash, metric.length - distance);
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += dash + gap;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
