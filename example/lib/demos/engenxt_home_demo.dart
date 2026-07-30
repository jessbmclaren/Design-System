import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the EngenXT home page: a phone screen assembled entirely from
/// the library, under `DsSkins.engenMobileLight()`.
///
/// This is the atomic model's top level, where the system meets real content.
/// Nothing here draws a colour, radius, size or shadow of its own: the header
/// mark, the greeting, the status pills, the promoted panel, the shortcuts and
/// the bar all read their appearance from `DsTokens.of(context)`, so switching
/// the skin re-brands the whole screen.
class EngenxtHomeDemo extends StatefulWidget {
  const EngenxtHomeDemo({super.key, this.tokens});

  /// The skin the screen is set in. Defaults to `DsSkins.engenMobileLight()`.
  ///
  /// The screen carries its own phone theme rather than the docs app's, so this
  /// is the seam a specimen uses to stand a loadable font in for the device
  /// face, which the skin deliberately leaves to the platform.
  final DsTokens? tokens;

  @override
  State<EngenxtHomeDemo> createState() => _EngenxtHomeDemoState();
}

class _EngenxtHomeDemoState extends State<EngenxtHomeDemo> {
  /// The phone the design was drawn at. The frame never exceeds this, and
  /// shrinks to whatever slot it is given.
  static const double _frameWidth = 390;
  static const double _frameHeight = 760;

  String _route = 'home';

  static const List<DsNavItem> _destinations = <DsNavItem>[
    DsNavItem(label: 'Home', icon: DsIcons.home, route: 'home'),
    DsNavItem(label: 'Fuel', icon: DsIcons.fuel, route: 'fuel'),
    DsNavItem(label: 'History', icon: DsIcons.time, route: 'history'),
    DsNavItem(label: 'Account', icon: DsIcons.user, route: 'account'),
  ];

  @override
  Widget build(BuildContext context) {
    // The screen is a phone theme, so it carries the mobile skin rather than
    // the docs app's own.
    return Theme(
      data: DsTheme.light(tokens: widget.tokens ?? DsSkins.engenMobileLight()),
      child: Builder(builder: _screen),
    );
  }

