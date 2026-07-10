# Animated ellipsis

An animated ellipsis trails waiting copy such as "Preparing your workspace", cycling from no dots up to three and back while work is in progress. `DsAnimatedEllipsis` reserves the width of the full ellipsis up front, so the sentence it follows never shifts as dots come and go.

Under reduced motion the dots do not cycle: the widget renders a static full ellipsis instead, so the copy still reads as ongoing. The dots change several times a second, so by default they are excluded from semantics and the sentence they trail carries the meaning. Announce progress through that text or a live region around it, never through the dots.

## Guidelines

**Do**

- Attach it to a sentence that names what is happening.
- Announce progress through the surrounding text, not the dots.
- Swap to a progress bar once the wait becomes measurable.

**Don't**

- Don't show it without any copy; three bare dots explain nothing.
- Don't pair it with a spinner on the same line.
- Don't leave it running after the work has finished.

## Example

```dart
Text.rich(
  TextSpan(
    children: [
      const TextSpan(text: 'Preparing your workspace'),
      WidgetSpan(child: DsAnimatedEllipsis()),
    ],
  ),
);
```

## See also

- [Loading](loading.md)
- [Waiting screens](waiting-screens.md)
