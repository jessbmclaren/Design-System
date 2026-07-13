// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Inputs → Segmented control.
final PatternPage segmentedControlPage = PatternPage(
  id: 'segmented-control',
  group: DocGroup.inputs,
  navTitle: 'Segmented control',
  title: 'Segmented control',
  description:
      'A segmented control is a pick-one switch for a small, fixed set of '
      'alternatives that share one axis: a sort direction, a boolean join, a '
      'preview width. `DsSegmentedControl` lays the options out as one bar where '
      'the selected segment fills with the accent colour, so the current choice '
      'reads at a glance and switching is a single tap. It is the shared '
      'primitive behind the And/Or join in the filter builder and the '
      'Ascending/Descending toggle in the sort builder.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'The control is generic over its value, so a segment can carry an enum, a '
      'bool or any domain value. It is controlled: you pass the selected `value` '
      'and are told of a change through `onChanged`, and a null `onChanged` '
      'disables the whole control and drops it from the focus order. Each '
      'segment is keyboard-focusable, activates on Enter and Space and reports '
      'its selected state to assistive technology. Give an icon-only segment a '
      '`semanticLabel` so it still has a name.',
    ),
    ProseBlock(
      'Reach for it only when the options are few and mutually exclusive. Two to '
      'four segments read well on one bar; beyond that the labels crowd, so use '
      'a `DsSelect` instead. Keep the labels short and parallel (Asc / Desc, not '
      'Ascending / Descending order) so every segment is about the same width.',
    ),
  ],
  dos: const [
    'Use it for a small, fixed set of mutually exclusive options that share one '
        'axis.',
    'Keep segment labels short and parallel so the bar stays balanced.',
    'Give an icon-only segment a semanticLabel so assistive technology can name '
        'it.',
    'Keep the control controlled: hold the value in your model and rebuild on '
        'onChanged.',
  ],
  donts: const [
    'Do not use it for more than about four options; reach for a select once '
        'the labels crowd.',
    'Do not use it for an action that fires immediately; a segmented control '
        'records a choice, it does not run a command.',
    'Do not rely on the fill colour alone to signal the choice; keep each '
        'segment clearly labelled.',
  ],
  code: '''
// Status is your own domain enum. The control is controlled: hold the
// value in state and rebuild when onChanged fires.
SortDirection direction = SortDirection.ascending;

DsSegmentedControl<SortDirection>(
  value: direction,
  onChanged: (value) => setState(() => direction = value),
  segments: const [
    DsSegment(
      value: SortDirection.ascending,
      label: 'Asc',
      icon: DsIcons.arrowUp,
      semanticLabel: 'Sort ascending',
    ),
    DsSegment(
      value: SortDirection.descending,
      label: 'Desc',
      icon: DsIcons.arrowDown,
      semanticLabel: 'Sort descending',
    ),
  ],
);
''',
  related: ['select', 'selection-controls', 'button-group'],
);
