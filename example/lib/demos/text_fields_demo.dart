import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Text fields page: a compact sign-in-style form showing a
/// labelled email field with helper text, a masked password field, and a third
/// field parked in its error state so a single captured frame demonstrates
/// both healthy and validation appearances at once.
class TextFieldsDemo extends StatefulWidget {
  const TextFieldsDemo({super.key});

  @override
  State<TextFieldsDemo> createState() => _TextFieldsDemoState();
}

class _TextFieldsDemoState extends State<TextFieldsDemo> {
  // Initialise to a meaningful, pre-filled state so the demo reads as a form
  // mid-use: a valid email, a masked password, and a confirmation field that is
  // deliberately showing a validation error.
  late final TextEditingController _emailController = TextEditingController(
    text: 'jordan@company.com',
  );
  late final TextEditingController _passwordController = TextEditingController(
    text: 'correcthorse',
  );
  late final TextEditingController _confirmController = TextEditingController(
    text: 'correcthorde',
  );

  bool get _passwordsMatch =>
      _confirmController.text == _passwordController.text;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DsTextField(
            label: 'Work email',
            hintText: 'you@company.com',
            helperText: 'Use the address you signed up with.',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(DsIcons.mail),
            controller: _emailController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DsTextField(
            label: 'Password',
            hintText: 'Enter your password',
            obscureText: true,
            prefixIcon: const Icon(DsIcons.lock),
            controller: _passwordController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DsTextField(
            label: 'Confirm password',
            hintText: 'Re-enter your password',
            obscureText: true,
            prefixIcon: const Icon(DsIcons.lock),
            controller: _confirmController,
            errorText: _passwordsMatch ? null : 'Passwords do not match.',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          DsButton(
            label: 'Sign in',
            fullWidth: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
