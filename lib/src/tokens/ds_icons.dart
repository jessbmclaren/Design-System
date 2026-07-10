import 'package:flutter/material.dart';

/// The design system's icon vocabulary.
///
/// Components — and the products that consume the system — reference glyphs by
/// their **semantic role** (`DsIcons.close`, `DsIcons.success`) rather than
/// reaching for `Icons.*` directly. Centralising the vocabulary here is what
/// makes the iconography a *system*: the family policy lives in one place, and
/// a future migration to a real Lucide font is a single file's edit, not a
/// codebase-wide audit.
///
/// ## Family policy (Lucide-styled)
///
/// The set is chosen to read like Lucide — thin, consistent, open line work:
///
/// * **Outlined line glyphs** are the default for actions, affordances and
///   status (close, edit, upload, info, warning, success, error).
/// * **Bare strokes** for pure directional marks (chevrons, arrows, add,
///   close, filter) that have no shape to outline.
/// * **Filled is reserved for true-state** glyphs where the fill carries the
///   meaning — a selected rating [star]. Everything else stays outlined.
/// * **The rounded family is banned** — it reads as consumer-playful, the wrong
///   register for a dense, professional product. Any rounded Material glyph is
///   mapped to its sharp / outlined equivalent here.
///
/// To re-brand the iconography, a consumer forks this one file and remaps the
/// roles to their own [IconData]; the rest of the system follows automatically.
abstract final class DsIcons {
  // --- Directional ----------------------------------------------------------

  /// A right-pointing chevron (disclosure, "see more").
  static const IconData chevronRight = Icons.chevron_right;

  /// A downward chevron (expand, open a dropdown).
  static const IconData expandMore = Icons.expand_more;

  /// An upward chevron (collapse).
  static const IconData expandLess = Icons.expand_less;

  /// Move a row up in an ordered list.
  static const IconData moveUp = Icons.keyboard_arrow_up;

  /// Move a row down in an ordered list.
  static const IconData moveDown = Icons.keyboard_arrow_down;

  /// Ascending sort.
  static const IconData arrowUp = Icons.arrow_upward;

  /// Descending sort.
  static const IconData arrowDown = Icons.arrow_downward;

  /// Forward navigation.
  static const IconData arrowForward = Icons.arrow_forward;

  /// Back navigation.
  static const IconData arrowBack = Icons.arrow_back_ios_new;

  // --- Actions --------------------------------------------------------------

  /// Dismiss / clear / remove-from-view.
  static const IconData close = Icons.close;

  /// Confirm / done (sharp, not rounded).
  static const IconData check = Icons.check;

  /// Add / create.
  static const IconData add = Icons.add;

  /// Remove / subtract.
  static const IconData remove = Icons.remove;

  /// Edit in place.
  static const IconData edit = Icons.edit_outlined;

  /// Delete.
  static const IconData delete = Icons.delete_outline;

  /// Copy to clipboard.
  static const IconData copy = Icons.copy;

  /// Open a filter.
  static const IconData filter = Icons.filter_list;

  /// An overflow menu (horizontal).
  static const IconData moreHorizontal = Icons.more_horiz;

  /// An overflow menu (vertical).
  static const IconData moreVertical = Icons.more_vert;

  /// Opens in a new context / external link.
  static const IconData externalLink = Icons.open_in_new;

  /// Upload a file.
  static const IconData upload = Icons.cloud_upload_outlined;

  /// A completed upload.
  static const IconData uploadDone = Icons.cloud_done_outlined;

  /// A date / calendar affordance.
  static const IconData calendar = Icons.calendar_today;

  // --- Status ---------------------------------------------------------------

  /// Success / positive confirmation.
  static const IconData success = Icons.check_circle_outline;

  /// Informational.
  static const IconData info = Icons.info_outline;

  /// A caution (outlined, never the rounded amber glyph).
  static const IconData warning = Icons.warning_amber;

  /// An error / failure.
  static const IconData error = Icons.error_outline;

  // --- Selection & true-state ----------------------------------------------

  /// A selected rating step — filled, because the fill is the state.
  static const IconData star = Icons.star;

  /// An unselected rating step.
  static const IconData starOutline = Icons.star_border;

  /// An empty checkbox.
  static const IconData checkboxBlank = Icons.check_box_outline_blank;

  /// A ticked checkbox (outlined, to sit with the line family).
  static const IconData checkboxChecked = Icons.check_box_outlined;

  // --- Entities -------------------------------------------------------------

  /// A person / user.
  static const IconData user = Icons.person_outline;

  /// A file / document.
  static const IconData file = Icons.insert_drive_file_outlined;

  /// A folder.
  static const IconData folder = Icons.folder_open_outlined;

  /// A shipment / vehicle.
  static const IconData shipping = Icons.local_shipping_outlined;

  /// A workspace / group of records.
  static const IconData workspace = Icons.workspaces_outline;

  /// A placeholder for an image that failed to load.
  static const IconData brokenImage = Icons.broken_image_outlined;
}
