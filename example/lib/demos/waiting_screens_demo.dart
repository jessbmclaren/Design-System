import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Waiting screens page: a centred panel built from theme
/// tokens with a large DsSpinner, a title, a supporting line that sets the
/// expectation, and a secondary Cancel action. The spinner animates; no timers
/// are started, so a single captured frame is representative.
class WaitingScreensDemo extends StatelessWidget {
  const WaitingScreensDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: tokens.formBackgroundColor,
            border: Border.all(color: tokens.colorBorder),
            borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DsSpinner(size: DsSpinnerSize.large),
              const SizedBox(height: 20),
              Text(
                'Preparing your report',
                textAlign: TextAlign.center,
                style: DsTypography.headingSm.toTextStyle(
                  color: tokens.colorText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This can take up to a minute. You can keep working and '
                'we\'ll notify you when it\'s ready.',
                textAlign: TextAlign.center,
                style: DsTypography.bodySm.toTextStyle(
                  color: tokens.colorSecondaryText,
                ),
              ),
              const SizedBox(height: 24),
              DsButton(
                label: 'Cancel',
                variant: DsButtonVariant.secondary,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
