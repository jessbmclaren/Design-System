# Step header

A step header opens a wizard or onboarding step with the step's single question or task. Use `DsStepHeader` for the title and, when the step needs one, a short lead saying why you are asking. The title takes its size from the type ramp and the lead renders in the secondary text colour, so the question stays the loudest thing on screen.

With `inlineLead` the lead continues the title's own paragraph in a lighter weight, so the pair reads as one flowing sentence: a bold question followed by a muted why. That is the house style for onboarding steps. The default keeps the lead as its own paragraph beneath the title, which suits longer supporting copy. The alignment option matches the heading alignment used by the sign-in and sign-up views, so adjacent screens line up.

## Guidelines

**Do**

- Keep the title to one sentence: the step's question or task.
- Use the lead to say why the step matters, not to repeat the title.
- Pick one size per flow and keep it for every step.
- Match the alignment of the surrounding view, such as a sign-up screen.

**Don't**

- Don't stack two questions into one header.
- Don't move instructions that belong beside a field into the lead.
- Don't centre the header above a left-aligned form.

## Example

```dart
const DsStepHeader(
  title: 'Describe your business in a few words.',
  lead: 'This helps us recommend the best setup.',
  inlineLead: true,
);
```

## See also

- [Onboarding wizard](onboarding-wizard.md)
- [Sign up](sign-up.md)
