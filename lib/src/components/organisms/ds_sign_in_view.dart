import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_elevation.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_icon.dart';

/// The primary call to action shown in a [DsSignInView].
///
/// This describes the label of the view's full-width primary button and the
/// callback invoked when it is tapped. The action is expected to navigate the
/// user onward (for example to a hosted authentication flow); the sign-in view
/// itself never collects credentials.
class DsSignInAction {
  /// Creates a description of a [DsSignInView] primary action.
  const DsSignInAction({required this.label, required this.onPressed});

  /// The label rendered on the primary button.
  final String label;

  /// Called when the primary button is tapped.
  final VoidCallback onPressed;
}

/// A centred sign-in / onboarding view.
///
/// [DsSignInView] presents a focused welcome card: an optional brand icon, a
/// [title], a supporting [description] and a single full-width primary
/// [DsButton] built from [primaryAction]. It deliberately collects no
/// passwords. The primary action navigates the user outward to a dedicated
/// authentication flow.
///
/// Use it as the landing screen for an app or feature, or as the empty state
/// that invites a signed-out user to continue. Provide a [footer] for
/// secondary links (such as a sign-up prompt), and use [additionalContextLabel]
/// with [additionalContext] to tuck supplementary detail (terms, help text,
/// enterprise sign-in options) behind a lightweight expand/reveal so the card
/// stays uncluttered by default.
///
/// The card is constrained to a comfortable reading width (~420dp) and shrinks
/// to fit narrower viewports, so it never overflows on small phones.
class DsSignInView extends StatefulWidget {
  /// Creates a centred sign-in / onboarding view.
  const DsSignInView({
    super.key,
    required this.title,
    required this.description,
    required this.primaryAction,
    this.form,
    this.brandIcon,
    this.brandColor,
    this.footer,
    this.additionalContextLabel,
    this.additionalContext,
  });

  /// The prominent heading, typically a short welcome message.
  final String title;

  /// Supporting copy shown beneath the [title].
  final String description;

  /// The full-width primary action that navigates the user onward.
  final DsSignInAction primaryAction;

  /// An optional form body, typically a column of `DsTextField`s (username,
  /// password), rendered between the description and the primary action. When
  /// omitted the view reads as a redirect / SSO card; when provided it reads as
  /// a credential sign-in. The view lays it out but owns none of its state.
  final Widget? form;

  /// An optional brand glyph shown in a tinted rounded square above the title.
  final IconData? brandIcon;

  /// The tint used for the brand glyph's container. Defaults to the primary
  /// button background token when omitted.
  final Color? brandColor;

  /// Optional content shown below the primary action, such as a sign-up link.
  final Widget? footer;

  /// The label for the expand/reveal control. When null, no reveal is shown.
  final String? additionalContextLabel;

  /// The content revealed when the [additionalContextLabel] control is
  /// expanded. Ignored when [additionalContextLabel] is null.
  final Widget? additionalContext;

  @override
  State<DsSignInView> createState() => _DsSignInViewState();
}

class _DsSignInViewState extends State<DsSignInView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final hasReveal = widget.additionalContextLabel != null;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DsSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DsSpacing.xl),
            decoration: BoxDecoration(
              color: tokens.formBackgroundColor,
              border: Border.all(color: tokens.colorBorder),
              borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
              boxShadow: DsElevation.medium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.brandIcon != null) ...[
                  _BrandMark(
                    icon: widget.brandIcon!,
                    color:
                        widget.brandColor ?? tokens.buttonPrimaryColorBackground,
                  ),
                  const SizedBox(height: DsSpacing.lg),
                ],
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: tokens.headingLg.toTextStyle(
                    color: tokens.colorText,
                  ),
                ),
                const SizedBox(height: DsSpacing.sm),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: tokens.bodySm.toTextStyle(
                    color: tokens.colorSecondaryText,
                  ),
                ),
                const SizedBox(height: DsSpacing.xl),
                if (widget.form != null) ...[
                  widget.form!,
                  const SizedBox(height: DsSpacing.lg),
                ],
                DsButton(
                  label: widget.primaryAction.label,
                  onPressed: widget.primaryAction.onPressed,
                  fullWidth: true,
                ),
                if (widget.footer != null) ...[
                  const SizedBox(height: DsSpacing.lg),
                  Align(
                    alignment: Alignment.center,
                    child: widget.footer,
                  ),
                ],
                if (hasReveal) ...[
                  const SizedBox(height: DsSpacing.md),
                  Divider(height: 1, color: tokens.colorBorder),
                  _RevealControl(
                    label: widget.additionalContextLabel!,
                    expanded: _expanded,
                    onToggle: () => setState(() => _expanded = !_expanded),
                  ),
                  if (_expanded && widget.additionalContext != null) ...[
                    const SizedBox(height: DsSpacing.sm),
                    widget.additionalContext!,
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The tinted rounded square that frames a brand glyph.
class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(DsSpacing.md),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          boxShadow: DsElevation.medium,
        ),
        child: DsIcon(
          icon: icon,
          size: DsIconSize.xl,
          color: tokens.buttonPrimaryColorText,
        ),
      ),
    );
  }
}

/// The tappable header for the additional-context reveal.
class _RevealControl extends StatelessWidget {
  const _RevealControl({
    required this.label,
    required this.expanded,
    required this.onToggle,
  });

  final String label;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final text = tokens.actionSecondaryTextTransform.apply(label);

    return Semantics(
      button: true,
      expanded: expanded,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DsSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.labelMd.toTextStyle(
                    color: tokens.actionSecondaryColorText,
                  ),
                ),
              ),
              const SizedBox(width: DsSpacing.xs),
              DsIcon(
                icon: expanded ? DsIcons.expandLess : DsIcons.expandMore,
                size: DsIconSize.lg,
                color: tokens.actionSecondaryColorText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
