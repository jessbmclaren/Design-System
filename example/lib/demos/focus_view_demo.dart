import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Focus view page: the panel rendered inline (screenshot
/// safe — the modal `show` helper is described in the code sample).
class FocusViewDemo extends StatelessWidget {
  const FocusViewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: DsFocusView(
        title: 'Rename workspace',
        onClose: () {},
        footer: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsButton(
              label: 'Cancel',
              variant: DsButtonVariant.secondary,
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            DsButton(label: 'Save', onPressed: () {}),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DsTextField(
              label: 'Workspace name',
              hintText: 'e.g. Northwind Operations',
            ),
            SizedBox(height: 16),
            DsTextField(
              label: 'Description',
              hintText: 'What is this workspace for?',
            ),
          ],
        ),
      ),
    );
  }
}
