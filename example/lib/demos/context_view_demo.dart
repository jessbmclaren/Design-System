import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Context view page: an inspector panel pinned beside a
/// primary content column. On wide layouts the panel sits at a fixed width to
/// the right of the main column; on narrow layouts it fills the available
/// width. A header action toggles whether the record is being watched, so the
/// panel demonstrates in-place state without any timers or animation.
class ContextViewDemo extends StatefulWidget {
  const ContextViewDemo({super.key});

  @override
  State<ContextViewDemo> createState() => _ContextViewDemoState();
}

class _ContextViewDemoState extends State<ContextViewDemo> {
  bool _watching = true;

  @override
  Widget build(BuildContext context) {
    final panel = DsContextView(
      title: 'Deployment details',
      onClose: () {},
      actions: [
        DsButton(
          label: _watching ? 'Watching' : 'Watch',
          variant:
              _watching ? DsButtonVariant.primary : DsButtonVariant.secondary,
          icon: _watching ? Icons.visibility : Icons.visibility_outlined,
          onPressed: () => setState(() => _watching = !_watching),
        ),
      ],
      footer: DsButton(
        label: 'View logs',
        variant: DsButtonVariant.secondary,
        onPressed: () {},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              DsAvatar(name: 'Priya Nair', size: 36),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Priya Nair',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Triggered the release'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const DsBadge(label: 'Succeeded', variant: DsBadgeVariant.success),
          const SizedBox(height: 20),
          const _Field(label: 'Environment', value: 'Production'),
          const _Field(label: 'Version', value: 'v4.12.0'),
          const _Field(label: 'Commit', value: 'a3c9f1e'),
          const _Field(label: 'Duration', value: '2m 18s'),
          const _Field(label: 'Finished', value: 'Today at 09:41'),
        ],
      ),
    );

    return SizedBox(
      height: 460,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 640;
          if (!wide) {
            return panel;
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: _MainContent()),
              SizedBox(width: 360, child: panel),
            ],
          );
        },
      ),
    );
  }
}

/// A stand-in for the primary content the context view sits beside.
class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return ColoredBox(
      color: tokens.colorBackground,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Releases',
              style: tokens.headingMd.toTextStyle(color: tokens.colorText),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a deployment to inspect its details in the panel.',
              style: TextStyle(color: tokens.colorSecondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

/// A label / value row used inside the context view body.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: TextStyle(color: tokens.colorSecondaryText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: tokens.colorText),
            ),
          ),
        ],
      ),
    );
  }
}
