import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../widgets/app_logo.dart';

const repositoryUrl = 'https://github.com/lobojoel2003/Seizewell';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const AboutScreen());

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          const Center(child: AppLogo(size: 88)),
          const SizedBox(height: 16),
          Text(
            'Seizewell',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Version ${s.info.display}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'A private seizure diary for patients and caregivers. Free and '
            'open-source software, licensed under the GNU General Public '
            'License v3.0.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Seizewell is a diary, not a medical device. It does not '
                'diagnose, detect or treat seizures. In an emergency, call '
                'your local emergency number.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.code_rounded),
            title: const Text('Source code'),
            subtitle: const Text('github.com/lobojoel2003/Seizewell'),
            onTap: () => s.platform.openUrl(repositoryUrl),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Report a problem'),
            onTap: () => s.platform.openUrl('$repositoryUrl/issues'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Open-source licences'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Seizewell',
              applicationVersion: s.info.display,
              applicationIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: AppLogo(size: 56),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
