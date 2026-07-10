import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import '../atoms/ds_checkbox.dart';
import '../atoms/ds_icon.dart';
import '../molecules/ds_form_field_group.dart';
import '../molecules/ds_select.dart';
import '../molecules/ds_text_field.dart';
import '../organisms/ds_onboarding_wizard.dart';

/// A guided, multi-step flow for verifying a business's identity and details.
///
/// [DsBusinessVerification] is a self-contained onboarding **organism** that
/// composes the Design System's existing building blocks. It does not
/// re-implement any fields, buttons or steppers. The step chrome (progress
/// stepper, title and the Back / Continue actions) is provided by
/// [DsOnboardingWizard]; each step's body is assembled from
/// [DsFormFieldGroup], [DsSelect], [DsTextField] and [DsCheckbox].
///
/// The flow walks the user through four steps:
///
/// 1. **Business type**: a single [DsSelect] to classify the entity (sole
///    trader, company, partnership or non-profit).
/// 2. **Business details**: the legal name, registration number and a
///    multi-line registered address.
/// 3. **Verify identity**: the representative's full name, an identifier /
///    reference number and a consent checkbox confirming the representative is
///    authorised to act for the business.
/// 4. **Review & submit**: a read-back of every entered value plus a note that
///    submitting sends the details for verification.
///
/// The widget owns its step index and all entered values in local state, so the
/// review step always reflects the latest input and moving back and forward
/// never loses data. Advancing past the identity step is gated on the consent
/// checkbox via [DsOnboardingWizard.nextEnabled]; every other step can always
/// advance. Submitting from the final step swaps the flow for a brief, static
/// success confirmation and invokes [onSubmitted].
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
  });

  /// Called once the user submits the flow from the final step, after the
  /// success confirmation is shown.
  final VoidCallback? onSubmitted;

  /// Called when the user backs out of the very first step.
  ///
  /// [DsOnboardingWizard] surfaces the back action; when the flow is on its
  /// first step there is nothing to go back to, so the callback lets an
  /// embedding screen dismiss or cancel the flow.
  final VoidCallback? onCancel;

  @override
  State<DsBusinessVerification> createState() => _DsBusinessVerificationState();
}

class _DsBusinessVerificationState extends State<DsBusinessVerification> {
  /// Zero-based index of the identity step, whose consent gates advancing.
  static const int _identityStep = 2;

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
  final TextEditingController _address = TextEditingController();
  final TextEditingController _representativeName = TextEditingController();
  final TextEditingController _idNumber = TextEditingController();

  /// Current step index. The flow always starts on step 0.
  int _step = 0;

  /// The selected business type, or `null` while nothing is chosen.
  String? _businessType;

  /// Whether the representative has confirmed they are authorised.
  bool _consent = false;

  /// Whether the flow has been submitted and now shows the success state.
  bool _submitted = false;

  int get _lastStep => _steps.length - 1;

  /// Whether the current step permits advancing. Only the identity step is
  /// gated: on it the consent checkbox must be ticked.
  bool get _canAdvance => _step == _identityStep ? _consent : true;

  @override
  void dispose() {
    _legalName.dispose();
    _registrationNumber.dispose();
    _address.dispose();
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
    } else {
      setState(() => _submitted = true);
      widget.onSubmitted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    if (_submitted) {
      return _SuccessState(tokens: tokens);
    }

    return DsOnboardingWizard(
      title: 'Verify your business',
      steps: _steps,
      currentIndex: _step,
      onBack: _step > 0 ? _handleBack : null,
      onNext: _handleNext,
      nextLabel: _step == _lastStep ? 'Submit' : 'Continue',
      nextEnabled: _canAdvance,
      child: _buildStepBody(tokens),
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
    return DsFormFieldGroup(
      legend: 'Business details',
      description: 'Enter the details exactly as they appear on your official '
          'registration.',
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
        DsTextField(
          label: 'Registered address',
          hintText: 'Street, city and postal code',
          controller: _address,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }

  // Step 2: Verify identity ---------------------------------------------

  Widget _buildIdentityStep() {
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
      _SummaryEntry('Registered address', _valueOrNull(_address.text)),
      _SummaryEntry('Representative', _valueOrNull(_representativeName.text)),
      _SummaryEntry('ID or reference', _valueOrNull(_idNumber.text)),
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
