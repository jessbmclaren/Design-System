import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_icon.dart';
import '../atoms/ds_link.dart';

/// A short how-to for bulk import, with the template download as its
/// call to action.
///
/// Pairs a titled explanation with numbered [steps] and, when
/// [onDownloadTemplate] is set, a 'Download template' button — so the file
/// people are asked to fill in is always one tap from the instructions that
/// describe it. An optional [onOpenGuide] link points at longer-form docs.
///
/// Purely presentational: the caller performs the actual download or
/// navigation in the callbacks.
class DsImportGuide extends StatelessWidget {
  /// Creates an import guide.
  const DsImportGuide({
    super.key,
    this.icon = DsIcons.fileText,
    required this.title,
    this.description,
    this.steps = const [],
    this.downloadLabel = 'Download template',
    this.onDownloadTemplate,
    this.guideLabel,
    this.onOpenGuide,
  });

  /// The glyph beside the title. Defaults to a document.
  final IconData icon;

  /// The heading, e.g. 'Add via CSV'.
  final String title;

  /// An optional sentence under the title framing when to use the import.
  final String? description;

  /// The numbered instructions, in order. May be empty.
  final List<String> steps;

  /// The label on the download button.
  final String downloadLabel;

  /// Called when the template download is requested. Null hides the button.
  final VoidCallback? onDownloadTemplate;

  /// The label on the trailing docs link, e.g. 'View template guide'.
  /// Shown only when [onOpenGuide] is also set.
  final String? guideLabel;

  /// Called when the docs link is pressed. Null hides the link.
  final VoidCallback? onOpenGuide;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final bodyStyle =
        tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText);

    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DsIcon(
                icon: icon,
                size: tokens.iconSizeMd,
                color: tokens.colorSecondaryText,
              ),
              const SizedBox(width: DsSpacing.sm),
              Flexible(
                child: Text(
                  title,
                  style: tokens.labelMd
                      .toTextStyle(color: tokens.colorText)
                      .copyWith(fontWeight: tokens.strongLabelFontWeight),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: DsSpacing.sm),
            Text(description!, style: bodyStyle),
          ],
          if (steps.isNotEmpty) ...[
            const SizedBox(height: DsSpacing.sm),
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0) const SizedBox(height: DsSpacing.xs),
              MergeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: DsSpacing.lg,
                      child: Text('${i + 1}.', style: bodyStyle),
                    ),
                    Expanded(child: Text(steps[i], style: bodyStyle)),
                  ],
                ),
              ),
            ],
          ],
          if (onDownloadTemplate != null) ...[
            const SizedBox(height: DsSpacing.lg),
            DsButton(
              label: downloadLabel,
              trailingIcon: DsIcons.download,
              variant: DsButtonVariant.secondary,
              onPressed: onDownloadTemplate,
            ),
          ],
          if (guideLabel != null && onOpenGuide != null) ...[
            const SizedBox(height: DsSpacing.md),
            DsLink(
              label: guideLabel!,
              trailingIcon: DsIcons.arrowForward,
              onPressed: onOpenGuide,
            ),
          ],
        ],
      ),
    );
  }
}
