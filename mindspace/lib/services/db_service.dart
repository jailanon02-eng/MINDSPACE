import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment.dart';

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
}
