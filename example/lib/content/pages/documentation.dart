// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Foundations → Documentation.
///
/// Orients a reader to how the system is documented: the atomic taxonomy, the
/// content-model pipeline that keeps the docs honest, and the standards every
/// page upholds. Meta-content, so it ships no live demo or code sample and is
/// authored in the content model like every other page.
final PatternPage documentationPage = PatternPage(
  id: 'documentation',
  group: DocGroup.foundations,
  navTitle: 'Documentation',
  title: 'Documentation brief',
  description:
      'The documentation is half the product. A design system only works when '
      'design and engineering use the same words and trust the same single '
      'source of truth, and the documentation is where that shared language is '
      'written down. Every component is documented to the same shape and the '
      'same standard, because a component is not finished until it is '
      'documented. Documentation is a requirement, not a nicety.',
  hasLiveDemo: false,
  blocks: const [
    SubheadingBlock('Built the atomic way'),
    ProseBlock(
      'The docs follow the atomic-design ladder, from atoms up through '
      'molecules, organisms and templates to pages, and show up as ten groups '
      'in the sidebar. `Foundations` is the layer of tokens beneath the atoms: '
      'design tokens, motion, iconography and breakpoints. `Actions`, `Inputs` '
      'and `Display` are mostly atoms and the smallest molecules. `Feedback`, '
      '`Overlays`, `Data` and `Charts` are molecules and organisms. `Layout` '
      'carries the templates. `Patterns` is where organisms are filled with '
      'real content, so the docs demos are the pages of atomic design, where '
      'the system is finally tested against reality.',
    ),
    SubheadingBlock('Anatomy of a page'),
    ProseBlock(
      'Every page is built to the same shape, so a reader always knows where '
      'to look. A title and description say what the component is, when to '
      'reach for it and when not to. Screenshots at desktop and a 320dp phone '
      'show how the component behaves across screen sizes rather than just '
      'claiming it works. Short, paired Do and Don\'t lists name the real '
      'mistakes to avoid. A copyable example is compiled against the live '
      'code. See-also links connect each page to its neighbours, so the system '
      'reads as a web of parts rather than a flat list.',
    ),
    SubheadingBlock('One source of truth'),
    ProseBlock(
      'The words you read do not live in the markdown. They live in a '
      'plain-Dart content model under `example/lib/content/pages/`, and the '
      'markdown files under `docs/patterns/` are generated from it, so the '
      'docs always describe the component that actually ships, not a mockup or '
      'an old screenshot. Three checks keep them honest. '
      '`generate_markdown.dart --check` fails if any page is out of date. '
      '`check_snippets.dart` compiles every code sample against the real '
      'components, so a renamed parameter breaks the build instead of leaving '
      'broken copy-paste. The screenshots are goldens, so an image can only '
      'change through a reviewed, regenerated render. The rule that follows is '
      'simple: never edit the generated markdown by hand, edit the content '
      'model and regenerate.',
    ),
    SubheadingBlock('This page proves the model'),
    ProseBlock(
      'This brief is written in the content model and generated like every '
      'other page. It has no live demo or code sample because it is about the '
      'documentation itself, but it is authored and generated the same way the '
      'system asks every component to be.',
    ),
  ],
  dos: const [
    'Place each component at its correct atomic level, and reach for a variant '
        'before a new atom.',
    'Read appearance from DsTokens only, so a single token change restyles the '
        'page and its screenshots at once.',
    'Meet the accessibility contract: labelled controls, 48dp targets, colour '
        'never the only cue and errors announced with their field.',
    'Hold the layout from a 320dp phone to a 1920dp desktop without overflow.',
    'Author copy in the content model, then regenerate the page and check the '
        'snippets.',
  ],
  donts: const [
    'Don\'t edit the generated files under docs/patterns by hand; edit the '
        'content model instead.',
    'Don\'t hard-code a colour, size or shadow; every appearance value is a '
        'token.',
    'Don\'t reach into another component\'s internals; organisms compose, they '
        'never dig in.',
    'Don\'t put business logic, network or storage inside a component; keep it '
        'presentational and controlled.',
  ],
  related: ['design-tokens', 'motion', 'breakpoints'],
);
