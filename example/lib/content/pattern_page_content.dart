// Pure Dart, no Flutter imports.
//
// This model is the single source of truth for every documentation page. It
// is consumed by two things:
//   1. The docs Flutter app, which renders each page (live demo + code + a
//      "View as Markdown" pane).
//   2. tool/generate_markdown.dart, a plain `dart run` CLI that emits the
//      docs/patterns/*.md twins.
//
// Because the CLI cannot import `flutter/material.dart`, this file and the
// markdown emitter must stay Flutter-free.

/// The navigation groups, in display order.
///
/// Organised by purpose (what a component is *for*) rather than by atomic layer.
/// The code stays atomic (`lib/src/components/{atoms,molecules,organisms}`),
/// while the docs navigate by intent so a component is easy to find.
enum DocGroup {
  foundations('Foundations'),
  actions('Actions'),
  inputs('Inputs'),
  display('Display'),
  feedback('Feedback'),
  overlays('Overlays'),
  data('Data'),
  charts('Charts'),
  layout('Layout'),
  patterns('Patterns');

  const DocGroup(this.label);

  /// The human-readable group heading shown in the sidebar and markdown.
  final String label;
}

/// The rendered size of a screenshot in the markdown twin.
enum ShotSize {
  phone('phone', 'Small phone (320dp)'),
  tablet('tablet', 'Tablet (768dp)'),
  desktop('desktop', 'Desktop (1280dp)');

  const ShotSize(this.slug, this.label);

  /// Filename suffix, e.g. `desktop` in `action-buttons_desktop.png`.
  final String slug;

  /// Human-readable caption for the size.
  final String label;
}

/// A screenshot reference embedded in the markdown twin.
class Shot {
  const Shot({required this.pageId, required this.size, this.caption});

  /// The owning page id (used to build the file name).
  final String pageId;

  /// The rendered size.
  final ShotSize size;

  /// An optional caption; falls back to [ShotSize.label].
  final String? caption;

  /// The image path relative to `docs/patterns/`.
  String get path => 'img/${pageId}_${size.slug}.png';

  /// The golden output path relative to the screenshot test file.
  String get goldenPath => '../../../docs/patterns/$path';
}

/// An extra content block rendered after the lead screenshot and before the
/// guidelines. Used mainly by the Foundations "Design tokens" page.
sealed class ContentBlock {
  const ContentBlock();
}

/// A prose paragraph.
class ProseBlock extends ContentBlock {
  const ProseBlock(this.text);
  final String text;
}

/// A subsection heading (renders as an `##` in markdown).
class SubheadingBlock extends ContentBlock {
  const SubheadingBlock(this.text);
  final String text;
}

/// One row in a [VariablesBlock] table.
class VariableRow {
  const VariableRow({
    required this.name,
    required this.type,
    required this.example,
    required this.description,
  });

  /// The variable name, e.g. `buttonPrimaryColorBackground`.
  final String name;

  /// The variable type, e.g. `Color`, `double`, `String`.
  final String type;

  /// An example value, e.g. `#0074D4`, `4`.
  final String example;

  /// What the variable controls.
  final String description;
}

/// A NAME / TYPE / EXAMPLE VALUE table of appearance variables.
class VariablesBlock extends ContentBlock {
  const VariablesBlock({this.title, required this.rows});

  /// Optional heading above the table.
  final String? title;

  /// The variable rows.
  final List<VariableRow> rows;
}

/// A single documentation page: one design pattern or foundation.
class PatternPage {
  const PatternPage({
    required this.id,
    required this.group,
    required this.navTitle,
    required this.title,
    required this.description,
    this.blocks = const [],
    this.dos = const [],
    this.donts = const [],
    this.code,
    this.shots = const [],
    this.hasLiveDemo = true,
    this.related = const [],
  });

  /// URL slug and demo key, e.g. `action-buttons`.
  final String id;

  /// The navigation group this page belongs to.
  final DocGroup group;

  /// Short label shown in the sidebar.
  final String navTitle;

  /// The page heading.
  final String title;

  /// The lead description paragraph, the most important copy on the page.
  final String description;

  /// Extra content blocks (prose, subheadings, variable tables) rendered
  /// after the lead description.
  final List<ContentBlock> blocks;

  /// "Do" guidance bullet points.
  final List<String> dos;

  /// "Don't" guidance bullet points.
  final List<String> donts;

  /// The Dart code sample shown on the page. This exact string is displayed
  /// in the app (syntax-highlighted) and embedded in the markdown twin, so
  /// the two can never disagree.
  final String? code;

  /// Screenshots embedded in the markdown twin.
  final List<Shot> shots;

  /// Whether the app renders a live demo for this page (keyed by [id]).
  final bool hasLiveDemo;

  /// Ids of related pages, shown as "See also" links.
  final List<String> related;
}
