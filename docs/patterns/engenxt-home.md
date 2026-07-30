# EngenXT home

A whole phone screen assembled from the library under `DsSkins.engenMobileLight()`. This is the atomic model's top level, where the system meets real content and the parts are tested against each other rather than one at a time.

Nothing on the screen draws a colour, radius, size or shadow of its own. The brand mark, the greeting, the status pills, the promoted panel, the shortcuts and the bar all read their appearance from `DsTokens.of(context)`, so pointing the theme at another skin re-brands the screen without touching a widget.

The header pairs a rounded `DsIconBadge` with a bare `DsWordmark`: the mark takes no arguments, because the skin already carries the name and the colour of its suffix. The bell is a `DsIconButton` with `showIndicator`, and the dot says what it means through `indicatorSemanticLabel` rather than sitting there as silent decoration.

The promoted panel is the one interesting piece. It re-tints its own subtree instead of passing colours down: the ink tokens are swapped for their on-brand counterparts in a nested `Theme`, so every atom inside keeps reading the tokens and none of them needs to know it is sitting on a brand gradient. That is the trick for any surface that inverts.

The greeting sets in the `display` tier and the two eyebrows in `labelEyebrow`, which the mobile skin sets in caps and tracks out. The eyebrow transform lives in the token, so the page passes plain sentence case and the skin decides how it is set.

## Guidelines

**Do**

- Let the skin carry the brand: the wordmark and its accent need no arguments.
- Re-tint a subtree with nested tokens when a surface inverts.
- Say what an indicator dot means, so it is not a silent state change.

**Don't**

- Don't hardcode an on-brand ink; swap the token and let the atoms read it.
- Don't set an eyebrow in caps in the copy; the token applies the transform.
- Don't reach past a component to restyle its internals.

## Example

```dart
Theme(
  data: DsTheme.light(tokens: DsSkins.engenMobileLight()),
  child: Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DsWordmark(),
              Text(
                'David',
                style: tokens.display.toTextStyle(color: tokens.colorText),
              ),
              const DsBadge(
                label: '2,450 pts',
                icon: DsIcons.star,
                variant: DsBadgeVariant.warning,
              ),
              DsBox(
                gradient: tokens.brandGradient,
                borderRadius: tokens.radiusLg,
                shadow: tokens.shadowMedium,
                child: const Text('Link vehicle'),
              ),
              DsActionTile(
                icon: DsIcons.fuel,
                title: 'I want to fuel',
                subtitle: 'Find a station',
                tone: DsIconBadgeTone.danger,
                onTap: openStations,
              ),
            ],
          ),
        ),
      ),
      DsBottomNav(
        items: const [
          DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
          DsNavItem(label: 'Fuel', icon: DsIcons.fuel, route: 'fuel'),
        ],
        selectedRoute: 'home',
        onNavigate: onNavigate,
      ),
    ],
  ),
);
```

## See also

- [Action tiles](action-tile.md)
- [Bottom navigation](bottom-nav.md)
- [Design tokens](design-tokens.md)
