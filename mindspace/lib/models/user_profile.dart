import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/terms.dart';

class UserProfile {
  final String name,
      firstName,
      lastName,
      consentStatus,
      username,
      bio,
      photoUrl; // name = display name
  final bool discoverable;
  final DateTime birthDate;
  UserProfile(
    this.name,
    this.birthDate,
    this.consentStatus, {
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.bio = '',
    this.photoUrl = '',
    this.discoverable = false,
  });

  int get age {
    final n = DateTime.now();
    var a = n.year - birthDate.year;
    if (n.month < birthDate.month ||
        (n.month == birthDate.month && n.day < birthDate.day))
      a--;
    return a;
  }

  bool get isMinor => age < 18;
  bool get restricted => isMinor && consentStatus != 'approved';
  String get label => username.isNotEmpty ? '@$username' : name;

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    m['name'] ?? '',
    (m['birthDate'] as Timestamp).toDate(),
    m['consentStatus'] ?? 'none',
    firstName: m['firstName'] ?? '',
    lastName: m['lastName'] ?? '',
    username: m['username'] ?? '',
    bio: m['bio'] ?? '',
    photoUrl: m['photoUrl'] ?? '',
    discoverable: m['discoverable'] ?? false,
  );

  /// Written once at sign-up.
  Map<String, dynamic> toMap() => {
    'name': name,
    'firstName': firstName,
    'lastName': lastName,
    'birthDate': Timestamp.fromDate(birthDate),
    'age': age,
    'consentStatus': consentStatus,
    'termsVersion': kTermsVersion,
    'termsAcceptedAt': FieldValue.serverTimestamp(),
  };
}
