import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';

/// The tone of a [DsInlineNotice], which picks its icon and colour from the
/// tokens.
enum DsInlineNoticeTone {
  /// A problem the user must resolve. The default.
  danger,

  /// A caution that does not block the user.
  warning,

  /// A positive confirmation.
  success,

  /// Neutral, informational context.
  info,
}

/// A small, caption-styled message shown beneath a field or control: a toned
/// icon followed by a line of text that may carry a single inline action link.
///
/// It is the richer sibling of a plain [DsTextField] `errorText`: use it when
/// the message needs a tappable word inside its own sentence, such as turning
/// an "email already registered" error into a "Sign in instead" doorway rather
/// than a dead end. For a boxed, dismissible message with its own action button
/// use `DsBanner`; for a transient one use `DsToast`.
///
/// The colour and icon come from [tone] (override the glyph with [icon]); the
/// text is caption-sized. The decorative icon is hidden from assistive
/// technology, so the sentence — including [actionLabel] — is read as one
/// message.
///
/// {@tool snippet}
///
/// ```dart
/// DsInlineNotice(
///   message: 'An account already exists with this email. ',
///   actionLabel: 'Sign in',
///   onAction: _goToSignIn,
///   trailingMessage: ' instead, or use a different email address.',
/// )
/// ```
///
/// {@end-tool}
class DsInlineNotice extends StatefulWidget {
  /// Creates an inline notice.
  ///
  /// [actionLabel] and [onAction] are supplied together or not at all.
  const DsInlineNotice({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.trailingMessage,
    this.tone = DsInlineNoticeTone.danger,
    this.icon,
  }) : assert(
          (actionLabel == null) == (onAction == null),
          'Provide actionLabel and onAction together, or neither.',
        );

  /// The leading text of the message.
  final String message;

  /// An optional word or phrase rendered inline as a link. Pair it with
  /// [onAction].
  final String? actionLabel;

  /// Called when [actionLabel] is tapped.
  final VoidCallback? onAction;

  /// Optional text rendered after the [actionLabel], completing the sentence.
  final String? trailingMessage;

  /// The tone, which selects the icon and colour. Defaults to
  /// [DsInlineNoticeTone.danger].
  final DsInlineNoticeTone tone;

  /// Overrides the glyph the [tone] would otherwise choose.
  final IconData? icon;

  @override
  State<DsInlineNotice> createState() => _DsInlineNoticeState();
}

class _DsInlineNoticeState extends State<DsInlineNotice> {
  // The inline action lives inside a TextSpan, which needs a gesture
  // recognizer; a recognizer is a disposable resource, so the notice owns one
  // and rebuilds it whenever the callback changes.
  TapGestureRecognizer? _recognizer;

  @override
  void initState() {
    super.initState();
    _syncRecognizer();
  }

  @override
  void didUpdateWidget(DsInlineNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onAction != widget.onAction) _syncRecognizer();
  }

  void _syncRecognizer() {
    _recognizer?.dispose();
    _recognizer = widget.onAction == null
        ? null
        : (TapGestureRecognizer()..onTap = widget.onAction);
  }

  @override
  void dispose() {
    _recognizer?.dispose();
    super.dispose();
  }

  (Color, IconData) _resolveTone(DsTokens tokens) => switch (widget.tone) {
        DsInlineNoticeTone.danger => (tokens.colorDanger, DsIcons.error),
        DsInlineNoticeTone.warning => (tokens.colorWarning, DsIcons.warning),
        DsInlineNoticeTone.success => (tokens.colorSuccess, DsIcons.success),
        DsInlineNoticeTone.info => (tokens.colorPrimary, DsIcons.info),
      };

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final (toneColor, toneIcon) = _resolveTone(tokens);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Decorative: the sentence already carries the meaning, so keep the
        // glyph out of the reading order.
        ExcludeSemantics(
          child: Padding(
            padding: EdgeInsets.only(
              top: tokens.spacingUnit * 0.25,
              right: tokens.spacingUnit,
            ),
            child: Icon(
              widget.icon ?? toneIcon,
              size: tokens.iconSizeSm,
              color: toneColor,
            ),
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: tokens.bodySm.toTextStyle(color: toneColor),
              children: [
                TextSpan(text: widget.message),
                if (widget.actionLabel != null)
                  TextSpan(
                    text: widget.actionLabel,
                    style: TextStyle(color: tokens.actionPrimaryColorText),
                    recognizer: _recognizer,
                  ),
                if (widget.trailingMessage != null)
                  TextSpan(text: widget.trailingMessage),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
