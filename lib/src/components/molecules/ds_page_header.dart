import 'package:flutter/material.dart';
import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_breakpoints.dart';

/// A page-level header that pairs a title (and optional subtitle) with a slot
/// for contextual actions.
///
/// Use [DsPageHeader] at the top of a screen or major section to establish
/// hierarchy: the [title] is rendered with the large heading token, an optional
/// [subtitle] with the small body token, and any [actions] (typically
/// `DsButton`s) sit alongside or below the title depending on available width.
///
/// The layout is responsive. At [DsBreakpoints.medium] (600dp) and wider the
/// title column and actions share a single row, with actions right-aligned and
/// wrapping if they run long. Below that width the actions stack beneath the
/// title so nothing overflows on small phones (down to 320dp). An optional
/// hairline divider ([showDivider]) closes the header off from the content
/// below.
///
/// This widget is purely declarative (it schedules no timers or animations),
/// so it renders identically in screenshots and live use.
class DsPageHeader extends StatelessWidget {
  /// Creates a page header.
  ///
  /// [title] is required. [subtitle], [leading] and [actions] are optional.
  const DsPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.leading,
    this.showDivider = true,
  });

  /// The primary heading text. Rendered with the large heading token and
  /// truncated with an ellipsis if it cannot fit.
  final String title;

  /// Optional supporting text shown beneath [title] in the secondary text
  /// colour. May wrap to a second line before truncating.
  final String? subtitle;

  /// Contextual actions (for example `DsButton`s) shown to the trailing side of
  /// the title on wide layouts, or stacked beneath it on compact layouts.
  final List<Widget> actions;

  /// Optional widget rendered before the title column, such as an icon or a
  /// back button.
  final Widget? leading;

  /// Whether to draw a one-pixel divider in the border colour beneath the
  /// header. Defaults to true.
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: tokens.headingLg.toTextStyle(color: tokens.colorText),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.xs),
          Text(
            subtitle!,
            style: tokens.bodySm
                .toTextStyle(color: tokens.colorSecondaryText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Resolve a finite width so the Expanded title never receives
        // unbounded constraints (which would throw under a Row/horizontal
        // scroll view). Constrain the header to it.
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final isWide = width >= DsBreakpoints.medium;

        final Widget headerRow = isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: DsSpacing.md),
                  ],
                  Expanded(child: titleColumn),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: DsSpacing.lg),
                    Wrap(
                      spacing: DsSpacing.sm,
                      runSpacing: DsSpacing.sm,
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: actions,
                    ),
                  ],
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: DsSpacing.md),
                      ],
                      Expanded(child: titleColumn),
                    ],
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: DsSpacing.md),
                    Wrap(
                      spacing: DsSpacing.sm,
                      runSpacing: DsSpacing.sm,
                      children: actions,
                    ),
                  ],
                ],
              );

        return SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: DsSpacing.lg),
                child: headerRow,
              ),
              if (showDivider)
                Container(height: 1, color: tokens.colorBorder),
            ],
          ),
        );
      },
    );
  }
}