  Widget _screen(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;

    // A 390dp phone, the width the design was drawn at, but never wider than
    // the slot it is given: the docs sweep this page from 320dp up, and a fixed
    // frame would overflow the narrow end.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.hasBoundedWidth
            ? math.min(_frameWidth, constraints.maxWidth)
            : _frameWidth;
        final double height = constraints.hasBoundedHeight
            ? math.min(_frameHeight, constraints.maxHeight)
            : _frameHeight;
        return _frame(context, tokens, unit, width, height);
      },
    );
  }

  Widget _frame(
    BuildContext context,
    DsTokens tokens,
    double unit,
    double width,
    double height,
  ) {
    return DsBox(
      width: width,
      height: height,
      background: tokens.colorBackground,
      borderRadius: tokens.radiusLg,
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(unit * 2.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _header(context, tokens, unit),
                  SizedBox(height: unit * 3),
                  _greeting(context, tokens, unit),
                  SizedBox(height: unit * 2),
                  _status(unit),
                  SizedBox(height: unit * 3),
                  _promoted(context, tokens, unit),
                  SizedBox(height: unit * 3),
                  Text(
                    tokens.labelEyebrow.textTransform.apply('Quick access'),
                    style: tokens.labelEyebrow
                        .toTextStyle(color: tokens.colorTextMuted),
                  ),
                  SizedBox(height: unit * 1.5),
                  _shortcuts(unit),
                ],
              ),
            ),
          ),
          DsBottomNav(
            items: _destinations,
            selectedRoute: _route,
            onNavigate: (String route) => setState(() => _route = route),
          ),
        ],
      ),
    );
  }

  /// The brand mark, the name and the two account controls.
  Widget _header(BuildContext context, DsTokens tokens, double unit) {
    return Row(
      children: <Widget>[
        // The mark takes the brand's second colour as its ground, with the
        // on-brand ink for the glyph.
        DsIconBadge(
          icon: DsIcons.fuel,
          shape: DsIconBadgeShape.rounded,
          size: unit * 5,
          backgroundColor: tokens.colorBrandSecondary,
          foregroundColor: tokens.colorOnPrimary,
        ),
        SizedBox(width: unit * 1.5),
        // No arguments: the skin's own name and its coloured suffix. On a very
        // narrow phone the mark scales down rather than pushing the account
        // controls off the row, because a wordmark must not ellipsize.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: const DsWordmark(),
          ),
        ),
        const Spacer(),
        // The bell sits on the muted tier so it reads as a control rather than
        // a bare glyph on the page.
        DsBox(
          background: tokens.colorSurfaceMuted,
          borderRadius: tokens.radiusFull,
          child: DsIconButton(
            icon: DsIcons.notifications,
            semanticLabel: 'Notifications',
            showIndicator: true,
            indicatorSemanticLabel: '1 unread',
            onPressed: () {},
          ),
        ),
        SizedBox(width: unit),
        DsAvatar(
          name: 'David',
          backgroundColor: tokens.colorPrimary,
          foregroundColor: tokens.colorOnPrimary,
        ),
      ],
    );
  }

  /// The eyebrow and the name, the screen's headline.
  Widget _greeting(BuildContext context, DsTokens tokens, double unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          tokens.labelEyebrow.textTransform.apply('Good morning'),
          style: tokens.labelEyebrow.toTextStyle(color: tokens.colorTextMuted),
        ),
        SizedBox(height: unit / 2),
        Text(
          'David',
          style: tokens.display.toTextStyle(color: tokens.colorText),
        ),
      ],
    );
  }

  /// The two standing facts about the account, as status pills.
  Widget _status(double unit) {
    return Wrap(
      spacing: unit,
      runSpacing: unit,
      children: const <Widget>[
        DsBadge(
          label: '2,450 pts',
          icon: DsIcons.star,
          variant: DsBadgeVariant.warning,
        ),
        DsBadge(
          label: '60L approved',
          icon: DsIcons.success,
          variant: DsBadgeVariant.success,
        ),
      ],
    );
  }

  /// The promoted next step, on the brand's gradient surface.
  ///
  /// The panel re-tints its own subtree rather than passing colours down: the
  /// ink tokens are swapped for their on-brand counterparts, so every atom
  /// inside keeps reading `DsTokens.of(context)` and none of them needs to know
  /// it is sitting on a brand fill.
  Widget _promoted(BuildContext context, DsTokens tokens, double unit) {
    final DsTokens onBrand = tokens.copyWith(
      colorText: tokens.colorOnPrimary,
      colorSecondaryText: tokens.colorOnPrimary.withValues(alpha: 0.82),
      colorIconMuted: tokens.colorOnPrimary,
    );

    return Theme(
      data: Theme.of(context)
          .copyWith(extensions: <ThemeExtension<dynamic>>[onBrand]),
      child: Builder(
        builder: (BuildContext context) {
          final DsTokens t = DsTokens.of(context);
          return Semantics(
            button: true,
            label: 'Link vehicle, scan your licence disc',
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(tokens.radiusLg),
                child: ExcludeSemantics(
                  child: DsBox(
                    gradient: tokens.brandGradient,
                    borderRadius: tokens.radiusLg,
                    shadow: tokens.shadowMedium,
                    padding: EdgeInsets.all(unit * 2),
                    child: Row(
                      children: <Widget>[
                        DsIconBadge(
                          icon: DsIcons.dashboard,
                          shape: DsIconBadgeShape.rounded,
                          size: unit * 6,
                          backgroundColor:
                              t.colorOnPrimary.withValues(alpha: 0.18),
                          foregroundColor: t.colorOnPrimary,
                        ),
                        SizedBox(width: unit * 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Link vehicle',
                                style: t.headingSm
                                    .toTextStyle(color: t.colorText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: unit / 4),
                              Text(
                                'Scan your licence disc',
                                style: t.bodySm
                                    .toTextStyle(color: t.colorSecondaryText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: unit),
                        DsIconBadge(
                          icon: DsIcons.chevronRight,
                          size: unit * 4,
                          backgroundColor:
                              t.colorOnPrimary.withValues(alpha: 0.18),
                          foregroundColor: t.colorOnPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// The two common jobs, as shortcut tiles.
  Widget _shortcuts(double unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: DsActionTile(
            icon: DsIcons.fuel,
            title: 'I want to fuel',
            subtitle: 'Find a station',
            tone: DsIconBadgeTone.danger,
            onTap: () {},
          ),
        ),
        SizedBox(width: unit * 1.5),
        Expanded(
          child: DsActionTile(
            icon: DsIcons.star,
            title: 'Rewards',
            subtitle: 'Points & streaks',
            tone: DsIconBadgeTone.warning,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
