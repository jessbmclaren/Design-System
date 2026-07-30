import 'package:flutter/material.dart';

/// Softens whichever end of a scroller still has content beyond it.
///
/// A strip that simply stops at the viewport edge tells nobody it scrolls: a
/// label sliced in half by the edge reads as a rendering fault, and one that
/// begins past the edge does not exist at all as far as the person holding the
/// phone is concerned. A dissolving edge is the affordance — content that
/// fades out reads as "there is more this way" — and it costs no space, which
/// is the whole problem with an arrow or a chevron on a strip that is already
/// too narrow.
///
/// The fade masks the child's own alpha rather than painting a coloured
/// gradient over it, so it holds on any background: a card, a page wash, dark
/// mode, a brand skin. It also means no caller has to tell it what colour it
/// is sitting on.
///
/// Nothing is faded while everything fits. A strip that does not scroll pays
/// neither the affordance nor the mask's save layer, and renders exactly as it
/// did before.
///
/// The widget starts no timers and runs no animation: the fade is a property of
/// the scroll position, so a still frame is stable and safe to screenshot.
///
/// This is an internal part. Callers reach it through the components that use
/// it (`DsTabs`, `DsDetailPanel`), which is why it is not exported.
class DsScrollFade extends StatefulWidget {
  /// Creates a scroller whose overflowing edges fade.
  const DsScrollFade({super.key, required this.builder, this.extent = 24});

  /// Builds the scrollable, which must attach the controller it is given.
  ///
  /// A builder rather than a plain child because the fade is driven by the
  /// scroll position, and the only way to read that position is to own the
  /// controller the scrollable uses.
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  /// How far the fade reaches in from an overflowing edge, in logical pixels.
  ///
  /// Clamped to half the width, so a very narrow strip fades from both ends
  /// rather than folding the two gradients through each other.
  final double extent;

  @override
  State<DsScrollFade> createState() => _DsScrollFadeState();
}

class _DsScrollFadeState extends State<DsScrollFade> {
  final ScrollController _controller = ScrollController();

  /// Keeps the scrollable's element — and so its scroll position — across the
  /// moment the mask appears or disappears above it.
  ///
  /// Load-bearing: inserting an ancestor rebuilds the subtree beneath it from
  /// scratch, and a rebuilt scrollable is one scrolled back to zero. Without
  /// this the first drag scrolled, the fade switched on, the position reset,
  /// and the strip snapped back to the start on every attempt.
  final GlobalKey _scrollerKey = GlobalKey();

  /// Whether there is nothing hidden off the leading / trailing edge. Both
  /// start true, so the first frame of a strip that fits is the frame it would
  /// have rendered without this widget at all.
  bool _atStart = true;
  bool _atEnd = true;
  bool _syncScheduled = false;

  /// Sub-pixel slack, so a position resting a rounding error away from an end
  /// does not fade an edge that has nothing behind it.
  static const double _epsilon = 0.5;

  @override
  void initState() {
    super.initState();
    _scheduleSync();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Metrics arrive during layout, and a set during layout is illegal, so
  /// every update is read after the frame that produced it.
  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      _sync();
    });
  }

  void _sync() {
    if (!mounted || !_controller.hasClients) return;
    final ScrollPosition position = _controller.position;
    final bool atStart = position.pixels <= position.minScrollExtent + _epsilon;
    final bool atEnd = position.pixels >= position.maxScrollExtent - _epsilon;
    if (atStart == _atStart && atEnd == _atEnd) return;
    setState(() {
      _atStart = atStart;
      _atEnd = atEnd;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Three things move the fade: the person scrolling, the window resizing,
    // and the content itself changing. The first arrives as a scroll
    // notification and the other two as a metrics notification.
    final Widget scroller = NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        _scheduleSync();
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          _scheduleSync();
          return false;
        },
        child: KeyedSubtree(
          key: _scrollerKey,
          child: widget.builder(context, _controller),
        ),
      ),
    );

    if (_atStart && _atEnd) return scroller;

    final TextDirection direction = Directionality.of(context);
    return ShaderMask(
      // The key names the edges being softened, so which edge faded is
      // observable from a test without reaching into private state.
      key: ValueKey<String>(
        'ds-scroll-fade:'
        '${<String>[if (!_atStart) 'leading', if (!_atEnd) 'trailing'].join('+')}',
      ),
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        // Opaque keeps the pixel, transparent removes it, so the gradient is
        // written in alpha and the colour itself is irrelevant.
        const Color keep = Color(0xFFFFFFFF);
        const Color drop = Color(0x00FFFFFF);
        final double edge = bounds.width <= 0
            ? 0
            : (widget.extent / bounds.width).clamp(0.0, 0.5);
        return LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: <Color>[
            _atStart ? keep : drop,
            keep,
            keep,
            _atEnd ? keep : drop,
          ],
          stops: <double>[0, edge, 1 - edge, 1],
        ).createShader(bounds, textDirection: direction);
      },
      child: scroller,
    );
  }
}
