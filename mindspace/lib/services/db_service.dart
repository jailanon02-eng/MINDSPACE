import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/appointment.dart';
import '../models/user_profile.dart';

/// Data lives under users/{uid}/appointments and users/{uid}/moods
class DbService {
  static final _db = FirebaseFirestore.instance;
  static DocumentReference<Map<String, dynamic>> get _user =>
      _db.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  static Stream<List<Appt>> appointments() => _user
      .collection('appointments')
      .orderBy('date')
      .snapshots()
      .map((s) => s.docs.map(Appt.fromDoc).toList());

  static Future<void> addAppointment(Appt a) => _user.collection('appointments').add(a.toMap());
  static Future<void> cancel(String id) => _user.collection('appointments').doc(id).delete();

  static Future<void> addMood(String mood, String note) => _user
      .collection('moods')
      .add({'mood': mood, 'note': note, 'createdAt': FieldValue.serverTimestamp()});

  static Stream<UserProfile?> profile() =>
      _user.snapshots().map((d) => d.exists ? UserProfile.fromMap(d.data()!) : null);

  static Future<UserProfile?> profileOnce() async {
    final d = await _user.get();
    return d.exists ? UserProfile.fromMap(d.data()!) : null;
  }

  static Future<void> saveProfile(UserProfile p) => _user.set(p.toMap(), SetOptions(merge: true));

  /// Uploads the parental consent form and marks it pending (a guardian/admin approves it server-side).
  static Future<void> uploadConsent(String fileName, Uint8List bytes) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseStorage.instance.ref('consents/$uid/$fileName').putData(bytes);
    await _user.set({'consentStatus': 'pending', 'consentFile': fileName}, SetOptions(merge: true));
  }
}
