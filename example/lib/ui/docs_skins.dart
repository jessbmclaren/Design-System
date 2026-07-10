import 'package:design_system/design_system.dart';

/// A selectable brand skin in the docs chrome.
///
/// A skin is *data*: a display name plus the token sets to feed [DsTheme]. The
/// default brand passes `null` (the system's neutral defaults); a branded skin
/// supplies its own [DsTokens] for light and dark.
///
/// This is the white-label promise made visible: the same components render
/// under any brand, and adding one to the switcher is a single entry in
/// [kDocsSkins] — no component, page, or wiring change.
class DocsSkin {
  const DocsSkin({required this.name, this.light, this.dark});

  /// Label shown in the switcher.
  final String name;

  /// Builds the light-mode tokens, or `null` for the system default.
  final DsTokens Function()? light;

  /// Builds the dark-mode tokens, or `null` for the system default.
  final DsTokens Function()? dark;

  /// The light tokens to hand [DsTheme.light], or `null` for the default brand.
  DsTokens? lightTokens() => light?.call();

  /// The dark tokens to hand [DsTheme.dark], or `null` for the default brand.
  DsTokens? darkTokens() => dark?.call();
}

/// The brands offered in the docs theme switcher.
///
/// Order matters: the first entry is the initial selection. Add a brand by
/// appending a [DocsSkin] that points at its [DsTokens] builders.
const List<DocsSkin> kDocsSkins = [
  DocsSkin(name: 'Default'),
  DocsSkin(name: 'Engen', light: DsSkins.engenLight, dark: DsSkins.engenDark),
];
