import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Spotlight page.
///
/// A [DsSpotlight] over a faux dashboard: the wash fades the page out, the
/// brand bloom rises from the bottom and the message nudges the next step. The
/// page beneath is inert while the spotlight is up. The first frame is static,
/// with no timers.
class SpotlightDemo extends StatelessWidget {
  const SpotlightDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    // The spotlight fills its bounds like a screen, so frame it at a
    // screen-like height inside the docs page rather than letting it bleed.
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
        child: SizedBox(
          height: 560,
          child: DsSpotlight(
            title: 'Verify your business to go live',
            body: "Your dashboard's ready to explore. Verify your registered "
                'company to switch on the tasks below.',
            actionLabel: 'Verify business',
            onAction: () {},
            child: const _FauxDashboard(),
          ),
        ),
      ),
    );
  }
}

/// A minimal stand-in dashboard, so the wash has real content to fade out.
class _FauxDashboard extends StatelessWidget {
  const _FauxDashboard();

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Padding(
      padding: EdgeInsets.all(tokens.spacingUnit * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: tokens.headingMd.toTextStyle(color: tokens.colorText),
          ),
          SizedBox(height: tokens.spacingUnit * 2),
          for (var i = 0; i < 3; i++) ...[
            _Tile(tokens: tokens),
            SizedBox(height: tokens.spacingUnit * 1.5),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.tokens});

  final DsTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        border: Border.all(color: tokens.colorBorder),
      ),
    );
  }
}
