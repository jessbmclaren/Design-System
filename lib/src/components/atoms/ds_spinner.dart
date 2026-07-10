import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

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
class DsSpinner extends StatefulWidget {
  const DsSpinner({
    super.key,
    this.size = DsSpinnerSize.medium,
    this.delay = Duration.zero,
    this.color,
    this.semanticLabel = 'Loading',
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
    return SizedBox(
      width: widget.size.dimension,
      height: widget.size.dimension,
      child: _visible
          ? CircularProgressIndicator(
              strokeWidth: widget.size.strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              semanticsLabel: widget.semanticLabel,
            )
          : null,
    );
  }
}
