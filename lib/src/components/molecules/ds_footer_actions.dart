import 'package:flutter/material.dart';

import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';

/// The action cluster that closes a wizard step, an onboarding screen or a
/// similar footer.
///
/// [DsFooterActions] bonds up to four pieces into one responsive unit: a
/// required primary action ([primaryLabel]), an optional back action
/// ([backLabel]), an optional [leading] widget such as a "Step 2 of 4"
/// caption and an optional low-emphasis action beneath the cluster
/// ([tertiaryLabel]), typically "Save and finish later". Every button is a
/// [DsButton], so the cluster inherits its theming, 48dp touch targets,
/// pending spinner and reduced-motion behaviour.
///
/// The component is controlled: it holds no state and simply reports taps
/// through [onPrimary], [onBack] and [onTertiary]. Gate progress by passing a
/// null [onPrimary], which disables the primary button, and set
/// [primaryPending] while the action is in flight to show a spinner and block
/// a double submit.
///
/// ## Responsiveness
///
/// The cluster measures its own width with a [LayoutBuilder], not the window,
/// so it adapts inside a narrow card as readily as on a full page:
///
/// * At [minRowWidth] and wider the actions sit in a single row with the
///   primary action last, on the trailing edge, and [leading] pinned to the
///   start.
/// * Below [minRowWidth] the cluster stacks vertically with every button
///   full-width and the primary action first, the standard mobile ordering,
///   with [leading] centred beneath the buttons.
///
/// The tertiary action renders centred beneath the cluster in both layouts.
///
/// ```dart
/// DsFooterActions(
///   backLabel: 'Back',
///   onBack: _goBack,
///   primaryLabel: 'Continue',
///   primaryTrailingIcon: DsIcons.arrowForward,
///   onPrimary: _formComplete ? _continue : null,
///   primaryPending: _saving,
///   tertiaryLabel: 'Save and finish later',
///   onTertiary: _saveForLater,
/// )
/// ```
class DsFooterActions extends StatelessWidget {
  /// Creates a footer action cluster.
  ///
  /// [primaryLabel] is required; the back and tertiary actions render only
  /// when their labels are provided.
  const DsFooterActions({
    super.key,
    required this.primaryLabel,
    this.onPrimary,
    this.primaryPending = false,
    this.primaryTrailingIcon,
    this.backLabel,
    this.onBack,
    this.backVariant = DsButtonVariant.tertiary,
    this.tertiaryLabel,
    this.onTertiary,
    this.leading,
    this.minRowWidth = 480,
  });

  /// The label of the primary action, such as "Continue".
  final String primaryLabel;

  /// Called when the primary action is tapped.
  ///
  /// A null callback disables the primary button, the way a step gates
  /// progress while its form is incomplete.
  final VoidCallback? onPrimary;

  /// Whether the primary action is in flight.
  ///
  /// While true the primary button shows a spinner over its label and ignores
  /// presses, so the action cannot be triggered twice. Defaults to false.
  final bool primaryPending;

  /// An optional trailing icon on the primary action, such as a forward arrow
  /// on a continue button.
  final IconData? primaryTrailingIcon;

  /// The label of the optional back action. When null no back button renders.
  final String? backLabel;

  /// Called when the back action is tapped. A null callback disables it.
  final VoidCallback? onBack;

  /// The emphasis of the back action. Defaults to [DsButtonVariant.tertiary],
  /// a quiet text button.
  final DsButtonVariant backVariant;

  /// The label of the optional low-emphasis action rendered centred beneath
  /// the cluster, typically "Save and finish later". When null it is omitted.
  final String? tertiaryLabel;

  /// Called when the tertiary action is tapped. A null callback disables it.
  final VoidCallback? onTertiary;

  /// Optional content pinned to the start edge of the row layout, such as a
  /// "Step 2 of 4" caption. When the cluster stacks it sits centred beneath
  /// the buttons instead.
  final Widget? leading;

  /// The width below which the cluster stacks vertically.
  ///
  /// The threshold tracks the cluster's own width, not the window. Pass `0`
  /// to keep the row at every width or [double.infinity] to always stack,
  /// for a parent that has already made the layout decision.
  final double minRowWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth.isFinite &&
            constraints.maxWidth < minRowWidth;

        final primary = DsButton(
          label: primaryLabel,
          onPressed: onPrimary,
          pending: primaryPending,
          trailingIcon: primaryTrailingIcon,
          fullWidth: stacked,
        );
        final Widget? back = backLabel == null
            ? null
            : DsButton(
                label: backLabel!,
                onPressed: onBack,
                variant: backVariant,
                fullWidth: stacked,
              );
        final Widget? tertiary = tertiaryLabel == null
            ? null
            : DsButton(
                label: tertiaryLabel!,
                onPressed: onTertiary,
                variant: DsButtonVariant.tertiary,
              );
        final leading = this.leading;

        if (stacked) {
          // Primary first, full-width, so the main action stays under the
          // thumb on a narrow screen; supporting pieces follow beneath.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              primary,
              if (back != null) ...[
                const SizedBox(height: DsSpacing.sm),
                back,
              ],
              if (leading != null) ...[
                const SizedBox(height: DsSpacing.md),
                Align(child: leading),
              ],
              if (tertiary != null) ...[
                const SizedBox(height: DsSpacing.md),
                Align(child: tertiary),
              ],
            ],
          );
        }

        final row = Row(
          children: [
            // Consume the leading space so the actions sit on the trailing
            // edge; Expanded also bounds wide leading content so it cannot
            // overflow.
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: leading ?? const SizedBox.shrink(),
              ),
            ),
            if (back != null) ...[
              back,
              const SizedBox(width: DsSpacing.md),
            ],
            primary,
          ],
        );
        if (tertiary == null) return row;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            row,
            const SizedBox(height: DsSpacing.md),
            Align(child: tertiary),
          ],
        );
      },
    );
  }
}
