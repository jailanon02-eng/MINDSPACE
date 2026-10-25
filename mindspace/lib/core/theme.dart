import 'package:flutter/material.dart';

// Brand Colors
const kPrimary = Color(0xFF3F8F8A);
const kAccent = Color(0xFFF2A97B);
const kBg = Color(0xFFF3F8F6);
const kText = Color(0xFF1F3B3A);
const kMuted = Color(0xFF6B8280);

// Global Navigation State
final currentTab = ValueNotifier<int>(
  0,
); // 0 Home, 1 Activities, 2 Appointments, 3 Profile

// Crisis Hotline Model & Configuration
class CrisisInfo {
  final String name;
  final String number;
  const CrisisInfo({required this.name, required this.number});
}

const List<CrisisInfo> kCrisisInfo = [
  CrisisInfo(name: 'NCMH Crisis Hotline (Philippines)', number: '1553'),
  CrisisInfo(name: 'Hopeline Philippines', number: '2919'),
  CrisisInfo(name: 'Emergency Services', number: '911'),
];

// Helper Utilities
const months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String fmtDate(DateTime d) =>
    '${months[d.month - 1].substring(0, 3)} ${d.day}, ${d.year}';
