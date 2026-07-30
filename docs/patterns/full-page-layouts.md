# Full-page layouts

A full page opens with a `DsPageHeader`: a clear title, a short subtitle for context and the page's primary and secondary actions anchored to the top right. Below it, `DsTabs` splits the content into labelled sections so people meet a high-level overview first and drill into detail only when they choose to. This structure keeps every screen in the product predictable: the same header, action placement and progressive disclosure from summary to specifics.

Lead with the information most people need on arrival and move supporting detail into later tabs. Give each section a stable, deep-linkable route so a tab can be bookmarked, shared and reopened in place. Switching tabs should never reset the reader's scroll position or their earlier selections.

On a narrow screen the strip scrolls sideways rather than wrapping, because a wrapped strip pushes the page itself below the fold. The end it has more tabs past is faded, so a label dissolving at the edge reads as "there is more this way"; a strip whose tabs all fit is not faded at all. Keep labels short, and never put something people must do behind a tab that only exists after a sideways scroll.

![Desktop (1120dp)](img/full-page-layouts_desktop.png)

*Desktop (1120dp)*

![Small phone (320dp)](img/full-page-layouts_phone.png)

*Small phone (320dp)*

## Guidelines

**Do**

- Organise content into a small set of clearly labelled tabs.
- Lead with an overview, then progressively disclose detail.
- Keep the page header and its primary actions visible.
- Use a consistent header and layout across every page.
- Give each section its own deep-linkable route.

**Don't**

- Don't surface everything on a single screen at once.
- Don't push primary actions below the fold.
- Don't nest tabs inside tabs.
- Don't reset scroll position or selection when a tab changes.

## Example

```dart
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    DsPageHeader(
      title: 'Customers',
      subtitle: '1,284 active this month',
      actions: [
        DsButton(
          label: 'Filter',
          variant: DsButtonVariant.secondary,
          onPressed: () {},
        ),
        DsButton(label: 'Add customer', onPressed: () {}),
      ],
    ),
    DsTabs(
      tabs: const [
        DsTab(label: 'Overview'),
        DsTab(label: 'Activity'),
        DsTab(label: 'Settings'),
      ],
      selectedIndex: selectedIndex,
      onChanged: (index) => setState(() => selectedIndex = index),
    ),
    // Render the selected section's content here.
  ],
)
```

## See also

- [Lists](lists.md)
- [Filter controls](filter-controls.md)
- [Action buttons](action-buttons.md)
