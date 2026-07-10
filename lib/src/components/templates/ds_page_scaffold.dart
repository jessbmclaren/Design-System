import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../molecules/ds_page_header.dart';

/// A page-level layout template: a [DsPageHeader] above a scrolling body,
/// centred and width-constrained for comfortable reading.
///
/// Templates sit above organisms in the atomic hierarchy: they define the
/// arrangement of a screen without committing to specific content. Fill
/// [body] with organisms (lists, tables, forms) to realise a concrete page.
///
/// The content is centred and capped at [maxContentWidth] on wide screens and
/// uses tighter horizontal padding on compact ones, so the same page reads
/// well from a 320dp phone up to a desktop.
class DsPageScaffold extends StatelessWidget {
  const DsPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.leading,
    required this.body,
    this.maxContentWidth = DsBreakpoints.contentMaxWidth,
  });

  /// The page title, shown in the header.
  final String title;

  /// Optional supporting text shown beneath the [title].
  final String? subtitle;

  /// Page-level actions, shown in the header and kept visible while the body
  /// scrolls.
  final List<Widget> actions;

  /// An optional leading widget in the header, such as a back link.
  final Widget? leading;

  /// The page content, typically composed of organisms.
  final Widget body;

  /// The maximum content width on wide screens.
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final compact = DsBreakpoints.of(context) == DsWindowSize.compact;
    // The page rhythm derives from the base spacing unit, so overriding
    // DsTokens.spacingUnit rescales the whole layout's whitespace.
    final unit = DsTokens.of(context).spacingUnit;
    final horizontal = compact ? unit * 2 : unit * 4;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontal,
              vertical: unit * 3.5,
            ),
            children: [
              DsPageHeader(
                title: title,
                subtitle: subtitle,
                actions: actions,
                leading: leading,
              ),
              SizedBox(height: unit * 3),
              body,
              SizedBox(height: unit * 6),
            ],
          ),
        ),
      ),
    );
  }
}
