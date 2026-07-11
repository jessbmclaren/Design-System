/// How a heading block is aligned.
///
/// Applies to a title, its description and any brand header above them.
/// Start alignment reads as a conventional form; centred alignment suits a
/// short, focused card such as a one-step sign-up. Shared by the auth-card
/// organisms and `DsStepHeader`.
enum DsHeadingAlignment {
  /// Align the heading block with the leading edge.
  start,

  /// Centre the heading block.
  center,
}
