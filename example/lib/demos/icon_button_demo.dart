import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Icon button page: enabled and disabled states, then the
/// control at three sizes. The buttons are real [DsIconButton]s, so hover,
/// press and keyboard focus behave exactly as they do in a product.
/// Screenshot safe: no timers, network or randomness.
class IconButtonDemo extends StatelessWidget {
  const IconButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('States', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            DsIconButton(
              icon: DsIcons.close,
              semanticLabel: 'Close',
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            DsIconButton(
              icon: DsIcons.edit,
              semanticLabel: 'Edit',
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            DsIconButton(
              icon: DsIcons.moreHorizontal,
              semanticLabel: 'More actions',
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            // A null onPressed disables the button and removes it from the
            // focus order.
            const DsIconButton(
              icon: DsIcons.refresh,
              semanticLabel: 'Refresh',
              onPressed: null,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Sizes', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Raise size and iconSize together so the glyph keeps its
            // proportion inside the circle.
            DsIconButton(
              icon: DsIcons.add,
              semanticLabel: 'Add (dense)',
              size: 32,
              iconSize: DsIconSize.sm,
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            DsIconButton(
              icon: DsIcons.add,
              semanticLabel: 'Add (default)',
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            DsIconButton(
              icon: DsIcons.add,
              semanticLabel: 'Add (prominent)',
              size: 48,
              iconSize: DsIconSize.lg,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Hover or press for the soft themed fill. Keyboard focus draws an '
          'accent ring instead, so it reads differently from hover.',
          style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
        ),
      ],
    );
  }
}
