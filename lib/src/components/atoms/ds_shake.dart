import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../util/ds_motion.dart';

/// Shakes its child once whenever [trigger] changes, for a rejected attempt.
///
/// [DsShake] is the physical answer to a refusal: a sign-in that comes back
/// wrong, a code that does not match. It plays one damped oscillation and
/// stops, so the motion says "that did not work" without pulling focus for
/// longer than the moment.
///
/// The shake is keyed to the identity of [trigger], not to a boolean, so a
/// second rejection with the same message still shakes: pass a counter, a
/// timestamp or the error object itself. Under reduced motion the child
/// simply stays still, because a shake is emphasis, never information: the
/// error message beside it carries the meaning.
///
/// ```dart
/// DsShake(
///   trigger: failureCount,
///   child: signInCard,
/// )
/// ```
class DsShake extends StatefulWidget {
  /// Creates a shake wrapper.
  const DsShake({
    super.key,
    required this.child,
    required this.trigger,
    this.distance = 8,
  });

  /// The content that shakes.
  final Widget child;

  /// The value whose change plays the shake. Null never shakes.
  final Object? trigger;

  /// How far the content travels at the first swing, in logical pixels.
  final double distance;

  @override
  State<DsShake> createState() => _DsShakeState();
}

class _DsShakeState extends State<DsShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: DsMotion.slow,
  );

  @override
  void didUpdateWidget(DsShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.trigger != null) {
      // Reduced motion drops the shake entirely: the message carries the
      // meaning, the movement was only emphasis.
      if (DsMotion.reduced(context)) return;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        if (!_controller.isAnimating) return child!;
        // One damped oscillation: three swings, each smaller than the last.
        final double t = _controller.value;
        final double decay = 1 - t;
        final double offset =
            math.sin(t * math.pi * 3) * widget.distance * decay;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: widget.child,
    );
  }
}
