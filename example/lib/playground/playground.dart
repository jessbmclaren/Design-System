import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../ui/code_block.dart';
import '../ui/demo_stage.dart';
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
  DemoViewport _viewport = DemoViewport.desktop;

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

    // The live component, framed in the shared stage so the playground and the
    // static demos wear the same viewport switch and the same surface.
    final stage = DemoStageCard(
      viewport: _viewport,
      minHeight: 180,
      child: Builder(builder: (context) => spec.builder(context, _values)),
    );

    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Controls', style: DocsType.headline(docs.textPrimary)),
            ),
            DsButton(
              label: 'Reset',
              variant: DsButtonVariant.secondary,
              onPressed: _reset,
            ),
          ],
        ),
        const SizedBox(height: 18),
        for (final knob in spec.knobs) ...[
          _control(knob),
          const SizedBox(height: 14),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // One header spanning the whole panel: the "Playground" title on the
        // left and the viewport switch on the right, so the stage and the
        // controls read as one unit rather than two stacked headings.
        DemoSectionHeader(
          title: 'Playground',
          trailingBuilder: (compact) => DemoViewportControl(
            value: _viewport,
            onChanged: (v) => setState(() => _viewport = v),
            compact: compact,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 720) {
              // Stage grows to fill the row; the controls hold a steady column
              // on the right. Top-aligned so both start on the same line.
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: stage),
                  const SizedBox(width: 28),
                  SizedBox(width: 300, child: controls),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                stage,
                const SizedBox(height: 24),
                controls,
              ],
            );
          },
        ),
        if (spec.code != null) ...[
          const SizedBox(height: 20),
          CodeBlock(code: spec.code!(_values)),
        ],
      ],
    );
  }
}
