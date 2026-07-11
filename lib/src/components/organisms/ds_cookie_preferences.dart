import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_badge.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_icon_button.dart';
import '../atoms/ds_switch.dart';
import '../molecules/ds_footer_actions.dart';

/// One cookie category listed in a [DsCookiePreferences].
class DsCookieCategory {
  /// Describes a cookie category.
  const DsCookieCategory({
    required this.id,
    required this.title,
    required this.description,
    this.enabled = false,
    this.locked = false,
  });

  /// The stable identifier reported through `onChanged`.
  final String id;

  /// The category name, such as "Analytics".
  final String title;

  /// A sentence on what the category is used for.
  final String description;

  /// Whether the category is currently allowed. Ignored visually for a
  /// [locked] category, which always reads as on.
  final bool enabled;

  /// Whether the category is always on, the way essential cookies are. A
  /// locked row renders a badge instead of a switch and never reports a
  /// change.
  final bool locked;
}

/// The signature of a [DsCookiePreferences] change report: the category's
/// [DsCookieCategory.id] and the value the user requested.
typedef DsCookieCategoryChanged = void Function(
  String categoryId,
  bool enabled,
);

/// The cookie preferences surface: a card of per-category consent switches.
///
/// [DsCookiePreferences] lists each [DsCookieCategory] as a row with its
/// title, its description and a trailing [DsSwitch]. A locked category, the
/// essential row, renders an always-on [DsBadge] instead of a switch, so it
/// reads as fact rather than choice. Beneath the rows sit a primary save
/// action and a secondary accept-all action.
///
/// The component is controlled: the caller owns the category state and
/// receives every toggle through [onChanged] with the category's id and the
/// requested value. A null [onChanged] disables every switch.
///
/// The card sizes itself to [maxWidth] and shrinks to narrower viewports. It
/// is built to be hosted inside a `DsTakeover` over the page that opened it,
/// which blurs the page, blocks its input and keeps keyboard focus inside
/// the card:
///
/// ```dart
/// DsTakeover(
///   background: page,
///   child: DsCookiePreferences(
///     categories: _categories,
///     onChanged: (id, enabled) => setState(() => _set(id, enabled)),
///     onSave: _save,
///     onAcceptAll: _acceptAll,
///     onClose: _close,
///   ),
/// )
/// ```
class DsCookiePreferences extends StatelessWidget {
  /// Creates the cookie preferences card.
  const DsCookiePreferences({
    super.key,
    required this.categories,
    required this.onChanged,
    this.onSave,
    this.onAcceptAll,
    this.onClose,
    this.title = 'Cookie preferences',
    this.description,
    this.saveLabel = 'Save preferences',
    this.acceptAllLabel = 'Accept all',
    this.lockedLabel = 'Always on',
    this.closeLabel = 'Close',
    this.maxWidth = 480,
  });

  /// The categories to list, in display order.
  final List<DsCookieCategory> categories;

  /// Called with the category id and the requested value when a switch is
  /// toggled. A null callback disables every switch.
  final DsCookieCategoryChanged? onChanged;

  /// Called when the primary save action is pressed. A null callback
  /// disables it.
  final VoidCallback? onSave;

  /// Called when the accept-all action is pressed, the shortcut that turns
  /// every optional category on. A null callback disables it.
  final VoidCallback? onAcceptAll;

  /// Called when the corner close button is pressed. Null hides the button;
  /// a card whose only ways out are its actions can omit it.
  final VoidCallback? onClose;

  /// The card heading.
  final String title;

  /// Optional supporting copy beneath the heading, such as where the choice
  /// can be changed later.
  final String? description;

  /// The label of the primary save action.
  final String saveLabel;

  /// The label of the secondary accept-all action.
  final String acceptAllLabel;

  /// The badge text on a locked category row.
  final String lockedLabel;

  /// The name assistive technology announces for the close button.
  final String closeLabel;

  /// The widest the card grows. It shrinks to fit narrower viewports.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final unit = tokens.spacingUnit;
    final onChanged = this.onChanged;

    Widget categoryRow(DsCookieCategory category) {
      final Widget trailing = category.locked
          ? DsBadge(label: lockedLabel)
          : DsSwitch(
              value: category.enabled,
              onChanged: onChanged == null
                  ? null
                  : (value) => onChanged(category.id, value),
              semanticLabel: category.title,
            );
      return Padding(
        padding: EdgeInsets.symmetric(vertical: unit * 1.5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: tokens.labelMd.toTextStyle(color: tokens.colorText),
                  ),
                  SizedBox(height: unit * 0.5),
                  Text(
                    category.description,
                    style: tokens.bodySm.toTextStyle(
                      color: tokens.colorSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: unit * 2),
            trailing,
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.formBackgroundColor,
          border: Border.all(color: tokens.colorBorder),
          borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
          boxShadow: tokens.shadowHigh,
        ),
        child: Padding(
          padding: EdgeInsets.all(unit * 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: tokens.headingSm.toTextStyle(
                        color: tokens.colorText,
                      ),
                    ),
                  ),
                  if (onClose != null)
                    DsIconButton(
                      icon: DsIcons.close,
                      onPressed: onClose,
                      semanticLabel: closeLabel,
                    ),
                ],
              ),
              if (description != null) ...[
                SizedBox(height: unit),
                Text(
                  description!,
                  style: tokens.bodySm.toTextStyle(
                    color: tokens.colorSecondaryText,
                  ),
                ),
              ],
              SizedBox(height: unit * 2),
              for (final (index, category) in categories.indexed) ...[
                if (index > 0)
                  Divider(height: 1, color: tokens.colorBorderSubtle),
                categoryRow(category),
              ],
              SizedBox(height: unit * 3),
              DsFooterActions(
                primaryLabel: saveLabel,
                onPrimary: onSave,
                backLabel: acceptAllLabel,
                onBack: onAcceptAll,
                backVariant: DsButtonVariant.secondary,
                // The card body is narrower than the default threshold, so
                // let the pair share a row until the card itself squeezes.
                minRowWidth: 340,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
