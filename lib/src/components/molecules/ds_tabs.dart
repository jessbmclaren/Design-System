import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_icon.dart';

/// A single entry in a [DsTabs] bar.
///
/// Provides the [label] shown to the user and an optional leading [icon].
class DsTab {
  const DsTab({required this.label, this.icon});

  /// The text shown for this tab.
  final String label;

  /// An optional leading icon shown before the [label].
  final IconData? icon;
}

/// A controlled, underline-style tab bar.
///
/// Use [DsTabs] to switch between sibling views within the same context, such
/// as sections of a settings page. The bar is fully controlled: it renders
/// [selectedIndex] as active and reports taps through [onChanged]. Keep your
/// own state in sync by updating [selectedIndex] in response to [onChanged].
///
/// The selected tab is tinted with the primary action colour and marked by a
/// 2px underline; unselected tabs use the secondary text colour. A 1px baseline
/// runs beneath the whole bar. When the tabs are wider than the available
/// space the bar scrolls horizontally, so it never overflows, even at 320dp.
class DsTabs extends StatelessWidget {
  const DsTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  /// The tabs to display, in order.
  final List<DsTab> tabs;

  /// The index of the currently selected tab within [tabs].
  final int selectedIndex;

  /// Called with the tapped tab's index when the user selects a tab.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    const indicatorHeight = 2.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: tokens.colorBorder),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var index = 0; index < tabs.length; index++)
              _DsTabItem(
                tab: tabs[index],
                selected: index == selectedIndex,
                indicatorHeight: indicatorHeight,
                selectedColor: tokens.actionPrimaryColorText,
                unselectedColor: tokens.colorSecondaryText,
                onTap: () => onChanged(index),
              ),
          ],
        ),
      ),
    );
  }
}

class _DsTabItem extends StatelessWidget {
  const _DsTabItem({
    required this.tab,
    required this.selected,
    required this.indicatorHeight,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final DsTab tab;
  final bool selected;
  final double indicatorHeight;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final color = selected ? selectedColor : unselectedColor;
    final labelStyle = tokens.labelMd.toTextStyle(color: color).copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        );

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? selectedColor : Colors.transparent,
                width: indicatorHeight,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tab.icon != null) ...[
                DsIcon(icon: tab.icon!, color: color),
                const SizedBox(width: 8),
              ],
              Text(
                tab.label,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
