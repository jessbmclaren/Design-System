import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_button.dart';

/// A single call-to-action rendered inside a [DsEmptyState].
///
/// Pair a short, verb-led [label] (for example "Add customer") with the
/// [onPressed] callback that starts the flow which will populate the screen.
@immutable
class DsEmptyStateAction {
  const DsEmptyStateAction({required this.label, required this.onPressed});

  /// The button label. Keep it short and action oriented.
  final String label;

  /// Called when the action button is tapped.
  final VoidCallback onPressed;
}

/// A centred placeholder shown when a screen, list or panel has no data.
///
/// Use [DsEmptyState] to explain why a region is empty and, where possible,
/// offer the user a way to fill it. A first-run list, a search with no
/// results and a cleared inbox are all good candidates.
///
/// The layout is a vertically centred column: an optional large [icon]
/// tinted with the secondary text colour, a required [title], an optional
/// supporting [message] constrained to a comfortable reading width, and an
/// optional primary [action] button. The content never overflows and stays
/// centred within the space it is given, from 320dp phones upward.
/// How a [DsEmptyState] is framed.
enum DsEmptyStateVariant {
  /// A centred block with a large glyph, for a whole empty page or panel.
  centred,

  /// A compact, left-aligned panel on the muted fill, for an empty result
  /// inside a page that still has its filters and toolbar above it.
  inline,

  /// A centred block inside a dashed outline, for a region that is waiting
  /// to be filled rather than a collection that is empty.
  outlined,
}

class DsEmptyState extends StatelessWidget {
  const DsEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.action,
    this.variant = DsEmptyStateVariant.centred,
  });

  /// How the empty state is framed. Defaults to [DsEmptyStateVariant.centred].

  /// The short headline describing the empty state.
  final String title;

  /// Optional supporting text giving more context or next steps.
  final String? message;

  /// Optional large glyph shown above the title.
  final IconData? icon;

  /// Optional primary action offering the user a way forward.
  final DsEmptyStateAction? action;

  /// The maximum width of the supporting message, for comfortable reading.
  static const double _messageMaxWidth = 320;

  /// The variant, declared after the fields so the doc above binds to it.
  final DsEmptyStateVariant variant;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    if (variant == DsEmptyStateVariant.inline) return _buildInline(tokens);

    final Widget centred = Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacingUnit * 3,
          vertical: tokens.spacingUnit * 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: tokens.colorSecondaryText,
              ),
              SizedBox(height: tokens.spacingUnit * 2),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: tokens.headingSm.toTextStyle(color: tokens.colorText),
            ),
            if (message != null) ...[
              SizedBox(height: tokens.spacingUnit),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _messageMaxWidth),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: tokens.bodySm
                      .toTextStyle(color: tokens.colorSecondaryText),
                ),
              ),
            ],
            if (action != null) ...[
              SizedBox(height: tokens.spacingUnit * 3),
              DsButton(
                label: action!.label,
                onPressed: action!.onPressed,
              ),
            ],
          ],
        ),
      ),
    );

    if (variant == DsEmptyStateVariant.centred) return centred;

    // Outlined: the same block inside a dashed frame, marking a region that
    // is waiting for content rather than a collection that is empty.
    return _DashedBorder(
      color: tokens.colorBorder,
      radius: tokens.formBorderRadius,
      child: centred,
    );
  }

  /// The compact panel: a muted strip with the title, the message beneath it
  /// and any action on the trailing edge, for an empty result within a page.
  Widget _buildInline(DsTokens tokens) {
    final double unit = tokens.spacingUnit;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: unit * 2, vertical: unit * 2),
      decoration: BoxDecoration(
        color: tokens.offsetBackgroundColor,
        borderRadius: BorderRadius.circular(tokens.formBorderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 20, color: tokens.colorSecondaryText),
            SizedBox(width: unit * 1.5),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: tokens.labelMd.toTextStyle(color: tokens.colorText),
                ),
                if (message != null) ...<Widget>[
                  SizedBox(height: unit / 2),
                  Text(
                    message!,
                    style: tokens.bodySm
                        .toTextStyle(color: tokens.colorSecondaryText),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...<Widget>[
            SizedBox(width: unit * 2),
            DsButton(
              label: action!.label,
              onPressed: action!.onPressed,
              variant: DsButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}

/// Paints a dashed rounded outline around [child].
class _DashedBorder extends StatelessWidget {
  const _DashedBorder({
    required this.color,
    required this.radius,
    required this.child,
  });

  final Color color;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );
    // Walk the outline, drawing a dash then skipping a gap.
    const double dash = 6;
    const double gap = 4;
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
