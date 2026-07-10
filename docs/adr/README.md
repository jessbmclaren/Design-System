# Architecture decision records

Short notes on the sharp decisions in this library: what we decided, what we
rejected and why. They exist because `CLAUDE.md` records the rules and git
history records the change, but neither keeps the option we turned down. That
rejected branch is what a newcomer re-litigates, so it lives here.

One file per decision, numbered `NNNN-title.md`, using this shape:

- **Status** accepted, superseded by NNNN, or deprecated.
- **Context** the forces in play when we chose.
- **Decision** what we settled on.
- **Rejected alternatives** the options we weighed and dropped, with the reason.
- **Consequences** what this buys us and what it costs.

Keep them to half a page. Add one only for a genuine fork with a real rejected
option, not for every change. Never edit an accepted record to reflect a new
decision: write a new record and mark the old one superseded.

| ADR | Decision |
| --- | --- |
| [0001](0001-white-label-base-vs-skin.md) | White-label base versus brand skin |
| [0002](0002-engen-is-a-theme-not-the-default.md) | Engen is a theme, not the default |
| [0003](0003-container-fit-responsiveness.md) | Container-fit responsiveness over window breakpoints |
| [0004](0004-brand-tunable-tokens.md) | Brand-tunable shadow and type-tracking tokens |
