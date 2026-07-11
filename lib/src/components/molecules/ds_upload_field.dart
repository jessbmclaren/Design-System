import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_icon_button.dart';
import '../atoms/ds_progress_bar.dart';

/// The lifecycle stage a [DsUploadField] is showing.
enum DsUploadFieldState {
  /// No file yet: the field invites the user to pick one.
  idle,

  /// A file is being sent: the field shows a determinate progress bar.
  uploading,

  /// The file arrived: the field confirms it and offers a remove affordance.
  success,

  /// The upload failed: the field explains why and offers a retry.
  error,
}

/// A single-row upload control with a caller-driven state machine.
///
/// [DsUploadField] renders one compact row (an icon, a status line and, while
/// uploading, a [DsProgressBar]) that walks the idle, uploading, success and
/// error stages of a file upload. The widget does no file IO of its own: the
/// host application owns the picker, the transfer and the retry policy, and
/// drives the field entirely through [state], [progress], [fileName],
/// [errorText] and the three callbacks.
///
/// In the idle state the row is a button that fires [onPick]. While uploading
/// it is inert and shows [progress]. On success it confirms [fileName] and
/// shows a remove affordance firing [onRemove]. On error the row becomes a
/// button again, firing [onRetry].
///
/// For a large drop-target surface at the start of an import flow use
/// `DsDropzone` instead; this field suits a form row, such as an identity
/// document inside a verification step.
///
/// ## Accessibility
///
/// The status line is a polite live region, so assistive technology announces
/// each state change (uploading, added, failed) without stealing focus. The
/// interactive states expose button semantics, activate from the keyboard and
/// keep a tap target of at least 48dp.
///
/// ```dart
/// DsUploadField(
///   state: _uploadState,
///   progress: _uploadProgress,
///   fileName: _fileName,
///   onPick: _pickFile,
///   onRetry: _pickFile,
///   onRemove: _removeFile,
/// )
/// ```
class DsUploadField extends StatelessWidget {
  /// Creates a single-row upload control.
  const DsUploadField({
    super.key,
    required this.state,
    this.progress = 0,
    this.fileName,
    this.errorText,
    this.onPick,
    this.onRetry,
    this.onRemove,
    this.idleLabel = 'Choose a file to upload',
    this.helperText,
    this.enabled = true,
  });

  /// The stage the field is showing. The caller owns the state machine and
  /// moves it through the stages as its upload progresses.
  final DsUploadFieldState state;

  /// The completed fraction of the upload, from 0 to 1. Only read while
  /// [state] is [DsUploadFieldState.uploading]. Defaults to 0.
  final double progress;

  /// The name of the file in flight or delivered. Shown in the uploading and
  /// success states.
  final String? fileName;

  /// The message explaining a failure, shown beneath the status line in the
  /// error state. When null a short generic message is used.
  final String? errorText;

  /// Called when the idle row is activated to pick a file. A null callback
  /// leaves the idle row non-interactive.
  final VoidCallback? onPick;

  /// Called when the error row is activated to try the upload again. A null
  /// callback leaves the error row non-interactive.
  final VoidCallback? onRetry;

  /// Called when the success state's remove affordance is activated. When
  /// null the affordance is hidden.
  final VoidCallback? onRemove;

  /// The prompt shown in the idle state. Defaults to a generic invitation.
  final String idleLabel;

  /// Accepted-type and size guidance shown beneath the prompt in the idle
  /// state, for example "PDF or PNG, up to 10 MB".
  final String? helperText;

  /// Whether the idle state accepts interaction. When false the idle row is
  /// dimmed and cannot be activated. The transient states ignore it. Defaults
  /// to true.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final uploading = state == DsUploadFieldState.uploading;
    final success = state == DsUploadFieldState.success;
    final failed = state == DsUploadFieldState.error;
    final idleDisabled = state == DsUploadFieldState.idle && !enabled;

    final VoidCallback? onTap = switch (state) {
      DsUploadFieldState.idle => enabled ? onPick : null,
      DsUploadFieldState.error => onRetry,
      _ => null,
    };

    final Color borderColor = failed
        ? tokens.colorDanger
        : success
            ? tokens.colorSuccess
            : tokens.colorBorder;
    final Color fill = success
        ? tokens.badgeSuccessColorBackground
        : failed
            ? tokens.badgeDangerColorBackground
            : tokens.formBackgroundColor;

    final (IconData icon, Color iconColor) = switch (state) {
      DsUploadFieldState.idle => (
          DsIcons.upload,
          tokens.colorSecondaryText,
        ),
      DsUploadFieldState.uploading => (
          DsIcons.upload,
          tokens.formAccentColor,
        ),
      DsUploadFieldState.success => (
          DsIcons.uploadDone,
          tokens.badgeSuccessColorText,
        ),
      DsUploadFieldState.error => (
          DsIcons.error,
          tokens.badgeDangerColorText,
        ),
    };

    final String title = switch (state) {
      DsUploadFieldState.idle => idleLabel,
      DsUploadFieldState.uploading => 'Uploading ${fileName ?? 'file'}',
      DsUploadFieldState.success => '${fileName ?? 'File'} added',
      DsUploadFieldState.error => 'Upload failed',
    };

    final String? caption = switch (state) {
      DsUploadFieldState.idle => helperText,
      DsUploadFieldState.uploading => null,
      DsUploadFieldState.success => null,
      DsUploadFieldState.error =>
        errorText ?? 'Something went wrong. Activate to try again.',
    };

    final Color captionColor =
        failed ? tokens.colorDanger : tokens.colorSecondaryText;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DsSpacing.md,
          vertical: DsSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: DsIconSize.lg, color: iconColor),
            const SizedBox(width: DsSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // The status line is the field's voice: a polite live
                  // region, so state changes are announced without moving
                  // focus.
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tokens.labelMd
                          .toTextStyle(color: tokens.colorText),
                    ),
                  ),
                  if (uploading) ...<Widget>[
                    const SizedBox(height: DsSpacing.sm),
                    DsProgressBar(
                      value: progress,
                      semanticLabel: 'Upload progress',
                    ),
                  ] else if (caption != null) ...<Widget>[
                    const SizedBox(height: DsSpacing.xxs),
                    Text(
                      caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tokens.bodySm.toTextStyle(color: captionColor),
                    ),
                  ],
                ],
              ),
            ),
            if (success && onRemove != null) ...<Widget>[
              const SizedBox(width: DsSpacing.sm),
              DsIconButton(
                icon: DsIcons.close,
                semanticLabel: 'Remove file',
                onPressed: onRemove,
                size: 32,
                iconSize: DsIconSize.sm,
              ),
            ],
          ],
        ),
      ),
    );

    final radius = BorderRadius.circular(tokens.formBorderRadius);
    final interactive = onTap != null;

    final surface = Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      ),
    );

    final Widget field = (state == DsUploadFieldState.idle ||
            state == DsUploadFieldState.error)
        ? Semantics(
            container: true,
            button: true,
            enabled: interactive,
            child: surface,
          )
        : Semantics(container: true, child: surface);

    if (idleDisabled) {
      return Opacity(opacity: 0.5, child: field);
    }
    return field;
  }
}
