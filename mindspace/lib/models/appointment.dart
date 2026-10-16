import 'package:cloud_firestore/cloud_firestore.dart';

class Appt {
  final String id, service, time;
  final DateTime date;
  Appt(this.service, this.date, this.time, {this.id = ''});

  factory Appt.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return Appt(m['service'], (m['date'] as Timestamp).toDate(), m['time'], id: d.id);
  }

  Map<String, dynamic> toMap() => {
        'service': service,
        'date': Timestamp.fromDate(date),
        'time': time,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
