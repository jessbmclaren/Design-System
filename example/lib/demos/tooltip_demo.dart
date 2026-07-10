import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Tooltip page: a compact toolbar of icon-only controls,
/// each wrapped in a [DsTooltip] that names its action on hover or long-press.
///
/// The bubbles stay closed on the first frame, so the demo is screenshot-safe.
class TooltipDemo extends StatelessWidget {
  const TooltipDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: const [
            _ToolbarAction(
              message: 'Copy to clipboard',
              icon: DsIcons.copy,
            ),
            _ToolbarAction(
              message: 'Duplicate row',
              icon: DsIcons.add,
            ),
            _ToolbarAction(
              message: 'Archive',
              icon: DsIcons.archive,
            ),
            _ToolbarAction(
              message: 'Delete permanently',
              icon: DsIcons.delete,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Monthly recurring revenue',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 6),
            const DsTooltip(
              message:
                  'Normalised value of all active subscriptions for the month.',
              child: DsIcon(
                icon: DsIcons.help,
                size: DsIconSize.sm,
                semanticLabel: 'What is monthly recurring revenue?',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// An icon-only toolbar button whose purpose is revealed by its tooltip.
class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DsTooltip(
      message: message,
      child: IconButton(
        icon: DsIcon(icon: icon, semanticLabel: message),
        onPressed: () {},
      ),
    );
  }
}
