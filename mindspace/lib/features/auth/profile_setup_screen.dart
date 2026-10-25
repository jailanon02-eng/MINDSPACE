import 'package:flutter/material.dart';
import '../../all.dart';


class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final name = TextEditingController();
  DateTime? dob;
  bool agree = false, saving = false;

  int? get age => dob == null ? null : UserProfile('', dob!, '').age;

  Future<void> _pick() async {
    final d = await showDatePicker(
        context: context, initialDate: DateTime(DateTime.now().year - 18), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (d != null) setState(() => dob = d);
  }

  Future<void> _save() async {
    setState(() => saving = true);
    final p = UserProfile(name.text.trim(), dob!, age! < 18 ? 'none' : 'notRequired');
    await DbService.saveProfile(p); // AuthGate moves on automatically
  }

  @override
  Widget build(BuildContext context) {
    final tooYoung = age != null && age! < 13;
    final ok = name.text.trim().isNotEmpty && dob != null && agree && !tooYoung && !saving;
    return AuthScaffold(
      title: 'A little about you',
      subtitle: 'Just what we need to keep you safe. We never ask for medical or diagnosis details.',
      children: [
        TextField(controller: name, onChanged: (_) => setState(() {}), textCapitalization: TextCapitalization.words,
            decoration: fieldDec('Display name or nickname', Icons.person_outline)),
        const SizedBox(height: 14),
        InkWell(
          onTap: _pick,
          borderRadius: BorderRadius.circular(14),
          child: InputDecorator(
            decoration: fieldDec('Date of birth', Icons.cake_outlined),
            child: Text(dob == null ? 'Date of birth' : fmtDate(dob!), style: TextStyle(color: dob == null ? kMuted : kText)),
          ),
        ),
        if (tooYoung)
          const Padding(padding: EdgeInsets.only(top: 10), child: Text('MindSpace is for ages 13 and up.', style: TextStyle(color: Colors.red))),
        if (age != null && age! >= 13 && age! < 18)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text('Since you are under 18, you will need to upload a parental consent form to unlock all features.',
                style: TextStyle(color: kPrimary, height: 1.4)),
          ),
        const SizedBox(height: 10),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, value: agree, activeColor: kPrimary,
          onChanged: (v) => setState(() => agree = v ?? false),
          title: const Text('I agree to the Terms of Use and Privacy Policy. MindSpace is a self-care app, not a substitute for professional care.',
              style: TextStyle(fontSize: 13, height: 1.4)),
        ),
        const SizedBox(height: 14),
        PrimaryButton(saving ? 'Saving...' : 'Get started', arrow: true, onTap: ok ? _save : null),
        TextButton(onPressed: AuthService.signOut, child: const Text('Use a different account')),
      ],
    );
  }
}
