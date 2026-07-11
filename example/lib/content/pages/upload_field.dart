// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Inputs → Upload field.
final PatternPage uploadFieldPage = PatternPage(
  id: 'upload-field',
  group: DocGroup.inputs,
  navTitle: 'Upload field',
  title: 'Upload field',
  description:
      'An upload field collects one file inside a form without the bulk of a '
      'drop zone: a single row that walks through idle, uploading, success '
      'and error. `DsUploadField` does no file IO of its own. The host '
      'application owns the picker, the transfer and the retry policy, and '
      'drives the row entirely through a state enum, a progress fraction, a '
      'file name, an error message and three callbacks: pick, retry and '
      'remove. While uploading the row shows a determinate `DsProgressBar`; '
      'on success it confirms the file and offers a remove affordance.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'The status line is a polite live region, so assistive technology '
      'announces each state change without stealing focus. The idle and '
      'error rows expose button semantics, activate from the keyboard and '
      'keep a tap target of at least 48dp; the uploading row is inert so a '
      'transfer cannot be restarted by accident. For the large drop-target '
      'surface at the start of an import flow use the drop zone instead.',
    ),
  ],
  dos: const [
    'Drive the field from your own upload state machine; it renders state '
        'and never invents it.',
    'Report determinate progress while the transfer runs so the wait is '
        'measurable.',
    'Say what went wrong in `errorText` and let the row itself be the '
        'retry.',
    'State the accepted types and size limit in `helperText` before the '
        'user picks a file.',
  ],
  donts: const [
    'Don\'t leave `progress` at zero during a transfer; a stuck bar reads '
        'as a hang.',
    'Don\'t clear the file name between states; the user needs to see which '
        'file failed or arrived.',
    'Don\'t use it for multi-file batches; give each file its own row or '
        'use an import flow.',
  ],
  code: '''
DsUploadField(
  state: _uploadState,
  progress: _uploadProgress,
  fileName: _fileName,
  helperText: 'PDF or PNG, up to 10 MB',
  onPick: _pickFile,
  onRetry: _pickFile,
  onRemove: _removeFile,
);
''',
  related: ['data-import', 'progress-bar', 'business-verification'],
);
