# Summary section

A summary section reads back what the user entered, with a way to go change it. It is the shape a review step takes before a flow commits: the title names the step, the edit link returns to it, and the body holds the values.

Keeping the edit affordance beside the title, rather than after the values, means a user scanning a review always finds the way back in the same place. The link announces what it edits, so a screen reader moving between sections never meets a row of identical Edit links.

## Guidelines

**Do**

- Name the section exactly as the step that collected it.
- Return the user to that step, with their answers still in place.
- Drop the edit link for anything that cannot be changed from here.

**Don't**

- Don't re-collect values in the summary; it reads back, it does not ask.
- Don't hide a value the user gave; a review that omits things is not a review.

## Example

```dart
DsSummarySection(
  title: 'Business details',
  onEdit: () => goToStep(1),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text('Northwind Traders'),
      Text('Registered 2019'),
    ],
  ),
);
```

## See also

- [Business verification](business-verification.md)
- [Onboarding wizard](onboarding-wizard.md)
- [Lists](lists.md)
