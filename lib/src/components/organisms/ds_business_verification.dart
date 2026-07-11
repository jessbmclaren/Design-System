import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_checkbox.dart';
import '../atoms/ds_divider.dart';
import '../atoms/ds_field_label.dart';
import '../atoms/ds_icon.dart';
import '../atoms/ds_icon_badge.dart';
import '../atoms/ds_icon_button.dart';
import '../molecules/ds_address_field_group.dart';
import '../molecules/ds_form_field_group.dart';
import '../molecules/ds_select.dart';
import '../molecules/ds_text_field.dart';
import '../molecules/ds_upload_field.dart';
import '../organisms/ds_onboarding_wizard.dart';

/// Builds or decorates the body of one verification step.
///
/// [stepIndex] is the zero-based step and [body] is the step's standard
/// content. Return [body] unchanged for the steps you do not customise, wrap
/// it to append market-specific fields or validators, or replace it entirely.
typedef DsVerificationStepBuilder = Widget Function(
  BuildContext context,
  int stepIndex,
  Widget body,
);

/// A guided, multi-step flow for verifying a business's identity and details.
///
/// [DsBusinessVerification] is a self-contained onboarding **organism** that
/// composes the Design System's existing building blocks. It does not
/// re-implement any fields, buttons or steppers. The step chrome (progress
/// stepper, title and the Back / Continue actions) is provided by
/// [DsOnboardingWizard]; each step's body is assembled from
/// [DsFormFieldGroup], [DsSelect], [DsTextField], [DsAddressFieldGroup] and
/// [DsCheckbox].
///
/// The flow walks the user through four steps:
///
/// 1. **Business type**: a single [DsSelect] to classify the entity (sole
///    trader, company, partnership or non-profit).
/// 2. **Business details**: the legal name, registration number and a
///    structured registered address collected by [DsAddressFieldGroup].
/// 3. **Verify identity**: the representative's full name, an identifier /
///    reference number, an optional document upload slot and a consent
///    checkbox confirming the representative is authorised to act for the
///    business.
/// 4. **Review & submit**: a read-back of every entered value plus a note that
///    submitting sends the details for verification.
///
/// The widget owns its step index and all entered values in local state, so the
/// review step always reflects the latest input and moving back and forward
/// never loses data. While the identity step shows its stock body, advancing
/// past it is gated on the consent checkbox via
/// [DsOnboardingWizard.nextEnabled]; every other step can always advance.
/// Submitting from the final step swaps the flow for a brief, static
/// success confirmation and invokes [onSubmitted]. With [showReceipt] the
/// confirmation becomes a receipt with a primary continue action and
/// [onSubmitted] waits for that action instead.
///
/// ## Extending the flow
///
/// The organism stays useful beyond its stock four steps without forking:
///
/// * [onClose] adds a takeover-style header (a corner close affordance, a
///   hairline divider and the flow title) above the wizard, matching the
///   corner close on the auth cards.
/// * [stepBodyBuilder] lets a caller append fields or validators to any step,
///   or replace a step body entirely. A builder that returns anything other
///   than the stock identity body takes that step's gating with it: the
///   consent gate lifts, so a replaced body can never strand the flow on a
///   checkbox that is no longer there. Reinstate a gate through
///   [canAdvance].
/// * [canAdvance] overrides whether a given step may advance, so a custom
///   step body can gate Continue on its own state.
/// * [uploadState] and its companions wire an identity document
///   [DsUploadField] into the identity step; the caller owns the upload state
///   machine.
/// * [addressCountries] and [addressConfig] tune the structured address block
///   for the market being served.
///
/// ## Responsiveness
///
/// All responsive behaviour is delegated to the composed widgets:
/// [DsOnboardingWizard] adapts its stepper and action bar, and
/// [DsFormFieldGroup] flows fields into one or two columns for the available
/// width. The flow therefore lays out cleanly from a 320dp phone up to a large
/// desktop and never overflows.
///
/// ## Screenshot safety
///
/// The first frame is always step 0 with empty fields, and the widget starts no
/// timers or indefinite animation, so it renders deterministically in
/// screenshots.
class DsBusinessVerification extends StatefulWidget {
  /// Creates a business-verification flow.
  const DsBusinessVerification({
    super.key,
    this.onSubmitted,
    this.onCancel,
    this.onClose,
    this.stepBodyBuilder,
    this.canAdvance,
    this.uploadState,
    this.uploadProgress = 0,
    this.uploadFileName,
    this.uploadErrorText,
    this.onUploadPick,
    this.onUploadRetry,
    this.onUploadRemove,
    this.addressCountries = const <DsSelectOption<String>>[],
    this.addressConfig = const DsAddressFieldConfig(),
    this.showReceipt = false,
    this.receiptContinueLabel = 'Continue',
  });

