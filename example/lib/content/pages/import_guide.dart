// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Data → Import guide.
final PatternPage importGuidePage = PatternPage(
  id: 'import-guide',
  group: DocGroup.data,
  navTitle: 'Import guide',
  title: 'Import guide',
  description:
      '`DsImportGuide` is a short how-to for bulk import, with the template '
      'download as its call to action: a titled explanation, numbered steps '
      'and — when `onDownloadTemplate` is set — a download button, so the '
      'file people are asked to fill in is always one tap from the '
      'instructions that describe it. An optional `guideLabel` / '
      '`onOpenGuide` link points at longer-form docs. It is purely '
      'presentational: the caller performs the actual download or navigation '
      'in the callbacks. Reach for it beside any surface that accepts a bulk '
      'upload — a roster footer, an empty state, an import wizard\'s first '
      'step.',
  hasLiveDemo: true,
  dos: const [
    'Keep the template one tap from the instructions: pass '
        '`onDownloadTemplate` so the button renders right under the steps '
        'that describe the file.',
    'Write steps as short imperatives in the order people perform them '
        '("Download the CSV template", "Complete all required fields").',
    'Point `guideLabel` / `onOpenGuide` at the longer-form docs instead of '
        'growing the step list.',
    'Perform the real download or navigation in the callbacks; the guide '
        'itself never touches IO.',
  ],
  donts: const [
    "Don't bury the guide in a help centre; place it beside the surface "
        'where the import actually happens.',
    "Don't number more than a handful of steps — if the process needs more, "
        'that is what the trailing docs link is for.',
    "Don't change the template's column headings between the guide and the "
        'file; the instructions and the download must describe each other.',
  ],
  code: '''
DsImportGuide(
  title: 'Add via CSV',
  description: 'Import many drivers at once from a spreadsheet.',
  steps: const [
    'Download the CSV template',
    'Complete all required fields',
    'Upload your completed template',
  ],
  downloadLabel: 'Download CSV template',
  onDownloadTemplate: _downloadTemplate,
  guideLabel: 'View template guide',
  onOpenGuide: _openTemplateGuide,
)
''',
  related: const ['data-import', 'roster-view', 'empty-state'],
);
