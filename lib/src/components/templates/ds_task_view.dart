import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_icon_button.dart';
import '../molecules/ds_footer_actions.dart';

/// A full-page surface for a single task: enter, do one job, leave.
///
/// [DsTaskView] is the frame between [DsPageScaffold] (a header above a
/// scrolling body, with no pinned actions) and `DsOnboardingWizard` (a
/// stepper-led flow). It gives one job its own page: a bordered header
/// carrying a back affordance, the [title] and an optional [subtitle], an
/// optional [banner] beneath it, the [body] centred in a readable column, and
/// the actions pinned along the bottom edge where a thumb reaches them.
///
/// The header grows with the user's text scale rather than clipping, the body
/// is capped at [maxBodyWidth] and scrolls when [scrollable], and the footer
/// is [DsFooterActions], so the actions sit in a row on a wide page and stack
/// full-width, primary first, on a narrow one. The pinned footer respects the
/// safe area and the keyboard inset, so a focused field is never hidden
/// beneath it.
///
/// ```dart
/// DsTaskView(
///   title: 'Add a vehicle',
///   subtitle: 'Step 2 of 3',
///   onBack: () => Navigator.of(context).maybePop(),
///   body: const VehicleForm(),
///   primaryLabel: 'Save vehicle',
///   onPrimary: _save,
///   secondaryLabel: 'Save draft',
///   onSecondary: _saveDraft,
/// )
/// ```
class DsTaskView extends StatelessWidget {
  /// Creates a single-task page.
  const DsTaskView({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.backIcon = DsIcons.arrowBack,
    this.backSemanticLabel = 'Back',
    this.headerTrailing,
    this.banner,
    required this.body,
    this.maxBodyWidth = 720,
    this.scrollable = true,
    required this.primaryLabel,
    this.onPrimary,
    this.primaryPending = false,
    this.primaryTrailingIcon,
    this.secondaryLabel,
    this.onSecondary,
    this.footerBackLabel,
    this.onFooterBack,
  });

  /// The task's name, shown in the header.
  final String title;

  /// Optional supporting line beneath the [title], such as a step counter.
  final String? subtitle;

  /// Called when the header's leading affordance is pressed. Null hides it.
  final VoidCallback? onBack;

  /// The glyph on the header's leading affordance. Defaults to a back arrow;
  /// pass [DsIcons.close] for a task that dismisses rather than returns.
  final IconData backIcon;

  /// The name assistive technology announces for the leading affordance.
  final String backSemanticLabel;

  /// Optional content on the header's trailing edge, such as a status badge.
  final Widget? headerTrailing;

  /// An optional full-width slot beneath the header, typically a `DsBanner`.
  final Widget? banner;

  /// The task's content, centred and capped at [maxBodyWidth].
  final Widget body;

  /// The widest the body column grows before the surplus is centred.
  final double maxBodyWidth;

  /// Whether the body scrolls. Set false when the body owns its own scrolling
  /// (a list, a grid) so the page does not nest two scroll views.
  final bool scrollable;

  /// The label on the footer's primary action.
  final String primaryLabel;

  /// Called when the primary action is pressed. Null disables it.
  final VoidCallback? onPrimary;

  /// Whether the primary action is in flight, which shows its spinner.
  final bool primaryPending;

  /// An optional trailing glyph on the primary action.
  final IconData? primaryTrailingIcon;

  /// The label on an optional secondary action beside the primary one.
  final String? secondaryLabel;

  /// Called when the secondary action is pressed. Null disables it.
  final VoidCallback? onSecondary;

  /// The label on an optional footer back action, shown on the leading edge.
  final String? footerBackLabel;

  /// Called when the footer's back action is pressed.
  final VoidCallback? onFooterBack;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;

    final Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBodyWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: unit * 2,
            vertical: unit * 3,
          ),
          child: body,
        ),
      ),
    );

    return Material(
      color: tokens.colorBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _TaskHeader(
              tokens: tokens,
              title: title,
              subtitle: subtitle,
              onBack: onBack,
              backIcon: backIcon,
              backSemanticLabel: backSemanticLabel,
              trailing: headerTrailing,
            ),
            ?banner,
            Expanded(
              child: scrollable
                  ? SingleChildScrollView(child: content)
                  : content,
            ),
            _TaskFooter(
              tokens: tokens,
              primaryLabel: primaryLabel,
              onPrimary: onPrimary,
              primaryPending: primaryPending,
              primaryTrailingIcon: primaryTrailingIcon,
              secondaryLabel: secondaryLabel,
              onSecondary: onSecondary,
              backLabel: footerBackLabel,
              onFooterBack: onFooterBack,
            ),
          ],
        ),
      ),
    );
  }
}

/// The bordered header band: leading affordance, title and subtitle, trailing
/// slot. Its height is a minimum, so it grows under a large text scale.
class _TaskHeader extends StatelessWidget {
  const _TaskHeader({
    required this.tokens,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.backIcon,
    required this.backSemanticLabel,
    required this.trailing,
  });

  final DsTokens tokens;
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final IconData backIcon;
  final String backSemanticLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final double unit = tokens.spacingUnit;
    return Container(
      constraints: BoxConstraints(minHeight: unit * 8),
      padding: EdgeInsets.symmetric(horizontal: unit * 2, vertical: unit),
      decoration: BoxDecoration(
        color: tokens.colorBackground,
        border: Border(bottom: BorderSide(color: tokens.colorBorderSubtle)),
      ),
      child: Row(
        children: <Widget>[
          if (onBack != null) ...<Widget>[
            DsIconButton(
              icon: backIcon,
              semanticLabel: backSemanticLabel,
              onPressed: onBack,
            ),
            SizedBox(width: unit),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style:
                        tokens.headingMd.toTextStyle(color: tokens.colorText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: tokens.bodySm
                        .toTextStyle(color: tokens.colorSecondaryText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            SizedBox(width: unit),
            Flexible(child: trailing!),
          ],
        ],
      ),
    );
  }
}

/// The pinned action bar: a hairline above [DsFooterActions], inset for the
/// keyboard so a focused field never hides beneath it.
class _TaskFooter extends StatelessWidget {
  const _TaskFooter({
    required this.tokens,
    required this.primaryLabel,
    required this.onPrimary,
    required this.primaryPending,
    required this.primaryTrailingIcon,
    required this.secondaryLabel,
    required this.onSecondary,
    required this.backLabel,
    required this.onFooterBack,
  });

  final DsTokens tokens;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryPending;
  final IconData? primaryTrailingIcon;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? backLabel;
  final VoidCallback? onFooterBack;

  @override
  Widget build(BuildContext context) {
    final double unit = tokens.spacingUnit;
    return Container(
      padding: EdgeInsets.fromLTRB(
        unit * 2,
        unit * 1.5,
        unit * 2,
        unit * 1.5 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: tokens.colorBackground,
        border: Border(top: BorderSide(color: tokens.colorBorderSubtle)),
      ),
      child: DsFooterActions(
        primaryLabel: primaryLabel,
        onPrimary: onPrimary,
        primaryPending: primaryPending,
        primaryTrailingIcon: primaryTrailingIcon,
        secondaryLabel: secondaryLabel,
        onSecondary: onSecondary,
        backLabel: backLabel,
        onBack: onFooterBack,
        backIcon: backLabel == null ? null : DsIcons.arrowBack,
      ),
    );
  }
}
