import 'package:flutter/material.dart';
import '../../all.dart';


import 'package:firebase_auth/firebase_auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  static const _loader = Scaffold(body: Center(child: CircularProgressIndicator()));

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) return _loader;
          if (s.data == null) return const LoginScreen();
          return StreamBuilder<UserProfile?>(
            stream: DbService.profile(),
            builder: (_, p) {
              if (p.connectionState == ConnectionState.waiting) return _loader;
              return p.data == null ? const ProfileSetupScreen() : const MainShell();
            },
          );
        },
      );
}
