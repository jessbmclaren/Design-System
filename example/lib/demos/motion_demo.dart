import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Motion page: a staggered, physical reveal built entirely
/// from `DsMotion` tokens. Sits settled at rest (screenshot safe) and replays
/// on demand so the choreography and the settle-overshoot are visible.
class MotionDemo extends StatefulWidget {
  const MotionDemo({super.key});

  @override
  State<MotionDemo> createState() => _MotionDemoState();
}

class _MotionDemoState extends State<MotionDemo>
    with SingleTickerProviderStateMixin {
  static const _tiles = ['Purposeful', 'Physical', 'Choreographed', 'Respectful'];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    // Base transition plus room for the stagger tail.
    duration: DsMotion.base + const Duration(milliseconds: 240),
    value: 1, // start revealed so the resting frame is stable.
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    if (DsMotion.reduced(context)) return; // honour reduce-motion
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Motion tokens in motion',
                style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
              ),
            ),
            DsButton(
              label: 'Replay',
              variant: DsButtonVariant.secondary,
              icon: Icons.play_arrow_rounded,
              onPressed: _replay,
            ),
          ],
        ),
        const SizedBox(height: DsSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 520;
            final tileWidth = wide
                ? (constraints.maxWidth - DsSpacing.md * 3) / 4
                : constraints.maxWidth;
            return Wrap(
              spacing: DsSpacing.md,
              runSpacing: DsSpacing.md,
              children: [
                for (var i = 0; i < _tiles.length; i++)
                  SizedBox(
                    width: tileWidth,
                    child: _RevealTile(
                      controller: _controller,
                      index: i,
                      label: _tiles[i],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// One tile that fades, rises and settles into place, offset from its siblings
/// by a staggered [Interval] so the group reveals a beat apart.
class _RevealTile extends StatelessWidget {
  const _RevealTile({
    required this.controller,
    required this.index,
    required this.label,
  });

  final AnimationController controller;
  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    // A staggered slice of the timeline for this tile.
    final start = (index * 0.14).clamp(0.0, 0.6);
    final fade = CurvedAnimation(
      parent: controller,
      curve: Interval(start, (start + 0.5).clamp(0.0, 1.0), curve: DsMotion.emphasized),
    );
    final rise = CurvedAnimation(
      parent: controller,
      // The settle curve gives the arrival a subtle physical overshoot.
      curve: Interval(start, (start + 0.6).clamp(0.0, 1.0), curve: DsMotion.settle),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: fade.value,
          child: Transform.translate(
            offset: Offset(0, (1 - rise.value) * 24),
            child: child,
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.colorBackground,
          border: Border.all(color: tokens.colorBorder),
          borderRadius: BorderRadius.circular(tokens.borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DsSpacing.md,
            vertical: DsSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tokens.colorPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text('${index + 1}',
                    style: tokens.headingXs.toTextStyle(color: tokens.colorPrimary)),
              ),
              const SizedBox(height: DsSpacing.sm),
              Text(label,
                  style: tokens.bodyMd.toTextStyle(color: tokens.colorText)),
            ],
          ),
        ),
      ),
    );
  }
}
