import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_field_label.dart';
import 'ds_form_field_group.dart';
import 'ds_select.dart';
import 'ds_text_field.dart';

/// The immutable value a [DsAddressFieldGroup] collects.
///
/// All text parts default to the empty string and [country] to null, so
/// `const DsAddressValue()` is a blank address. [copyWith] produces an updated
/// copy; equality is field-by-field, so a caller can cheaply detect changes.
@immutable
class DsAddressValue {
  /// Creates an address value. Omitted parts are empty.
  const DsAddressValue({
    this.street = '',
    this.unit = '',
    this.suburb = '',
    this.city = '',
    this.region = '',
    this.postalCode = '',
    this.country,
  });

  /// The street line: number and street name.
  final String street;

  /// The optional unit, apartment or building line.
  final String unit;

  /// The suburb or district. A first-class field in markets where the postal
  /// code belongs to the suburb rather than the city. Hidden by default; show
  /// it through [DsAddressFieldConfig.showSuburb].
  final String suburb;

  /// The city or town.
  final String city;

  /// The province, state or region.
  final String region;

  /// The postal or ZIP code.
  final String postalCode;

  /// The selected country value, or null while none is chosen.
  final String? country;

  /// Whether every part of the address is still blank.
  bool get isEmpty =>
      street.isEmpty &&
      unit.isEmpty &&
      suburb.isEmpty &&
      city.isEmpty &&
      region.isEmpty &&
      postalCode.isEmpty &&
      country == null;

  /// Returns a copy with the given parts replaced.
  DsAddressValue copyWith({
    String? street,
    String? unit,
    String? suburb,
    String? city,
    String? region,
    String? postalCode,
    String? country,
  }) {
    return DsAddressValue(
      street: street ?? this.street,
      unit: unit ?? this.unit,
      suburb: suburb ?? this.suburb,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }

  /// The non-empty parts joined with commas, for read-back summaries.
  String format() {
    final parts = <String>[
      if (street.isNotEmpty) street,
      if (unit.isNotEmpty) unit,
      if (suburb.isNotEmpty) suburb,
      if (city.isNotEmpty) city,
      if (region.isNotEmpty) region,
      if (postalCode.isNotEmpty) postalCode,
      if (country != null && country!.isNotEmpty) country!,
    ];
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) {
    return other is DsAddressValue &&
        other.street == street &&
        other.unit == unit &&
        other.suburb == suburb &&
        other.city == city &&
        other.region == region &&
        other.postalCode == postalCode &&
        other.country == country;
  }

  @override
  int get hashCode =>
      Object.hash(street, unit, suburb, city, region, postalCode, country);
}

/// Per-market labels, hints, visibility and validation for a
/// [DsAddressFieldGroup].
///
/// Address conventions differ by market: one calls the region a province,
/// another a state, some carry a suburb the postal code belongs to and some do
/// not use postal codes at all. This object lets a consumer rename, hide or
/// validate individual fields without touching the group's layout or
/// behaviour. Every validator defaults to null, so the group stays lax until a
/// market opts a field into validation.
@immutable
class DsAddressFieldConfig {
  /// Creates an address field configuration. The defaults are neutral
  /// international labels with the optional fields hidden and no validation.
  const DsAddressFieldConfig({
    this.streetLabel = 'Street address',
    this.streetHint,
    this.streetValidator,
    this.unitLabel = 'Unit or building',
    this.unitHint,
    this.suburbLabel = 'Suburb',
    this.suburbHint,
    this.suburbValidator,
    this.cityLabel = 'City',
    this.cityHint,
    this.cityValidator,
    this.regionLabel = 'Region',
    this.regionHint,
    this.regionValidator,
    this.postalCodeLabel = 'Postal code',
    this.postalCodeHint,
    this.postalCodeValidator,
    this.postalCodeKeyboardType,
    this.postalCodeInputFormatters,
    this.countryLabel = 'Country',
    this.countryHint = 'Select a country',
    this.countryValidator,
    this.showUnit = true,
    this.showSuburb = false,
    this.showRegion = true,
    this.showPostalCode = true,
    this.showCountry = true,
  });

