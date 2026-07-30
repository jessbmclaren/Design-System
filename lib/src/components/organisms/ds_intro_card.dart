import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_icon_button.dart';

/// A card that introduces something new: an eyebrow, a headline, a short
/// explanation and a way to begin.
///
/// [DsIntroCard] is the content a takeover usually carries: a feature the
/// user has not met, a product tour's opening frame, a welcome. The eyebrow
/// says what kind of thing this is, the title says what it is, the body says
/// why it matters, and the actions offer the way forward and the way past.
///
/// It is deliberately content-shaped rather than flow-shaped: it holds no
/// steps and no state, so a host can present it inside `DsTakeover`, a
/// dialog or a page.
///
/// ```dart
/// DsTakeover(
///   child: DsIntroCard(
///     eyebrow: 'New',
///     title: 'Track spend as it happens',
///     body: const Text('Every transaction lands here within a minute.'),
///     primaryAction: DsButton(label: 'Show me', onPressed: start),
///     secondaryAction: DsButton(
///       label: 'Not now',
///       variant: DsButtonVariant.tertiary,
///       onPressed: dismiss,
///     ),
///     onClose: dismiss,
///   ),
/// )
/// ```
class DsIntroCard extends StatelessWidget {
  /// Creates an introduction card.
  const DsIntroCard({
    super.key,
    required this.title,
    this.eyebrow,
    this.body,
    this.media,
    this.primaryAction,
    this.secondaryAction,
    this.onClose,
    this.maxWidth,
  });

  /// The headline, set in the largest heading so it carries the card.
  final String title;

  /// A short, quiet line above the title naming the kind of thing this is.
  final String? eyebrow;

  /// The explanation beneath the title.
  final Widget? body;

  /// Optional visual above the text, such as an illustration.
  final Widget? media;

  /// The way forward.
  final Widget? primaryAction;

  /// The way past, for an introduction the user can decline.
  final Widget? secondaryAction;

  /// Called when the corner close affordance is pressed. Null hides it.
  final VoidCallback? onClose;

  /// The widest the card grows. Defaults to [DsTokens.dialogMaxWidthLg].
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? tokens.dialogMaxWidthLg,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.formBackgroundColor,
          borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
          boxShadow: tokens.shadowHigh,
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(tokens.cardPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (media != null) ...<Widget>[
                    media!,
                    SizedBox(height: unit * 3),
                  ],
                  if (eyebrow != null) ...<Widget>[
                    Text(
                      tokens.labelEyebrow.textTransform.apply(eyebrow!),
                      style: tokens.labelEyebrow
                          .toTextStyle(color: tokens.actionPrimaryColorText),
                    ),
                    SizedBox(height: unit),
                  ],
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: tokens.headingXl
                          .toTextStyle(color: tokens.colorText),
                    ),
                  ),
                  if (body != null) ...<Widget>[
                    SizedBox(height: unit * 1.5),
                    DefaultTextStyle.merge(
                      style: tokens.bodyMd
                          .toTextStyle(color: tokens.colorSecondaryText),
                      child: body!,
                    ),
                  ],
                  if (primaryAction != null || secondaryAction != null) ...[
                    SizedBox(height: unit * 3),
                    // The actions wrap rather than shrink, so a narrow card
                    // stacks them instead of squeezing their labels.
                    Wrap(
                      spacing: unit * 1.5,
                      runSpacing: unit,
                      children: <Widget>[
                        ?primaryAction,
                        ?secondaryAction,
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onClose != null)
              PositionedDirectional(
                top: unit,
                end: unit,
                child: DsIconButton(
                  icon: DsIcons.close,
                  semanticLabel: 'Close',
                  onPressed: onClose,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
