import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_button.dart';

/// The action cluster that closes a wizard step, an onboarding screen or a
/// similar footer.
///
/// [DsFooterActions] bonds up to four pieces into one responsive unit: a
/// required primary action ([primaryLabel]), an optional back action
/// ([backLabel]), an optional [leading] widget such as a "Step 2 of 4"
/// caption and an optional low-emphasis action beneath the cluster
/// ([tertiaryLabel]), typically "Save and finish later". Every button is a
/// [DsButton], so the cluster inherits its theming, 48dp touch targets,
/// pending spinner and reduced-motion behaviour.
///
/// The component is controlled: it holds no state and simply reports taps
/// through [onPrimary], [onBack] and [onTertiary]. Gate progress by passing a
/// null [onPrimary], which disables the primary button, and set
/// [primaryPending] while the action is in flight to show a spinner and block
/// a double submit.
///
/// ## Responsiveness
///
/// The cluster measures its own width, not the window, so it adapts inside a
/// narrow card as readily as on a full page:
///
/// * At [minRowWidth] and wider the actions sit in a single row with the
///   primary action last, on the trailing edge, and [leading] pinned to the
///   start. When the row's own content cannot fit the available width, for
///   example long translated labels or a large text scale, the cluster falls
///   back to the stacked layout instead of overflowing, whatever
///   [minRowWidth] says.
/// * Below [minRowWidth] the cluster stacks vertically with every button
///   full-width and the primary action first, the standard mobile ordering.
///   The back action follows, then the tertiary action and finally the
///   [leading] caption, both centred, so the action cluster stays together.
///
/// The tertiary action renders centred beneath the cluster in both layouts.
///
/// Under an unbounded width (a horizontal scroll view, say) there is no
/// width to measure against, so the cluster sizes itself to its content: it
/// keeps the row unless [minRowWidth] is [double.infinity], which stacks at
/// the width of the widest piece.
///
/// ```dart
/// DsFooterActions(
///   backLabel: 'Back',
///   onBack: _goBack,
///   primaryLabel: 'Continue',
///   primaryTrailingIcon: DsIcons.arrowForward,
///   onPrimary: _formComplete ? _continue : null,
///   primaryPending: _saving,
///   tertiaryLabel: 'Save and finish later',
///   onTertiary: _saveForLater,
/// )
/// ```
class DsFooterActions extends StatelessWidget {
  /// Creates a footer action cluster.
  ///
  /// [primaryLabel] is required; the back and tertiary actions render only
  /// when their labels are provided.
  const DsFooterActions({
    super.key,
    required this.primaryLabel,
    this.onPrimary,
    this.primaryPending = false,
    this.primaryTrailingIcon,
    this.secondaryLabel,
    this.onSecondary,
    this.secondaryVariant = DsButtonVariant.secondary,
    this.backLabel,
    this.onBack,
    this.backVariant = DsButtonVariant.tertiary,
    this.backIcon,
    this.tertiaryLabel,
    this.onTertiary,
    this.leading,
    this.minRowWidth = 480,
  });

  /// The label of the primary action, such as "Continue".
  final String primaryLabel;

  /// Called when the primary action is tapped.
  ///
  /// A null callback disables the primary button, the way a step gates
  /// progress while its form is incomplete.
  final VoidCallback? onPrimary;

  /// Whether the primary action is in flight.
  ///
  /// While true the primary button shows a spinner over its label and ignores
  /// presses, so the action cannot be triggered twice. Defaults to false.
  final bool primaryPending;

  /// An optional trailing icon on the primary action, such as a forward arrow
  /// on a continue button.
  final IconData? primaryTrailingIcon;

  /// The label of the optional back action. When null no back button renders.
  /// The label of an optional secondary action sitting beside the primary
  /// one, for the second real choice a footer offers ("Save draft" beside
  /// "Submit"). Null shows no secondary action.
  final String? secondaryLabel;

  /// Called when the secondary action is tapped. A null callback disables it.
  final VoidCallback? onSecondary;

  /// The variant of the secondary action. Defaults to
  /// [DsButtonVariant.secondary].
  final DsButtonVariant secondaryVariant;

  final String? backLabel;

  /// Called when the back action is tapped. A null callback disables it.
  final VoidCallback? onBack;

  /// The emphasis of the back action. Defaults to [DsButtonVariant.tertiary],
  /// a quiet text button.
  final DsButtonVariant backVariant;

  /// An optional leading glyph on the back action, typically
  /// [DsIcons.arrowBack].
  final IconData? backIcon;

  /// The label of the optional low-emphasis action rendered centred beneath
  /// the cluster, typically "Save and finish later". When null it is omitted.
  final String? tertiaryLabel;

  /// Called when the tertiary action is tapped. A null callback disables it.
  final VoidCallback? onTertiary;

