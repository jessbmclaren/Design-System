import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Link page: primary and secondary hyperlinks, an external
/// link with the "open in new" glyph, a link with a trailing chevron and a
/// disabled link. The full range of `DsLink` affordances in one compact view.
class LinkDemo extends StatelessWidget {
  const LinkDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            DsLink(label: 'View invoice', onPressed: _noop),
            DsLink(
              label: 'Billing settings',
              variant: DsLinkVariant.secondary,
              onPressed: _noop,
            ),
          ],
        ),
        SizedBox(height: 12),
        DsLink(
          label: 'API documentation',
          external: true,
          onPressed: _noop,
        ),
        SizedBox(height: 4),
        DsLink(
          label: 'All activity',
          trailingIcon: Icons.chevron_right,
          onPressed: _noop,
        ),
        SizedBox(height: 4),
        // A null onPressed renders the link disabled and muted.
        DsLink(label: 'Archived (unavailable)'),
      ],
    );
  }
}

void _noop() {}