  /// Called once the flow completes.
  ///
  /// By default it fires as soon as the user submits from the final step,
  /// alongside the success confirmation. With [showReceipt] it fires only
  /// when the user leaves the receipt through its continue action (or the
  /// header's close affordance, which must not forget a submission that has
  /// already happened).
  final VoidCallback? onSubmitted;

  /// Called when the user backs out of the very first step.
  ///
  /// When set, the wizard keeps its back action on the first step and routes
  /// it here, so an embedding screen can dismiss or cancel the flow. When
  /// null (the default) the first step shows no back action, since there is
  /// nowhere to go back to.
  final VoidCallback? onCancel;

  /// Called when the takeover header's close affordance is activated.
  ///
  /// When set, the flow renders a takeover-style header above the wizard: the
  /// close affordance, a hairline divider and the flow title, the same corner
  /// close pattern the auth cards use. The header then carries the title, so
  /// the wizard's own heading is dropped to avoid saying it twice. When null
  /// (the default) no header is rendered and the flow looks exactly as
  /// before.
  final VoidCallback? onClose;

  /// Builds or decorates the body of each step.
  ///
  /// Receives the zero-based step index and the step's standard content, so a
  /// caller can append market-specific fields or validators beneath the stock
  /// ones, or swap a step body entirely. When null (the default) every step
  /// renders its standard content.
  ///
  /// The stock consent gate on the identity step applies only while the
  /// builder returns that step's body unchanged. A builder that wraps or
  /// replaces the identity body lifts the gate, so the flow can never
  /// deadlock behind the stock checkbox; use [canAdvance] to gate the custom
  /// body on your own state instead.
  final DsVerificationStepBuilder? stepBodyBuilder;

  /// Overrides whether the step at the given zero-based index may advance.
  ///
  /// Return true or false to control the Continue action directly, or null to
  /// keep the stock behaviour for that step (the consent gate on the identity
  /// step, always enabled elsewhere). When the callback itself is null (the
  /// default) every step uses the stock behaviour.
  final bool? Function(int stepIndex)? canAdvance;

  /// The state of the identity document upload slot.
  ///
  /// When non-null, the identity step shows a [DsUploadField] driven by this
  /// state plus [uploadProgress], [uploadFileName], [uploadErrorText] and the
  /// three upload callbacks; the caller owns the whole upload state machine.
  /// When null (the default) the slot is hidden.
  final DsUploadFieldState? uploadState;

  /// The completed fraction of the document upload, from 0 to 1. Only read
  /// while [uploadState] is [DsUploadFieldState.uploading]. Defaults to 0.
  final double uploadProgress;

  /// The name of the document in flight or delivered.
  final String? uploadFileName;

  /// The message explaining a failed document upload.
  final String? uploadErrorText;

  /// Called when the upload slot is activated to pick a document.
  final VoidCallback? onUploadPick;

  /// Called when the failed upload slot is activated to try again.
  final VoidCallback? onUploadRetry;

  /// Called when the delivered document's remove affordance is activated.
  final VoidCallback? onUploadRemove;

  /// The choices offered by the registered address's country select. An empty
  /// list (the default) hides the country field.
  final List<DsSelectOption<String>> addressCountries;

  /// Labels, hints and field visibility for the registered address block, so
  /// a market can rename or hide address fields.
  final DsAddressFieldConfig addressConfig;

  /// Whether submitting shows a receipt with a primary continue action.
  ///
  /// When false (the default) submitting shows the brief success confirmation
  /// and fires [onSubmitted] immediately, the original behaviour. When true
  /// the flow instead shows a receipt confirming what happens next, and
  /// [onSubmitted] fires only when the user continues from it.
  final bool showReceipt;

  /// The label of the receipt's primary continue action. Defaults to
  /// `'Continue'`. Only used with [showReceipt].
  final String receiptContinueLabel;

  @override
  State<DsBusinessVerification> createState() => _DsBusinessVerificationState();
}

class _DsBusinessVerificationState extends State<DsBusinessVerification> {
  /// Zero-based index of the identity step, whose consent gates advancing.
  static const int _identityStep = 2;

  /// The title shared by the wizard heading and the takeover header.
  static const String _title = 'Verify your business';

  /// The ordered steps shown by the wizard's progress stepper.
  static const List<DsWizardStep> _steps = <DsWizardStep>[
    DsWizardStep(label: 'Business type'),
    DsWizardStep(label: 'Business details'),
    DsWizardStep(label: 'Verify identity'),
    DsWizardStep(label: 'Review & submit'),
  ];

