import 'package:cloud_firestore/cloud_firestore.dart';

/// Only the minimum needed: display name, birth date (for the age check) and consent state.
class UserProfile {
  final String name, consentStatus; // consentStatus: notRequired | none | pending | approved
  final DateTime birthDate;
  UserProfile(this.name, this.birthDate, this.consentStatus);

  int get age {
    final n = DateTime.now();
    var a = n.year - birthDate.year;
    if (n.month < birthDate.month || (n.month == birthDate.month && n.day < birthDate.day)) a--;
    return a;
  }

  bool get isMinor => age < 18;
  bool get restricted => isMinor && consentStatus != 'approved';

  factory UserProfile.fromMap(Map<String, dynamic> m) =>
      UserProfile(m['name'] ?? '', (m['birthDate'] as Timestamp).toDate(), m['consentStatus'] ?? 'none');

  Map<String, dynamic> toMap() =>
      {'name': name, 'birthDate': Timestamp.fromDate(birthDate), 'consentStatus': consentStatus};
}
