import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// A vertical list of rows separated by dividers.
///
/// Pass any widgets as [children] — typically [DsListItem]s. A hairline
/// [Divider] is drawn between adjacent children when [showDividers] is true.
///
/// [DsList] lays its children out in a [Column], so it sizes to its content
/// and can be embedded inside scroll views, cards, or sheets. It does not
/// scroll on its own; wrap it in a scrollable if the content may exceed the
/// viewport.
///
/// Set [bordered] to wrap the list in a rounded, hairline-bordered container
/// with clipped corners — useful for presenting the list as a grouped card.
class DsList extends StatelessWidget {
  const DsList({
    super.key,
    required this.children,
    this.showDividers = true,
    this.bordered = false,
  });

  /// The rows to display, typically [DsListItem]s.
  final List<Widget> children;

  /// Whether to draw a hairline divider between adjacent [children].
  final bool showDividers;

  /// Whether to wrap the list in a rounded, bordered container.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (showDividers && i < children.length - 1) {
        rows.add(Divider(
          height: 1,
          thickness: 1,
          color: tokens.colorBorder,
        ));
      }
    }

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );

    if (!bordered) {
      return column;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        border: Border.all(color: tokens.colorBorder),
      ),
      child: column,
    );
  }
}
