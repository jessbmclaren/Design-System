// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Foundations → Motion.
final PatternPage motionPage = PatternPage(
  id: 'motion',
  group: DocGroup.foundations,
  navTitle: 'Motion',
  title: 'Motion',
  description:
      'Motion is a material, not a decoration. In this system things enter by '
      'decelerating into place, leave by accelerating away and settle with a '
      'subtle overshoot instead of snapping. That is the difference between an '
      'interface that feels mechanical and one that feels alive. `DsMotion` '
      'gives you the vocabulary to do that consistently: a small duration '
      'scale, a set of physical curves, a spring for true physics and a '
      'stagger helper for choreographing a group. Use the tokens, not '
      'raw millisecond values, so every surface moves with the same hand.',
  blocks: const [
    ProseBlock(
      'Three ideas run through all of it. **Purposeful.** Motion earns its '
      'place by explaining a change (where a thing came from, where it went) or '
      'directing attention, never as ornament. **Physical.** Easing mimics '
      'real objects: quick to start, softly landing, with weight; the `settle` '
      'curve and the `spring` give an arrival that hint of overshoot that reads '
      'as alive. **Choreographed.** When several elements change together, '
      'stagger them a beat apart with `DsMotion.stagger` so the sequence has '
      'cause and effect rather than a simultaneous jump.',
    ),
    SubheadingBlock('Duration scale'),
    VariablesBlock(rows: [
      VariableRow(name: 'DsMotion.fast', type: 'Duration', example: '120ms', description: 'Micro-interactions: hover, press, a toggle flipping.'),
      VariableRow(name: 'DsMotion.base', type: 'Duration', example: '220ms', description: 'The standard transition for most state changes.'),
      VariableRow(name: 'DsMotion.slow', type: 'Duration', example: '360ms', description: 'Larger surfaces (sheets, dialogs, an accordion) where time reads as weight.'),
      VariableRow(name: 'DsMotion.expressive', type: 'Duration', example: '520ms', description: 'Choreographed, hero moments. Use sparingly; it is a spotlight.'),
    ]),
    SubheadingBlock('Curves'),
    VariablesBlock(rows: [
      VariableRow(name: 'DsMotion.standard', type: 'Curve', example: 'easeOutCubic', description: 'The everyday gentle decelerate into place.'),
      VariableRow(name: 'DsMotion.emphasized', type: 'Curve', example: 'cubic(0.2, 0, 0, 1)', description: 'A strong decelerate for entrances: fast off the mark, softly landing.'),
      VariableRow(name: 'DsMotion.decelerate', type: 'Curve', example: 'cubic(0.05, 0.7, 0.1, 1)', description: 'Pure decelerate for elements arriving from off-screen.'),
      VariableRow(name: 'DsMotion.accelerate', type: 'Curve', example: 'cubic(0.3, 0, 0.8, 0.15)', description: 'Accelerate for elements leaving the screen entirely.'),
      VariableRow(name: 'DsMotion.settle', type: 'Curve', example: 'cubic(0.34, 1.35, 0.64, 1)', description: 'A physical settle with a restrained overshoot: the premium, alive arrival.'),
      VariableRow(name: 'DsMotion.spring', type: 'SpringDescription', example: 'stiffness 180', description: 'A spring for physics-driven motion: a dragged card snapping back.'),
    ]),
    ProseBlock(
      'One law above all: **respect reduced motion.** When a person has '
      'asked their platform for less motion, animation is not softened. It is '
      'removed. Resolve every duration and curve through `DsMotion.durationOf` '
      'and `DsMotion.curveOf`, which collapse to a still, instant change under '
      'the setting, and gate any bespoke animation behind `DsMotion.reduced`. '
      'The demo above obeys this: press Replay with reduce-motion on and it '
      'stays put.',
    ),
  ],
  dos: const [
    'Use the duration scale and curves; a bespoke millisecond value is a '
        'motion that agrees with nothing else on screen.',
    'Let entrances decelerate (`emphasized`) and exits accelerate '
        '(`accelerate`). Motion should mirror how real objects arrive and leave.',
    'Choreograph a group with `DsMotion.stagger` so a reveal reads as a '
        'sequence, not a simultaneous pop.',
    'Resolve durations and curves through `durationOf` / `curveOf`, and gate '
        'custom animation on `DsMotion.reduced`, so reduce-motion is honoured '
        'everywhere by construction.',
  ],
  donts: const [
    "Don't animate for its own sake; if a motion doesn't explain a change or "
        'guide attention, cut it.',
    "Don't use a bouncy elastic curve: `settle` gives a hint of "
        'overshoot; more than that reads as a toy, not a tool.',
    "Don't run long or looping animation on content people are trying to read; "
        'reserve `expressive` for genuine moments.',
    "Don't ship an animation that ignores reduce-motion. That is an "
        'accessibility defect, not a polish gap.',
  ],
  code: '''
// Resolve tokens through the reduce-motion-aware helpers.
AnimatedContainer(
  duration: DsMotion.durationOf(context, DsMotion.base),
  curve: DsMotion.curveOf(context, DsMotion.emphasized),
  // …
);

// Choreograph a group: each item begins a beat after the last.
for (var i = 0; i < items.length; i++)
  AnimatedReveal(
    delay: DsMotion.stagger(context, i),
    curve: DsMotion.settle,
    child: items[i],
  );
''',
  shots: const [
    Shot(pageId: 'motion', size: ShotSize.desktop),
    Shot(pageId: 'motion', size: ShotSize.phone),
  ],
  hasLiveDemo: true,
  related: ['design-tokens'],
);
