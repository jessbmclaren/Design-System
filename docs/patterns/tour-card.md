# Tour card

`DsTourCard` is a stepped, illustrated walkthrough for a short product tour: a tinted frame holding the current step's illustration, the step's title and body, an animated progress bar and Back and Next actions, with Next becoming the finishing action on the last step. The card is controlled: the caller owns `currentStep` and moves it in `onStepChanged`, so a tour can be resumed, closed or driven from outside at any point.

Each `DsTourStep` carries a title, a body and an optional illustration. The design system ships no artwork; the illustration is any widget you supply, and the card draws a token-tinted surface behind it and swaps it with the step transition. Illustrations are decorative by default and stay out of the semantics tree; set `illustrationLabel` only when one carries information the copy does not.

A tour card differs from a coachmark in scope. A coachmark is a compact callout you anchor to one piece of UI to explain that one thing; the tour card is self-contained and walks through several ideas without pointing at anything. Introduce a control in place with `DsCoachmark`; give the two-minute overview after sign-up with a tour card, floated over the page in your own overlay.

Arrow keys move between steps whenever focus is inside the card, and `enableSwipe` adds horizontal swiping for touch. Progress is announced as "Step x of y" on every change. Step transitions run on the motion scale and collapse to a still frame under reduced motion. Below roughly 440dp of the card's own width the footer restacks: the progress bar takes its own line and the actions go full width beneath it, so nothing overflows on a 320dp phone.

## Guidelines

**Do**

- Keep the tour to a handful of steps; it is an overview, not the manual.
- Give each step one idea: the title names it and the body adds a sentence.
- Provide onSkip on every tour so people can leave from any step.
- Name the first real action in doneLabel ("Add your first record") so finishing the tour starts the work.

**Don't**

- Don't advance the tour from inside the card; move currentStep in your own state through onStepChanged.
- Don't use it to point at a specific control; anchor a DsCoachmark to the control instead.
- Don't gate the product behind it; a tour is skippable by definition.
- Don't restate the body in illustrationLabel; decorative artwork should stay silent for a screen reader.

## Example

```dart
DsTourCard(
  steps: const [
    DsTourStep(
      title: 'Import your data',
      body: 'Bring everything across in one spreadsheet.',
      illustration: ImportIllustration(),
    ),
    DsTourStep(
      title: 'Invite your team',
      body: 'Everyone works from the same records.',
    ),
    DsTourStep(
      title: 'You are ready',
      body: 'Add the first record and the rest follows.',
    ),
  ],
  currentStep: step,
  onStepChanged: (value) => setState(() => step = value),
  onSkip: _closeTour,
  onDone: _closeTour,
  doneLabel: 'Add your first record',
);
```

## See also

- [Coachmark](coachmark.md)
- [Setup guide](setup-guide.md)
- [Onboarding wizard](onboarding-wizard.md)
- [Progress bar](progress-bar.md)
