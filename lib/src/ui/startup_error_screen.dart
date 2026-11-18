import 'package:material_ui/material_ui.dart';

import 'widgets/common.dart';

/// Shown when the encrypted diary cannot be opened, for example because the
/// phone's keystore lost the key after a restore from a device backup.
class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onErase,
  });

  final Object error;
  final VoidCallback onRetry;
  final Future<void> Function() onErase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.lock_clock_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              'Seizewell can’t open your diary',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The diary is encrypted with a key stored in this phone’s '
              'secure keystore, and that key is not available. This can '
              'happen after restoring the phone from a backup.\n\n'
              'If you have a Seizewell backup file, you can erase this copy, '
              'then restore the backup from More → Backup & restore.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              '$error',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () async {
                final ok = await confirm(
                  context,
                  title: 'Erase and start over?',
                  message:
                      'The unreadable diary on this phone will be deleted.',
                  confirmLabel: 'Erase',
                  destructive: true,
                );
                if (ok) await onErase();
              },
              child: const Text('Erase and start over'),
            ),
          ],
        ),
      ),
    );
  }
}
