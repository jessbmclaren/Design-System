import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_auth_gradient.dart';
import '../atoms/ds_brand_bloom.dart';
import '../atoms/ds_icon_button.dart';

/// The widest the hero panel grows inside its half of the split, so the
/// marketing content keeps a readable measure on large desktops.
const double _heroMaxWidth = 440;

/// The full-page frame for an auth flow.
///
/// [DsAuthShell] arranges the chrome that every sign-in and sign-up page
/// shares: a decorative [backdrop] behind everything, [child] (the card)
/// centred in a scroll view, a [header] pinned to the top start corner, a
/// [footer] of legal links pinned to the bottom and an optional [banner]
/// overlaid along the bottom edge, typically a `DsCookieBanner`.
///
/// The card sits in a scroll view whose content is at least as tall as the
/// viewport, so a short card stays centred, a tall card scrolls and a short
/// viewport never overflows. The header and footer are pinned outside the
/// scroll, so they hold their corners while the card moves.
///
/// When [hero] is provided and the shell's own width reaches
/// [DsBreakpoints.expanded], the page splits into two panes with the hero on
/// the start side and the card on the end side. Below the breakpoint the hero
/// is dropped and the plain centred card remains.
///
/// The [backdrop] defaults to a [DsAuthGradient] under a [DsBrandBloom]. Pass
/// another widget to swap the treatment. Pass null to opt out and let the
/// host page's background show through.
///
/// ```dart
/// DsAuthShell(
///   header: const DsWordmark(primary: 'acme', accent: 'id'),
///   onBack: () => Navigator.of(context).maybePop(),
///   footer: legalLinks,
///   banner: showConsent ? cookieBanner : null,
///   child: signInCard,
/// )
/// ```
class DsAuthShell extends StatelessWidget {
  /// Creates the auth page frame.
  const DsAuthShell({
    super.key,
    required this.child,
    this.header,
    this.onBack,
    this.backLabel = 'Back',
    this.hero,
    this.footer,
    this.banner,
    this.backdrop = defaultBackdrop,
  });

  /// The default [backdrop]: the theme's auth wash under a brand bloom, the
  /// same pairing the sign-in and waiting screens use.
  static const Widget defaultBackdrop = Stack(
    fit: StackFit.expand,
    children: <Widget>[DsAuthGradient(), DsBrandBloom()],
  );

  /// The card, centred in a min-height scroll view. A card taller than the
  /// viewport scrolls; the pinned chrome stays put.
  final Widget child;

  /// Content pinned to the top start corner, typically a `DsWordmark`. Null
  /// leaves the corner empty.
  final Widget? header;

  /// Called when the back affordance beside the [header] is pressed. Null
  /// hides the affordance entirely.
  final VoidCallback? onBack;

  /// The name assistive technology announces for the back affordance.
  final String backLabel;

  /// Optional marketing content shown beside the card once the shell's width
  /// reaches [DsBreakpoints.expanded]. Below the breakpoint it is dropped, so
  /// compact viewports keep the plain centred card.
  final Widget? hero;

  /// Content pinned along the bottom edge, typically a wrapping line of legal
  /// links. Null leaves the edge empty.
  final Widget? footer;

  /// An overlay slot along the bottom edge, above the [footer], for a consent
  /// surface such as a `DsCookieBanner`. The slot claims no focus of its own,
  /// so showing it never pulls focus out of the card.
  final Widget? banner;

  /// The decorative layer behind the page. Defaults to [defaultBackdrop];
  /// pass null to opt out.
  final Widget? backdrop;

  /// One pane of the page: [content] centred in a scroll view whose content
  /// is at least as tall as the pane, so short content centres and tall
  /// content scrolls.
  Widget _scrollingPane(double unit, Widget content) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                // The vertical inset keeps a centred card clear of the pinned
                // header and footer; a scrolled card may still pass beneath
                // them, which is the pinned-chrome behaviour.
                padding: EdgeInsets.symmetric(
                  vertical: unit * 9,
                  horizontal: unit * 3,
                ),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final unit = tokens.spacingUnit;
    final hasHeader = header != null || onBack != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (backdrop != null) Positioned.fill(child: backdrop!),
        SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // The shell measures its own width rather than the
                    // window, so it behaves the same when embedded.
                    final wide =
                        DsBreakpoints.windowSizeFor(constraints.maxWidth) >=
                            DsWindowSize.expanded;
                    final showHero = hero != null && wide;
                    if (!showHero) return _scrollingPane(unit, child);
                    return Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _scrollingPane(
                            unit,
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: _heroMaxWidth,
                              ),
                              child: hero!,
                            ),
                          ),
                        ),
                        Expanded(flex: 6, child: _scrollingPane(unit, child)),
                      ],
                    );
                  },
                ),
              ),
              if (hasHeader)
                PositionedDirectional(
                  top: unit * 2,
                  start: unit * 2,
                  end: unit * 2,
                  child: Row(
                    children: [
                      if (onBack != null) ...[
                        DsIconButton(
                          icon: DsIcons.arrowBack,
                          onPressed: onBack,
                          semanticLabel: backLabel,
                        ),
                        SizedBox(width: unit),
                      ],
                      if (header != null) Flexible(child: header!),
                    ],
                  ),
                ),
              if (footer != null)
                PositionedDirectional(
                  bottom: unit * 2,
                  start: unit * 3,
                  end: unit * 3,
                  child: footer!,
                ),
              if (banner != null)
                PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  end: 0,
                  child: banner!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
