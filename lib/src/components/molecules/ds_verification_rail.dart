import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../../tokens/ds_typography.dart';
import '../atoms/ds_icon_badge.dart';

/// The progress state of one [DsVerificationSection].
enum DsVerificationSectionState {
  /// The section is complete. Its marker shows a check.
  done,

  /// The section is the one in progress. Its marker and label are emphasised
  /// and its sub-steps, if any, are shown.
  active,

  /// The section has not been reached yet. Its marker stays neutral.
  upcoming,
}

/// One labelled section of a [DsVerificationRail].
@immutable
class DsVerificationSection {
  /// Creates a rail section.
  const DsVerificationSection({
    required this.label,
    this.state = DsVerificationSectionState.upcoming,
    this.subSteps = const <String>[],
  });

  /// The short name of the section, shown beside its marker.
  final String label;

  /// The section's progress state. Defaults to
  /// [DsVerificationSectionState.upcoming].
  final DsVerificationSectionState state;

  /// Optional sub-step labels listed beneath the section while it is
  /// [DsVerificationSectionState.active]. Hidden in every other state and in
  /// the compact horizontal layout.
  final List<String> subSteps;
}

/// A vertical progress rail for a sectioned flow, such as a verification
/// takeover.
///
/// [DsVerificationRail] lists the flow's sections top to bottom, each with a
/// circular marker and a label. A done section's marker is a [DsIconBadge]
/// check, the active section shows its 1-based number on the primary colour
/// pair and upcoming sections stay on the neutral badge pair. The active
/// section also expands its optional sub-steps into a dotted list, with
/// [activeSubStep] naming the one in progress.
///
/// The component is controlled: the caller owns which section is in which
/// state and updates [sections] as the flow advances. When [onSectionSelected]
/// is set, done sections become tappable so the user can jump back to an
/// earlier section; active and upcoming sections are never interactive.
///
/// ## Responsiveness
///
/// The rail watches its own width through a [LayoutBuilder]. Below
/// [compactBreakpoint] it swaps the vertical list for a compact summary: the
/// active section's marker and label with a "Step n of N" caption beneath,
/// which holds its single line however many sections the flow has. The
/// compact form is informational only, so wire Back and Continue actions
/// elsewhere on small screens.
///
/// The rail never scrolls itself. Like the library's other list-like
/// components it renders at its natural height, so give it a scrollable
/// parent when the section list can outgrow the viewport.
///
/// All colours, spacing and type come from [DsTokens], and the widget runs no
/// timers or animations, so it renders deterministically in screenshots.
///
/// ```dart
/// DsVerificationRail(
///   sections: const [
///     DsVerificationSection(
///       label: 'Business',
///       state: DsVerificationSectionState.active,
///       subSteps: ['Type', 'Details'],
///     ),
///     DsVerificationSection(label: 'Identity'),
///   ],
///   activeSubStep: 1,
///   onSectionSelected: (index) => _jumpTo(index),
/// )
/// ```
class DsVerificationRail extends StatelessWidget {
  /// Creates a vertical verification progress rail.
  const DsVerificationRail({
    super.key,
    required this.sections,
    this.activeSubStep = 0,
    this.onSectionSelected,
    this.compactBreakpoint = 200,
    this.compactShowsAllMarkers = false,
  });

  /// The flow's sections, in order. The caller keeps each section's state up
  /// to date as the flow advances.
  final List<DsVerificationSection> sections;

  /// The zero-based index of the sub-step in progress within the active
  /// section. Ignored when the active section has no sub-steps. Defaults
  /// to 0.
  final int activeSubStep;

  /// Called with a done section's index when it is tapped, so the user can
  /// jump back to an earlier section. When null (the default) no section is
  /// interactive.
  final ValueChanged<int>? onSectionSelected;

  /// The rail width, in logical pixels, below which the vertical list swaps
  /// for the compact horizontal summary. Defaults to 200.
  final double compactBreakpoint;

  /// Whether the compact summary shows a marker for every section (a check
  /// when done, otherwise the section number) beside the active section's
  /// title, rather than only the single active marker with a "Step n of N"
  /// caption. Defaults to false. The all-markers row reads the whole journey
  /// at a glance, but needs the width for one marker per section.
  final bool compactShowsAllMarkers;

  /// The marker diameter shared by both layouts.
  static const double _markerSize = 28;

