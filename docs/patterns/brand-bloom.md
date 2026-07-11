# Brand bloom

The brand bloom is the soft radial glow that lifts an auth backdrop from a flat wash to a branded one. `DsBrandBloom` paints a single pool of the theme's `bloomColor` that fades to transparent, anchored by `alignment` and sized by `radius`. The default token is a quiet neutral, so the white-label look barely changes until a skin supplies its brand tint.

The bloom is static decoration: excluded from semantics, with no animation to still under reduced motion. Layer it between a `DsAuthGradient` and the page content, and tune `opacity` when the glow competes with what sits on top. Like the wash, it fills the bounds its parent provides.

## Guidelines

**Do**

- Anchor the glow along an edge or corner, rising into the page.
- Keep the default opacity unless the content on top loses contrast.
- Let the `bloomColor` token carry the brand; the widget only shapes it.

**Don't**

- Don't stack several blooms to build a scene; one pool is an accent, more is wallpaper.
- Don't put small text directly over the densest part of the glow.
- Don't use it to signal state; it is decoration, not feedback.

## Example

```dart
Stack(
  fit: StackFit.expand,
  children: [
    const DsAuthGradient(),
    const DsBrandBloom(alignment: Alignment.bottomRight),
    Center(child: signInCard),
  ],
);
```

## See also

- [Auth gradient](auth-gradient.md)
- [Waiting screens](waiting-screens.md)
