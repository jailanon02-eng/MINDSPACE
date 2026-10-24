import 'package:flutter/material.dart';
import '../../all.dart';

import 'package:firebase_auth/firebase_auth.dart';

InputDecoration fieldDec(String hint, IconData i, {Widget? suffix}) => InputDecoration(
      hintText: hint, prefixIcon: Icon(i, color: kMuted, size: 20), suffixIcon: suffix,
      filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );

mixin Busy<T extends StatefulWidget> on State<T> {
  bool busy = false;
  Future<void> run(Future<void> Function() f) async {
    setState(() => busy = true);
    try {
      await f();
    } on FirebaseAuthException catch (e) {
      if (mounted && !e.code.contains('cancel')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Something went wrong')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class GoogleButton extends StatelessWidget {
  final VoidCallback? onTap;
  const GoogleButton({super.key, this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity, height: 52,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: kText,
              side: const BorderSide(color: Color(0xFFCFE0DC)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
          onPressed: onTap,
          icon: const Text('G', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF4285F4))),
          label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
}

class AuthScaffold extends StatelessWidget {
  final String title, subtitle;
  final List<Widget> children;
  final bool back;
  const AuthScaffold({super.key, required this.title, required this.subtitle, required this.children, this.back = false});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: back ? AppBar() : null,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const CircleAvatar(radius: 28, backgroundColor: kPrimary, child: Icon(Icons.eco, color: Colors.white, size: 30)),
                  const SizedBox(height: 20),
                  Text(title, style: kTitle.copyWith(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: kMuted, height: 1.4)),
                  const SizedBox(height: 28),
                  ...children,
                ]),
              ),
            ),
          ),
        ),
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with Busy {
  final email = TextEditingController(), pass = TextEditingController();
  bool hide = true;

  @override
  Widget build(BuildContext context) => AuthScaffold(
        title: 'Welcome back',
        subtitle: 'A calm place to check in with yourself.',
        children: [
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: fieldDec('Email', Icons.mail_outline)),
          const SizedBox(height: 14),
          TextField(
            controller: pass, obscureText: hide,
            decoration: fieldDec('Password', Icons.lock_outline,
                suffix: IconButton(icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => hide = !hide))),
          ),
          const SizedBox(height: 22),
          PrimaryButton(busy ? 'Please wait...' : 'Log In',
              onTap: busy ? null : () => run(() => AuthService.signIn(email.text.trim(), pass.text))),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: Text('or', style: TextStyle(color: kMuted)))),
          GoogleButton(onTap: busy ? null : () => run(AuthService.google)),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text("New here? Create an account"),
            ),
          ),
        ],
      );
}
