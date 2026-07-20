import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_icon_button.dart';

/// A centred modal dialog: a title, a body and a row of actions.
///
/// [DsDialog] is the general modal container the system was missing. It
/// carries any [body] on a themed surface, capped at [maxWidth] and centred
/// over a dimmed barrier, with the [actions] laid along the bottom edge.
/// Present it with [DsDialog.show], which returns whatever the dialog is
/// popped with; a chosen action closes the dialog first and then runs, so a
/// navigation that rebuilds the tree never races the closing barrier.
///
/// Use it for a decision that must be answered before the page continues (a
/// confirmation, a small form). On a narrow, touch-first width prefer
/// [DsModalSheet], or let [showDsDialogOrSheet] pick between the two by
/// width.
///
/// ```dart
/// final confirmed = await DsDialog.show<bool>(
///   context,
///   title: 'Delete group?',
///   body: const Text('Vehicles in this group return to Unassigned.'),
///   actions: [
///     DsButton(
///       label: 'Cancel',
///       variant: DsButtonVariant.secondary,
///       onPressed: () => Navigator.of(context).pop(false),
///     ),
///     DsButton(
///       label: 'Delete',
///       variant: DsButtonVariant.danger,
///       onPressed: () => Navigator.of(context).pop(true),
///     ),
///   ],
/// );
/// ```
class DsDialog extends StatelessWidget {
  /// Creates the dialog surface. Prefer presenting it with [show].
  const DsDialog({
    super.key,
    this.title,
    required this.body,
    this.actions = const <Widget>[],
    this.maxWidth,
    this.onClose,
  });

  /// The dialog's heading. Null renders no title row.
  final String? title;

  /// The dialog's content.
  final Widget body;

  /// The actions along the bottom edge, in reading order with the primary
  /// action last. They wrap onto further runs when the width is tight.
  final List<Widget> actions;

  /// The widest the dialog grows. Defaults to [DsTokens.dialogMaxWidthSm].
  final double? maxWidth;

  /// Called when the corner close affordance is pressed. Null hides it.
  final VoidCallback? onClose;

