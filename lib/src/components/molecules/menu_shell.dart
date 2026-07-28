import 'package:flutter/material.dart';

/// Internal: the anchored-popover shell behind `DsMenu` and `DsCheckMenu`.
///
/// Deliberately un-prefixed and absent from the barrel — it is not a component
/// in its own right, it is the plumbing two of them share: a [MenuAnchor]
/// stripped of its own Material panel, and a trigger that behaves like a
/// button for pointer, keyboard and assistive technology alike.
///
/// The two menus differ only in what they put *inside* the popover (a list of
/// commands, a checklist), so that is all they supply. Keeping the shell in one
/// place is what stops them drifting apart on the things a user notices first:
/// how the trigger announces itself, whether Tab reaches it, whether Escape
/// closes the panel.
class MenuShell extends StatelessWidget {
  /// Creates a popover shell.
  const MenuShell({
    super.key,
    required this.trigger,
    required this.panel,
  });

  /// The widget the user taps to open the popover.
  final Widget trigger;

  /// The surface shown while open. It draws its own fill, border and shadow.
  final Widget panel;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      // The panel draws its own fill, border and shadow, so the anchor's
      // built-in Material surface is made transparent and un-clipped to avoid
      // double-painting or clipping the drop shadow.
      clipBehavior: Clip.none,
      style: const MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Color(0x00000000)),
        surfaceTintColor: WidgetStatePropertyAll<Color>(Color(0x00000000)),
        shadowColor: WidgetStatePropertyAll<Color>(Color(0x00000000)),
        elevation: WidgetStatePropertyAll<double>(0),
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.zero),
      ),
      menuChildren: <Widget>[panel],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        void toggle() {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        }

        // MergeSemantics folds the trigger's own content into the button node,
        // so assistive technology announces "Columns, button, collapsed" as one
        // control rather than reading the label and the state as two nodes.
        return MergeSemantics(
          child: Semantics(
            button: true,
            expanded: controller.isOpen,
            onTap: toggle,
            // FocusableActionDetector makes the trigger reachable by Tab and
            // activatable by Enter/Space (via the ambient ActivateIntent), so
            // the menu is fully keyboard-operable, not pointer-only.
            child: FocusableActionDetector(
              actions: <Type, Action<Intent>>{
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    toggle();
                    return null;
                  },
                ),
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: toggle,
                child: child,
              ),
            ),
          ),
        );
      },
      child: trigger,
    );
  }
}
