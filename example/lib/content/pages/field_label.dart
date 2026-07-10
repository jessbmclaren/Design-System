// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Inputs → Field label.
final PatternPage fieldLabelPage = PatternPage(
  id: 'field-label',
  group: DocGroup.inputs,
  navTitle: 'Field label',
  title: 'Field label',
  description:
      '`DsFieldLabel` is the caption that names a form control, built from the '
      'same tokens as every field in the system. You will rarely place one by '
      'hand, because `DsTextField` and its siblings already draw a label above '
      'the input. It exists for the cases a field cannot own its label: a label '
      'that shares its row with an inline action such as a "Forgot password?" '
      'link, or a bespoke control that still needs a caption consistent with '
      'the rest of the system.',
  hasLiveDemo: false,
  dos: const [
    'Use DsFieldLabel when a label must sit on the same row as an inline action, such as a "Forgot password?" link.',
    'Let DsTextField render its own label whenever the field can own it.',
    'Keep the text to a short noun phrase that names the control.',
    'Match the label wording to the field it captions so the pairing is obvious.',
  ],
  donts: const [
    'Don\'t add a DsFieldLabel above a DsTextField that already renders a label; you will show two.',
    'Don\'t use it as a section heading or general body text; it is a field caption.',
    'Don\'t spell out guidance in the label; put that in the field\'s helper text.',
    'Don\'t restyle it with a bespoke TextStyle; the atom reads its type from tokens.',
  ],
  code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const DsFieldLabel(label: 'Password'),
        TextButton(
          onPressed: _resetPassword,
          child: const Text('Forgot password?'),
        ),
      ],
    ),
    const SizedBox(height: 6),
    const DsPasswordField(hintText: 'Enter your password'),
  ],
);
''',
  related: const ['text-fields'],
);
