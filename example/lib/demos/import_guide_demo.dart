import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Import guide page: the CSV how-to with its template
/// download one tap from the instructions. The callbacks stand in for the
/// real download and navigation with a SnackBar.
class ImportGuideDemo extends StatelessWidget {
  const ImportGuideDemo({super.key});

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: DsImportGuide(
        title: 'Add via CSV',
        description: 'Import many drivers at once from a spreadsheet.',
        steps: const [
          'Download the CSV template',
          'Complete all required fields (do not change the column headings '
              'or format)',
          'Upload your completed template',
        ],
        downloadLabel: 'Download CSV template',
        onDownloadTemplate: () =>
            _notify(context, 'Downloading the CSV template…'),
        guideLabel: 'View template guide',
        onOpenGuide: () => _notify(context, 'Opening the template guide…'),
      ),
    );
  }
}
