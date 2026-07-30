# Bottom navigation

A bottom navigation bar puts a phone's top-level destinations along the edge where the thumb already rests. `DsBottomNav` is the touch counterpart to the nav rail: both take the same `DsNavItem` vocabulary, so a product can swap one for the other on a window-class change without restating its navigation.

The selected destination carries a brand-tinted pill behind its glyph and the brand ink on both glyph and label, and announces itself as selected, so the current place reads without relying on colour alone. Labels stay visible rather than appearing on selection, because a label that comes and goes moves the row it sits in.

Three to five destinations read comfortably on a phone. Beyond that the labels crush, and the last destinations belong behind one of the others. Every destination holds the 48dp minimum target even where a short label leaves the content smaller, and the bar honours the device's bottom inset itself.

Selection is controlled: pass `selectedRoute` and apply `onNavigate` yourself. A null callback disables the whole bar and drops it from the focus order. Nested `DsNavItem` children and section headings are ignored, because a bottom bar is a flat set of top-level places and anything deeper belongs on the destination itself.

## Guidelines

**Do**

- Keep the set to three to five top-level places.
- Use the same `DsNavItem` list as the rail, so the two forms agree.
- Pair the bar with a rail above the compact window class.

**Don't**

- Don't nest destinations; a bottom bar is flat by design.
- Don't hide the labels to fit more places in.
- Don't put a destructive or one-off action in the bar.

## Example

```dart
DsBottomNav(
  items: const [
    DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
    DsNavItem(label: 'Fuel', icon: DsIcons.fuel, route: 'fuel'),
    DsNavItem(label: 'History', icon: DsIcons.time, route: 'history'),
    DsNavItem(label: 'Account', icon: DsIcons.user, route: 'account'),
  ],
  selectedRoute: 'home',
  onNavigate: (String route) => setState(() => _route = route),
);
```

## See also

- [Navigation rail](nav-rail.md)
- [App shell](app-shell.md)
- [Action tiles](action-tile.md)
