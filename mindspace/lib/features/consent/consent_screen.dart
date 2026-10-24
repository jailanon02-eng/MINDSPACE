import 'package:flutter/material.dart';

import '../../all.dart';

import 'package:file_picker/file_picker.dart';

/// Returns true if the user may use full features; otherwise explains and offers the consent upload.
Future<bool> ensureAccess(BuildContext c) async {
  final p = await DbService.profileOnce();
  if (p == null || !p.restricted) return true;
  if (!c.mounted) return false;
  await showDialog(
    context: c,
    builder: (d) => AlertDialog(
      title: const Text('Parental consent needed'),
      content: Text(
        p.consentStatus == 'pending'
            ? 'Your consent form is being reviewed. This feature unlocks once it is approved.'
            : 'Please upload a signed parental consent form to use this feature.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('Later'),
        ),
        if (p.consentStatus != 'pending')
          FilledButton(
            onPressed: () {
              Navigator.pop(d);
              Navigator.push(
                c,
                MaterialPageRoute(builder: (_) => const ConsentScreen()),
              );
            },
            child: const Text('Upload form'),
          ),
      ],
    ),
  );
  return false;
}

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});
  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool busy = false;

  Future<void> _upload() async {
    final f = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (f == null) return;
    setState(() => busy = true);
    try {
      await DbService.uploadConsent(f.name, await f.readAsBytes());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploaded. We will review it soon.')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please try again.')),
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Parental consent')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.family_restroom, size: 56, color: kPrimary),
          const SizedBox(height: 16),
          Text('We need a parent or guardian to say yes', style: kTitle),
          const SizedBox(height: 10),
          const Text(
            'Because you are under 18, a parent or guardian must sign a consent form. Upload a clear photo or PDF of it. '
            'Until it is approved, you can still browse, but booking and most activities stay locked.',
            style: TextStyle(color: kMuted, height: 1.5),
          ),
          const Spacer(),
          PrimaryButton(
            busy ? 'Uploading...' : 'Choose file (PDF, JPG, PNG)',
            onTap: busy ? null : _upload,
          ),
        ],
      ),
    ),
  );
}