  /// The available business types. The value doubles as the display label so
  /// the review step can read it back directly.
  static const List<DsSelectOption<String>> _businessTypeOptions =
      <DsSelectOption<String>>[
    DsSelectOption<String>(value: 'Sole trader', label: 'Sole trader'),
    DsSelectOption<String>(value: 'Company', label: 'Company'),
    DsSelectOption<String>(value: 'Partnership', label: 'Partnership'),
    DsSelectOption<String>(value: 'Non-profit', label: 'Non-profit'),
  ];

  final TextEditingController _legalName = TextEditingController();
  final TextEditingController _registrationNumber = TextEditingController();
  final TextEditingController _representativeName = TextEditingController();
  final TextEditingController _idNumber = TextEditingController();

  /// Current step index. The flow always starts on step 0.
  int _step = 0;

  /// The selected business type, or `null` while nothing is chosen.
  String? _businessType;

  /// The structured registered address.
  DsAddressValue _address = const DsAddressValue();

  /// Whether the representative has confirmed they are authorised.
  bool _consent = false;

  /// Whether the flow has been submitted and now shows its confirmation.
  bool _submitted = false;

  int get _lastStep => _steps.length - 1;

  /// Whether the current step permits advancing.
  ///
  /// A [DsBusinessVerification.canAdvance] override wins outright. Otherwise
  /// only the identity step is gated, and only while it shows its stock body
  /// ([identityBodyIsStock]): the consent checkbox must be ticked. A builder
  /// that wraps or replaces the identity body removes that checkbox from the
  /// flow's control, so the gate lifts rather than stranding the user.
  bool _canAdvance({required bool identityBodyIsStock}) {
    final override = widget.canAdvance?.call(_step);
    if (override != null) return override;
    if (_step != _identityStep || !identityBodyIsStock) return true;
    return _consent;
  }

