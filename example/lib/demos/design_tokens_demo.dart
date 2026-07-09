import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Design tokens page: colour swatches plus a small sampler
/// of themed components so the tokens are visible in context.
class DesignTokensDemo extends StatelessWidget {
  const DesignTokensDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final swatches = <(String, Color)>[
      ('Primary', tokens.buttonPrimaryColorBackground),
      ('Secondary', tokens.buttonSecondaryColorBackground),
      ('Danger', tokens.buttonDangerColorBackground),
      ('Border', tokens.colorBorder),
      ('Success', tokens.badgeSuccessColorBackground),
      ('Warning', tokens.badgeWarningColorBackground),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (name, color) in swatches)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: tokens.colorBorder),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(name, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DsButton(label: 'Primary', onPressed: () {}),
            DsButton(
              label: 'Secondary',
              variant: DsButtonVariant.secondary,
              onPressed: () {},
            ),
            const DsBadge(label: 'Success', variant: DsBadgeVariant.success),
            const DsBadge(label: 'Warning', variant: DsBadgeVariant.warning),
          ],
        ),
      ],
    );
  }
}
