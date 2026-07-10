import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_icon.dart';
import '../atoms/ds_icon_button.dart';
import 'ds_sign_up_view.dart' show DsHeadingAlignment;

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
/// [title], an optional supporting [description] and a single full-width primary
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
/// For a form-led card, left-align the heading with [headingAlignment], move
/// the sign-up prompt into the edge-to-edge tinted [footerBand] and add a
/// corner close button with [onClose]. Set [showBorder] to false for a
/// shadow-only card.
///
/// The card is constrained to a comfortable reading width (~420dp) and shrinks
/// to fit narrower viewports, so it never overflows on small phones.
class DsSignInView extends StatefulWidget {
  /// Creates a centred sign-in / onboarding view.
  const DsSignInView({
    super.key,
    required this.title,
    required this.primaryAction,
    this.description,
    this.form,
    this.brandIcon,
    this.brandColor,
    this.headingAlignment = DsHeadingAlignment.center,
    this.footer,
    this.footerBand,
    this.additionalContextLabel,
    this.additionalContext,
    this.onClose,
    this.showBorder = true,
  });

  /// The prominent heading, typically a short welcome message.
  final String title;

  /// Optional supporting copy shown beneath the [title].
  final String? description;

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

  /// How the heading block (the [brandIcon], the [title] and the
  /// [description]) is aligned. Defaults to [DsHeadingAlignment.center].
  final DsHeadingAlignment headingAlignment;

  /// Optional content shown below the primary action, such as a sign-up link.
  final Widget? footer;

  /// Optional content rendered edge-to-edge below the card's padded body, in
  /// a tinted band with a hairline top border. The band touches the card's
  /// edges and the card's bottom corner radius clips it.
  final Widget? footerBand;

  /// The label for the expand/reveal control. When null, no reveal is shown.
  final String? additionalContextLabel;

  /// The content revealed when the [additionalContextLabel] control is
  /// expanded. Ignored when [additionalContextLabel] is null.
  final Widget? additionalContext;

  /// Called when the close button in the card's top corner is tapped. When
  /// null no close affordance is shown.
  final VoidCallback? onClose;

  /// Whether the card draws a hairline border. Set false for a shadow-only
  /// card.
  final bool showBorder;

  @override
  State<DsSignInView> createState() => _DsSignInViewState();
}

class _DsSignInViewState extends State<DsSignInView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DsSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: tokens.formBackgroundColor,
              border: widget.showBorder
                  ? Border.all(color: tokens.colorBorder)
                  : null,
              borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
              boxShadow: tokens.shadowMedium,
            ),
            // The close affordance sits fully inside the Stack: hit-testing
            // stops at the Stack's bounds, so a control hanging outside the
            // padded body would paint whole but respond only in part.
            child: Stack(
              children: [
                _buildCard(tokens),
                if (widget.onClose != null)
                  Positioned(
                    top: DsSpacing.sm,
                    right: DsSpacing.sm,
                    child: DsIconButton(
                      icon: DsIcons.close,
                      semanticLabel: 'Close',
                      onPressed: widget.onClose,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The padded card body, plus the optional edge-to-edge
  /// [DsSignInView.footerBand] clipped to the card's corner radius.
  Widget _buildCard(DsTokens tokens) {
    final body = Padding(
      padding: const EdgeInsets.all(DsSpacing.xl),
      child: _buildBody(tokens),
    );
    if (widget.footerBand == null) return body;

    // The band sits outside the body's padding so its tint reaches the card's
    // edges; the ClipRRect keeps it inside the bottom corner radius.
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          body,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DsSpacing.xl,
              vertical: DsSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: tokens.offsetBackgroundColor,
              border: Border(top: BorderSide(color: tokens.colorBorder)),
            ),
            child: widget.footerBand,
          ),
        ],
      ),
    );
  }

  /// The card body: heading block, optional form, primary action, footer and
  /// the additional-context reveal.
  Widget _buildBody(DsTokens tokens) {
    final hasReveal = widget.additionalContextLabel != null;
    final centred = widget.headingAlignment == DsHeadingAlignment.center;
    final textAlign = centred ? TextAlign.center : TextAlign.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.brandIcon != null) ...[
          _BrandMark(
            icon: widget.brandIcon!,
            color: widget.brandColor ?? tokens.buttonPrimaryColorBackground,
            alignment: centred ? Alignment.center : Alignment.centerLeft,
          ),
          const SizedBox(height: DsSpacing.lg),
        ],
        Text(
          widget.title,
          textAlign: textAlign,
          style: tokens.headingLg.toTextStyle(
            color: tokens.colorText,
          ),
        ),
        if (widget.description != null) ...[
          const SizedBox(height: DsSpacing.sm),
          Text(
            widget.description!,
            textAlign: textAlign,
            style: tokens.bodySm.toTextStyle(
              color: tokens.colorSecondaryText,
            ),
          ),
        ],
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
    );
  }
}

/// The tinted rounded square that frames a brand glyph.
class _BrandMark extends StatelessWidget {
  const _BrandMark({
    required this.icon,
    required this.color,
    required this.alignment,
  });

  final IconData icon;
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.all(DsSpacing.md),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          boxShadow: tokens.shadowMedium,
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
