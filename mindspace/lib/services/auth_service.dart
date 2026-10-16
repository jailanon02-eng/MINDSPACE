import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _a = FirebaseAuth.instance;
  static Future<void> signIn(String e, String p) => _a.signInWithEmailAndPassword(email: e, password: p);
  static Future<void> register(String e, String p) => _a.createUserWithEmailAndPassword(email: e, password: p);
  static Future<void> guest() => _a.signInAnonymously();
  static Future<void> signOut() => _a.signOut();
}
