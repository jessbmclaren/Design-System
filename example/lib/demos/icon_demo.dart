import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Icon page: the DsIconSize scale rendered at the default
/// theme colour, alongside a row of meaning-bearing glyphs that draw their
/// tint from theme tokens.
class IconDemo extends StatelessWidget {
  const IconDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Size scale', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 20,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _ScaleStep(label: 'xs', size: DsIconSize.xs),
            _ScaleStep(label: 'sm', size: DsIconSize.sm),
            _ScaleStep(label: 'md', size: DsIconSize.md),
            _ScaleStep(label: 'lg', size: DsIconSize.lg),
            _ScaleStep(label: 'xl', size: DsIconSize.xl),
          ],
        ),
        const SizedBox(height: 24),
        Text('Meaningful tint', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            DsIcon(
              icon: Icons.check_circle_outline,
              size: DsIconSize.lg,
              color: tokens.badgeSuccessColorText,
              semanticLabel: 'Succeeded',
            ),
            DsIcon(
              icon: Icons.error_outline,
              size: DsIconSize.lg,
              color: tokens.colorDanger,
              semanticLabel: 'Failed',
            ),
            DsIcon(
              icon: Icons.bolt_outlined,
              size: DsIconSize.lg,
              color: tokens.colorPrimary,
              semanticLabel: 'Active',
            ),
            const DsIcon(
              icon: Icons.schedule,
              size: DsIconSize.lg,
              semanticLabel: 'Pending',
            ),
          ],
        ),
      ],
    );
  }
}

class _ScaleStep extends StatelessWidget {
  const _ScaleStep({required this.label, required this.size});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DsIcon(icon: Icons.dashboard_outlined, size: size),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
