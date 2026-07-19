import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../util/ds_motion.dart';
import '../atoms/ds_link.dart';

/// The kind of outcome a resend produced.
enum DsResendOutcome {
  /// It went out. The control restarts its cooldown.
  sent,

  /// It was refused by a rate limit. The control shows the wait and offers
  /// nothing to press.
  rateLimited,

  /// It could not be made at all (offline, or a server error). The control
  /// returns to offering a resend so it can be tried again.
  failed,
}

/// What a resend produced, returned from [DsResendControl.onResend].
///
/// A rate-limited resend carries the wait to show, because how long the wait is
/// is only known once the request comes back — the caller builds it from the
/// API's retry-after, for example "Try again in 5 minutes".
class DsResendResult {
  const DsResendResult(this.outcome, {this.rateLimitedLabel});

  /// It went out; the cooldown restarts.
  const DsResendResult.sent() : this(DsResendOutcome.sent);

  /// It could not be made; the resend stays offerable so it can be retried.
  const DsResendResult.failed() : this(DsResendOutcome.failed);

  /// It was refused by a rate limit; [label] names the wait to show.
  const DsResendResult.rateLimited(String label)
    : this(DsResendOutcome.rateLimited, rateLimitedLabel: label);

  /// Which outcome this is.
  final DsResendOutcome outcome;

  /// The wait to show while rate-limited. Falls back to the control's
  /// [DsResendControl.rateLimitedLabel] when null.
  final String? rateLimitedLabel;
}

/// A "didn't get it? resend" control with a cooldown.
///
/// The pattern behind every "we've sent you something" step: hold the resend
/// behind a short countdown so a link is not fired five times in five seconds,
/// then offer it. It owns only its own cooldown; the caller owns the send and
/// tells the control how it went by returning a [DsResendOutcome], so the same
/// widget covers a plain resend, a rate-limited one and a failed one without
/// the caller wiring three states by hand.
///
/// The countdown is an animation, not a `Timer`, so it needs no cancellation
/// and leaves nothing pending in a test. It honours the reduce-motion law: a
/// per-second ticker is exactly the kind of live motion that law silences, so
/// under reduced motion the cooldown is skipped and the resend is offered
/// straight away rather than animating a clock no one asked to move.
///
/// {@tool snippet}
///
/// ```dart
/// DsResendControl(
///   onResend: () async {
///     final result = await api.resend(email);
///     return result.rateLimited
///         ? DsResendResult.rateLimited('Try again in $minutes minutes')
///         : const DsResendResult.sent();
///   },
/// )
/// ```
///
/// {@end-tool}
class DsResendControl extends StatefulWidget {
  /// Creates a resend control.
  const DsResendControl({
    super.key,
    required this.onResend,
    this.cooldown = const Duration(seconds: 30),
    this.startRateLimited = false,
    this.promptLabel = 'Didn’t get it?',
    this.resendLabel = 'Resend',
    this.rateLimitedLabel = 'Try again later',
  });

  /// Performs the resend and reports how it went. A null callback disables the
  /// control. It is awaited, so it can do real work; while it runs the resend
  /// is inert, so there is no double send.
  final Future<DsResendResult> Function()? onResend;

  /// How long the resend is held before it is offered.
  final Duration cooldown;

  /// Opens straight into the rate-limited reading, for a step reached after a
  /// send that was already refused.
  final bool startRateLimited;

  /// The lead-in text before the resend link ("Didn't get it?").
  final String promptLabel;

  /// The resend link's label.
  final String resendLabel;

  /// What to show while rate-limited. Build it from the API's retry-after so it
  /// names the wait, for example "Try again in 5 minutes".
  final String rateLimitedLabel;

  @override
  State<DsResendControl> createState() => _DsResendControlState();
}

class _DsResendControlState extends State<DsResendControl> {
  // Bumping the epoch remounts the animation, restarting the cooldown.
  int _epoch = 0;
  bool _ready = false;
  bool _sending = false;
  late bool _rateLimited = widget.startRateLimited;
  String? _rateLimitedLabel;

  String _fmt(int seconds) => '0:${seconds.toString().padLeft(2, '0')}';

  Future<void> _resend() async {
    if (_sending || widget.onResend == null) return;
    setState(() => _sending = true);
    final result = await widget.onResend!();
    if (!mounted) return;
    setState(() {
      _sending = false;
      switch (result.outcome) {
        case DsResendOutcome.sent:
          _ready = false;
          _epoch++; // restart the cooldown
        case DsResendOutcome.rateLimited:
          _rateLimited = true;
          _rateLimitedLabel = result.rateLimitedLabel;
        case DsResendOutcome.failed:
          _ready = true; // offer it again straight away
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final muted = tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText);

    // Rate-limited: name the wait, offer nothing to press. The label from the
    // outcome wins (it names the actual wait); the fixed prop is the fallback,
    // used for a control that opens already rate-limited.
    if (_rateLimited) {
      return Semantics(
        liveRegion: true,
        child: Text(
          _rateLimitedLabel ?? widget.rateLimitedLabel,
          style: muted,
          textAlign: TextAlign.center,
        ),
      );
    }

    // Offered — either the cooldown has elapsed, or reduced motion skips it.
    if (_ready || DsMotion.reduced(context)) {
      return Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text('${widget.promptLabel} ', style: muted),
          DsLink(
            label: widget.resendLabel,
            // Disabled while a send is in flight, and when there is no send to
            // make at all.
            onPressed: (_sending || widget.onResend == null) ? null : _resend,
          ),
        ],
      );
    }

    // Counting down.
    final seconds = widget.cooldown.inSeconds;
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(_epoch),
      tween: Tween<double>(begin: seconds.toDouble(), end: 0),
      duration: widget.cooldown,
      onEnd: () => setState(() => _ready = true),
      builder: (context, value, _) {
        final remaining = value.ceil().clamp(1, seconds);
        return Text(
          '${widget.promptLabel} ${widget.resendLabel} in ${_fmt(remaining)}',
          style: muted,
        );
      },
    );
  }
}
