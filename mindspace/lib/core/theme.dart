import 'package:flutter/material.dart';

const kPrimary = Color(0xFF5B4FC4);
const kBg = Color(0xFFF7F6FD);
const kText = Color(0xFF2B2A4C);
const kMuted = Color(0xFF7A7A99);

final currentTab = ValueNotifier<int>(0);

const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December'];
String fmtDate(DateTime d) => '${months[d.month - 1].substring(0, 3)} ${d.day}, ${d.year}';
