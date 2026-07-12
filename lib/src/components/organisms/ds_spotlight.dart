import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_brand_bloom.dart';
import '../atoms/ds_button.dart';

/// A soft spotlight nudge over a page: a translucent wash that fades the page
/// out, a brand bloom rising from the bottom, and a short message with one
/// action anchored near the bottom edge.
///
/// [DsSpotlight] is the first-run coach the user meets on a fresh dashboard —
/// "verify your business to go live", "add your first vehicle" — a gentle,
/// per-step nudge rather than a hard gate. It overlays [child] (the page it
/// spotlights) with three layers: a top-to-bottom wash of the page colour that
/// leaves the content faintly visible up top and near-opaque below, a
/// [DsBrandBloom.pools] glow behind the message, and the message block itself.
///
/// The wash is a modal barrier. [child] is wrapped in [IgnorePointer],
/// [ExcludeSemantics] and a focus scope that can never hold focus, so while the
/// spotlight is up the page cannot be tapped, read by assistive technology or
/// reached by keyboard; a page field that was focused when the spotlight mounts
/// is released on the first frame. Only the message and its action stay live.
///
/// The message floats bottom-right by default, clearing [messageRightInset] so
/// it does not collide with a floating panel (such as a setup guide). Set
/// [docked] on compact layouts and it bottom-centres instead. On short
/// viewports its bottom inset shrinks and the message scrolls, so the heading
/// yields before the action does.
///
/// The spotlight holds no route of its own and runs no timers or animation
/// (the bloom is static paint), so the caller shows and removes it — typically
/// by rebuilding the page with or without it — and it renders deterministically
/// in screenshots. Copy defaults to brand-neutral English; [title] is required
/// and every other string is a parameter, so branded wording arrives without
/// forking the component.
///
/// ```dart
/// DsSpotlight(
///   title: 'Verify your business to go live',
///   body: 'Verify your company to switch on the tasks below.',
///   actionLabel: 'Verify business',
///   onAction: _openVerification,
///   child: dashboard,
/// )
/// ```
class DsSpotlight extends StatefulWidget {
  /// Creates a spotlight nudge over [child].
  const DsSpotlight({
    super.key,
    required this.child,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.docked = false,
    this.messageRightInset,
    this.messageBottomInset = 96,
    this.messageMaxWidth = 384,
    this.bloom,
  });

  /// The page the spotlight overlays. It stays visible through the wash but is
  /// removed from pointer, semantics and focus handling while the spotlight is
  /// up.
  final Widget child;

  /// The message heading. Required — it names the step the nudge points at.
  final String title;

  /// The supporting line beneath [title]. Omitted when null.
  final String? body;

  /// The label of the message's action. When null no action is shown; a null
  /// [onAction] leaves the action visible but disabled, out of the focus
  /// order, per the library's controlled-widget convention.
  final String? actionLabel;

  /// Called when the message's action is activated. A null callback disables
  /// the action.
  final VoidCallback? onAction;

  /// Whether the message bottom-centres (compact layouts) rather than anchoring
  /// bottom-right. Defaults to false.
  final bool docked;

  /// The floating message's clearance from the right edge, so it can dodge a
  /// panel floating in the same corner. Ignored when [docked]. Null falls back
  /// to three spacing units.
  final double? messageRightInset;

  /// The message's base clearance from the bottom edge. Clamped down on short
  /// viewports (to at most 18% of the height, never below two spacing units) so
  /// the message always fits. Defaults to 96.
  final double messageBottomInset;

  /// The message's maximum width in logical pixels. Defaults to 384.
  final double messageMaxWidth;

  /// The bloom painted behind the message. Defaults to
  /// [DsBrandBloom.pools], the multi-pool brand sweep. Pass your own, or a
  /// `SizedBox.shrink()` to drop it.
  final Widget? bloom;

  @override
  State<DsSpotlight> createState() => _DsSpotlightState();
}

