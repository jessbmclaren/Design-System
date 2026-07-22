// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Inputs → Radio group.
final PatternPage radioGroupPage = PatternPage(
  id: 'radio-group',
  group: DocGroup.inputs,
  navTitle: 'Radio group',
  title: 'Radio group',
  description:
      '`DsRadioGroup` is the single-select list primitive: hand it a list of '
      '`DsRadioOption`s and it stacks one `DsRadio` per option, reporting the '
      'chosen value through one `onChanged`. Reach for it — rather than a '
      '`DsSelect` dropdown — when the choices are few and worth seeing at a '
      'glance (a role, a plan tier, a delivery speed): laying them out flat '
      'trades a little height for a decision the reader can make without '
      'opening a menu. It is controlled, so the parent owns the value; an '
      'optional `label` renders a field label above the list, and an '
      '`errorText` renders beneath it for a group that must not be left empty.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'The group owns no state of its own — pass the selected value and update '
      'it in the callback. Because every option is visible, it doubles as its '
      'own affordance: there is no closed field to open, so the reader compares '
      'all the choices at once. Keep the list short; past six or seven options a '
      '`DsSelect` reads better. Each row is its own radio to assistive '
      'technology and the set announces itself as mutually exclusive, so the '
      'group adds no wrapper beyond the label and error message.',
    ),
  ],
  dos: const [
    'Use a radio group for a mutually exclusive choice among a few options that '
        'are worth seeing at once.',
    'Give the group a `label` so the question sits above the options like any '
        'other field.',
    'Set `errorText` when the group is required and left empty, rather than '
        'rolling your own message.',
    'Write each option as the outcome it names ("Founder / owner"), not a code.',
  ],
  donts: const [
    'Do not use a radio group for a long list; reach for `DsSelect` once the '
        'options stop fitting comfortably.',
    'Do not use it for independent options that can each be on or off; that is '
        'a set of checkboxes (`DsChipGroup`).',
    'Do not track each row yourself; hand the group `options` and read back one '
        'value.',
  ],
  code: '''
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

String? role;

DsRadioGroup<String>(
  label: 'What is your role?',
  options: const [
    DsRadioOption(value: 'owner', label: 'Founder / owner'),
    DsRadioOption(value: 'admin', label: 'Administrator'),
    DsRadioOption(value: 'ops', label: 'Operations'),
    DsRadioOption(value: 'finance', label: 'Finance'),
    DsRadioOption(value: 'other', label: 'Other'),
  ],
  value: role,
  errorText: submitted && role == null ? 'Please select your role' : null,
  onChanged: (next) => setState(() => role = next),
)
''',
  shots: const [
    Shot(pageId: 'radio-group', size: ShotSize.desktop),
    Shot(pageId: 'radio-group', size: ShotSize.phone),
  ],
  related: ['selection-controls', 'select', 'choice-chips'],
);
