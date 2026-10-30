import 'package:flutter/material.dart';

import '../../all.dart';
import '../../core/terms.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final first = TextEditingController(),
      last = TextEditingController(),
      nick = TextEditingController();
  final scroll = ScrollController();
  DateTime? dob;
  bool read = false, agree = false, saving = false;

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (!read &&
          scroll.hasClients &&
          scroll.offset >= scroll.position.maxScrollExtent - 12) {
        setState(() => read = true);
      }
    });
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  int? get age => dob == null ? null : UserProfile('', dob!, '').age;

  Future<void> _pick() async {
    final d = await showDatePicker(
      context: context,
      helpText: 'Date of birth',
      initialDate: DateTime(DateTime.now().year - 18),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => dob = d);
  }

  Future<void> _save() async {
    setState(() => saving = true);
    final p = UserProfile(
      nick.text.trim(),
      dob!,
      age! < 18 ? 'none' : 'notRequired',
      firstName: first.text.trim(),
      lastName: last.text.trim(),
    );
    await DbService.saveProfile(p); // AuthGate moves on automatically
  }

  @override
  Widget build(BuildContext context) {
    final tooYoung = age != null && age! < 13;
    final ok =
        first.text.trim().isNotEmpty &&
        last.text.trim().isNotEmpty &&
        nick.text.trim().isNotEmpty &&
        dob != null &&
        agree &&
        !tooYoung &&
        !saving;
    return AuthScaffold(
      title: 'A little about you',
      subtitle: 'Just what we need to keep you safe. We never ask for medical or diagnosis details.',
      children: [
        TextField(
          controller: first,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.words,
          decoration: fieldDec('First name', Icons.person_outline),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: last,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.words,
          decoration: fieldDec('Last name', Icons.person_outline),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: nick,
          onChanged: (_) => setState(() {}),
          decoration: fieldDec('Display name or nickname', Icons.face_outlined),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 6, left: 4),
          child: Text(
            'This is the name other people will see.',
            style: TextStyle(color: kMuted, fontSize: 12),
          ),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: _pick,
          borderRadius: BorderRadius.circular(14),
          child: InputDecorator(
            decoration: fieldDec('Date of birth', Icons.cake_outlined),
            child: Text(
              dob == null ? 'Date of birth' : fmtDate(dob!),
              style: TextStyle(color: dob == null ? kMuted : kText),
            ),
          ),
        ),
        const SizedBox(height: 14),
        InputDecorator(
          decoration: fieldDec('Age', Icons.numbers),
          child: Text(
            age == null ? 'Filled in from your date of birth' : '$age',
            style: TextStyle(color: age == null ? kMuted : kText),
          ),
        ),
        if (tooYoung)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'MindSpace is for ages 13 and up.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        if (age != null && age! >= 13 && age! < 18)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Since you are under 18, you will need to upload a parental consent form to unlock all features.',
              style: TextStyle(color: kPrimary, height: 1.4),
            ),
          ),
        const SizedBox(height: 22),
        Text('Terms and Conditions', style: kTitle.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          read
              ? 'Thanks for reading all the way through.'
              : 'Please scroll to the bottom to continue.',
          style: TextStyle(color: read ? kPrimary : kMuted, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          height: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: read ? kPrimary : const Color(0xFFCFE0DC),
            ),
          ),
          child: Scrollbar(
            controller: scroll,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.all(14),
              child: const Text(
                kTerms,
                style: TextStyle(fontSize: 13, height: 1.5, color: kText),
              ),
            ),
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: agree,
          activeColor: kPrimary,
          onChanged: read ? (v) => setState(() => agree = v ?? false) : null,
          title: Text(
            'I have read and agree to the Terms and Conditions.',
            style: TextStyle(fontSize: 13, color: read ? kText : kMuted),
          ),
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          saving ? 'Saving...' : 'Get started',
          arrow: true,
          onTap: ok ? _save : null,
        ),
        TextButton(
          onPressed: AuthService.signOut,
          child: const Text('Use a different account'),
        ),
      ],
    );
  }
}
