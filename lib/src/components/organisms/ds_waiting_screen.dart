import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_animated_ellipsis.dart';
import '../atoms/ds_auth_gradient.dart';
import '../atoms/ds_fade_slide_in.dart';
import '../atoms/ds_spinner.dart';

/// The full-page branded loader for the moments between screens.
///
/// [DsWaitingScreen] holds attention while an account is provisioned or a
/// session is established: a centred [DsSpinner] over a [headline] with a
/// trailing [DsAnimatedEllipsis], an optional supporting line beneath and an
/// optional [header] slot (typically a wordmark) pinned to the top leading
/// corner. The header band spans the full width inside the screen's safe
/// area, and header text that outgrows it ellipsises on one line instead of
/// clipping off the edge. The whole block enters through a [DsFadeSlideIn],
/// on a [DsAuthGradient] backdrop by default.
///
/// The screen holds no timers and never advances itself; the caller swaps it
/// out when the operation completes. Under reduced motion every part settles
/// to a still frame: the entrance shows its settled state, the ellipsis
/// renders in full and the spinner becomes a static ring.
///
/// The headline sits in a polite live region, so assistive technology
/// announces what is happening as the screen appears.
///
/// ```dart
/// DsWaitingScreen(
///   header: const DsWordmark(primary: 'acme'),
///   headline: 'Signing you in',
///   supportingText: 'This will only take a moment.',
/// )
/// ```
class DsWaitingScreen extends StatelessWidget {
  /// Creates a full-page waiting screen.
  const DsWaitingScreen({
    super.key,
    required this.headline,
    this.supportingText,
    this.header,
    this.showSpinner = true,
    this.icon,
    this.backdrop = const DsAuthGradient(),
  });

  /// A mark shown in place of the spinner, for the moment the wait ends
  /// well: a check on the success tone, say. Supplying it also drops the
  /// animated ellipsis, because nothing is in progress any more.
  final Widget? icon;

  /// The short line naming the work in progress, such as "Signing you in".
  /// An animated ellipsis is appended automatically, so leave the trailing
  /// dots off.
  final String headline;

  /// An optional second line setting expectations, such as "This will only
  /// take a moment." Null shows the headline alone.
  final String? supportingText;

  /// An optional widget pinned to the top leading corner, typically a
  /// wordmark, so the wait still reads as part of the product.
  final Widget? header;

  /// Whether the large spinner shows above the headline. Defaults to true.
  final bool showSpinner;

  /// The full-bleed layer painted behind the content. Defaults to a
  /// [DsAuthGradient]; pass a custom widget (a gradient with a bloom, say) or
  /// null for a plain surface.
  final Widget? backdrop;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final unit = tokens.spacingUnit;
    final headlineStyle =
        tokens.headingLg.toTextStyle(color: tokens.colorText);

    // An arrival is not a wait: the mark replaces the spinner and the
    // headline stops trailing off.
    final bool arrived = icon != null;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (arrived) ...[
          icon!,
          SizedBox(height: unit * 3),
        ] else if (showSpinner) ...[
          // The headline announces the operation, so the spinner keeps its
          // plain label without a second live region.
          const DsSpinner(size: DsSpinnerSize.large),
          SizedBox(height: unit * 3),
        ],
        Semantics(
          container: true,
          liveRegion: true,
          child: arrived
              ? Text(
                  headline,
                  style: headlineStyle,
                  textAlign: TextAlign.center,
                )
              : Text.rich(
                  TextSpan(
                    text: headline,
                    children: [
                      WidgetSpan(
                        child: DsAnimatedEllipsis(style: headlineStyle),
                      ),
                    ],
                  ),
                  style: headlineStyle,
                  textAlign: TextAlign.center,
                ),
        ),
        if (supportingText != null) ...[
          SizedBox(height: unit),
          Text(
            supportingText!,
            style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (backdrop != null) Positioned.fill(child: backdrop!),
        SafeArea(
          // The scroll view keeps large text scales usable on short
          // viewports instead of overflowing the centred column.
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: unit * 3,
                      vertical: unit * 3,
                    ),
                    child: DsFadeSlideIn(child: content),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (header != null)
          // The band spans the width and sits inside its own SafeArea, so a
          // wordmark clears a notch and wide content ellipsises within the
          // viewport instead of walking off it.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(unit * 3, unit * 3, unit * 3, 0),
                child: DefaultTextStyle.merge(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: header!,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