  /// Presents the dialog above [context]'s navigator and returns the value it
  /// is popped with. The barrier and its dim come from the theme, and
  /// Escape or a barrier tap dismisses with null.
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget body,
    List<Widget> actions = const <Widget>[],
    double? maxWidth,
    bool barrierDismissible = true,
  }) {
    final DsTokens tokens = DsTokens.of(context);
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: tokens.overlayBackdropColor,
      builder: (BuildContext context) => DsDialog(
        title: title,
        body: body,
        actions: actions,
        maxWidth: maxWidth,
        onClose: barrierDismissible
            ? () => Navigator.of(context).pop()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.all(unit * 2),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? tokens.dialogMaxWidthSm,
          minHeight: tokens.dialogMinHeight,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.formBackgroundColor,
            borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
            boxShadow: tokens.shadowHigh,
          ),
          child: Padding(
            padding: EdgeInsets.all(unit * 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (title != null || onClose != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: title == null
                            ? const SizedBox.shrink()
                            : Semantics(
                                header: true,
                                child: Text(
                                  title!,
                                  style: tokens.headingSm
                                      .toTextStyle(color: tokens.colorText),
                                ),
                              ),
                      ),
                      if (onClose != null)
                        DsIconButton(
                          icon: DsIcons.close,
                          semanticLabel: 'Close',
                          onPressed: onClose,
                        ),
                    ],
                  ),
                if (title != null || onClose != null) SizedBox(height: unit * 2),
                Flexible(child: SingleChildScrollView(child: body)),
                if (actions.isNotEmpty) ...<Widget>[
                  SizedBox(height: unit * 3),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: unit * 1.5,
                    runSpacing: unit,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A modal sheet from the bottom edge: a title, a body and actions.
///
/// [DsModalSheet] is [DsDialog]'s thumb-zone counterpart, and the general
/// container beside [DsMenuSheet]'s menu rows: any [body] on a top-rounded
/// surface with a grab handle, a scrolling middle and an optional pinned
/// action row. Present it with [DsModalSheet.show].
///
/// ```dart
/// await DsModalSheet.show<void>(
///   context,
///   title: 'Filter vehicles',
///   body: const VehicleFilters(),
///   actions: [DsButton(label: 'Apply', onPressed: _apply)],
/// );
/// ```
class DsModalSheet extends StatelessWidget {
  /// Creates the sheet's content. Prefer presenting it with [show].
  const DsModalSheet({
    super.key,
    this.title,
    required this.body,
    this.actions,
  });

  /// The sheet's heading. Null renders no title row.
  final String? title;

  /// The sheet's content, which scrolls when it outgrows the viewport.
  final Widget body;

  /// Optional actions pinned beneath the body.
  final List<Widget>? actions;

  /// Presents the sheet and returns the value it is popped with.
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget body,
    List<Widget>? actions,
    bool isDismissible = true,
  }) {
    final DsTokens tokens = DsTokens.of(context);
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: tokens.formBackgroundColor,
      barrierColor: tokens.overlayBackdropColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.overlayBorderRadius),
        ),
      ),
      // Material 3 caps a modal sheet at 640dp, so a wide window floats it
      // centred rather than spanning edge to edge.
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (BuildContext context) =>
          DsModalSheet(title: title, body: body, actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;
    final List<Widget>? actions = this.actions;

    return SafeArea(
      top: false,
      child: Padding(
        // Lift the sheet clear of the keyboard when the body holds a field.
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // The grab handle signalling drag-to-dismiss; decorative only.
            ExcludeSemantics(
              child: Center(
                child: Container(
                  width: unit * 4,
                  height: unit / 2,
                  margin: EdgeInsets.symmetric(vertical: unit),
                  decoration: BoxDecoration(
                    color: tokens.colorBorderSubtle,
                    borderRadius: BorderRadius.circular(unit / 4),
                  ),
                ),
              ),
            ),
            if (title != null)
              Padding(
                padding: EdgeInsets.fromLTRB(unit * 2.5, 0, unit * 2.5, unit),
                child: Semantics(
                  header: true,
                  child: Text(
                    title!,
                    style: tokens.headingSm.toTextStyle(color: tokens.colorText),
                  ),
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  unit * 2.5,
                  unit / 2,
                  unit * 2.5,
                  unit * 2,
                ),
                child: body,
              ),
            ),
            if (actions != null && actions.isNotEmpty)
              Container(
                padding: EdgeInsets.fromLTRB(
                  unit * 2.5,
                  unit * 1.5,
                  unit * 2.5,
                  unit * 2,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: tokens.colorBorderSubtle),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: unit * 1.5,
                  runSpacing: unit,
                  children: actions,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Presents [body] as a [DsDialog] on a wide window and a [DsModalSheet] on a
/// narrow one, switching at [DsBreakpoints.medium].
///
/// The same decision on a desktop is a centred dialog and on a phone a sheet
/// in the thumb zone. Callers that would otherwise re-write that switch on
/// every screen reach for this instead.
Future<T?> showDsDialogOrSheet<T>(
  BuildContext context, {
  String? title,
  required Widget body,
  List<Widget> actions = const <Widget>[],
  double? maxWidth,
  bool dismissible = true,
}) {
  final bool wide =
      MediaQuery.sizeOf(context).width >= DsBreakpoints.medium;
  if (wide) {
    return DsDialog.show<T>(
      context,
      title: title,
      body: body,
      actions: actions,
      maxWidth: maxWidth,
      barrierDismissible: dismissible,
    );
  }
  return DsModalSheet.show<T>(
    context,
    title: title,
    body: body,
    actions: actions.isEmpty ? null : actions,
    isDismissible: dismissible,
  );
}
