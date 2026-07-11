# Address field group

An address field group collects a postal address as separate, verifiable parts instead of one free-text line: street, an optional unit line, city, region, postal code and a country select. `DsAddressFieldGroup` composes `DsTextField`, `DsSelect` and `DsFormFieldGroup`, so the block inherits their theming and stacks to a single column on narrow screens. It is controlled: the caller passes the current `DsAddressValue` and receives every edit through `onChanged` as a new immutable value.

Address conventions differ by market: one calls the region a province, another a state, and some markets skip unit lines or postal codes entirely. `DsAddressFieldConfig` renames or hides individual fields without touching the layout, and the country choices come from a plain option list; an empty list hides the country select. The street lines always span the full width, while the shorter fields pair up two per row once the group is at least 360dp wide.

## Guidelines

**Do**

- Collect the address in parts so each one can be validated and verified on its own.
- Rename fields to the market's own words through the config, such as Province instead of Region.
- Hide the fields a market does not use rather than leaving them blank.
- Keep the value in your own state and pass it back down; the group follows external updates.

**Don't**

- Don't fall back to a single free-text address line; it cannot be verified against a registry.
- Don't mark every field required in copy; flag the optional minority instead (the unit line already is).
- Don't hardcode a country when the market list is known; give the select the real options.

## Example

```dart
DsAddressFieldGroup(
  legend: 'Registered address',
  value: _address,
  countries: const [
    DsSelectOption(value: 'BE', label: 'Belgium'),
    DsSelectOption(value: 'NL', label: 'Netherlands'),
  ],
  config: const DsAddressFieldConfig(regionLabel: 'Province'),
  onChanged: (address) => setState(() => _address = address),
);
```

## See also

- [Form field group](form-field-group.md)
- [Text fields](text-fields.md)
- [Select](select.md)
- [Business verification](business-verification.md)
