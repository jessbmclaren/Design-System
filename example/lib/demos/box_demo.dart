import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Box page: three `DsBox` surfaces built entirely from
/// theme tokens — a padded card with a border and shadow, a tinted callout,
/// and a plain padded box — showing how spacing, background, border, radius
/// and elevation compose without a raw Container.
class BoxDemo extends StatelessWidget {
  const BoxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A card surface: background + border + radius + elevation.
        DsBox(
          padding: const EdgeInsets.all(DsSpacing.lg),
          background: tokens.colorBackground,
          borderColor: tokens.colorBorder,
          borderRadius: tokens.borderRadius,
          shadow: DsElevation.low,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly volume',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: tokens.colorSecondaryText,
                ),
              ),
              const SizedBox(height: DsSpacing.xs),
              Text(
                '\$48,290',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: tokens.colorText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.md),

        // A tinted callout: a filled box with a matching border tint.
        DsBox(
          padding: const EdgeInsets.all(DsSpacing.md),
          background: tokens.colorPrimary.withValues(alpha: 0.08),
          borderColor: tokens.colorPrimary.withValues(alpha: 0.24),
          borderRadius: tokens.borderRadius,
          child: Text(
            'Every colour and radius here reads from DsTokens, so one theme '
            'change re-skins the surface.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: tokens.colorText,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.md),

        // A plain padded box: no decoration, as cheap as a Padding.
        DsBox(
          padding: const EdgeInsets.symmetric(
            horizontal: DsSpacing.md,
            vertical: DsSpacing.sm,
          ),
          child: Text(
            'Undecorated · padding only',
            style: TextStyle(
              fontSize: 12,
              color: tokens.colorSecondaryText,
            ),
          ),
        ),
      ],
    );
  }
}