  /// The narrowest active-section label the all-markers compact strip keeps.
  /// When a marker per section plus this would overflow the rail's width, the
  /// compact summary falls back to the single-marker form rather than squash
  /// the label to nothing or overflow the row.
  static const double _minCompactLabelWidth = 48;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Resolve a finite width so the label rows' Expanded children never
        // receive unbounded constraints.
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final Widget child;
        if (width >= compactBreakpoint) {
          child = _buildVertical(tokens);
        } else if (compactShowsAllMarkers && _allMarkersFit(width, tokens)) {
          child = _buildCompactAllMarkers(tokens);
        } else {
          // The all-markers strip cannot fit a marker per section here, so fall
          // back to the single-marker summary, which always fits.
          child = _buildCompact(tokens);
        }
        return SizedBox(width: width, child: child);
      },
    );
  }

  /// The full vertical rail: one row per section, the active section expanded
  /// into its sub-steps.
  Widget _buildVertical(DsTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 0; i < sections.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: tokens.spacingUnit),
          _SectionRow(
            tokens: tokens,
            section: sections[i],
            index: i,
            count: sections.length,
            onSelected: _handlerFor(i),
          ),
          if (sections[i].state == DsVerificationSectionState.active &&
              sections[i].subSteps.isNotEmpty)
            _SubSteps(
              tokens: tokens,
              steps: sections[i].subSteps,
              activeIndex: activeSubStep,
            ),
        ],
      ],
    );
  }

  /// The compact fallback: the active section's marker and label with a
  /// "Step n of N" caption, so the summary keeps one line however many
  /// sections the flow has. Informational only, so nothing is tappable here.
  Widget _buildCompact(DsTokens tokens) {
    int? activeIndex;
    for (var i = 0; i < sections.length; i++) {
      if (sections[i].state == DsVerificationSectionState.active) {
        activeIndex = i;
        break;
      }
    }
    final activeLabel = activeIndex == null ? null : sections[activeIndex].label;

    final done = sections
        .where((s) => s.state == DsVerificationSectionState.done)
        .length;
    final caption = activeIndex == null
        ? '$done of ${sections.length} complete'
        : 'Step ${activeIndex + 1} of ${sections.length}';

    return Semantics(
      container: true,
      label: _compactSemanticLabel(activeLabel),
      child: ExcludeSemantics(
        child: Row(
          children: <Widget>[
            if (activeIndex != null) ...<Widget>[
              _Marker(
                tokens: tokens,
                state: DsVerificationSectionState.active,
                number: activeIndex + 1,
              ),
              SizedBox(width: tokens.spacingUnit * 1.5),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (activeLabel != null)
                    Text(
                      activeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tokens.bodyMd
                          .copyWith(fontWeight: tokens.strongLabelFontWeight)
                          .toTextStyle(color: tokens.colorText),
                    ),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tokens.bodySm
                        .toTextStyle(color: tokens.colorSecondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Whether a marker per section, the gaps between them and a readable slice
  /// of the active label fit [width]. Below this the all-markers strip would
  /// overflow, so the compact summary falls back to the single marker.
  bool _allMarkersFit(double width, DsTokens tokens) {
    final n = sections.length;
    if (n == 0) return true;
    final markers = n * _markerSize + (n - 1) * tokens.spacingUnit;
    return markers + tokens.spacingUnit * 1.5 + _minCompactLabelWidth <= width;
  }

  /// The compact all-markers summary: a marker for every section (a check when
  /// done, otherwise its number) with the active section's title alongside, so
  /// the whole journey reads at a glance on a narrow rail.
  Widget _buildCompactAllMarkers(DsTokens tokens) {
    int? activeIndex;
    for (var i = 0; i < sections.length; i++) {
      if (sections[i].state == DsVerificationSectionState.active) {
        activeIndex = i;
        break;
      }
    }
    final activeLabel = activeIndex == null ? null : sections[activeIndex].label;

    return Semantics(
      container: true,
      label: _compactSemanticLabel(activeLabel),
      child: ExcludeSemantics(
        child: Row(
          children: <Widget>[
            for (var i = 0; i < sections.length; i++) ...<Widget>[
              if (i > 0) SizedBox(width: tokens.spacingUnit),
              _Marker(tokens: tokens, state: sections[i].state, number: i + 1),
            ],
            if (activeLabel != null) ...<Widget>[
              SizedBox(width: tokens.spacingUnit * 1.5),
              Expanded(
                child: Text(
                  activeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.bodyMd
                      .copyWith(fontWeight: DsTypography.semiBold)
                      .toTextStyle(color: tokens.colorText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The accessible summary of the compact layout, since its markers carry no
  /// text of their own.
  String _compactSemanticLabel(String? activeLabel) {
    final done = sections
        .where((s) => s.state == DsVerificationSectionState.done)
        .length;
    final progress = '$done of ${sections.length} sections complete';
    if (activeLabel == null) return progress;
    return '$activeLabel, $progress';
  }

  /// The tap handler for the section at [index], or null when the section is
  /// not interactive. Only done sections can be selected.
  VoidCallback? _handlerFor(int index) {
    final onSelected = onSectionSelected;
    if (onSelected == null) return null;
    if (sections[index].state != DsVerificationSectionState.done) return null;
    return () => onSelected(index);
  }
}

/// One section's marker and label, tappable when the section is done and the
/// rail has an [DsVerificationRail.onSectionSelected] callback.
class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.tokens,
    required this.section,
    required this.index,
    required this.count,
    required this.onSelected,
  });

  final DsTokens tokens;
  final DsVerificationSection section;
  final int index;
  final int count;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final active = section.state == DsVerificationSectionState.active;
    final upcoming = section.state == DsVerificationSectionState.upcoming;

    final label = Text(
      section.label,
      style: tokens.bodyMd
          .copyWith(
            fontWeight:
                active ? tokens.strongLabelFontWeight : DsTypography.medium,
          )
          .toTextStyle(
            color: upcoming ? tokens.colorSecondaryText : tokens.colorText,
          ),
    );

    final row = ConstrainedBox(
      // A 48dp minimum keeps tappable rows accessible and gives every row the
      // same vertical rhythm.
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: <Widget>[
          _Marker(tokens: tokens, state: section.state, number: index + 1),
          SizedBox(width: tokens.spacingUnit * 1.5),
          Expanded(child: label),
        ],
      ),
    );

    final stateLabel = switch (section.state) {
      DsVerificationSectionState.done => 'complete',
      DsVerificationSectionState.active => 'current section',
      DsVerificationSectionState.upcoming => 'not started',
    };

    final semanticLabel =
        '${section.label}, section ${index + 1} of $count, $stateLabel';

    if (onSelected == null) {
      return Semantics(
        container: true,
        label: semanticLabel,
        child: ExcludeSemantics(child: row),
      );
    }

    return Semantics(
      container: true,
      button: true,
      enabled: true,
      label: semanticLabel,
      // Expose the tap action on the announced node so an assistive-technology
      // activate gesture jumps back, matching the pointer and keyboard paths.
      // onSelected is non-null here: the inert case returned above.
      onTap: onSelected,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          child: InkWell(
            onTap: onSelected,
            borderRadius: BorderRadius.circular(tokens.formBorderRadius),
            child: row,
          ),
        ),
      ),
    );
  }
}

/// The circular section marker: a check when done, otherwise the section's
/// 1-based number on the primary or neutral badge pair.
class _Marker extends StatelessWidget {
  const _Marker({
    required this.tokens,
    required this.state,
    required this.number,
  });

  final DsTokens tokens;
  final DsVerificationSectionState state;
  final int number;

  @override
  Widget build(BuildContext context) {
    if (state == DsVerificationSectionState.done) {
      return const DsIconBadge(
        icon: DsIcons.check,
        tone: DsIconBadgeTone.primary,
        size: DsVerificationRail._markerSize,
      );
    }

    final active = state == DsVerificationSectionState.active;
    final background = active
        ? tokens.buttonPrimaryColorBackground
        : tokens.badgeNeutralColorBackground;
    final foreground = active
        ? tokens.buttonPrimaryColorText
        : tokens.badgeNeutralColorText;

    return Container(
      width: DsVerificationRail._markerSize,
      height: DsVerificationRail._markerSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        '$number',
        style: tokens.labelSm
            .copyWith(fontWeight: tokens.strongLabelFontWeight)
            .toTextStyle(color: foreground)
            .copyWith(height: 1),
      ),
    );
  }
}

/// The dotted sub-step list under the active section, with hairline connector
/// segments between the dots.
class _SubSteps extends StatelessWidget {
  const _SubSteps({
    required this.tokens,
    required this.steps,
    required this.activeIndex,
  });

  final DsTokens tokens;
  final List<String> steps;
  final int activeIndex;

  /// The width of the dot column, centred under the section marker.
  static const double _dotColumn = 16;

  @override
  Widget build(BuildContext context) {
    // Centre the dot column under the marker's centre line.
    const indent = DsVerificationRail._markerSize / 2 - _dotColumn / 2;

    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: tokens.spacingUnit / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < steps.length; i++) ...<Widget>[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.only(left: _dotColumn / 2 - 0.5),
                child: Container(
                  width: 1,
                  height: tokens.spacingUnit * 1.5,
                  color: tokens.colorBorderSubtle,
                ),
              ),
            _SubStepRow(
              tokens: tokens,
              label: steps[i],
              active: i == activeIndex,
              index: i,
              count: steps.length,
            ),
          ],
        ],
      ),
    );
  }
}

/// One sub-step: a small dot and its label.
class _SubStepRow extends StatelessWidget {
  const _SubStepRow({
    required this.tokens,
    required this.label,
    required this.active,
    required this.index,
    required this.count,
  });

  final DsTokens tokens;
  final String label;
  final bool active;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: <Widget>[
        SizedBox(
          width: _SubSteps._dotColumn,
          height: _SubSteps._dotColumn,
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? tokens.formAccentColor : tokens.colorBorder,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        SizedBox(width: tokens.spacingUnit * 1.5),
        Expanded(
          child: Text(
            label,
            style: tokens.bodySm
                .copyWith(
                  fontWeight:
                      active ? DsTypography.medium : DsTypography.regular,
                )
                .toTextStyle(
                  color: active ? tokens.colorText : tokens.colorSecondaryText,
                ),
          ),
        ),
      ],
    );

    final stateLabel = active ? 'current step' : 'step';
    return Semantics(
      container: true,
      label: '$label, $stateLabel ${index + 1} of $count',
      child: ExcludeSemantics(child: row),
    );
  }
}
