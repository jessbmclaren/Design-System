import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// A preview frame that renders a live demo at a chosen viewport width, so
/// readers can see how a pattern responds from a small phone up to desktop.
class DeviceFrame extends StatefulWidget {
  const DeviceFrame({super.key, required this.child});

  /// The live demo to render.
  final Widget child;

  @override
  State<DeviceFrame> createState() => _DeviceFrameState();
}

enum _Viewport {
  phone('Phone', 320),
  tablet('Tablet', 768),
  desktop('Desktop', null);

  const _Viewport(this.label, this.width);
  final String label;
  final double? width;
}

class _DeviceFrameState extends State<DeviceFrame> {
  _Viewport _viewport = _Viewport.desktop;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Live example',
              style: theme.textTheme.titleSmall,
            ),
            const Spacer(),
            _ViewportToggle(
              value: _viewport,
              onChanged: (v) => setState(() => _viewport = v),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: tokens.offsetBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.colorBorder),
          ),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: _ConstrainedViewport(
              width: _viewport.width,
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConstrainedViewport extends StatelessWidget {
  const _ConstrainedViewport({required this.width, required this.child});

  final double? width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (width == null) {
      return child;
    }
    final media = MediaQuery.of(context);
    // Constrain the width AND report that width to MediaQuery so components
    // that read the window size resolve their breakpoints against the frame.
    return SizedBox(
      width: width,
      child: MediaQuery(
        data: media.copyWith(size: Size(width!, media.size.height)),
        child: child,
      ),
    );
  }
}

class _ViewportToggle extends StatelessWidget {
  const _ViewportToggle({required this.value, required this.onChanged});

  final _Viewport value;
  final ValueChanged<_Viewport> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Wrap(
      spacing: 4,
      children: [
        for (final v in _Viewport.values)
          _ToggleChip(
            label: v.label,
            selected: v == value,
            onTap: () => onChanged(v),
            tokens: tokens,
          ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.tokens,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final DsTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? tokens.buttonPrimaryColorBackground
          : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected
                  ? tokens.buttonPrimaryColorText
                  : tokens.colorSecondaryText,
            ),
          ),
        ),
      ),
    );
  }
}
