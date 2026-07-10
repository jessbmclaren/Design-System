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

    dsGoldenMatrix(
        'atom', 'icon', () => const DsIcon(icon: Icons.check_circle_outline));

    // No `src` → the deterministic fallback box (never touches the network).
    dsGoldenMatrix(
      'atom',
      'img',
      () => const DsImg(width: 96, height: 96, placeholder: Text('loading')),
    );

    dsGoldenMatrix('atom', 'inline', () => const DsInline(text: 'important'));

    dsGoldenMatrix('atom', 'link', () => const DsLink(label: 'View details'));

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

    dsGoldenMatrix('atom', 'spinner', () => const DsSpinner());

    dsGoldenMatrix(
      'atom',
      'switch',
      () => DsSwitch(
        value: true,
        label: 'Email notifications',
        onChanged: (_) {},
      ),
    );
  });
}