  /// Optional content pinned to the start edge of the row layout, such as a
  /// "Step 2 of 4" caption. When the cluster stacks it sits centred beneath
  /// the buttons and the tertiary action instead.
  final Widget? leading;

  /// The width below which the cluster stacks vertically.
  ///
  /// The threshold tracks the cluster's own width, not the window. Pass `0`
  /// to prefer the row at every width or [double.infinity] to always stack,
  /// for a parent that has already made the layout decision. Whatever the
  /// threshold, a row whose content cannot fit the available width falls
  /// back to the stacked layout rather than overflowing.
  final double minRowWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final leading = this.leading;
    final Widget? back = backLabel == null
        ? null
        : DsButton(
            label: backLabel!,
            onPressed: onBack,
            variant: backVariant,
            icon: backIcon,
          );
    final Widget? secondary = secondaryLabel == null
        ? null
        : DsButton(
            label: secondaryLabel!,
            onPressed: onSecondary,
            variant: secondaryVariant,
          );
    final Widget? tertiary = tertiaryLabel == null
        ? null
        : DsButton(
            label: tertiaryLabel!,
            onPressed: onTertiary,
            variant: DsButtonVariant.tertiary,
          );

    // One set of children serves both layouts; the render object measures
    // their intrinsic widths, picks row or stacked and stretches the buttons
    // itself when stacking, so no piece is ever built twice.
    return _FooterCluster(
      minRowWidth: minRowWidth,
      hasLeading: leading != null,
      hasBack: back != null,
      hasSecondary: secondary != null,
      hasTertiary: tertiary != null,
      gap: tokens.spacingUnit * 1.5,
      stackGap: tokens.spacingUnit,
      textDirection: Directionality.of(context),
      children: <Widget>[
        ?leading,
        ?back,
        ?secondary,
        DsButton(
          label: primaryLabel,
          onPressed: onPrimary,
          pending: primaryPending,
          trailingIcon: primaryTrailingIcon,
        ),
        ?tertiary,
      ],
    );
  }
}

/// The layout host for [DsFooterActions]: a row that measures its own
/// content and falls back to the stacked arrangement when the row cannot
/// fit.
class _FooterCluster extends MultiChildRenderObjectWidget {
  const _FooterCluster({
    required this.minRowWidth,
    required this.hasLeading,
    required this.hasBack,
    required this.hasSecondary,
    required this.hasTertiary,
    required this.gap,
    required this.stackGap,
    required this.textDirection,
    required super.children,
  });

  final double minRowWidth;
  final bool hasLeading;
  final bool hasBack;
  final bool hasSecondary;
  final bool hasTertiary;

  /// The gap between the back and primary actions in the row layout, and
  /// above the tertiary action and the caption.
  final double gap;

  /// The tighter gap between the stacked primary and back buttons.
  final double stackGap;

  final TextDirection textDirection;

  @override
  _RenderFooterCluster createRenderObject(BuildContext context) {
    return _RenderFooterCluster(
      minRowWidth: minRowWidth,
      hasLeading: hasLeading,
      hasBack: hasBack,
      hasSecondary: hasSecondary,
      hasTertiary: hasTertiary,
      gap: gap,
      stackGap: stackGap,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderFooterCluster renderObject,
  ) {
    renderObject
      ..minRowWidth = minRowWidth
      ..hasLeading = hasLeading
      ..hasBack = hasBack
      ..hasSecondary = hasSecondary
      ..hasTertiary = hasTertiary
      ..gap = gap
      ..stackGap = stackGap
      ..textDirection = textDirection;
  }
}

class _FooterClusterParentData extends ContainerBoxParentData<RenderBox> {}

/// The named children of the cluster, resolved from the child list.
class _FooterSlots {
  _FooterSlots({
    required this.leading,
    required this.back,
    required this.secondary,
    required this.primary,
    required this.tertiary,
  });

  final RenderBox? leading;
  final RenderBox? back;
  final RenderBox? secondary;
  final RenderBox primary;
  final RenderBox? tertiary;
}

class _RenderFooterCluster extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FooterClusterParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FooterClusterParentData> {
  _RenderFooterCluster({
    required double minRowWidth,
    required bool hasLeading,
    required bool hasBack,
    required bool hasSecondary,
    required bool hasTertiary,
    required double gap,
    required double stackGap,
    required TextDirection textDirection,
  })  : _minRowWidth = minRowWidth,
        _hasLeading = hasLeading,
        _hasBack = hasBack,
        _hasSecondary = hasSecondary,
        _hasTertiary = hasTertiary,
        _gap = gap,
        _stackGap = stackGap,
        _textDirection = textDirection;

  /// The gap between the back and primary actions in the row layout, and
  /// above the tertiary action and the caption.
  double _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  /// The tighter gap between the stacked primary and back buttons.
  double _stackGap;
  set stackGap(double value) {
    if (_stackGap == value) return;
    _stackGap = value;
    markNeedsLayout();
  }

