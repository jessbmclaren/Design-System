// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Status → Communicating state.
final PatternPage communicatingStatePage = PatternPage(
  id: 'communicating-state',
  group: DocGroup.feedback,
  navTitle: 'Communicating state',
  title: 'Communicating state',
  description:
      'Tell people the result of an action or a condition they need to '
      'address, and match the delivery to how urgent and how durable the '
      'message is. Use a `DsToast` for brief, transient confirmation: a quick '
      '"Changes saved" that fades on its own and never interrupts the task. '
      'Use a `DsBanner` for a persistent issue or a required action (a failed '
      'sync, an expiring key, an unverified account) that stays in view until '
      'the person resolves it. Choosing the right one keeps routine feedback '
      'quiet and makes genuine problems impossible to miss.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'A toast is fire-and-forget: it acknowledges success and disappears, so '
      'never put anything the person must read or act on inside it. A banner '
      'is anchored to the surface it describes. Place it directly under the '
      'page header or at the top of the affected section, give it a single '
      'clear action and let the person dismiss it only once the underlying '
      'condition is gone.',
    ),
  ],
  dos: const [
    'Use a toast for quick, low-stakes confirmations such as "Changes saved".',
    'Use a banner for issues that need action and must stay visible until resolved.',
    'Keep toast text to one short, plain sentence.',
    'Give every banner a single, clear action that resolves the condition.',
    'Match the variant to severity so colour and icon reinforce the message.',
  ],
  donts: const [
    'Don\'t put something the user must act on inside a toast; it will vanish.',
    'Don\'t use a banner for a fleeting confirmation; it will linger and nag.',
    'Don\'t stack multiple banners; surface the most important condition first.',
    'Don\'t rely on colour alone; always pair it with a title or message.',
  ],
  code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    // Persistent: an issue that needs action and must stay visible.
    DsBanner(
      variant: DsBannerVariant.warning,
      title: 'Billing details are out of date',
      message: 'Update your payment method to avoid an interruption.',
      action: DsBannerAction(
        label: 'Update',
        onPressed: () {},
      ),
    ),
    const SizedBox(height: 16),
    // Transient: a brief confirmation that fades on its own.
    const DsToast(
      message: 'Changes saved',
      icon: DsIcons.success,
    ),
  ],
);
''',
  shots: const [
    Shot(pageId: 'communicating-state', size: ShotSize.desktop),
    Shot(pageId: 'communicating-state', size: ShotSize.phone),
  ],
  related: ['action-buttons', 'lists'],
);
