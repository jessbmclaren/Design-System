# Fade slide in

A fade slide in wraps content arriving on screen for the first time: the child fades in while sliding up a few pixels, then never replays. `DsFadeSlideIn` runs on the motion scale and collapses to the settled frame under reduced motion, delay included.

Give several siblings an increasing delay, most simply from `DsMotion.stagger`, so a group reveals a beat apart instead of all at once. The child's semantics are exposed from the moment it mounts, so assistive technology reads the content without waiting on the choreography.

## Guidelines

**Do**

- Wrap whole blocks, such as a card or a step, rather than single words.
- Stagger siblings with `DsMotion.stagger` so the reveal reads in order.
- Trust the defaults; the duration and curve come from the motion scale.

**Don't**

- Don't animate content that is already on screen when it merely updates.
- Don't chain long delays; the page should settle within half a second.
- Don't hide meaning behind the entrance; screen readers get the content immediately.

## Example

```dart
DsFadeSlideIn(
  delay: DsMotion.stagger(context, index),
  child: card,
);
```

## See also

- [Motion](motion.md)
- [Box](box.md)
