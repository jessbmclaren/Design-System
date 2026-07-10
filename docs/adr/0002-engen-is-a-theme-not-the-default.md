# 0002. Engen is a theme, not the default

**Status:** accepted

## Context

Engen was the first real brand to land on the library, so its values were the
first concrete numbers we had: indigo `#15259B`, a navy ink ramp, tighter
heading tracking and an indigo-tinted card shadow. Because it was the only
brand in front of us, the pull was to treat its look as the library's look and
merge those values into `DsTokens.light()` / `dark()`.

## Decision

Engen ships as a skin, `DsSkins.engenLight()` and `DsSkins.engenDark()`, layered
on the neutral base per [0001](0001-white-label-base-vs-skin.md). It is opted
into with `DsTheme.light(tokens: DsSkins.engenLight())`. The white-label
defaults keep their neutral values and know nothing about Engen.

## Rejected alternatives

- **Make Engen the default by merging its values into `DsTokens.light()`.**
  Rejected: it re-brands every consumer who wanted the neutral base, and it
  couples the library's identity to one client. The next brand would then have
  to unpick Engen rather than start from neutral.

## Consequences

- The white-label default stays neutral and brand-free; Engen is opt-in.
- Golden tests render each atom across `default`, `dark` and `skin-engen`, so
  both the neutral base and the skin are protected against accidental change.
  Changing the Engen skin is a deliberate `--update-goldens` step.
- Engen proves the skin path end to end, which is the pattern any future brand
  follows.