  double _minRowWidth;
  set minRowWidth(double value) {
    if (_minRowWidth == value) return;
    _minRowWidth = value;
    markNeedsLayout();
  }

  bool _hasLeading;
  set hasLeading(bool value) {
    if (_hasLeading == value) return;
    _hasLeading = value;
    markNeedsLayout();
  }

  bool _hasBack;
  set hasBack(bool value) {
    if (_hasBack == value) return;
    _hasBack = value;
    markNeedsLayout();
  }

  bool _hasSecondary;
  set hasSecondary(bool value) {
    if (_hasSecondary == value) return;
    _hasSecondary = value;
    markNeedsLayout();
  }

  bool _hasTertiary;
  set hasTertiary(bool value) {
    if (_hasTertiary == value) return;
    _hasTertiary = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FooterClusterParentData) {
      child.parentData = _FooterClusterParentData();
    }
  }

  _FooterSlots _resolveSlots() {
    RenderBox? child = firstChild;
    RenderBox? leading;
    RenderBox? back;
    RenderBox? tertiary;
    if (_hasLeading) {
      leading = child;
      child = childAfter(child!);
    }
    if (_hasBack) {
      back = child;
      child = childAfter(child!);
    }
    RenderBox? secondary;
    if (_hasSecondary) {
      secondary = child;
      child = childAfter(child!);
    }
    final primary = child!;
    if (_hasTertiary) {
      tertiary = childAfter(primary);
    }
    return _FooterSlots(
      leading: leading,
      back: back,
      secondary: secondary,
      primary: primary,
      tertiary: tertiary,
    );
  }

  /// The width the row layout needs to hold its content without overflow:
  /// the buttons at their intrinsic widths plus the caption's minimum.
  double _rowNeed(_FooterSlots slots) {
    var need = slots.primary.getMaxIntrinsicWidth(double.infinity);
    final secondary = slots.secondary;
    if (secondary != null) {
      need += _gap + secondary.getMaxIntrinsicWidth(double.infinity);
    }
    final back = slots.back;
    if (back != null) {
      need += _gap + back.getMaxIntrinsicWidth(double.infinity);
    }
    final leading = slots.leading;
    if (leading != null) {
      need += _gap + leading.getMinIntrinsicWidth(double.infinity);
    }
    final tertiary = slots.tertiary;
    if (tertiary != null) {
      need = math.max(need, tertiary.getMaxIntrinsicWidth(double.infinity));
    }
    return need;
  }

  /// Whether the cluster stacks for the given incoming width. Below
  /// [_minRowWidth] it stacks by request; above it, it still stacks when the
  /// row's own content cannot fit. An unbounded width has nothing to measure
  /// against, so only an explicitly infinite threshold stacks there.
  bool _shouldStack(_FooterSlots slots, double maxWidth) {
    if (!maxWidth.isFinite) return _minRowWidth == double.infinity;
    return maxWidth < _minRowWidth || _rowNeed(slots) > maxWidth;
  }