  @override
  void dispose() {
    _legalName.dispose();
    _registrationNumber.dispose();
    _representativeName.dispose();
    _idNumber.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_step > 0) {
      setState(() => _step -= 1);
    } else {
      widget.onCancel?.call();
    }
  }

  void _handleNext() {
    if (_step < _lastStep) {
      setState(() => _step += 1);
      return;
    }
    setState(() => _submitted = true);
    // The receipt defers completion to its continue action; the original
    // behaviour completes immediately.
    if (!widget.showReceipt) {
      widget.onSubmitted?.call();
    }
  }

  /// What the takeover header's close affordance does right now. Once the
  /// receipt is up the submission has already happened, so closing completes
  /// the flow rather than cancelling it.
  VoidCallback? get _headerClose {
    if (_submitted && widget.showReceipt) {
      return () => widget.onSubmitted?.call();
    }
    return widget.onClose;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final hasHeader = widget.onClose != null;

    final Widget content;
    if (_submitted) {
      content = widget.showReceipt
          ? _ReceiptState(
              tokens: tokens,
              continueLabel: widget.receiptContinueLabel,
              onContinue: () => widget.onSubmitted?.call(),
            )
          : _SuccessState(tokens: tokens);
    } else {
      Widget body = _buildStepBody(tokens);
      var identityBodyIsStock = true;
      final builder = widget.stepBodyBuilder;
      if (builder != null) {
        final built = builder(context, _step, body);
        // A builder that hands the stock body back unchanged keeps the stock
        // gating; anything else takes the step's gating with it.
        identityBodyIsStock = identical(built, body);
        body = built;
      }
      // The first step's back action backs out of the flow, so it only
      // appears when there is an onCancel to receive that.
      final showBack = _step > 0 || widget.onCancel != null;
      content = DsOnboardingWizard(
        // The takeover header carries the title when present, so the wizard
        // drops its own heading rather than saying it twice.
        title: hasHeader ? null : _title,
        steps: _steps,
        currentIndex: _step,
        onBack: showBack ? _handleBack : null,
        onNext: _handleNext,
        nextLabel: _step == _lastStep ? 'Submit' : 'Continue',
        nextEnabled: _canAdvance(identityBodyIsStock: identityBodyIsStock),
        child: body,
      );
    }

    if (!hasHeader) return content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TakeoverHeader(tokens: tokens, title: _title, onClose: _headerClose),
        Expanded(child: content),
      ],
    );
  }

  Widget _buildStepBody(DsTokens tokens) {
    switch (_step) {
      case 0:
        return _buildBusinessTypeStep();
      case 1:
        return _buildBusinessDetailsStep();
      case _identityStep:
        return _buildIdentityStep();
      default:
        return _buildReviewStep(tokens);
    }
  }

  // Step 0: Business type ------------------------------------------------

  Widget _buildBusinessTypeStep() {
    return DsFormFieldGroup(
      legend: 'Business type',
      description: 'Tell us how your business is set up so we can tailor the '
          'checks that follow.',
      columns: 1,
      children: <Widget>[
        DsSelect<String>(
          label: 'Business type',
          value: _businessType,
          hintText: 'Select a business type',
          options: _businessTypeOptions,
          onChanged: (value) => setState(() => _businessType = value),
        ),
      ],
    );
  }

  // Step 1: Business details --------------------------------------------

  Widget _buildBusinessDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DsFormFieldGroup(
          legend: 'Business details',
          description: 'Enter the details exactly as they appear on your '
              'official registration.',
          columns: 1,
          children: <Widget>[
            DsTextField(
              label: 'Legal name',
              hintText: 'Registered business name',
              controller: _legalName,
            ),
            DsTextField(
              label: 'Registration number',
              hintText: 'e.g. 12345678',
              controller: _registrationNumber,
            ),
          ],
        ),
        const SizedBox(height: DsSpacing.lg),
        DsAddressFieldGroup(
          legend: 'Registered address',
          value: _address,
          countries: widget.addressCountries,
          config: widget.addressConfig,
          onChanged: (value) => setState(() => _address = value),
        ),
      ],
    );
  }

  // Step 2: Verify identity ---------------------------------------------

  Widget _buildIdentityStep() {
    final uploadState = widget.uploadState;

    return DsFormFieldGroup(
      legend: 'Verify identity',
      description: 'We need to know who is completing this verification on '
          'behalf of the business.',
      columns: 1,
      children: <Widget>[
        DsTextField(
          label: 'Full name',
          hintText: 'Your full legal name',
          controller: _representativeName,
        ),
        DsTextField(
          label: 'ID or reference number',
          hintText: 'Passport, licence or reference number',
          controller: _idNumber,
        ),
        if (uploadState != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const DsFieldLabel(label: 'Identity document'),
              const SizedBox(height: 6),
              DsUploadField(
                state: uploadState,
                progress: widget.uploadProgress,
                fileName: widget.uploadFileName,
                errorText: widget.uploadErrorText,
                onPick: widget.onUploadPick,
                onRetry: widget.onUploadRetry,
                onRemove: widget.onUploadRemove,
                idleLabel: 'Upload an identity document',
              ),
            ],
          ),
        DsCheckbox(
          value: _consent,
          label: "I confirm I'm authorised to act for this business",
          onChanged: (value) => setState(() => _consent = value),
        ),
      ],
    );
  }

  // Step 3: Review & submit ---------------------------------------------

  Widget _buildReviewStep(DsTokens tokens) {
    final rows = <_SummaryEntry>[
      _SummaryEntry('Business type', _businessType),
      _SummaryEntry('Legal name', _valueOrNull(_legalName.text)),
      _SummaryEntry(
        'Registration number',
        _valueOrNull(_registrationNumber.text),
      ),
      _SummaryEntry(
        'Registered address',
        _address.isEmpty ? null : _address.format(),
      ),
      _SummaryEntry('Representative', _valueOrNull(_representativeName.text)),
      _SummaryEntry('ID or reference', _valueOrNull(_idNumber.text)),
      if (widget.uploadState != null)
        _SummaryEntry(
          'Identity document',
          widget.uploadState == DsUploadFieldState.success
              ? (widget.uploadFileName ?? 'Provided')
              : null,
        ),
      _SummaryEntry('Authorisation', _consent ? 'Confirmed' : 'Not confirmed'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Review your details',
          style: tokens.labelMd
              .copyWith(fontWeight: DsTypography.semiBold)
              .toTextStyle(color: tokens.colorText),
        ),
        const SizedBox(height: DsSpacing.md),
        for (var i = 0; i < rows.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: DsSpacing.sm),
          _SummaryRow(tokens: tokens, entry: rows[i]),
        ],
        const SizedBox(height: DsSpacing.lg),
        Text(
          'Submitting sends these details for verification. We\'ll let you know '
          'once the review is complete.',
          style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
        ),
      ],
    );
  }

  /// Returns [text] trimmed, or `null` when it is empty, so the summary can
  /// show a neutral placeholder for values the user has not entered.
  String? _valueOrNull(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// The takeover-style top bar: a close affordance, a short vertical hairline
/// and the flow title, above a bottom hairline separating it from the flow.
class _TakeoverHeader extends StatelessWidget {
  const _TakeoverHeader({
    required this.tokens,
    required this.title,
    required this.onClose,
  });

  final DsTokens tokens;
  final String title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.md,
        vertical: DsSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.colorBorderSubtle)),
      ),
      child: Row(
        children: <Widget>[
          DsIconButton(
            icon: DsIcons.close,
            semanticLabel: 'Close',
            onPressed: onClose,
          ),
          const SizedBox(width: DsSpacing.md),
          const DsDivider(axis: DsDividerAxis.vertical, length: 24),
          const SizedBox(width: DsSpacing.lg),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tokens.labelMd
                    .copyWith(fontWeight: DsTypography.medium)
                    .toTextStyle(color: tokens.colorText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One label / value pair rendered in the review summary.
@immutable
class _SummaryEntry {
  const _SummaryEntry(this.label, this.value);

  final String label;
  final String? value;
}

/// A single read-back row: a muted label beside the entered value.
///
/// Both columns flex so the row never overflows on a 320dp phone; a missing
/// value falls back to an em dash in the secondary text colour.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.tokens, required this.entry});

  final DsTokens tokens;
  final _SummaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final value = entry.value;
    final hasValue = value != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(
            entry.label,
            style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
          ),
        ),
        const SizedBox(width: DsSpacing.md),
        Expanded(
          flex: 3,
          child: Text(
            hasValue ? value : '—',
            style: tokens.bodySm.toTextStyle(
              color: hasValue ? tokens.colorText : tokens.colorSecondaryText,
            ),
          ),
        ),
      ],
    );
  }
}

