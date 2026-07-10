import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../util/ds_motion.dart';

/// The visual size of a [DsSpinner].
enum DsSpinnerSize {
  /// 16dp: inline, next to text or inside compact controls.
  small(16, 2),

  /// 24dp: section-level loading.
  medium(24, 2.5),

  /// 40dp: full-page or full-view loading.
  large(40, 3.5);

  const DsSpinnerSize(this.dimension, this.strokeWidth);

  /// The width and height of the spinner in logical pixels.
  final double dimension;

  /// The stroke width of the progress indicator.
  final double strokeWidth;
}

/// A determinate-scope loading indicator.
///
/// Match the [size] to what is loading: [DsSpinnerSize.large] for a whole
/// view, [DsSpinnerSize.medium] for a section, [DsSpinnerSize.small] inline.
/// Use [delay] to avoid flashing a spinner for fast operations; the spinner
/// stays invisible until the delay elapses.
///
/// When the user has requested reduced motion the spinner renders a static
/// three-quarter ring instead of animating, so it still reads as busy without
/// the spin. Pass a [label] to announce what is loading through a polite live
/// region; without one the spinner keeps its plain [semanticLabel].
class DsSpinner extends StatefulWidget {
  /// Creates a loading indicator.
  const DsSpinner({
    super.key,
    this.size = DsSpinnerSize.medium,
    this.delay = Duration.zero,
    this.color,
    this.semanticLabel = 'Loading',
    this.label,
  });

  /// The visual size of the spinner.
  final DsSpinnerSize size;

  /// How long to wait before the spinner becomes visible.
  ///
  /// A value of 200 to 300ms prevents a spinner flashing for operations that
  /// complete almost immediately.
  final Duration delay;

  /// The spinner colour. Defaults to the primary action colour.
  final Color? color;

  /// The semantic label announced by assistive technologies.
  final String semanticLabel;

  /// A description of what is loading, announced through a live region as the
  /// spinner appears (for example "Loading results"). When set it replaces
  /// [semanticLabel] as the announced text; when null the spinner keeps its
  /// plain [semanticLabel] with no live region.
  final String? label;

  @override
  State<DsSpinner> createState() => _DsSpinnerState();
}

class _DsSpinnerState extends State<DsSpinner> {
  bool _visible = false;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _visible = true;
    } else {
      _revealTimer = Timer(widget.delay, () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final color = widget.color ?? tokens.buttonPrimaryColorBackground;
    final liveRegion = widget.label != null;

    final ring = SizedBox(
      width: widget.size.dimension,
      height: widget.size.dimension,
      child: _visible
          ? CircularProgressIndicator(
              strokeWidth: widget.size.strokeWidth,
              // Under reduced motion a static three-quarter ring still reads
              // as busy without the spin.
              value: DsMotion.reduced(context) ? 0.75 : null,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              // The live region below carries the announcement when a [label]
              // is set, so the indicator's own label is dropped to avoid a
              // double reading.
              semanticsLabel: liveRegion ? null : widget.semanticLabel,
            )
          : null,
    );

    if (!liveRegion || !_visible) return ring;

    // The node is created when the spinner becomes visible, so a polite live
    // region announces the label at that moment rather than on mount.
    return Semantics(
      container: true,
      liveRegion: true,
      label: widget.label,
      child: ring,
    );
  }
}