  Size _computeLayout(BoxConstraints constraints, {required bool dry}) {
    final slots = _resolveSlots();
    Size layoutChild(RenderBox child, BoxConstraints childConstraints) {
      if (dry) return child.getDryLayout(childConstraints);
      child.layout(childConstraints, parentUsesSize: true);
      return child.size;
    }

    void place(RenderBox child, double x, double y, double contentWidth) {
      if (dry) return;
      final parentData = child.parentData! as _FooterClusterParentData;
      final dx = _textDirection == TextDirection.ltr
          ? x
          : contentWidth - x - child.size.width;
      parentData.offset = Offset(dx, y);
    }

    final maxWidth = constraints.maxWidth;
    final bounded = maxWidth.isFinite;

    if (_shouldStack(slots, maxWidth)) {
      // Stacked: full-width primary first, back beneath, then the centred
      // tertiary action and the centred caption.
      final width = bounded
          ? maxWidth
          : [
              for (final child in [
                slots.leading,
                slots.back,
                slots.secondary,
                slots.primary,
                slots.tertiary,
              ])
                if (child != null) child.getMaxIntrinsicWidth(double.infinity),
            ].reduce(math.max);
      final stretch = BoxConstraints(minWidth: width, maxWidth: width);
      final centred = BoxConstraints(maxWidth: width);

      final primarySize = layoutChild(slots.primary, stretch);
      place(slots.primary, 0, 0, width);
      var height = primarySize.height;

      final secondary = slots.secondary;
      if (secondary != null) {
        final secondarySize = layoutChild(secondary, stretch);
        place(secondary, 0, height + _stackGap, width);
        height += _stackGap + secondarySize.height;
      }

      final back = slots.back;
      if (back != null) {
        final backSize = layoutChild(back, stretch);
        place(back, 0, height + _stackGap, width);
        height += _stackGap + backSize.height;
      }
      final tertiary = slots.tertiary;
      if (tertiary != null) {
        final tertiarySize = layoutChild(tertiary, centred);
        place(tertiary, (width - tertiarySize.width) / 2, height + _gap, width);
        height += _gap + tertiarySize.height;
      }
      final leading = slots.leading;
      if (leading != null) {
        final leadingSize = layoutChild(leading, centred);
        place(leading, (width - leadingSize.width) / 2, height + _gap, width);
        height += _gap + leadingSize.height;
      }
      return constraints.constrain(Size(width, height));
    }

    // Row: the actions sit on the trailing edge and the caption takes
    // whatever width remains at the start.
    final loose = BoxConstraints(maxWidth: bounded ? maxWidth : double.infinity);
    final primarySize = layoutChild(slots.primary, loose);
    final secondary = slots.secondary;
    final secondarySize =
        secondary == null ? Size.zero : layoutChild(secondary, loose);
    final back = slots.back;
    final backSize = back == null ? Size.zero : layoutChild(back, loose);
    var actionsWidth = primarySize.width;
    if (secondary != null) actionsWidth += _gap + secondarySize.width;
    if (back != null) actionsWidth += _gap + backSize.width;

    final leading = slots.leading;
    Size leadingSize = Size.zero;
    if (leading != null) {
      final available = bounded
          ? math.max(0.0, maxWidth - actionsWidth - _gap)
          : double.infinity;
      leadingSize = layoutChild(leading, BoxConstraints(maxWidth: available));
    }

    final width = bounded
        ? maxWidth
        : actionsWidth + (leading == null ? 0 : _gap + leadingSize.width);
    final rowHeight = math.max(
      math.max(primarySize.height, secondarySize.height),
      math.max(backSize.height, leadingSize.height),
    );

    place(
      slots.primary,
      width - primarySize.width,
      (rowHeight - primarySize.height) / 2,
      width,
    );
    // The trailing cluster reads primary, then secondary, then back as it
    // walks inward from the trailing edge.
    var trailingEdge = width - primarySize.width;
    if (secondary != null) {
      trailingEdge -= _gap + secondarySize.width;
      place(
        secondary,
        trailingEdge,
        (rowHeight - secondarySize.height) / 2,
        width,
      );
    }
    if (back != null) {
      place(
        back,
        trailingEdge - _gap - backSize.width,
        (rowHeight - backSize.height) / 2,
        width,
      );
    }
    if (leading != null) {
      place(leading, 0, (rowHeight - leadingSize.height) / 2, width);
    }

    var height = rowHeight;
    final tertiary = slots.tertiary;
    if (tertiary != null) {
      final tertiarySize =
          layoutChild(tertiary, BoxConstraints(maxWidth: width));
      place(
        tertiary,
        (width - tertiarySize.width) / 2,
        rowHeight + _gap,
        width,
      );
      height += _gap + tertiarySize.height;
    }
    return constraints.constrain(Size(width, height));
  }

  @override
  void performLayout() {
    size = _computeLayout(constraints, dry: false);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeLayout(constraints, dry: true);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    // The stacked fallback means the cluster never needs more than its
    // widest single piece.
    var width = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      width = math.max(width, child.getMinIntrinsicWidth(height));
    }
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (_minRowWidth == double.infinity) {
      var width = 0.0;
      for (var child = firstChild; child != null; child = childAfter(child)) {
        width = math.max(width, child.getMaxIntrinsicWidth(height));
      }
      return width;
    }
    return _rowNeed(_resolveSlots());
  }

  double _intrinsicHeight(
    double width,
    double Function(RenderBox child, double width) heightOf,
  ) {
    final slots = _resolveSlots();
    if (_shouldStack(slots, width)) {
      var height = heightOf(slots.primary, width);
      if (slots.back != null) {
        height += _stackGap + heightOf(slots.back!, width);
      }
      if (slots.tertiary != null) {
        height += _gap + heightOf(slots.tertiary!, width);
      }
      if (slots.leading != null) {
        height += _gap + heightOf(slots.leading!, width);
      }
      return height;
    }
    var height = heightOf(slots.primary, width);
    if (slots.back != null) {
      height = math.max(height, heightOf(slots.back!, width));
    }
    if (slots.leading != null) {
      height = math.max(height, heightOf(slots.leading!, width));
    }
    if (slots.tertiary != null) {
      height += _gap + heightOf(slots.tertiary!, width);
    }
    return height;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(
        width,
        (child, width) => child.getMinIntrinsicHeight(width),
      );

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(
        width,
        (child, width) => child.getMaxIntrinsicHeight(width),
      );

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
