import 'package:flutter/material.dart';

import '../../all.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with Busy {
  final email = TextEditingController(),
      pass = TextEditingController(),
      confirm = TextEditingController();

  Future<void> _submit() async {
    if (!email.text.contains('@')) return _msg('Enter a valid email.');
    if (pass.text.length < 8) {
      return _msg('Password must be at least 8 characters.');
    }
    if (pass.text != confirm.text) return _msg('Passwords do not match.');
    await run(() => AuthService.register(email.text.trim(), pass.text));
    if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
  }

  void _msg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) => AuthScaffold(
    back: true,
    title: 'Create your account',
    subtitle:
        'Next, we will ask for a few basics. We collect as little as possible.',
    children: [
      GoogleButton(
        onTap: busy
            ? null
            : () async {
                await run(AuthService.google);
                if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
              },
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('or use email', style: TextStyle(color: kMuted)),
        ),
      ),
      TextField(
        controller: email,
        keyboardType: TextInputType.emailAddress,
        decoration: fieldDec('Email', Icons.mail_outline),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: pass,
        obscureText: true,
        decoration: fieldDec('Password (8+ characters)', Icons.lock_outline),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: confirm,
        obscureText: true,
        decoration: fieldDec('Confirm password', Icons.lock_outline),
      ),
      const SizedBox(height: 22),
      PrimaryButton(
        busy ? 'Please wait...' : 'Continue',
        arrow: true,
        onTap: busy ? null : _submit,
      ),
    ],
  );
}
