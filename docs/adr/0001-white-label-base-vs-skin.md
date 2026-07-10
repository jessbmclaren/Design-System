# 0001. White-label base versus brand skin

**Status:** accepted

## Context

The library has to dress up as more than one brand. The question is where a
brand's appearance lives. Colour, radius, type and elevation all vary by brand,
and every component reads them. If brand values sit in the wrong place the
library either can't re-theme cleanly or carries one client's look as its
baseline.

## Decision

`DsTokens.light()` and `DsTokens.dark()` are a neutral, brand-neutral base and
stay neutral. A brand is a **skin**: a `DsTokens` value built with `copyWith`
(collected in `DsSkins`), opted into with `DsTheme.light(tokens: mySkin())`.

Components read appearance only from `DsTokens.of(context)`. They never read a
primitive (`DsColors`, `DsElevation`, `DsRadii`, `DsSpacing`, `DsTypography`)
directly. The primitives back the token defaults; the component consumes the
token.

## Rejected alternatives

- **Bake a default brand into `DsTokens.light()`.** Rejected: every brand then
  inherits another brand's residue, and there is no neutral baseline to diff a
  skin against or to hand a new client.
- **A widget subclass per brand.** Rejected: subclasses drift from the base
  over time and can reach past the token contract into internals, which breaks
  the single source of appearance.

## Consequences

- Adding a brand is data (`copyWith`), not code. The base stays diff-able and
  the skin is a small, reviewable delta.
- The cost is discipline: no component may read a primitive, and every
  appearance value a component needs must exist as a token (see
  [0004](0004-brand-tunable-tokens.md)).
- `DsTokens` is a `ThemeExtension`, so each field is threaded through the
  constructor, defaults, `copyWith`, `lerp`, `==` and `hashCode`.
