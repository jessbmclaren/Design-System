import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import 'ds_icon.dart';

/// A quiet text link for a site or marketing bar.
///
/// [DsNavLink] is the top-level navigation label: plain body text in the
/// page's ink, underlined on hover and focus, with an optional chevron when
/// it opens a menu rather than navigating. It sits between a link, which is
/// styled to stand out in prose, and a button, which announces itself as an
/// action.
///
/// The target is padded to the accessible minimum while the text keeps its
/// compact look, and keyboard focus draws the accent ring rather than
/// relying on the underline alone.
///
/// ```dart
/// DsNavLink(label: 'Pricing', onTap: () => go('/pricing'))
/// DsNavLink(label: 'Product', dropdown: true, onTap: openProductMenu)
/// ```
class DsNavLink extends StatefulWidget {
  /// Creates a navigation link.
  const DsNavLink({
    super.key,
    required this.label,
    this.dropdown = false,
    this.onTap,
  });

  /// The destination's name.
  final String label;

  /// Whether the link opens a menu, which adds a trailing chevron and
  /// announces the link as a button rather than a plain link.
  final bool dropdown;

  /// Called when the link is chosen. Null renders it inert.
  final VoidCallback? onTap;

  @override
  State<DsNavLink> createState() => _DsNavLinkState();
}

class _DsNavLinkState extends State<DsNavLink> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;
    final bool enabled = widget.onTap != null;
    final bool underlined = (_hovered || _focused) && enabled;

    return Semantics(
      button: widget.dropdown,
      link: !widget.dropdown,
      enabled: enabled,
      label: widget.label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(tokens.radiusControl),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onHover: (bool value) => setState(() => _hovered = value),
          onFocusChange: (bool value) => setState(() => _focused = value),
          child: ExcludeSemantics(
            child: Container(
              // The visible label stays compact; the padding carries the
              // target out to the accessible minimum.
              constraints: BoxConstraints(minHeight: tokens.minTapTarget),
              padding: EdgeInsets.symmetric(horizontal: unit * 1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tokens.radiusControl),
                border: Border.all(
                  color: _focused
                      ? tokens.actionPrimaryColorText
                      : const Color(0x00000000),
                  width: tokens.focusRingWidth,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      widget.label,
                      style: tokens.bodyMd.toTextStyle(
                        color: enabled
                            ? tokens.colorText
                            : tokens.colorTextDisabled,
                      ).copyWith(
                        decoration:
                            underlined ? TextDecoration.underline : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.dropdown) ...<Widget>[
                    SizedBox(width: unit / 2),
                    DsIcon(
                      icon: DsIcons.expandMore,
                      size: DsIconSize.sm,
                      color: enabled
                          ? tokens.colorSecondaryText
                          : tokens.colorTextDisabled,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
