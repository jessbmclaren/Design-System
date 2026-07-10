import 'dart:async';

import 'package:flutter/material.dart';

import '../../util/ds_motion.dart';

/// A one-shot entrance: the child fades in while sliding up a few pixels.
///
/// [DsFadeSlideIn] wraps a block of content arriving on screen for the first
/// time, an onboarding step or a freshly loaded card. The animation plays once
/// when the widget mounts and never replays; give several siblings an
/// increasing [delay] (see [DsMotion.stagger]) so a group reveals a beat
/// apart.
///
/// Motion runs on the [DsMotion] scale: [DsMotion.expressive] long through the
/// [DsMotion.emphasized] entrance curve by default. Under reduced motion the
/// wrapper renders the settled frame immediately, with no fade, slide or
/// delay.
///
/// The child's semantics are always included, even before the fade completes,
/// so assistive technology reads the content without waiting on the
/// choreography.
///
/// ```dart
/// DsFadeSlideIn(
///   delay: DsMotion.stagger(context, index),
///   child: card,
/// )
/// ```
class DsFadeSlideIn extends StatefulWidget {
  /// Creates a one-shot fade-and-slide entrance around [child].
  const DsFadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = DsMotion.expressive,
    this.curve = DsMotion.emphasized,
    this.offset = 12,
  });

  /// The content being revealed.
  final Widget child;

  /// How long after mounting the entrance begins.
  ///
  /// Ignored under reduced motion, where the settled frame shows immediately.
  final Duration delay;

  /// How long the entrance runs. Defaults to [DsMotion.expressive].
  final Duration duration;

  /// The easing of the entrance. Defaults to [DsMotion.emphasized].
  final Curve curve;

  /// How far below its resting position the child starts, in logical pixels.
  ///
  /// Defaults to 12.
  final double offset;

  @override
  State<DsFadeSlideIn> createState() => _DsFadeSlideInState();
}

class _DsFadeSlideInState extends State<DsFadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (DsMotion.reduced(context)) {
      // A still frame: jump to settled and never schedule the entrance.
      _timer?.cancel();
      _started = true;
      _controller.value = 1;
    } else if (!_started) {
      _started = true;
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        _timer = Timer(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      // The content is real as soon as it mounts; assistive technology should
      // not wait for the choreography.
      alwaysIncludeSemantics: true,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, (1 - _curve.value) * widget.offset),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