/// The centred confirmation shown after a successful submission.
///
/// A check glyph in the theme's success-badge colours sits above a heading and
/// a short supporting line. The layout is static and scroll-safe, so it renders
/// cleanly at any width from 320dp upward.
class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.tokens});

  final DsTokens tokens;

  static const double _badgeSize = 64;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DsSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: _badgeSize,
                height: _badgeSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.badgeSuccessColorBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.badgeSuccessColorBorder),
                ),
                child: DsIcon(
                  icon: DsIcons.check,
                  size: DsIconSize.xl,
                  color: tokens.badgeSuccessColorText,
                  semanticLabel: 'Success',
                ),
              ),
              const SizedBox(height: DsSpacing.lg),
              Semantics(
                header: true,
                child: Text(
                  'Verification submitted',
                  textAlign: TextAlign.center,
                  style: tokens.headingMd.toTextStyle(color: tokens.colorText),
                ),
              ),
              const SizedBox(height: DsSpacing.sm),
              Text(
                "Thanks. We've received your business details and will review "
                'them shortly. You can safely close this window.',
                textAlign: TextAlign.center,
                style: tokens.bodyMd
                    .toTextStyle(color: tokens.colorSecondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The opt-in receipt shown after submission: a confirmation of what was
/// received, honest expectations about the checks and a primary continue
/// action that completes the flow.
class _ReceiptState extends StatelessWidget {
  const _ReceiptState({
    required this.tokens,
    required this.continueLabel,
    required this.onContinue,
  });

  final DsTokens tokens;
  final String continueLabel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DsSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const DsIconBadge(
                icon: DsIcons.check,
                tone: DsIconBadgeTone.success,
                size: 64,
                semanticLabel: 'Submitted',
              ),
              const SizedBox(height: DsSpacing.lg),
              // A live region so the arrival of the receipt is announced.
              Semantics(
                header: true,
                liveRegion: true,
                child: Text(
                  'Verification submitted',
                  textAlign: TextAlign.center,
                  style: tokens.headingMd.toTextStyle(color: tokens.colorText),
                ),
              ),
              const SizedBox(height: DsSpacing.sm),
              Text(
                "We've received your business details and started the checks. "
                "They usually finish quickly, and we'll let you know the "
                "moment they're done.",
                textAlign: TextAlign.center,
                style: tokens.bodyMd
                    .toTextStyle(color: tokens.colorSecondaryText),
              ),
              const SizedBox(height: DsSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DsSpacing.lg),
                decoration: BoxDecoration(
                  color: tokens.offsetBackgroundColor,
                  borderRadius: BorderRadius.circular(tokens.formBorderRadius),
                ),
                child: Text(
                  'You can keep working while the checks run. Anything that '
                  'needs a verified business unlocks as soon as they pass.',
                  textAlign: TextAlign.center,
                  style: tokens.bodySm
                      .toTextStyle(color: tokens.colorSecondaryText),
                ),
              ),
              const SizedBox(height: DsSpacing.xl),
              DsButton(
                label: continueLabel,
                onPressed: onContinue,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
