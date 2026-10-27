import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String name, consentStatus, username, bio, photoUrl;
  final bool discoverable;
  final DateTime birthDate;
  UserProfile(
    this.name,
    this.birthDate,
    this.consentStatus, {
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
    username: m['username'] ?? '',
    bio: m['bio'] ?? '',
    photoUrl: m['photoUrl'] ?? '',
    discoverable: m['discoverable'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'birthDate': Timestamp.fromDate(birthDate),
    'consentStatus': consentStatus,
  };
}
