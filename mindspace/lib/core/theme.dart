import 'package:flutter/material.dart';

const kPrimary = Color(0xFF3F8F8A);
const kAccent = Color(0xFFF2A97B);
const kBg = Color(0xFFF3F8F6);
const kText = Color(0xFF1F3B3A);
const kMuted = Color(0xFF6B8280);

/// Fill in your country's crisis lines. Shown in the "Need urgent help?" dialog.
const kCrisisInfo = 'If you are in danger or thinking about hurting yourself, call your local emergency number now.\n\n'
    'TODO: add your country\'s mental-health crisis hotline here.';

final currentTab = ValueNotifier<int>(0); // 0 Home, 1 Activities, 2 Appointments, 3 Profile

const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December'];
String fmtDate(DateTime d) => '${months[d.month - 1].substring(0, 3)} ${d.day}, ${d.year}';