  /// The label of the street field.
  final String streetLabel;

  /// Placeholder text for the street field.
  final String? streetHint;

  /// Optional validator for the street field.
  final FormFieldValidator<String>? streetValidator;

  /// The label of the optional unit field.
  final String unitLabel;

  /// Placeholder text for the unit field.
  final String? unitHint;

  /// The label of the suburb field. Shown only when [showSuburb] is true.
  final String suburbLabel;

  /// Placeholder text for the suburb field.
  final String? suburbHint;

  /// Optional validator for the suburb field.
  final FormFieldValidator<String>? suburbValidator;

  /// The label of the city field.
  final String cityLabel;

  /// Placeholder text for the city field.
  final String? cityHint;

  /// Optional validator for the city field.
  final FormFieldValidator<String>? cityValidator;

  /// The label of the region field. Rename it to Province or State where the
  /// market expects that word.
  final String regionLabel;

  /// Placeholder text for the region field. Ignored when the group is given
  /// region options and renders a select instead of a free-text field.
  final String? regionHint;

  /// Optional validator for the region field, applied to the free-text field
  /// or the select alike.
  final FormFieldValidator<String>? regionValidator;

  /// The label of the postal code field.
  final String postalCodeLabel;

  /// Placeholder text for the postal code field.
  final String? postalCodeHint;

  /// Optional validator for the postal code field.
  final FormFieldValidator<String>? postalCodeValidator;

  /// The keyboard type for the postal code field, so a numeric market can
  /// bring up a number pad.
  final TextInputType? postalCodeKeyboardType;

  /// Input formatters for the postal code field, so a market can mask or
  /// bound the entry.
  final List<TextInputFormatter>? postalCodeInputFormatters;

  /// The label of the country select.
  final String countryLabel;

  /// Placeholder text for the country select while nothing is chosen.
  final String? countryHint;

  /// Optional validator for the country select, so a market can make the
  /// country required like the other fields.
  final FormFieldValidator<String>? countryValidator;

  /// Whether the unit field is rendered. Defaults to true.
  final bool showUnit;

  /// Whether the suburb field is rendered. Defaults to false.
  final bool showSuburb;

  /// Whether the region field is rendered. Defaults to true.
  final bool showRegion;

  /// Whether the postal code field is rendered. Defaults to true.
  final bool showPostalCode;

  /// Whether the country select is rendered. Also requires a non-empty country
  /// list on the group, and is superseded by a country read-back line.
  /// Defaults to true.
  final bool showCountry;
}

/// A structured postal address entry block.
///
/// [DsAddressFieldGroup] collects an address as separate, verifiable parts
/// (street, an optional unit line, an optional suburb, city, region, postal
/// code and a country) instead of one free-text line. It composes
/// [DsTextField], [DsSelect] and [DsFormFieldGroup], so it inherits their
/// theming, error styling and responsive stacking: the street lines span the
/// full width and the shorter fields pair up two per row when the group is at
/// least 360dp wide, stacking below that so nothing overflows on a 320dp phone.
///
/// The group is controlled. The caller passes the current [value] and receives
/// every edit through [onChanged] as a new immutable [DsAddressValue]; a null
/// [onChanged] disables every field. Markets rename, hide or validate fields
/// through [config].
///
/// The region can be a free-text field or a fixed list. Pass [regionOptions]
/// and the region becomes a [DsSelect] of those choices (a province picker);
/// leave it empty for a free-text region. The country can be an editable
/// select from [countries], or, when the flow serves one market, a
/// [countryReadback] line that states the country rather than asking for it.
///
/// ```dart
/// DsAddressFieldGroup(
///   value: _address,
///   config: const DsAddressFieldConfig(
///     showSuburb: true,
///     regionLabel: 'Province',
///   ),
///   regionOptions: provinces,
///   countryReadback: 'South Africa',
///   onChanged: (address) => setState(() => _address = address),
/// )
/// ```
class DsAddressFieldGroup extends StatefulWidget {
  /// Creates a structured address entry block.
  const DsAddressFieldGroup({
    super.key,
    this.value = const DsAddressValue(),
    this.onChanged,
    this.countries = const <DsSelectOption<String>>[],
    this.regionOptions = const <DsSelectOption<String>>[],
    this.countryReadback,
    this.config = const DsAddressFieldConfig(),
    this.legend,
    this.description,
    this.enabled = true,
  });

