import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// The design system's icon vocabulary.
///
/// Components (and the products that consume the system) reference glyphs by
/// their **semantic role** (`DsIcons.close`, `DsIcons.success`) rather than
/// reaching for [LucideIcons] (or `Icons.*`) directly. Centralising the
/// vocabulary here is what makes the iconography a *system*: the family policy
/// lives in one place, and re-branding the icon set is a single file's edit,
/// not a codebase-wide audit.
///
/// ## Family policy (Lucide)
///
/// The set is drawn from [Lucide](https://lucide.dev) (thin, consistent, open
/// line work) via the `flutter_lucide` package:
///
/// * **Outlined line glyphs** are the default for actions, affordances and
///   status (close, edit, upload, info, warning, success, error).
/// * **Bare strokes** for pure directional marks (chevrons, arrows, add,
///   remove) that have no shape to outline.
/// * **Filled is reserved for true-state** glyphs where the fill carries the
///   meaning: a selected rating [star]. Lucide is an outline-only set with no
///   solid star, so that one true-state glyph keeps its Material solid form;
///   the empty rating step ([starOutline]) uses the Lucide outline star, giving
///   a clear filled/empty contrast.
///
/// To re-brand the iconography, a consumer forks this one file and remaps the
/// roles to their own [IconData]; the rest of the system follows automatically.
abstract final class DsIcons {
  // --- Directional ----------------------------------------------------------

  /// A right-pointing chevron (disclosure, "see more").
  static const IconData chevronRight = LucideIcons.chevron_right;

  /// A downward chevron (expand, open a dropdown).
  static const IconData expandMore = LucideIcons.chevron_down;

  /// An upward chevron (collapse).
  static const IconData expandLess = LucideIcons.chevron_up;

  /// Move a row up in an ordered list.
  static const IconData moveUp = LucideIcons.chevron_up;

  /// Move a row down in an ordered list.
  static const IconData moveDown = LucideIcons.chevron_down;

  /// Ascending sort.
  static const IconData arrowUp = LucideIcons.arrow_up;

  /// Descending sort.
  static const IconData arrowDown = LucideIcons.arrow_down;

  /// Forward navigation.
  static const IconData arrowForward = LucideIcons.arrow_right;

  /// Back navigation.
  static const IconData arrowBack = LucideIcons.arrow_left;

  // --- Actions --------------------------------------------------------------

  /// Dismiss / clear / remove-from-view.
  static const IconData close = LucideIcons.x;

  /// Confirm / done.
  static const IconData check = LucideIcons.check;

  /// Add / create.
  static const IconData add = LucideIcons.plus;

  /// Remove / subtract.
  static const IconData remove = LucideIcons.minus;

  /// Edit in place.
  static const IconData edit = LucideIcons.pencil;

  /// Delete.
  static const IconData delete = LucideIcons.trash_2;

  /// Copy to clipboard.
  static const IconData copy = LucideIcons.copy;

  /// Open a filter.
  static const IconData filter = LucideIcons.list_filter;

  /// An overflow menu (horizontal).
  static const IconData moreHorizontal = LucideIcons.ellipsis;

  /// An overflow menu (vertical).
  static const IconData moreVertical = LucideIcons.ellipsis_vertical;

  /// Opens in a new context / external link.
  static const IconData externalLink = LucideIcons.external_link;

  /// Upload a file.
  static const IconData upload = LucideIcons.cloud_upload;

  /// A completed upload.
  static const IconData uploadDone = LucideIcons.cloud_check;

  /// A date / calendar affordance.
  static const IconData calendar = LucideIcons.calendar;

  // --- Status ---------------------------------------------------------------

  /// Success / positive confirmation.
  static const IconData success = LucideIcons.circle_check;

  /// Informational.
  static const IconData info = LucideIcons.info;

  /// A caution.
  static const IconData warning = LucideIcons.triangle_alert;

  /// An error / failure.
  static const IconData error = LucideIcons.circle_alert;

  // --- Selection & true-state ----------------------------------------------

  /// A selected rating step: filled, because the fill is the state. Kept as the
  /// Material solid star, since Lucide has no solid star (see the family policy).
  static const IconData star = Icons.star;

  /// An unselected rating step (Lucide outline star).
  static const IconData starOutline = LucideIcons.star;

  /// An empty checkbox.
  static const IconData checkboxBlank = LucideIcons.square;

  /// A ticked checkbox.
  static const IconData checkboxChecked = LucideIcons.square_check;

  // --- Entities -------------------------------------------------------------

  /// A person / user.
  static const IconData user = LucideIcons.user;

  /// A file / document.
  static const IconData file = LucideIcons.file;

  /// A folder.
  static const IconData folder = LucideIcons.folder_open;

  /// A shipment / vehicle.
  static const IconData shipping = LucideIcons.truck;

  /// A workspace / group of records.
  static const IconData workspace = LucideIcons.layers;

  /// A placeholder for an image that failed to load.
  static const IconData brokenImage = LucideIcons.image_off;
}
