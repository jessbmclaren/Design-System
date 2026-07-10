import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';

/// A focused overlay surface for additional context or multi-step flows.
///
/// [DsFocusView] renders a self-contained panel: a titled header, a scrollable
/// body, and an optional footer for actions such as a primary [DsButton] or a
/// step indicator. Use it to draw attention to a single task — confirming a
/// change, collecting a short form, or guiding the user through a sequence of
/// steps — without navigating away from the current screen.
///
/// The widget itself starts no timers or animations, so it renders a stable
/// still frame that is safe to capture in screenshots. To present it as a modal
/// dialog over the current route, call the static [show] helper, which wraps the
/// same panel in a [Dialog] with the design system's overlay backdrop.
///
/// The panel is constrained to a comfortable reading width (~560dp) and centered
/// horizontally. It remains usable down to 320dp-wide viewports.
class DsFocusView extends StatelessWidget {
  const DsFocusView({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.onClose,
    this.fill = false,
  });

  /// The heading shown at the top of the panel.
  final String title;

  /// The main content, rendered in a scrollable body.
  final Widget child;

  /// Optional footer content, such as a primary [DsButton] and/or a step
  /// indicator. Aligned to the trailing edge above a divider.
  final Widget? footer;

  /// Called when the header close button is tapped. When null, no close button
  /// is shown.
  final VoidCallback? onClose;

  /// Whether the panel fills the height of its parent, attached to the leading
  /// edge — the drawer presentation. When false (the default) it hugs its
  /// content and is centred as a dialog.
  final bool fill;

  /// The maximum width of the panel in logical pixels, in dialog mode.
  static const double maxWidth = 560;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final borderColor = tokens.colorBorder;

    final panel = Column(
      mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header.
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.headingSm.toTextStyle(
                    color: tokens.colorText,
                  ),
                ),
              ),
              if (onClose != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(DsIcons.close),
                  iconSize: 20,
                  color: tokens.colorSecondaryText,
                  tooltip: 'Close',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: borderColor),
        // Body — fills in drawer mode, hugs content in dialog mode.
        if (fill)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          )
        else
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        // Footer.
        if (footer != null) ...[
          Divider(height: 1, thickness: 1, color: borderColor),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerRight,
              child: footer,
            ),
          ),
        ],
      ],
    );

    if (fill) {
      // Drawer: fill the height, hairline on the leading (left) edge only.
      return DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.formBackgroundColor,
          border: Border(left: BorderSide(color: borderColor)),
        ),
        child: panel,
      );
    }

    // Dialog: hug content, rounded border, centred and width-constrained.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: tokens.formBackgroundColor,
            borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
            border: Border.all(color: borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: panel,
        ),
      ),
    );
  }

  /// Presents a [DsFocusView] as an overlay over the current route.
  ///
  /// The overlay style follows the `overlays` token by default — a centred
  /// [DsOverlayStyle.dialog] or a [DsOverlayStyle.drawer]: an edge-anchored
  /// panel that slides in from the trailing (right) edge, full height, and
  /// spans the full width on compact viewports. Pass [style] to override it for
  /// a single call. Either way the background is dimmed with the design
  /// system's overlay backdrop colour.
  ///
  /// Returns the value passed to [Navigator.pop] when the overlay is dismissed.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    Widget? footer,
    DsOverlayStyle? style,
  }) {
    final tokens = DsTokens.of(context);
    final resolved = style ?? tokens.overlays;
    final compact = MediaQuery.sizeOf(context).width < 400;

    if (resolved == DsOverlayStyle.drawer) {
      return showGeneralDialog<T>(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: tokens.overlayBackdropColor,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (dialogContext, _, _) {
          final width =
              compact ? MediaQuery.sizeOf(dialogContext).width : 440.0;
          return Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: width,
              height: double.infinity,
              child: Material(
                type: MaterialType.transparency,
                child: SafeArea(
                  left: false,
                  child: DsFocusView(
                    title: title,
                    footer: footer,
                    fill: true,
                    onClose: () => Navigator.of(dialogContext).pop(),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
        transitionBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      );
    }

    return showDialog<T>(
      context: context,
      barrierColor: tokens.overlayBackdropColor,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 24,
            vertical: 24,
          ),
          child: DsFocusView(
            title: title,
            footer: footer,
            onClose: () => Navigator.of(dialogContext).pop(),
            child: child,
          ),
        );
      },
    );
  }
}
