import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../ui/code_block.dart';
import '../ui/docs_style.dart';

/// A single interactive control in a component [PlaygroundSpec].
///
/// Knobs are pure data. The [PlaygroundPanel] renders the matching control
/// (a [DsSelect], [DsSwitch] or [DsTextField]), so a spec reads as a plain
/// list of the props a person can turn.
sealed class Knob {
  const Knob(this.id, this.label);

  /// The key this knob writes into the values map handed to the builder.
  final String id;

  /// The human-readable control label.
  final String label;

  /// The starting value.
  Object? get initial;
}

/// A pick-one knob rendered as a [DsSelect].
class SelectKnob extends Knob {
  const SelectKnob(super.id, super.label,
      {required this.options, required this.value});

  final List<({String label, Object? value})> options;
  final Object? value;

  @override
  Object? get initial => value;
}

/// A boolean knob rendered as a [DsSwitch].
class ToggleKnob extends Knob {
  const ToggleKnob(super.id, super.label, {this.value = false});

  final bool value;

  @override
  Object? get initial => value;
}

/// A free-text knob rendered as a [DsTextField].
class TextKnob extends Knob {
  const TextKnob(super.id, super.label, {required this.value});

  final String value;

  @override
  Object? get initial => value;
}

/// Describes an interactive playground for one component: the [knobs] a person
/// can turn, a [builder] that renders the component from the current knob
/// values and an optional [code] generator that mirrors those values.
class PlaygroundSpec {
  const PlaygroundSpec({required this.knobs, required this.builder, this.code});

  final List<Knob> knobs;
  final Widget Function(BuildContext context, Map<String, Object?> values)
      builder;
  final String Function(Map<String, Object?> values)? code;
}

/// Renders a [PlaygroundSpec]: a live stage that re-renders the component as
/// the knobs change, the knobs themselves and the generated code. Stage and
/// knobs sit side by side on wide viewports and stack on a phone.
class PlaygroundPanel extends StatefulWidget {
  const PlaygroundPanel({super.key, required this.spec});

  final PlaygroundSpec spec;

  @override
  State<PlaygroundPanel> createState() => _PlaygroundPanelState();
}

class _PlaygroundPanelState extends State<PlaygroundPanel> {
  late Map<String, Object?> _values;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _seed();
  }

  void _seed() {
    _values = {for (final knob in widget.spec.knobs) knob.id: knob.initial};
    for (final knob in widget.spec.knobs) {
      if (knob is TextKnob) {
        _controllers[knob.id] = TextEditingController(text: knob.value);
      }
    }
  }

  void _reset() {
    setState(() {
      for (final knob in widget.spec.knobs) {
        _values[knob.id] = knob.initial;
        if (knob is TextKnob) _controllers[knob.id]?.text = knob.value;
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _control(Knob knob) {
    switch (knob) {
      case SelectKnob():
        return DsSelect<Object?>(
          label: knob.label,
          value: _values[knob.id],
          options: [
            for (final option in knob.options)
              DsSelectOption<Object?>(value: option.value, label: option.label),
          ],
          onChanged: (value) => setState(() => _values[knob.id] = value),
        );
      case ToggleKnob():
        return DsSwitch(
          label: knob.label,
          value: _values[knob.id] as bool? ?? false,
          onChanged: (value) => setState(() => _values[knob.id] = value),
        );
      case TextKnob():
        return DsTextField(
          label: knob.label,
          controller: _controllers[knob.id],
          onChanged: (value) => setState(() => _values[knob.id] = value),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    final spec = widget.spec;

    final stage = Container(
      decoration: BoxDecoration(
        color: docs.surface,
        border: Border.all(color: docs.separator),
        borderRadius: BorderRadius.circular(DocsRadii.lg),
        boxShadow: DocsShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Builder(builder: (context) => spec.builder(context, _values)),
        ),
      ),
    );

    final knobs = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Playground', style: DocsType.headline(docs.textPrimary)),
            ),
            DsButton(
              label: 'Reset',
              variant: DsButtonVariant.secondary,
              onPressed: _reset,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final knob in spec.knobs) ...[
          _control(knob),
          const SizedBox(height: 12),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 720) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: SizedBox(height: 260, child: stage)),
                  const SizedBox(width: 24),
                  SizedBox(width: 300, child: knobs),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 220, child: stage),
                const SizedBox(height: 16),
                knobs,
              ],
            );
          },
        ),
        if (spec.code != null) ...[
          const SizedBox(height: 16),
          CodeBlock(code: spec.code!(_values)),
        ],
      ],
    );
  }
}
