import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden_helpers.dart';

/// Visual regression goldens for the atoms.
///
/// Each atom is captured under the default light, default dark and one skin
/// (see [dsGoldenThemes]). Instances are deliberately minimal and deterministic
/// — no network images, no time- or random-dependent data — so the pixels are
/// stable across runs.
void main() {
  group('golden · atoms', () {
    // Captured under reduced motion so the golden is the settled full
    // ellipsis, not whichever frame of the cycle the pump lands on.
    dsGoldenMatrix(
      'atom',
      'animated_ellipsis',
      () => const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Preparing your workspace'),
              WidgetSpan(child: DsAnimatedEllipsis()),
            ],
          ),
        ),
      ),
    );

    // A fixed height turns the parent-sized wash into stable pixels.
    dsGoldenMatrix(
      'atom',
      'auth_gradient',
      () => const SizedBox(height: 160, child: DsAuthGradient()),
    );

    dsGoldenMatrix('atom', 'avatar', () => const DsAvatar(name: 'Ada Lovelace'));

    dsGoldenMatrix(
        'atom', 'back_link', () => const DsBackLink(label: 'Back to customers'));

    // A row of every badge variant — where colour-token regressions surface.
    dsGoldenMatrix(
      'atom',
      'badge',
      () => const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          DsBadge(label: 'Neutral'),
          DsBadge(label: 'Success', variant: DsBadgeVariant.success),
          DsBadge(label: 'Warning', variant: DsBadgeVariant.warning),
          DsBadge(label: 'Danger', variant: DsBadgeVariant.danger),
        ],
      ),
    );

    dsGoldenMatrix(
        'atom', 'box', () => const DsBox(child: Text('Boxed content')));

    // Captured over the wash so the glow reads against its natural backdrop.
    dsGoldenMatrix(
      'atom',
      'brand_bloom',
      () => const SizedBox(
        height: 160,
        child: DsAuthGradient(child: DsBrandBloom()),
      ),
    );

    // The multi-pool sweep: a single quiet hue on the neutral base, the brand
    // stops under the skin.
    dsGoldenMatrix(
      'atom',
      'brand_bloom_pools',
      () => const SizedBox(
        height: 160,
        child: DsAuthGradient(child: DsBrandBloom.pools()),
      ),
    );

    // The pool sweep on the dark skin, so the dark bloom stops are pinned
    // alongside the light ones the matrix already captures.
    testWidgets('atom · brand_bloom_pools · skin-engen-dark', (tester) async {
      await expectDsGolden(
        tester,
        const SizedBox(
          height: 160,
          child: DsAuthGradient(child: DsBrandBloom.pools()),
        ),
        name: 'atom__brand_bloom_pools__skin-engen-dark',
        theme: DsTheme.dark(tokens: DsSkins.engenDark()),
      );
    });

    // A row of every button variant.
    dsGoldenMatrix(
      'atom',
      'button',
      () => const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          DsButton(label: 'Primary'),
          DsButton(label: 'Secondary', variant: DsButtonVariant.secondary),
          DsButton(label: 'Danger', variant: DsButtonVariant.danger),
        ],
      ),
    );

    dsGoldenMatrix(
      'atom',
      'checkbox',
      () => DsCheckbox(value: true, label: 'Accept terms', onChanged: (_) {}),
    );

    dsGoldenMatrix('atom', 'chip', () => const DsChip(label: 'Active'));

    dsGoldenMatrix('atom', 'divider', () => const DsDivider());

    // Captured under reduced motion so the golden is the settled frame, not a
    // mid-entrance blend that shifts whenever the motion scale is tuned.
    dsGoldenMatrix(
      'atom',
      'fade_slide_in',
      () => const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: DsFadeSlideIn(child: Text('Entrance content')),
      ),
    );

    dsGoldenMatrix(
        'atom', 'icon', () => const DsIcon(icon: Icons.check_circle_outline));

    // Enabled beside disabled, so the disabled fade is pinned alongside the
    // resting circle.
    dsGoldenMatrix(
      'atom',
      'icon_button',
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          DsIconButton(
            icon: DsIcons.close,
            semanticLabel: 'Close',
            onPressed: () {},
          ),
          const DsIconButton(
            icon: DsIcons.close,
            semanticLabel: 'Close',
            onPressed: null,
          ),
        ],
      ),
    );

    // A row of every tone, where a token-pair regression surfaces.
    dsGoldenMatrix(
      'atom',
      'icon_badge',
      () => const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          DsIconBadge(icon: DsIcons.check),
          DsIconBadge(icon: DsIcons.check, tone: DsIconBadgeTone.brandSoft),
          DsIconBadge(icon: DsIcons.check, tone: DsIconBadgeTone.success),
          DsIconBadge(icon: DsIcons.warning, tone: DsIconBadgeTone.warning),
          DsIconBadge(icon: DsIcons.close, tone: DsIconBadgeTone.danger),
          DsIconBadge(icon: DsIcons.lock, tone: DsIconBadgeTone.neutral),
        ],
      ),
    );

    // No `src` → the deterministic fallback box (never touches the network).
    dsGoldenMatrix(
      'atom',
      'img',
      () => const DsImg(width: 96, height: 96, placeholder: Text('loading')),
    );

    dsGoldenMatrix('atom', 'inline', () => const DsInline(text: 'important'));

    dsGoldenMatrix('atom', 'link', () => const DsLink(label: 'View details'));

    // Static (animate stays false) so the fill lands on a deterministic frame.
    dsGoldenMatrix(
        'atom', 'progress_bar', () => const DsProgressBar(value: 0.6));

    dsGoldenMatrix(
      'atom',
      'radio',
      () => DsRadio<String>(
        value: 'a',
        groupValue: 'a',
        label: 'Option A',
        onChanged: (_) {},
      ),
    );

    dsGoldenMatrix(
        'atom', 'sparkline', () => const DsSparkline(values: [3, 5, 2, 8, 6, 9, 7]));

    dsGoldenMatrix(
      'atom',
      'segmented_control',
      () => Center(
        child: DsSegmentedControl<bool>(
          value: true,
          onChanged: (_) {},
          segments: const <DsSegment<bool>>[
            DsSegment(value: true, label: 'Asc', icon: DsIcons.arrowUp),
            DsSegment(value: false, label: 'Desc', icon: DsIcons.arrowDown),
          ],
        ),
      ),
    );

    dsGoldenMatrix('atom', 'spinner', () => const DsSpinner());

    dsGoldenMatrix(
      'atom',
      'step_header',
      () => const DsStepHeader(
        title: 'Describe your business in a few words.',
        lead: 'This helps us recommend the best setup.',
      ),
    );

    dsGoldenMatrix(
      'atom',
      'switch',
      () => DsSwitch(
        value: true,
        label: 'Email notifications',
        onChanged: (_) {},
      ),
    );

    // Primary and accent together, so the two-tone weight pairing is pinned.
    dsGoldenMatrix(
      'atom',
      'wordmark',
      () => const DsWordmark(primary: 'acme', accent: 'id'),
    );
  });
}
