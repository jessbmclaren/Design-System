import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Form field group page: two related groups — a name and
/// contact pair, and a full-width address block — showing the responsive
/// two-column and single-column layouts side by side.
class FormFieldGroupDemo extends StatefulWidget {
  const FormFieldGroupDemo({super.key});

  @override
  State<FormFieldGroupDemo> createState() => _FormFieldGroupDemoState();
}

class _FormFieldGroupDemoState extends State<FormFieldGroupDemo> {
  // Seed the fields so a single captured frame shows meaningful content.
  final _firstName = TextEditingController(text: 'Amara');
  final _lastName = TextEditingController(text: 'Okafor');
  final _email = TextEditingController(text: 'amara@northwind.co');
  final _phone = TextEditingController(text: '+1 555 0142');
  final _street = TextEditingController(text: '48 Harbour View');
  final _city = TextEditingController(text: 'Bristol');
  final _postcode = TextEditingController(text: 'BS1 4TR');
  final _country = TextEditingController(text: 'United Kingdom');

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _street.dispose();
    _city.dispose();
    _postcode.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // A two-column group: short, similar-width fields flow two-per-row.
        DsFormFieldGroup(
          legend: 'Contact details',
          description: 'We only use this to send order updates.',
          children: [
            DsTextField(label: 'First name', controller: _firstName),
            DsTextField(label: 'Last name', controller: _lastName),
            DsTextField(
              label: 'Email',
              hintText: 'you@company.com',
              keyboardType: TextInputType.emailAddress,
              controller: _email,
            ),
            DsTextField(
              label: 'Phone',
              keyboardType: TextInputType.phone,
              controller: _phone,
            ),
          ],
        ),
        const SizedBox(height: 32),
        // A single-column group: full-width fields stay stacked at every size.
        DsFormFieldGroup(
          legend: 'Shipping address',
          description: 'Where should we send your order?',
          columns: 1,
          children: [
            DsTextField(label: 'Street', controller: _street),
            DsTextField(label: 'City', controller: _city),
            DsTextField(label: 'Postal code', controller: _postcode),
            DsTextField(label: 'Country', controller: _country),
          ],
        ),
      ],
    );
  }
}
