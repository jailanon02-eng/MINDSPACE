import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../all.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hide = true;
  final email = TextEditingController(), pass = TextEditingController();
  Future<void> _go(Future<void> f) async {
    try {
      await f;
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
    } on FirebaseAuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Auth error')));
    }
  }

  InputDecoration _dec(String hint, IconData i, {Widget? suffix}) => InputDecoration(
        hintText: hint, prefixIcon: Icon(i, color: kMuted), suffixIcon: suffix, filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD9D6F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD9D6F0))),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(children: [
                  const Icon(Icons.eco, size: 64, color: kPrimary),
                  const Text('MindSpace', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: kPrimary)),
                  const SizedBox(height: 8),
                  const Text('A safe space for\nyour mental wellness.', textAlign: TextAlign.center, style: TextStyle(color: kMuted)),
                  const SizedBox(height: 40),
                  TextField(controller: email, decoration: _dec('Email or Username', Icons.mail_outline)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: pass,
                    obscureText: hide,
                    decoration: _dec('Password', Icons.lock_outline,
                        suffix: IconButton(icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => hide = !hide))),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton('Log In', onTap: () => _go(AuthService.signIn(email.text.trim(), pass.text))),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('or', style: TextStyle(color: kMuted))),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: kPrimary, side: const BorderSide(color: kPrimary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                      onPressed: () => _go(AuthService.register(email.text.trim(), pass.text)),
                      child: const Text('Create Account'),
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextButton(onPressed: () => _go(AuthService.guest()), child: const Text('Continue as Guest')),
                ]),
              ),
            ),
          ),
        ),
      );
}
