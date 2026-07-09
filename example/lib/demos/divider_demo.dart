import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Divider page.
///
/// Shows a horizontal `DsDivider` separating stacked settings rows and a
/// bounded-height vertical `DsDivider` splitting a row of summary statistics.
class DividerDemo extends StatelessWidget {
  const DividerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    final TextStyle labelStyle = TextStyle(
      fontFamily: tokens.fontFamily,
      fontSize: tokens.fontSizeBase,
      color: tokens.colorText,
    );
    final TextStyle mutedStyle = TextStyle(
      fontFamily: tokens.fontFamily,
      fontSize: tokens.fontSizeBase - 2,
      color: tokens.colorSecondaryText,
    );
    final TextStyle statStyle = TextStyle(
      fontFamily: tokens.fontFamily,
      fontSize: tokens.fontSizeBase + 8,
      fontWeight: FontWeight.w600,
      color: tokens.colorText,
    );

    Widget row(String title, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(title, style: labelStyle)),
            const SizedBox(width: 12),
            Text(value, style: mutedStyle),
          ],
        ),
      );
    }

    Widget stat(String value, String caption) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: statStyle),
          const SizedBox(height: 2),
          Text(caption, style: mutedStyle),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal dividers separating stacked rows.
        row('Two-factor authentication', 'On'),
        const DsDivider(),
        row('Session timeout', '30 min'),
        const DsDivider(),
        row('Login notifications', 'Email'),
        const SizedBox(height: 28),

        // Vertical dividers splitting side-by-side stats. The Row is wrapped in
        // IntrinsicHeight so the vertical rule has a bounded height to fill.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: stat('1,284', 'Active users')),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DsDivider(axis: DsDividerAxis.vertical),
              ),
              Expanded(child: stat('98.6%', 'Uptime')),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DsDivider(axis: DsDividerAxis.vertical),
              ),
              Expanded(child: stat('42', 'Open tickets')),
            ],
          ),
        ),
      ],
    );
  }
}
