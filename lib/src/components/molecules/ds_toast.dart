import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// An optional trailing action shown inside a [DsToast].
///
/// Use a toast action for a single, low-friction follow-up such as "Undo" or
/// "Retry". Keep the [label] short — a toast is transient and the action must
/// be readable at a glance.
class DsToastAction {
  const DsToastAction({required this.label, required this.onPressed});

  /// The action label, e.g. "Undo".
  final String label;

  /// Called when the action is tapped.
  final VoidCallback onPressed;
}

/// A transient feedback toast that confirms an action or reports a status.
///
/// A toast is a compact, high-contrast pill that floats above the UI and
/// disappears on its own. Reach for it to acknowledge a completed action
/// ("Changes saved") or a quick status, optionally offering one follow-up
/// action via [action]. For anything the user must acknowledge or that blocks
/// progress, use a dialog instead.
///
/// The widget itself is purely visual and starts no timers, so it is safe to
/// embed directly in screenshots, galleries and golden tests. To present a
/// toast that auto-dismisses over an app, call [DsToast.show], which inserts an
/// [OverlayEntry] near the bottom of the screen and removes it after
/// `duration`.
///
/// ```dart
/// DsToast.show(
///   context,
///   message: 'Changes saved',
///   icon: Icons.check_circle_outline,
///   action: DsToastAction(label: 'Undo', onPressed: _undo),
/// );
/// ```
class DsToast extends StatelessWidget {
  const DsToast({
    super.key,
    required this.message,
    this.action,
    this.icon,
  });

  /// The message to display. Keep it concise — a single short sentence.
  final String message;

  /// An optional trailing action, such as "Undo".
  final DsToastAction? action;

  /// An optional leading icon that reinforces the message.
  final IconData? icon;

  /// The maximum width of the toast pill.
  static const double _maxWidth = 360;

  /// Presents a [DsToast] in an overlay near the bottom centre of the screen
  /// and removes it automatically after [duration].
  ///
  /// This is the only entry point that schedules a timer, keeping the widget
  /// itself safe for static rendering. Calling it multiple times stacks toasts
  /// independently; each manages and removes its own overlay entry.
  static void show(
    BuildContext context, {
    required String message,
    DsToastAction? action,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    var removed = false;
    Timer? autoDismiss;

    void dismiss() {
      if (removed) return;
      removed = true;
      autoDismiss?.cancel();
      entry.remove();
    }

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: DsToast(
                  message: message,
                  icon: icon,
                  action: action == null
                      ? null
                      : DsToastAction(
                          label: action.label,
                          onPressed: () {
                            dismiss();
                            action.onPressed();
                          },
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    autoDismiss = Timer(duration, dismiss);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    // A high-contrast surface: the primary text colour becomes the background
    // and the form background becomes the foreground, so the pill reads clearly
    // against both light and dark app surfaces.
    final background = tokens.colorText;
    final foreground = tokens.formBackgroundColor;
    final accent = tokens.actionPrimaryColorText;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: foreground),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: 12),
                  _DsToastActionButton(action: action!, accent: accent),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// The tappable trailing action label rendered inside a [DsToast].
class _DsToastActionButton extends StatelessWidget {
  const _DsToastActionButton({required this.action, required this.accent});

  final DsToastAction action;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: action.onPressed,
        borderRadius: BorderRadius.circular(6),
        // Meet the 48dp minimum touch target while keeping the label compact.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Center(
              widthFactor: 1,
              child: Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
