import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
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
    this.city = '',
    this.region = '',
    this.postalCode = '',
    this.country,
  });

  /// The street line: number and street name.
  final String street;

  /// The optional unit, apartment or building line.
  final String unit;

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
      city.isEmpty &&
      region.isEmpty &&
      postalCode.isEmpty &&
      country == null;

  /// Returns a copy with the given parts replaced.
  DsAddressValue copyWith({
    String? street,
    String? unit,
    String? city,
    String? region,
    String? postalCode,
    String? country,
  }) {
    return DsAddressValue(
      street: street ?? this.street,
      unit: unit ?? this.unit,
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
        other.city == city &&
        other.region == region &&
        other.postalCode == postalCode &&
        other.country == country;
  }

  @override
  int get hashCode =>
      Object.hash(street, unit, city, region, postalCode, country);
}

/// Per-market labels, hints and visibility for a [DsAddressFieldGroup].
///
/// Address conventions differ by market: one calls the region a province,
/// another a state, and some markets do not use unit lines or postal codes at
/// all. This object lets a consumer rename or hide individual fields without
/// touching the group's layout or behaviour.
@immutable
class DsAddressFieldConfig {
  /// Creates an address field configuration. The defaults are neutral
  /// international labels with every field shown.
  const DsAddressFieldConfig({
    this.streetLabel = 'Street address',
    this.streetHint,
    this.unitLabel = 'Unit or building',
    this.unitHint,
    this.cityLabel = 'City',
    this.cityHint,
    this.regionLabel = 'Region',
    this.regionHint,
    this.postalCodeLabel = 'Postal code',
    this.postalCodeHint,
    this.countryLabel = 'Country',
    this.countryHint = 'Select a country',
    this.showUnit = true,
    this.showRegion = true,
    this.showPostalCode = true,
    this.showCountry = true,
  });

  /// The label of the street field.
  final String streetLabel;

  /// Placeholder text for the street field.
  final String? streetHint;

  /// The label of the optional unit field.
  final String unitLabel;

  /// Placeholder text for the unit field.
  final String? unitHint;

  /// The label of the city field.
  final String cityLabel;

  /// Placeholder text for the city field.
  final String? cityHint;

  /// The label of the region field. Rename it to Province or State where the
  /// market expects that word.
  final String regionLabel;

  /// Placeholder text for the region field.
  final String? regionHint;

  /// The label of the postal code field.
  final String postalCodeLabel;

  /// Placeholder text for the postal code field.
  final String? postalCodeHint;

  /// The label of the country select.
  final String countryLabel;

  /// Placeholder text for the country select while nothing is chosen.
  final String? countryHint;

  /// Whether the unit field is rendered. Defaults to true.
  final bool showUnit;

  /// Whether the region field is rendered. Defaults to true.
  final bool showRegion;

  /// Whether the postal code field is rendered. Defaults to true.
  final bool showPostalCode;

  /// Whether the country select is rendered. Also requires a non-empty
  /// country list on the group. Defaults to true.
  final bool showCountry;
}

/// A structured postal address entry block.
///
/// [DsAddressFieldGroup] collects an address as separate, verifiable parts
/// (street, an optional unit line, city, region, postal code and a country
/// select) instead of one free-text line. It composes [DsTextField],
/// [DsSelect] and [DsFormFieldGroup], so it inherits their theming, error
/// styling and responsive stacking: the street lines span the full width and
/// the shorter fields pair up two per row when the group is at least 360dp
/// wide, stacking below that so nothing overflows on a 320dp phone.
///
/// The group is controlled. The caller passes the current [value] and
/// receives every edit through [onChanged] as a new immutable
/// [DsAddressValue]; a null [onChanged] disables every field. Markets rename
/// or hide fields through [config], and the country choices come from
/// [countries]; an empty list hides the country select.
///
/// ```dart
/// DsAddressFieldGroup(
///   value: _address,
///   countries: const [
///     DsSelectOption(value: 'BE', label: 'Belgium'),
///     DsSelectOption(value: 'NL', label: 'Netherlands'),
///   ],
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
  /// hides the country field entirely.
  final List<DsSelectOption<String>> countries;

  /// Labels, hints and field visibility for the market being served.
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
    _city.dispose();
    _region.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  /// The latest value as typed, built from the controllers so it never lags a
  /// keystroke behind.
  DsAddressValue get _current => DsAddressValue(
        street: _street.text,
        unit: _unit.text,
        city: _city.text,
        region: _region.text,
        postalCode: _postalCode.text,
        country: widget.value.country,
      );

  void _notify() => widget.onChanged?.call(_current);

  void _handleCountry(String? country) {
    if (country == null) return;
    widget.onChanged?.call(_current.copyWith(country: country));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final config = widget.config;
    final enabled = widget.enabled && widget.onChanged != null;
    final showCountry = config.showCountry && widget.countries.isNotEmpty;

    final pairedFields = <Widget>[
      DsTextField(
        label: config.cityLabel,
        hintText: config.cityHint,
        controller: _city,
        enabled: enabled,
        onChanged: (_) => _notify(),
      ),
      if (config.showRegion)
        DsTextField(
          label: config.regionLabel,
          hintText: config.regionHint,
          controller: _region,
          enabled: enabled,
          onChanged: (_) => _notify(),
        ),
      if (config.showPostalCode)
        DsTextField(
          label: config.postalCodeLabel,
          hintText: config.postalCodeHint,
          controller: _postalCode,
          enabled: enabled,
          onChanged: (_) => _notify(),
        ),
      if (showCountry)
        DsSelect<String>(
          label: config.countryLabel,
          value: widget.value.country,
          hintText: config.countryHint,
          options: widget.countries,
          enabled: enabled,
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
        SizedBox(height: tokens.spacingUnit * 2),
        DsFormFieldGroup(columns: 2, children: pairedFields),
      ],
    );
  }
}
