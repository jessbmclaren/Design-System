import 'package:design_system/design_system.dart';

import 'playground.dart';

/// Interactive playgrounds keyed by page id. A page with a spec here shows a
/// live knobs panel in place of its static demo, so people can turn each prop
/// and watch the component (and its code) update.
final Map<String, PlaygroundSpec> _playgrounds = {
  'action-buttons': PlaygroundSpec(
    knobs: const [
      SelectKnob('variant', 'Variant', value: DsButtonVariant.primary, options: [
        (label: 'Primary', value: DsButtonVariant.primary),
        (label: 'Secondary', value: DsButtonVariant.secondary),
        (label: 'Danger', value: DsButtonVariant.danger),
      ]),
      ToggleKnob('icon', 'Leading icon'),
      ToggleKnob('pending', 'Pending'),
      ToggleKnob('disabled', 'Disabled'),
      TextKnob('label', 'Label', value: 'Save changes'),
    ],
    builder: (context, v) => DsButton(
      label: (v['label'] as String).isEmpty ? 'Button' : v['label'] as String,
      variant: v['variant'] as DsButtonVariant,
      icon: (v['icon'] as bool) ? DsIcons.check : null,
      pending: v['pending'] as bool,
      onPressed: (v['disabled'] as bool) ? null : () {},
    ),
    code: (v) {
      final b = StringBuffer('DsButton(\n');
      b.writeln("  label: '${v['label']}',");
      b.writeln('  variant: DsButtonVariant.${(v['variant'] as DsButtonVariant).name},');
      if (v['icon'] as bool) b.writeln('  icon: DsIcons.check,');
      if (v['pending'] as bool) b.writeln('  pending: true,');
      b.writeln('  onPressed: ${(v['disabled'] as bool) ? 'null' : '() {}'},');
      b.write(');');
      return b.toString();
    },
  ),
  'avatar': PlaygroundSpec(
    knobs: const [
      TextKnob('name', 'Name', value: 'Ada Lovelace'),
      SelectKnob('size', 'Size', value: 48.0, options: [
        (label: 'Small', value: 32.0),
        (label: 'Medium', value: 48.0),
        (label: 'Large', value: 64.0),
      ]),
    ],
    builder: (context, v) => DsAvatar(
      name: (v['name'] as String).isEmpty ? null : v['name'] as String,
      size: v['size'] as double,
    ),
    code: (v) => "DsAvatar(\n"
        "  name: '${v['name']}',\n"
        "  size: ${(v['size'] as double).toStringAsFixed(0)},\n"
        ");",
  ),
  'link': PlaygroundSpec(
    knobs: const [
      TextKnob('label', 'Label', value: 'View documentation'),
      SelectKnob('variant', 'Variant', value: DsLinkVariant.primary, options: [
        (label: 'Primary', value: DsLinkVariant.primary),
        (label: 'Secondary', value: DsLinkVariant.secondary),
      ]),
      ToggleKnob('external', 'External'),
    ],
    builder: (context, v) => DsLink(
      label: (v['label'] as String).isEmpty ? 'Link' : v['label'] as String,
      variant: v['variant'] as DsLinkVariant,
      external: v['external'] as bool,
      onPressed: () {},
    ),
    code: (v) => "DsLink(\n"
        "  label: '${v['label']}',\n"
        "  variant: DsLinkVariant.${(v['variant'] as DsLinkVariant).name},\n"
        "${(v['external'] as bool) ? '  external: true,\n' : ''}"
        "  onPressed: () {},\n"
        ");",
  ),
  'text-fields': PlaygroundSpec(
    knobs: const [
      TextKnob('label', 'Label', value: 'Email'),
      TextKnob('hint', 'Hint', value: 'you@company.com'),
      ToggleKnob('error', 'Error'),
      ToggleKnob('obscure', 'Obscure'),
      ToggleKnob('disabled', 'Disabled'),
    ],
    builder: (context, v) => DsTextField(
      label: (v['label'] as String).isEmpty ? null : v['label'] as String,
      hintText: (v['hint'] as String).isEmpty ? null : v['hint'] as String,
      errorText: (v['error'] as bool) ? 'Enter a valid value' : null,
      obscureText: v['obscure'] as bool,
      enabled: !(v['disabled'] as bool),
    ),
    code: (v) {
      final b = StringBuffer('DsTextField(\n');
      b.writeln("  label: '${v['label']}',");
      b.writeln("  hintText: '${v['hint']}',");
      if (v['error'] as bool) b.writeln("  errorText: 'Enter a valid value',");
      if (v['obscure'] as bool) b.writeln('  obscureText: true,');
      if (v['disabled'] as bool) b.writeln('  enabled: false,');
      b.write(');');
      return b.toString();
    },
  ),
  'loading': PlaygroundSpec(
    knobs: const [
      SelectKnob('size', 'Size', value: DsSpinnerSize.medium, options: [
        (label: 'Small', value: DsSpinnerSize.small),
        (label: 'Medium', value: DsSpinnerSize.medium),
        (label: 'Large', value: DsSpinnerSize.large),
      ]),
    ],
    builder: (context, v) => DsSpinner(size: v['size'] as DsSpinnerSize),
    code: (v) => 'DsSpinner(size: DsSpinnerSize.${(v['size'] as DsSpinnerSize).name});',
  ),
};

/// The playground for [id], or null if the page has none.
PlaygroundSpec? playgroundFor(String id) => _playgrounds[id];
