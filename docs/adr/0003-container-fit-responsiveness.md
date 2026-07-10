# 0003. Container-fit responsiveness over window breakpoints

**Status:** accepted

## Context

A form field group should stack its fields one per row when it is cramped and
flow them two per row when there is room. The obvious first cut keys that
choice on the Material 3 window class from `DsBreakpoints` (compact below
600dp, medium 600 to 840, expanded above). But a component does not own the
window. The same field group can sit in a narrow card on a wide desktop, where
the window is `expanded` but the component has 300dp to work with.

## Decision

Layout-shaping components respond to their own measured width, not the window
class. `DsFormFieldGroup` uses a `LayoutBuilder` and a content threshold
(`minRowWidth = 360`): at or above it the fields flow two per row, below it they
stack. `DsBreakpoints.of(context)` is reserved for genuine window-class
decisions, such as page chrome and padding. Wide pages still cap their main
content at `DsBreakpoints.contentMaxWidth` (960dp) and centre the surplus, so a
layout does not sprawl to 1920dp.

## Rejected alternatives

- **Key component layout on the window class.** Rejected: a component in a
  narrow pane on a wide screen would read `expanded` and use the wide layout,
  then overflow. What matters for a component's internal layout is the
  component's width, not the window's.

## Consequences

- One component fits a narrow card and a wide pane without a variant.
- `example/test/device_matrix_test.dart` sweeps each page across the device
  ladder (320dp to 1920dp), and a component's own test asserts no overflow at
  320dp and at a wide width.
- The rule to hold: measure yourself with a `LayoutBuilder`, and ask the window
  only for window-level choices.
