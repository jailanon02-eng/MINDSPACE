import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../all.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FirebaseAuth.instance.currentUser == null ? const LoginScreen() : const MainShell()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF6A5FB5), Color(0xFFE88F8A), Color(0xFFF0B27A), Color(0xFF2F3E55)]),
          ),
          child: SafeArea(
            child: Column(children: [
              const Spacer(flex: 3),
              const Icon(Icons.eco, size: 90, color: Colors.white),
              const Text('MindSpace', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 8),
              const Text("You matter. You're not alone.", style: TextStyle(color: Colors.white70)),
              const Spacer(flex: 4),
              SizedBox(width: 50, child: LinearProgressIndicator(minHeight: 4, color: Colors.white,
                  backgroundColor: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 8),
              const Text('Loading...', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      );
}
