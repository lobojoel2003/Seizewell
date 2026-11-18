import 'package:material_ui/material_ui.dart';

import '../widgets/common.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const PrivacyScreen());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget point(IconData icon, String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InfoCard(icon: icon, title: title, body: body),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Your data stays here')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Text(
            'Seizure records are some of the most sensitive health data '
            'there is. Seizewell is built so that nobody but you can read '
            'them.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          point(
            Icons.phone_android_rounded,
            'Only on this phone',
            'There is no account, no server and no cloud sync. The Android '
                'app does not even have permission to use the internet.',
          ),
          point(
            Icons.enhanced_encryption_rounded,
            'Encrypted at rest',
            'The diary is a SQLCipher database encrypted with AES-256. Its '
                'random key is kept in the Android Keystore or iOS Keychain and '
                'never leaves the device.',
          ),
          point(
            Icons.visibility_off_rounded,
            'No tracking',
            'No analytics, no ads, no crash reporting, no third-party SDKs '
                'that phone home.',
          ),
          point(
            Icons.ios_share_rounded,
            'You decide what leaves',
            'Reports, exports and backups are only created when you ask, '
                'and only go where you send them. Backups are encrypted with '
                'your own passphrase.',
          ),
          point(
            Icons.code_rounded,
            'Open source',
            'Seizewell is free software under the GPL-3.0 licence. Anyone '
                'can check that it does what it says.',
          ),
        ],
      ),
    );
  }
}
