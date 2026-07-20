import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_divider.dart';
import '../atoms/ds_heading_alignment.dart';
import '../atoms/ds_icon.dart';
import '../atoms/ds_icon_button.dart';
import 'ds_auth_card_parts.dart';

/// The primary call to action shown in a [DsSignInView].
///
/// This describes the label of the view's full-width primary button and the
/// callback invoked when it is tapped. The action is expected to navigate the
/// user onward (for example to a hosted authentication flow); the sign-in view
/// itself never collects credentials.
class DsSignInAction {
  /// Creates a description of a [DsSignInView] primary action.
  const DsSignInAction({
    required this.label,
    required this.onPressed,
    this.pending = false,
  });

  /// The label rendered on the primary button.
  final String label;

  /// Called when the primary button is tapped. Pass `null` to disable the
  /// button (for example while the caller's form is invalid).
  final VoidCallback? onPressed;

  /// Whether the action is in flight, which shows a spinner on the button and
  /// prevents further taps. Mirrors `DsSignUpView.submitPending`.
  final bool pending;
}

/// A centred sign-in and onboarding view.
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
/// The card is constrained to a comfortable reading width
/// ([DsAuthCardLayout.signInMaxWidth]) and shrinks to fit narrower viewports,
/// so it never overflows on small phones.
class DsSignInView extends StatefulWidget {
  /// Creates a centred sign-in and onboarding view.
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
    this.embedded = false,
  });

  /// The prominent heading, typically a short welcome message.
  final String title;

  /// Optional supporting copy shown beneath the [title].
  final String? description;

  /// The full-width primary action that navigates the user onward.
  final DsSignInAction primaryAction;

  /// An optional form body, typically a column of `DsTextField`s (username,
  /// password), rendered between the description and the primary action. When
  /// omitted the view reads as a redirect or SSO card; when provided it reads
  /// as a credential sign-in. The view lays it out but owns none of its state.
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
  /// a tinted band with a top border in the standard border colour. The band
  /// touches the card's edges and the card's bottom corner radius clips it.
  final Widget? footerBand;

  /// The label for the expand/reveal control. When null, no reveal is shown.
  final String? additionalContextLabel;

  /// The content revealed when the [additionalContextLabel] control is
  /// expanded. Ignored when [additionalContextLabel] is null.
  final Widget? additionalContext;

  /// Called when the close button in the card's top corner is tapped. When
  /// null no close affordance is shown. While the button is shown the heading
  /// block is inset at its trailing edge so the title never paints beneath it.
  final VoidCallback? onClose;

  /// Whether the card draws a hairline border. Set false for a shadow-only
  /// card.
  final bool showBorder;

  /// Whether the card frames its own page.
  ///
  /// When false (the default) the view centres and scrolls itself, so it can be
  /// dropped straight into a `Scaffold` body. Set it true to render just the
  /// constrained card, for a host that already owns the page framing — a
  /// template that supplies the background, the centring and the scroll (an
  /// auth shell). Nesting a self-framing view inside such a host would scroll
  /// twice; embedded mode is how the same card lives in both places.
  final bool embedded;

  @override
  State<DsSignInView> createState() => _DsSignInViewState();
}

class _DsSignInViewState extends State<DsSignInView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final card = ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: DsAuthCardLayout.signInMaxWidth,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: tokens.formBackgroundColor,
          border:
              widget.showBorder ? Border.all(color: tokens.colorBorder) : null,
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
                top: tokens.spacingUnit,
                right: tokens.spacingUnit,
                child: DsIconButton(
                  icon: DsIcons.close,
                  semanticLabel: 'Close',
                  onPressed: widget.onClose,
                ),
              ),
          ],
        ),
      ),
    );

    // Embedded: the host frames the page, so hand back just the card.
    if (widget.embedded) return card;

    // Standalone: frame our own page — centred and scrollable for a Scaffold.
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacingUnit * 3),
        child: card,
      ),
    );
  }

  /// The padded card body, plus the optional edge-to-edge
  /// [DsSignInView.footerBand] clipped to the card's corner radius.
  Widget _buildCard(DsTokens tokens) {
    final body = Padding(
      padding: EdgeInsets.all(tokens.spacingUnit * 3),
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
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacingUnit * 3,
              vertical: tokens.spacingUnit * 2,
            ),
            decoration: BoxDecoration(
              color: tokens.offsetBackgroundColor,
              // The standard border tier, not the subtle hairline: the subtle
              // tier sits below 1.1:1 against the band tint in the Engen
              // light skin, so it vanishes exactly where the band needs an
              // edge.
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
        // While a close button floats in the corner the heading block gives
        // up its trailing edge to it, so title and description glyphs never
        // paint beneath the icon.
        Padding(
          padding: EdgeInsets.only(
            right: widget.onClose != null
                ? DsAuthCardLayout.headingCloseInset(tokens)
                : 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.brandIcon != null) ...[
                DsAuthBrandMark(
                  icon: widget.brandIcon!,
                  color:
                      widget.brandColor ?? tokens.buttonPrimaryColorBackground,
                  alignment: centred ? Alignment.center : Alignment.centerLeft,
                ),
                SizedBox(height: tokens.spacingUnit * 2),
              ],
              Semantics(
                header: true,
                child: Text(
                  widget.title,
                  textAlign: textAlign,
                  style: tokens.headingLg.toTextStyle(color: tokens.colorText),
                ),
              ),
              if (widget.description != null) ...[
                SizedBox(height: tokens.spacingUnit),
                Text(
                  widget.description!,
                  textAlign: textAlign,
                  style: tokens.bodySm.toTextStyle(
                    color: tokens.colorSecondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: tokens.spacingUnit * 3),
        if (widget.form != null) ...[
          widget.form!,
          SizedBox(height: tokens.spacingUnit * 2),
        ],
        DsButton(
          label: widget.primaryAction.label,
          onPressed: widget.primaryAction.onPressed,
          pending: widget.primaryAction.pending,
          fullWidth: true,
        ),
        if (widget.footer != null) ...[
          SizedBox(height: tokens.spacingUnit * 2),
          Align(alignment: Alignment.center, child: widget.footer),
        ],
        if (hasReveal) ...[
          SizedBox(height: tokens.spacingUnit * 1.5),
          const DsDivider(),
          _RevealControl(
            label: widget.additionalContextLabel!,
            expanded: _expanded,
            onToggle: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded && widget.additionalContext != null) ...[
            SizedBox(height: tokens.spacingUnit),
            widget.additionalContext!,
          ],
        ],
      ],
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
      // The transparent Material hosts the ink splash above the card's opaque
      // background; without it the ink would paint on the Scaffold's material
      // beneath the card and never show.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          child: ConstrainedBox(
            // Keep the reveal a full touch target, like the buttons beside it.
            constraints: BoxConstraints(minHeight: tokens.minTapTarget),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacingUnit * 1.5),
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
                  SizedBox(width: tokens.spacingUnit / 2),
                  DsIcon(
                    icon: expanded ? DsIcons.expandLess : DsIcons.expandMore,
                    size: DsIconSize.lg,
                    color: tokens.actionSecondaryColorText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
