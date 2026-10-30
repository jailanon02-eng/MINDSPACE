import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../all.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfileScreen> {
  final name = TextEditingController(),
      user = TextEditingController(),
      bio = TextEditingController();
  UserProfile? p;
  Uint8List? pic;
  bool discoverable = false, saving = false;

  @override
  void initState() {
    super.initState();
    DbService.profileOnce().then((x) {
      if (!mounted || x == null) return;
      setState(() {
        p = x;
        name.text = x.name;
        user.text = x.username;
        bio.text = x.bio;
        discoverable = x.discoverable;
      });
    });
  }

  void _msg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _pick() async {
    final f = await FilePicker.pickFile(type: FileType.image);
    if (f == null) return;
    final b = await f.readAsBytes();
    if (b.length > 2 * 1024 * 1024) {
      return _msg('Please choose a picture under 2 MB.');
    }
    setState(() => pic = b);
  }

  Future<void> _save() async {
    final u = user.text.trim().toLowerCase();
    if (name.text.trim().isEmpty) return _msg('Please enter a name.');
    if (u.isNotEmpty && !RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(u)) {
      return _msg('Username: 3-20 letters, numbers or _');
    }
    if (discoverable && u.isEmpty) {
      return _msg('Pick a username so friends can find you.');
    }
    setState(() => saving = true);
    try {
      final url = pic == null ? null : await SocialService.uploadAvatar(pic!);
      await SocialService.saveProfile(
        name: name.text.trim(),
        username: u,
        bio: bio.text.trim(),
        discoverable: discoverable && !(p?.isMinor ?? true),
        photoUrl: url,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _msg('$e'.replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? img = pic != null
        ? MemoryImage(pic!)
        : (p?.photoUrl.isNotEmpty ?? false)
        ? NetworkImage(p!.photoUrl)
        : null;
    final minor = p?.isMinor ?? true;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pick,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: kPrimary,
                        backgroundImage: img,
                        child: img == null
                            ? const Icon(
                                Icons.person,
                                size: 56,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: name,
                decoration: fieldDec('Name', Icons.person_outline),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: user,
                decoration: fieldDec(
                  'Username (e.g. calm_fox)',
                  Icons.alternate_email,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: bio,
                maxLines: 3,
                maxLength: 150,
                decoration: fieldDec('Short bio (optional)', Icons.edit_note),
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: kPrimary,
                value: discoverable && !minor,
                onChanged: minor
                    ? null
                    : (v) => setState(() => discoverable = v),
                title: const Text(
                  'Let friends find me by username',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  minor
                      ? 'Friends and sharing are available for ages 18+.'
                      : 'Only your name, username, bio and picture are shown.',
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                saving ? 'Saving...' : 'Save profile',
                onTap: saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
