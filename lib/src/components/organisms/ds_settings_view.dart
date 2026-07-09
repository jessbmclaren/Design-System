import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_spacing.dart';

/// A titled group of related settings rows within a [DsSettingsView].
///
/// A section renders a [title] (and optional [description]) above a bordered,
/// rounded container that wraps [children] with hairline dividers between them.
/// Children are typically rows such as `DsListItem`, form fields, toggles, or
/// any widget that represents a single setting.
@immutable
class DsSettingsSection {
  /// Creates a settings section.
  const DsSettingsSection({
    required this.title,
    this.description,
    required this.children,
  });

  /// The section heading, rendered in the `headingSm` type token.
  final String title;

  /// An optional supporting line rendered beneath [title] in `bodySm`.
  final String? description;

  /// The rows that make up this section, stacked vertically and separated by
  /// hairline dividers.
  final List<Widget> children;
}

/// A scrollable settings page composed of titled [DsSettingsSection]s.
///
/// The page centres its content and caps it at [maxContentWidth] on wide
/// screens, applying comfortable horizontal padding that tightens on compact
/// window sizes. Each section renders its title and optional description above
/// a bordered, rounded card wrapping the section's children with 1dp dividers.
///
/// The view is fully responsive from a 320dp phone up to large desktops and
/// scrolls vertically via a [ListView], so it can host an arbitrary number of
/// sections without overflow.
///
/// ```dart
/// DsSettingsView(
///   header: const Text('Settings'),
///   sections: [
///     DsSettingsSection(
///       title: 'Account',
///       description: 'Manage how you sign in.',
///       children: [emailRow, passwordRow],
///     ),
///     DsSettingsSection(
///       title: 'Notifications',
///       children: [emailToggle, pushToggle],
///     ),
///   ],
/// )
/// ```
class DsSettingsView extends StatelessWidget {
  /// Creates a settings view.
  const DsSettingsView({
    super.key,
    required this.sections,
    this.header,
    this.footer,
    this.maxContentWidth = 720,
  });

  /// The settings sections to render, in order.
  final List<DsSettingsSection> sections;

  /// An optional widget rendered above the first section, e.g. a page title.
  final Widget? header;

  /// An optional widget rendered below the last section, e.g. a sign-out
  /// action or legal note.
  final Widget? footer;

  /// The maximum width the content column is allowed to grow to on wide
  /// screens. Content narrower than this is centred.
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final windowSize = DsBreakpoints.of(context);

    // Horizontal padding tightens on small phones so 320dp never feels cramped.
    final double horizontalPadding =
        windowSize == DsWindowSize.compact ? DsSpacing.lg : DsSpacing.xl;

    final children = <Widget>[
      if (header != null) ...<Widget>[
        header!,
        const SizedBox(height: DsSpacing.xl),
      ],
      for (var i = 0; i < sections.length; i++) ...<Widget>[
        if (i > 0) const SizedBox(height: DsSpacing.xxl),
        _DsSettingsSectionView(section: sections[i], tokens: tokens),
      ],
      if (footer != null) ...<Widget>[
        const SizedBox(height: DsSpacing.xxl),
        footer!,
      ],
    ];

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: DsSpacing.xl,
      ),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders a single [DsSettingsSection]: heading, optional description and a
/// bordered card wrapping the section children with dividers.
class _DsSettingsSectionView extends StatelessWidget {
  const _DsSettingsSectionView({
    required this.section,
    required this.tokens,
  });

  final DsSettingsSection section;
  final DsTokens tokens;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(tokens.formBorderRadius);

    final rows = <Widget>[];
    for (var i = 0; i < section.children.length; i++) {
      if (i > 0) {
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            color: tokens.colorBorder,
          ),
        );
      }
      rows.add(section.children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            section.title,
            style: tokens.headingSm.toTextStyle(color: tokens.colorText),
          ),
        ),
        if (section.description != null) ...<Widget>[
          const SizedBox(height: DsSpacing.xs),
          Text(
            section.description!,
            style:
                tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
          ),
        ],
        const SizedBox(height: DsSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.formBackgroundColor,
            borderRadius: radius,
            border: Border.all(color: tokens.colorBorder),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: rows,
            ),
          ),
        ),
      ],
    );
  }
}
