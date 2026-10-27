import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _a = FirebaseAuth.instance;
  static Future<void> signIn(String e, String p) => _a.signInWithEmailAndPassword(email: e, password: p);
  static Future<void> register(String e, String p) => _a.createUserWithEmailAndPassword(email: e, password: p);
  static Future<void> google() async {
    final provider = GoogleAuthProvider();
    if (kIsWeb) {
      await _a.signInWithPopup(provider);
    } else {
      await _a.signInWithProvider(provider);
    }
  }
  static Future<void> signOut() => _a.signOut();
}
