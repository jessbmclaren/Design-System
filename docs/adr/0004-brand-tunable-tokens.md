# 0004. Brand-tunable shadow and type-tracking tokens

**Status:** accepted

## Context

Bringing Engen's real values in (see
[0002](0002-engen-is-a-theme-not-the-default.md)) exposed two appearance
dimensions with no token behind them. Components read their drop shadow straight
from the `DsElevation` primitive, and the type ramp had no letter-spacing. Engen
wanted an indigo-tinted shadow and headings tracked at `-0.4`, and neither was
reachable from a skin: per [0001](0001-white-label-base-vs-skin.md) a skin is a
`DsTokens` built with `copyWith`, and you cannot `copyWith` a primitive a
component reads directly.

## Decision

Promote both to the token layer.

- Add `shadowLow`, `shadowMedium` and `shadowHigh` (`List<BoxShadow>`) to
  `DsTokens`, defaulting to `DsElevation.low` / `medium` / `high`. Components
  read `tokens.shadowMedium`, not `DsElevation.medium`.
- Add nullable `letterSpacing` to `DsTypeToken`, carried through to the emitted
  `TextStyle`.

Engen then supplies its indigo-tinted shadow scale and `-0.4` heading tracking
through `copyWith`, like any other token.

## Rejected alternatives

- **Leave components reading `DsElevation` directly.** Rejected: a skin cannot
  override a primitive, so a brand-tinted shadow was impossible. This is the
  same rule as [0001](0001-white-label-base-vs-skin.md).
- **A bespoke per-brand shadow widget.** Rejected: elevation is an appearance
  value, so it belongs in the token layer next to colour and radius, not in a
  one-off widget.

## Consequences

- Elevation and type tracking are now brandable like colour and radius.
- The cost is the `ThemeExtension` contract every `DsTokens` field carries:
  constructor, field, `light()` / `dark()` defaults, `copyWith`, `lerp`, `==`
  and `hashCode`. A `List<BoxShadow>` field also needs `listEquals` (from
  `package:flutter/foundation.dart`), `Object.hashAll` and `BoxShadow.lerpList`,
  so theme animation and equality stay correct.
