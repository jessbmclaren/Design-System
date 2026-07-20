import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../util/ds_motion.dart';

/// A bar that lifts off the page once content scrolls beneath it.
///
/// [DsFloatingBar] is treatment only: it wraps whatever bar the caller
/// supplies and, while [floating], fades in a hairline and a soft shadow so
/// the bar reads as a layer above the content rather than part of it. At rest
/// it is flat, indistinguishable from the page.
///
/// The caller owns the knowledge of whether anything has scrolled beneath,
/// because only the caller knows which scroll view matters. Drive it from a
/// scroll listener and pass the result.
///
/// ```dart
/// DsFloatingBar(
///   floating: _scrollOffset > 0,
///   child: const SiteTopNav(),
/// )
/// ```
class DsFloatingBar extends StatelessWidget {
  /// Creates a scroll-aware bar treatment.
  const DsFloatingBar({
    super.key,
    required this.floating,
    required this.child,
  });

  /// Whether content has scrolled beneath the bar, which lifts it.
  final bool floating;

  /// The bar itself, which sets its own height and content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    return AnimatedContainer(
      duration: DsMotion.durationOf(context, DsMotion.fast),
      curve: DsMotion.curveOf(context, DsMotion.standard),
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        // The hairline is always present but transparent at rest, so the bar
        // does not change height as it lifts.
        border: Border(
          bottom: BorderSide(
            color: floating
                ? tokens.colorBorderSubtle
                : tokens.colorBorderSubtle.withValues(alpha: 0),
          ),
        ),
        boxShadow: floating ? tokens.shadowLow : const <BoxShadow>[],
      ),
      child: child,
    );
  }
}