class _DsSpotlightState extends State<DsSpotlight> {
  /// Owns the page's focus subtree. The scope can never request focus, so focus
  /// cannot move into the page while the spotlight is up, and it gives the
  /// state a handle for releasing focus already inside the page when the
  /// spotlight mounts.
  final FocusScopeNode _pageFocus = FocusScopeNode(
    debugLabel: 'DsSpotlight page',
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void initState() {
    super.initState();
    // Focus exclusion only blocks new focus requests: a field focused before
    // the spotlight mounts keeps primary focus and its open input connection.
    // Resolve any focus caught inside the page once the first frame is out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final primary = FocusManager.instance.primaryFocus;
      if (primary != null && primary.ancestors.contains(_pageFocus)) {
        primary.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _pageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final unit = tokens.spacingUnit;
    final surface = tokens.colorBackground;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // The page stays visible through the wash but inert: no taps, no
        // semantics, no focus.
        FocusScope(
          node: _pageFocus,
          canRequestFocus: false,
          skipTraversal: true,
          child: ExcludeFocus(
            child: ExcludeSemantics(
              child: IgnorePointer(child: widget.child),
            ),
          ),
        ),
        // The wash: the page colour deepening downward, so the content reads
        // faintly up top and recedes into a near-opaque surface below.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  surface.withValues(alpha: 0.82),
                  surface.withValues(alpha: 0.92),
                  surface.withValues(alpha: 0.99),
                ],
                stops: const <double>[0.0, 0.42, 1.0],
              ),
            ),
          ),
        ),
        // The brand bloom, decorative and non-interactive.
        Positioned.fill(
          child: IgnorePointer(
            child: widget.bloom ?? const DsBrandBloom.pools(),
          ),
        ),
        // The message block — the only live surface.
        LayoutBuilder(
          builder: (context, viewport) {
            // Lift the message clear of the bottom edge, but never so far on a
            // short viewport that the heading is pushed off-screen.
            final bottomInset = widget.messageBottomInset
                .clamp(0.0, viewport.maxHeight * 0.18)
                .clamp(unit * 2, widget.messageBottomInset);
            final maxHeight = (viewport.maxHeight - bottomInset - unit * 2)
                .clamp(unit * 12, double.infinity);

            return Align(
              alignment:
                  widget.docked ? Alignment.bottomCenter : Alignment.bottomRight,
              child: Padding(
                padding: widget.docked
                    ? EdgeInsets.fromLTRB(unit * 2, 0, unit * 2, bottomInset)
                    : EdgeInsets.only(
                        right: widget.messageRightInset ?? unit * 3,
                        bottom: bottomInset,
                      ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.messageMaxWidth,
                    maxHeight: maxHeight,
                  ),
                  // Reversed so the action pins to the bottom and the heading
                  // scrolls away first when height is tight.
                  child: SingleChildScrollView(
                    reverse: true,
                    child: _Message(tokens: tokens, widget: widget),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// The spotlight's message column: heading, optional body and optional action.
class _Message extends StatelessWidget {
  const _Message({required this.tokens, required this.widget});

  final DsTokens tokens;
  final DsSpotlight widget;

  @override
  Widget build(BuildContext context) {
    final unit = tokens.spacingUnit;
    final hasAction = widget.actionLabel != null;
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              widget.title,
              style: tokens.headingMd.toTextStyle(color: tokens.colorText),
            ),
          ),
          if (widget.body != null) ...<Widget>[
            SizedBox(height: unit * 1.5),
            Text(
              widget.body!,
              style: tokens.bodyMd.toTextStyle(
                color: tokens.colorSecondaryText,
              ),
            ),
          ],
          if (hasAction) ...<Widget>[
            SizedBox(height: unit * 2.5),
            DsButton(
              label: widget.actionLabel!,
              variant: DsButtonVariant.secondary,
              onPressed: widget.onAction,
            ),
          ],
        ],
      ),
    );
  }
}
