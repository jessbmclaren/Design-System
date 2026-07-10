import 'package:flutter/material.dart';

import '../../util/ds_motion.dart';

/// A trailing ellipsis that animates while the user waits.
///
/// [DsAnimatedEllipsis] cycles from no dots up to [dotCount] and back to none,
/// the classic "Preparing your workspace…" suffix on waiting copy. It reserves
/// the width of the full ellipsis up front, so the sentence it follows never
/// shifts as dots appear.
///
/// Each step of the cycle holds for [DsMotion.slow]. Under reduced motion the
/// dots do not animate: the widget renders a static, full ellipsis instead,
/// so the copy still reads as "in progress".
///
/// The dots change several times a second, so by default they are excluded
/// from semantics and the sentence they trail carries the meaning. Keep the
/// state announced through that text (or a live region around it), not
/// through the dots.
///
/// ```dart
/// Text.rich(TextSpan(children: [
///   const TextSpan(text: 'Preparing your workspace'),
///   WidgetSpan(child: DsAnimatedEllipsis(style: style)),
/// ]))
/// ```
class DsAnimatedEllipsis extends StatefulWidget {
  /// Creates an animated ellipsis.
  const DsAnimatedEllipsis({
    super.key,
    this.style,
    this.dotCount = 3,
    this.excludeFromSemantics = true,
  });

  /// The text style the dots render with.
  ///
  /// Defaults to the ambient [DefaultTextStyle], so the dots match the
  /// sentence they follow.
  final TextStyle? style;

  /// How many dots the cycle builds up to. Defaults to 3.
  final int dotCount;

  /// Whether the dots are hidden from assistive technology.
  ///
  /// Defaults to true: the parent text carries the meaning and the mutating
  /// dots would only add noise. Set to false when the ellipsis genuinely
  /// stands alone.
  final bool excludeFromSemantics;

  @override
  State<DsAnimatedEllipsis> createState() => _DsAnimatedEllipsisState();
}

class _DsAnimatedEllipsisState extends State<DsAnimatedEllipsis>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: DsMotion.slow * (widget.dotCount + 1),
  );

  @override
  void didUpdateWidget(DsAnimatedEllipsis oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dotCount != oldWidget.dotCount) {
      _controller.duration = DsMotion.slow * (widget.dotCount + 1);
      if (_controller.isAnimating) {
        _controller
          ..stop()
          ..repeat();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (DsMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    final reserved = '.' * widget.dotCount;

    final Widget dots;
    if (DsMotion.reduced(context)) {
      // A still frame: the full ellipsis, so the copy still reads as ongoing.
      dots = Text(reserved, style: style);
    } else {
      dots = Stack(
        children: [
          // Reserve the full width invisibly so the preceding sentence never
          // shifts as dots come and go.
          Opacity(opacity: 0, child: Text(reserved, style: style)),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final steps = widget.dotCount + 1;
              final count = (_controller.value * steps).floor() % steps;
              return Text('.' * count, style: style);
            },
          ),
        ],
      );
    }

    if (widget.excludeFromSemantics) {
      return ExcludeSemantics(child: dots);
    }
    return dots;
  }
}