  /// The address being edited. The group seeds its fields from it and follows
  /// external updates, so the caller stays the owner of the state.
  final DsAddressValue value;

  /// Called with a new [DsAddressValue] on every edit. A null callback
  /// disables the whole group.
  final ValueChanged<DsAddressValue>? onChanged;

  /// The choices offered by the country select. An empty list (the default)
  /// hides the country field, unless a [countryReadback] is given.
  final List<DsSelectOption<String>> countries;

  /// The choices offered for the region. When non-empty the region renders as
  /// a [DsSelect] (a province or state picker) instead of a free-text field.
  final List<DsSelectOption<String>> regionOptions;

  /// A fixed country stated as a read-back line rather than asked. When set,
  /// the country select is suppressed and the country is shown as a plain
  /// labelled line, for a flow that serves a single market.
  final String? countryReadback;

  /// Labels, hints, visibility and validation for the market being served.
  final DsAddressFieldConfig config;

  /// Optional heading naming the block, forwarded to the underlying
  /// [DsFormFieldGroup] legend.
  final String? legend;

  /// Optional supporting copy beneath the [legend].
  final String? description;

  /// Whether the fields accept input. Defaults to true.
  final bool enabled;

  @override
  State<DsAddressFieldGroup> createState() => _DsAddressFieldGroupState();
}

class _DsAddressFieldGroupState extends State<DsAddressFieldGroup> {
  late final TextEditingController _street =
      TextEditingController(text: widget.value.street);
  late final TextEditingController _unit =
      TextEditingController(text: widget.value.unit);
  late final TextEditingController _suburb =
      TextEditingController(text: widget.value.suburb);
  late final TextEditingController _city =
      TextEditingController(text: widget.value.city);
  late final TextEditingController _region =
      TextEditingController(text: widget.value.region);
  late final TextEditingController _postalCode =
      TextEditingController(text: widget.value.postalCode);

  @override
  void didUpdateWidget(DsAddressFieldGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == oldWidget.value) return;
    // Follow an external value change without disturbing a field whose text
    // already matches (which would move the caret mid-edit).
    _sync(_street, widget.value.street);
    _sync(_unit, widget.value.unit);
    _sync(_suburb, widget.value.suburb);
    _sync(_city, widget.value.city);
    _sync(_region, widget.value.region);
    _sync(_postalCode, widget.value.postalCode);
  }

  void _sync(TextEditingController controller, String text) {
    if (controller.text != text) controller.text = text;
  }

