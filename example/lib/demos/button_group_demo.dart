import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Button group page: a record toolbar of `DsButton`s laid
/// out with `DsButtonGroup`. The actions are given in priority order (a
/// primary "Save" first, supporting "Duplicate" and "Archive" next, and a
/// destructive "Delete" last), so the group keeps the leading ones inline and
/// collapses the rest into the trailing "More" menu when the width is tight.
///
/// Tapping an action records it in a short status line via `setState`, so the
/// demo starts in a meaningful state and reacts without any timers or
/// animation. The overflow menu stays closed on the first frame.
class ButtonGroupDemo extends StatefulWidget {
  const ButtonGroupDemo({super.key});

  @override
  State<ButtonGroupDemo> createState() => _ButtonGroupDemoState();
}

class _ButtonGroupDemoState extends State<ButtonGroupDemo> {
  String _last = 'No action taken yet';

  void _record(String action) => setState(() => _last = '$action selected');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsButtonGroup(
          children: [
            DsButton(
              label: 'Save',
              onPressed: () => _record('Save'),
            ),
            DsButton(
              label: 'Duplicate',
              variant: DsButtonVariant.secondary,
              icon: Icons.copy_outlined,
              onPressed: () => _record('Duplicate'),
            ),
            DsButton(
              label: 'Archive',
              variant: DsButtonVariant.secondary,
              icon: Icons.archive_outlined,
              onPressed: () => _record('Archive'),
            ),
            DsButton(
              label: 'Delete',
              variant: DsButtonVariant.danger,
              icon: Icons.delete_outline,
              onPressed: () => _record('Delete'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(_last, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
