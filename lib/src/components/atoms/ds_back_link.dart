import 'package:flutter/material.dart';
import '../../theme/ds_tokens_extension.dart';

/// A back navigation link that returns the user to a previous screen or list.
///
/// Renders a small leading back chevron followed by a label styled with the
/// primary action tokens (color, text decoration and transform), so it reads
/// as an inline textual link rather than a button.
///
/// Use it at the top of detail or edit views to provide an obvious path back
/// to the originating collection, for example "Back to customers".
///
/// The [label] is required and the primary action text transform is applied to
/// it automatically. Provide [onPressed] to handle the navigation; when it is
/// null the link renders in a non-interactive state.
class DsBackLink extends StatelessWidget {
  /// Creates a back navigation link.
  const DsBackLink({super.key, required this.label, this.onPressed});

  /// The link text, e.g. "Back to customers".
  final String label;

  /// Called when the link is tapped. When null the link is not interactive.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final text = tokens.actionPrimaryTextTransform.apply(label);

    return Semantics(
      link: onPressed != null,
      enabled: onPressed != null,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(tokens.buttonBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: tokens.actionPrimaryColorText,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.actionPrimaryColorText,
                    decoration: tokens.actionPrimaryTextDecorationLine,
                    decorationColor: tokens.actionPrimaryTextDecorationColor,
                    decorationStyle: tokens.actionPrimaryTextDecorationStyle,
                    decorationThickness:
                        tokens.actionPrimaryTextDecorationThickness,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
