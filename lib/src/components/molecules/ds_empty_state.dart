import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';

/// A single call-to-action rendered inside a [DsEmptyState].
///
/// Pair a short, verb-led [label] (for example "Add customer") with the
/// [onPressed] callback that starts the flow which will populate the screen.
@immutable
class DsEmptyStateAction {
  const DsEmptyStateAction({required this.label, required this.onPressed});

  /// The button label. Keep it short and action oriented.
  final String label;

  /// Called when the action button is tapped.
  final VoidCallback onPressed;
}

/// A centred placeholder shown when a screen, list or panel has no data.
///
/// Use [DsEmptyState] to explain why a region is empty and, where possible,
/// offer the user a way to fill it. A first-run list, a search with no
/// results and a cleared inbox are all good candidates.
///
/// The layout is a vertically centred column: an optional large [icon]
/// tinted with the secondary text colour, a required [title], an optional
/// supporting [message] constrained to a comfortable reading width, and an
/// optional primary [action] button. The content never overflows and stays
/// centred within the space it is given, from 320dp phones upward.
class DsEmptyState extends StatelessWidget {
  const DsEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.action,
  });

  /// The short headline describing the empty state.
  final String title;

  /// Optional supporting text giving more context or next steps.
  final String? message;

  /// Optional large glyph shown above the title.
  final IconData? icon;

  /// Optional primary action offering the user a way forward.
  final DsEmptyStateAction? action;

  /// The maximum width of the supporting message, for comfortable reading.
  static const double _messageMaxWidth = 320;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: DsSpacing.xl,
          vertical: DsSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: tokens.colorSecondaryText,
              ),
              const SizedBox(height: DsSpacing.lg),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: tokens.headingSm.toTextStyle(color: tokens.colorText),
            ),
            if (message != null) ...[
              const SizedBox(height: DsSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _messageMaxWidth),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: tokens.bodySm
                      .toTextStyle(color: tokens.colorSecondaryText),
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: DsSpacing.xl),
              DsButton(
                label: action!.label,
                onPressed: action!.onPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
