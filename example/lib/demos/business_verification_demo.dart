import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Business verification page: a `DsBusinessVerification`
/// flow shaped for one market to show the type routing, the province picker,
/// the country read-back, the role select and the brand-soft receipt.
///
/// Everything market-specific lives here in the demo, not the component: the
/// business types, the registered and unregistered copy, the provinces and the
/// roles are all passed in, so the white-label flow stays neutral. It starts
/// deterministically on step 0 with empty fields (no timers, animation or
/// network), so it is screenshot-safe.
class BusinessVerificationDemo extends StatelessWidget {
  const BusinessVerificationDemo({super.key});

  // South African registered entity types, with the two that verify on a
  // personal identifier rather than a registration number called out.
  static const List<DsSelectOption<String>> _types = <DsSelectOption<String>>[
    DsSelectOption<String>(value: 'Sole proprietor', label: 'Sole proprietor'),
    DsSelectOption<String>(
      value: 'Private company (Pty) Ltd',
      label: 'Private company (Pty) Ltd',
    ),
    DsSelectOption<String>(
      value: 'Close corporation (CC)',
      label: 'Close corporation (CC)',
    ),
    DsSelectOption<String>(
      value: 'Non-profit company (NPC)',
      label: 'Non-profit company (NPC)',
    ),
    DsSelectOption<String>(value: 'Partnership', label: 'Partnership'),
  ];

  static const Set<String> _unregistered = {'Sole proprietor', 'Partnership'};

  static const DsBusinessFieldCopy _registered = DsBusinessFieldCopy(
    nameLabel: 'Registered company name',
    nameHint: 'e.g. Acme Logistics (Pty) Ltd',
    nameHelper: 'Exactly as it appears on your CIPC registration.',
    identifierLabel: 'Company registration number (CIPC)',
    identifierHint: '2019/123456/07',
    identifierHelper: 'Find this on your CIPC registration certificate.',
    identifierKeyboardType: TextInputType.number,
    addressLegend: 'Registered company address',
  );

  static const DsBusinessFieldCopy _unregisteredCopy = DsBusinessFieldCopy(
    nameLabel: 'Business name',
    nameHint: 'e.g. Acme Logistics',
    nameHelper: 'The trading name you do business under.',
    identifierLabel: 'South African ID number',
    identifierHint: '8001015009087',
    identifierHelper: 'Sole proprietors verify with an SA ID number instead.',
    identifierKeyboardType: TextInputType.number,
    addressLegend: 'Business address',
  );

  static const List<DsSelectOption<String>> _provinces =
      <DsSelectOption<String>>[
    DsSelectOption<String>(value: 'Eastern Cape', label: 'Eastern Cape'),
    DsSelectOption<String>(value: 'Free State', label: 'Free State'),
    DsSelectOption<String>(value: 'Gauteng', label: 'Gauteng'),
    DsSelectOption<String>(value: 'KwaZulu-Natal', label: 'KwaZulu-Natal'),
    DsSelectOption<String>(value: 'Limpopo', label: 'Limpopo'),
    DsSelectOption<String>(value: 'Mpumalanga', label: 'Mpumalanga'),
    DsSelectOption<String>(value: 'North West', label: 'North West'),
    DsSelectOption<String>(value: 'Northern Cape', label: 'Northern Cape'),
    DsSelectOption<String>(value: 'Western Cape', label: 'Western Cape'),
  ];

  static const List<DsSelectOption<String>> _roles = <DsSelectOption<String>>[
    DsSelectOption<String>(value: 'Director', label: 'Director'),
    DsSelectOption<String>(value: 'Member', label: 'Member'),
    DsSelectOption<String>(
      value: 'Authorised representative',
      label: 'Authorised representative',
    ),
    DsSelectOption<String>(
      value: 'Company secretary',
      label: 'Company secretary',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 640,
      child: DsBusinessVerification(
        onClose: () {},
        businessTypeOptions: _types,
        unregisteredValues: _unregistered,
        registeredCopy: _registered,
        unregisteredCopy: _unregisteredCopy,
        addressConfig: const DsAddressFieldConfig(
          showSuburb: true,
          regionLabel: 'Province',
          postalCodeKeyboardType: TextInputType.number,
        ),
        addressRegionOptions: _provinces,
        addressCountryReadback: 'South Africa',
        roleOptions: _roles,
        roleLabel: 'Your role in the business',
        roleHelperText: "We'll check this against the company's CIPC directors.",
        showReceipt: true,
        receiptContinueLabel: 'Go to dashboard',
        // Verification runs on in the background, so the receipt is a holding
        // state: the brand-soft tone reads as "we're checking", not approved.
        receiptBadgeTone: DsIconBadgeTone.brandSoft,
      ),
    );
  }
}
