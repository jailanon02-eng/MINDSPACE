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
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthGate()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3F8F8A), Color(0xFF8CCFC4), Color(0xFFF6D9C3)]),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .25), shape: BoxShape.circle),
              child: const Icon(Icons.eco, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 22),
            const Text('MindSpace', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 8),
            const Text("Five minutes to feel a little lighter", style: TextStyle(color: Colors.white, fontSize: 15)),
          ]),
        ),
      );
}
