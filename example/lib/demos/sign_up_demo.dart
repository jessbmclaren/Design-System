import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Sign up page.
///
/// Renders a real [DsSignUpView] with a branded header, a single-column
/// [DsFormFieldGroup] and a benefits [aside]. The fields start pre-filled so the
/// primary action is enabled on the first frame; editing a field re-runs
/// validation via [setState] so the button disables the moment a required field
/// is emptied. No timers, network or overlays — the captured frame is stable.
class SignUpDemo extends StatefulWidget {
  const SignUpDemo({super.key});

  @override
  State<SignUpDemo> createState() => _SignUpDemoState();
}

class _SignUpDemoState extends State<SignUpDemo> {
  final TextEditingController _email =
      TextEditingController(text: 'jordan@northwind.io');
  final TextEditingController _password =
      TextEditingController(text: 'correct-horse-battery');

  bool get _isValid =>
      _email.text.trim().isNotEmpty && _password.text.trim().isNotEmpty;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return DsSignUpView(
      brandIcon: Icons.workspaces_outline,
      brandColor: const Color(0xFF6D28D9),
      title: 'Create your workspace',
      description: 'Start your 14-day trial. No card required.',
      form: DsFormFieldGroup(
        columns: 1,
        children: [
          DsTextField(
            label: 'Work email',
            hintText: 'you@company.com',
            keyboardType: TextInputType.emailAddress,
            controller: _email,
            onChanged: (_) => setState(() {}),
          ),
          DsTextField(
            label: 'Password',
            helperText: 'At least 12 characters.',
            obscureText: true,
            controller: _password,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      primaryActionLabel: 'Create account',
      onSubmit: _isValid ? () {} : null,
      footer: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: DsTypography.bodySm.toTextStyle(
              color: tokens.colorSecondaryText,
            ),
          ),
          InkWell(
            onTap: () {},
            child: Text(
              'Sign in',
              style: DsTypography.labelMd.toTextStyle(
                color: tokens.actionPrimaryColorText,
              ),
            ),
          ),
        ],
      ),
      aside: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Everything in your trial',
            style: DsTypography.labelMd
                .copyWith(fontWeight: DsTypography.semiBold)
                .toTextStyle(color: tokens.colorText),
          ),
          const SizedBox(height: 12),
          _Benefit(text: 'Unlimited projects and members', tokens: tokens),
          _Benefit(text: 'Single sign-on and audit logs', tokens: tokens),
          _Benefit(text: 'Priority support, no card required', tokens: tokens),
        ],
      ),
    );
  }
}

/// A single check-marked benefit row in the sign-up [aside].
class _Benefit extends StatelessWidget {
  const _Benefit({required this.text, required this.tokens});

  final String text;
  final DsTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: tokens.actionPrimaryColorText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: DsTypography.bodySm.toTextStyle(
                color: tokens.colorSecondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