  @override
  void dispose() {
    _street.dispose();
    _unit.dispose();
    _suburb.dispose();
    _city.dispose();
    _region.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  /// Whether the region is a fixed list (a select) rather than free text.
  bool get _regionIsSelect => widget.regionOptions.isNotEmpty;

  /// The latest value as typed, built from the controllers so it never lags a
  /// keystroke behind. The region comes from the controlled value when it is a
  /// select, and from its controller when it is free text.
  DsAddressValue get _current => DsAddressValue(
        street: _street.text,
        unit: _unit.text,
        suburb: _suburb.text,
        city: _city.text,
        region: _regionIsSelect ? widget.value.region : _region.text,
        postalCode: _postalCode.text,
        // A stated read-back country is part of the collected address, so it
        // rides in the value rather than being display-only.
        country: widget.countryReadback ?? widget.value.country,
      );

  void _notify() => widget.onChanged?.call(_current);

  void _handleCountry(String? country) {
    if (country == null) return;
    widget.onChanged?.call(_current.copyWith(country: country));
  }

  void _handleRegion(String? region) {
    if (region == null) return;
    widget.onChanged?.call(_current.copyWith(region: region));
  }

  /// Autovalidate on interaction only where a validator is actually set, so a
  /// lax field never shows an error path.
  AutovalidateMode? _avm(FormFieldValidator<String>? validator) =>
      validator == null ? null : AutovalidateMode.onUserInteraction;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final config = widget.config;
    final enabled = widget.enabled && widget.onChanged != null;
    final showCountrySelect = widget.countryReadback == null &&
        config.showCountry &&
        widget.countries.isNotEmpty;

    final pairedFields = <Widget>[
      if (config.showSuburb)
        DsTextField(
          label: config.suburbLabel,
          hintText: config.suburbHint,
          controller: _suburb,
          enabled: enabled,
          validator: config.suburbValidator,
          autovalidateMode: _avm(config.suburbValidator),
          onChanged: (_) => _notify(),
        ),
      DsTextField(
        label: config.cityLabel,
        hintText: config.cityHint,
        controller: _city,
        enabled: enabled,
        validator: config.cityValidator,
        autovalidateMode: _avm(config.cityValidator),
        onChanged: (_) => _notify(),
      ),
      if (config.showRegion)
        if (_regionIsSelect)
          DsSelect<String>(
            label: config.regionLabel,
            value: widget.value.region.isEmpty ? null : widget.value.region,
            hintText: config.regionHint,
            options: widget.regionOptions,
            enabled: enabled,
            validator: config.regionValidator,
            autovalidateMode: _avm(config.regionValidator),
            onChanged: _handleRegion,
          )
        else
          DsTextField(
            label: config.regionLabel,
            hintText: config.regionHint,
            controller: _region,
            enabled: enabled,
            validator: config.regionValidator,
            autovalidateMode: _avm(config.regionValidator),
            onChanged: (_) => _notify(),
          ),
      if (config.showPostalCode)
        DsTextField(
          label: config.postalCodeLabel,
          hintText: config.postalCodeHint,
          controller: _postalCode,
          enabled: enabled,
          keyboardType: config.postalCodeKeyboardType,
          inputFormatters: config.postalCodeInputFormatters,
          validator: config.postalCodeValidator,
          autovalidateMode: _avm(config.postalCodeValidator),
          onChanged: (_) => _notify(),
        ),
      if (showCountrySelect)
        DsSelect<String>(
          label: config.countryLabel,
          value: widget.value.country,
          hintText: config.countryHint,
          options: widget.countries,
          enabled: enabled,
          validator: config.countryValidator,
          autovalidateMode: _avm(config.countryValidator),
          onChanged: _handleCountry,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The street lines always span the full width; the shorter parts pair
        // up below when the group is wide enough.
        DsFormFieldGroup(
          legend: widget.legend,
          description: widget.description,
          columns: 1,
          children: <Widget>[
            DsTextField(
              label: config.streetLabel,
              hintText: config.streetHint,
              controller: _street,
              enabled: enabled,
              validator: config.streetValidator,
              autovalidateMode: _avm(config.streetValidator),
              onChanged: (_) => _notify(),
            ),
            if (config.showUnit)
              DsTextField(
                label: config.unitLabel,
                hintText: config.unitHint,
                controller: _unit,
                optional: true,
                enabled: enabled,
                onChanged: (_) => _notify(),
              ),
          ],
        ),
        // A single-market flow states the country once as a read-back line
        // rather than asking for it.
        if (widget.countryReadback != null) ...<Widget>[
          SizedBox(height: tokens.spacingUnit * 2),
          _CountryReadback(
            label: config.countryLabel,
            value: widget.countryReadback!,
          ),
        ],
        SizedBox(height: tokens.spacingUnit * 2),
        DsFormFieldGroup(columns: 2, children: pairedFields),
      ],
    );
  }
}

/// A labelled read-back line stating a fixed country, for a single-market
/// flow that names the country rather than asking for it.
class _CountryReadback extends StatelessWidget {
  const _CountryReadback({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    // Fold the label and value into one read-only field node ("Country:
    // South Africa"), the way a text field folds its label into the control,
    // rather than announcing two loose text nodes.
    return Semantics(
      container: true,
      label: label,
      value: value,
      readOnly: true,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DsFieldLabel(label: label),
            SizedBox(height: tokens.fieldLabelGap),
            Text(
              value,
              style: tokens.bodyMd.toTextStyle(color: tokens.colorText),
            ),
          ],
        ),
      ),
    );
  }
}
