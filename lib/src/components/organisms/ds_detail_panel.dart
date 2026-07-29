import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_icon_button.dart';

/// One tab on a [DsDetailPanel].
@immutable
class DsDetailTab {
  /// Creates a tab.
  const DsDetailTab({required this.label, this.count});

  /// What the tab holds.
  final String label;

  /// How many things are in it.
  ///
  /// Rendered beside the label so the answer to "is there anything in there"
  /// arrives before the tap, not after it. A zero is shown, not hidden — an
  /// empty tab that admits it is empty saves a click; one that looks the same
  /// as a full one costs one.
  final int? count;
}

/// The surface a single record is read on: who it is, what it holds, and what
/// can be done to it.
///
/// The counterpart to [DsFocusView]. A focus view is shaped for a *form* — one
/// title, one column of inputs, a commit at the bottom. A record is a different
/// animal: it has an identity rather than a title, several kinds of content
/// rather than one, and its actions operate on something that already exists.
/// Building records out of the form component is what leads to a page headed
/// "Edit vehicle" when nobody is editing anything.
///
/// The anatomy, top to bottom:
///
///  * an **identity block** — [leading] beside [title] and [subtitle], with
///    [status] to their right and the close beyond that. The record names
///    itself, so there is no separate heading;
///  * **[actions]**, on their own row beneath the identity, because a record's
///    verbs are about the thing and belong under its name rather than crowded
///    against the close button;
///  * a **[tabs]** strip, when there is more than one kind of content;
///  * the **body**, which scrolls;
///  * a **[footer]**, pinned, for the one action that changes what the record
///    *is* rather than what it says.
///
/// The panel **owns no width**. It fills the bounds it is given and scrolls
/// inside them, so the host decides whether it docks, overlays, or takes the
/// whole screen on a phone.
///
/// It is a widget rather than a route on purpose: a record's actions raise
/// confirmations and undo messages, and a pushed route paints above the host's
/// message layer — which would put the undo for an action behind the panel that
/// offered it.
class DsDetailPanel extends StatelessWidget {
  /// Creates a detail panel.
  const DsDetailPanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.status,
    this.actions = const <Widget>[],
    this.tabs = const <DsDetailTab>[],
    this.selectedTab = 0,
    this.onTabChanged,
    this.footer,
    this.onClose,
    this.banner,
  });

  /// What the record is called — its registration, its name.
  final String title;

  /// A second identifying line: the reference someone else knows it by.
  final String? subtitle;

  /// An avatar or type glyph, left of the identity.
  final Widget? leading;

  /// The record's state, as a badge. Sits with the identity rather than among
  /// the values, because state is something a record *is*.
  final Widget? status;

  /// The record's verbs — edit, an overflow of the rest.
  final List<Widget> actions;

  /// The kinds of content this record has. One or none renders no strip.
  final List<DsDetailTab> tabs;

  /// Which tab is showing.
  final int selectedTab;

  /// Called with the index of a chosen tab.
  final ValueChanged<int>? onTabChanged;

  /// A notice above the body — a flagged import, an expiry. Renders inside the
  /// scroll so it cannot eat the panel on a phone.
  final Widget? banner;

  /// The selected tab's content.
  final Widget child;

  /// The action that changes what the record is: retire it, restore it.
  /// Pinned, so it does not move with the content and cannot be hit by
  /// accident on the way past.
  final Widget? footer;

  /// Dismisses the panel.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;
    final Color border = tokens.colorBorder;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        border: Border(left: BorderSide(color: border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(unit * 2.5, unit * 2, unit * 1.5, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (leading != null) ...<Widget>[
                      leading!,
                      SizedBox(width: unit * 1.5),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: tokens.headingSm.toTextStyle(
                                color: tokens.colorText,
                              ),
                            ),
                          ),
                          if (subtitle != null) ...<Widget>[
                            SizedBox(height: unit * 0.25),
                            Text(
                              subtitle!,
                              overflow: TextOverflow.ellipsis,
                              style: tokens.bodySm.toTextStyle(
                                color: tokens.colorSecondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (status != null) ...<Widget>[
                      SizedBox(width: unit * 1.5),
                      Padding(
                        padding: EdgeInsets.only(top: unit * 0.25),
                        child: status,
                      ),
                    ],
                    if (onClose != null) ...<Widget>[
                      SizedBox(width: unit),
                      DsIconButton(
                        icon: DsIcons.close,
                        onPressed: onClose,
                        semanticLabel: 'Close',
                        iconSize: DsIconSize.lg,
                        color: tokens.colorSecondaryText,
                      ),
                    ],
                  ],
                ),
                if (actions.isNotEmpty) ...<Widget>[
                  SizedBox(height: unit * 2),
                  // Wrap, not Row: on a phone the verbs stack rather than
                  // squeezing each other into ellipses.
                  Wrap(
                    spacing: unit * 1.5,
                    runSpacing: unit,
                    children: actions,
                  ),
                ],
                SizedBox(height: unit * 2),
              ],
            ),
          ),
          if (tabs.length > 1)
            _TabStrip(
              tabs: tabs,
              selectedIndex: selectedTab,
              onSelected: onTabChanged,
            ),
          Divider(height: 1, thickness: 1, color: border),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(unit * 2.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (banner != null) ...<Widget>[
                    banner!,
                    SizedBox(height: unit * 2.5),
                  ],
                  child,
                ],
              ),
            ),
          ),
          if (footer != null) ...<Widget>[
            Divider(height: 1, thickness: 1, color: border),
            Padding(padding: EdgeInsets.all(unit * 2.5), child: footer),
          ],
        ],
      ),
    );
  }
}

/// The tab strip: labels with their counts, the selected one underlined.
///
/// Scrolls horizontally rather than wrapping. A record can carry six kinds of
/// content and a wrapped strip pushes the record itself below the fold on a
/// phone — the tabs are navigation, and navigation should not cost half the
/// screen.
class _TabStrip extends StatelessWidget {
  const _TabStrip({
    required this.tabs,
    required this.selectedIndex,
    this.onSelected,
  });

  final List<DsDetailTab> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: unit * 2.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < tabs.length; i++)
            Semantics(
              button: true,
              selected: i == selectedIndex,
              child: InkWell(
                onTap: onSelected == null ? null : () => onSelected!(i),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: unit * 1.5,
                    vertical: unit * 1.5,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2,
                        color: i == selectedIndex
                            ? tokens.colorPrimary
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        tabs[i].label,
                        style: tokens.labelSm.toTextStyle(
                          color: i == selectedIndex
                              ? tokens.colorText
                              : tokens.colorSecondaryText,
                        ),
                      ),
                      if (tabs[i].count != null) ...<Widget>[
                        SizedBox(width: unit * 0.75),
                        Text(
                          '${tabs[i].count}',
                          style: tokens.bodySm.toTextStyle(
                            color: tokens.colorSecondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
