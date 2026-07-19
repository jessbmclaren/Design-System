import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Breakpoints page: a panel that measures its own width,
/// resolves the window class for it and highlights the active range. The
/// desktop and phone screenshots land in different classes, which is the
/// point.
class BreakpointsDemo extends StatelessWidget {
  const BreakpointsDemo({super.key});

  static const _classes = [
    (DsWindowSize.compact, 'Compact', 'below 600dp'),
    (DsWindowSize.medium, 'Medium', '600 to 839dp'),
    (DsWindowSize.expanded, 'Expanded', '840 to 1199dp'),
    (DsWindowSize.large, 'Large', '1200dp and up'),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final size = DsBreakpoints.windowSizeFor(width);
        final wide = width >= DsBreakpoints.medium;
        final tileWidth =
            wide ? (width - DsSpacing.md * 2) / 3 : width;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This panel measures ${width.round()}dp, the ${size.name} class',
              style:
                  tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
            ),
            const SizedBox(height: DsSpacing.lg),
            Wrap(
              spacing: DsSpacing.md,
              runSpacing: DsSpacing.md,
              children: [
                for (final (value, label, range) in _classes)
                  SizedBox(
                    width: tileWidth,
                    child: _ClassTile(
                      label: label,
                      range: range,
                      active: value == size,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// One window-class tile; the active class carries the accent border.
class _ClassTile extends StatelessWidget {
  const _ClassTile({
    required this.label,
    required this.range,
    required this.active,
  });

  final String label;
  final String range;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active
            ? tokens.colorPrimary.withValues(alpha: 0.06)
            : tokens.colorBackground,
        border: Border.all(
          color: active ? tokens.formAccentColor : tokens.colorBorder,
        ),
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
            Text(
              label,
              style: tokens.headingXs.toTextStyle(
                color: active ? tokens.colorPrimary : tokens.colorText,
              ),
            ),
            const SizedBox(height: DsSpacing.xs),
            Text(
              range,
              style:
                  tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
