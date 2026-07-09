import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Text area page: two `DsTextArea` fields captured mid-use.
/// The first is a healthy release-notes field with helper text and a live
/// character counter tracking a pre-filled value; the second is parked in its
/// error state so a single frame shows both the calm and validation
/// appearances at once.
class TextAreaDemo extends StatefulWidget {
  const TextAreaDemo({super.key});

  @override
  State<TextAreaDemo> createState() => _TextAreaDemoState();
}

class _TextAreaDemoState extends State<TextAreaDemo> {
  // Initialise to a meaningful state: a partly written note so the counter
  // reads a real count, and an empty required field showing its error.
  late final TextEditingController _notesController = TextEditingController(
    text: 'Fixed a rounding error on the billing summary and tightened the '
        'empty-state copy across the dashboard.',
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DsTextArea(
            label: 'Release notes',
            hintText: 'Summarise what changed in this version…',
            helperText: 'Shown to teammates on the deployment timeline.',
            minLines: 4,
            maxLines: 8,
            maxLength: 280,
            controller: _notesController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          const DsTextArea(
            label: 'Reason for rollback',
            hintText: 'Explain why this deploy is being reverted…',
            errorText: 'A reason is required before you can roll back.',
            minLines: 3,
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}
