import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../services/backup_service.dart';
import '../../services/platform_services.dart';
import '../widgets/common.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const BackupScreen());

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _busy = false;

  Future<String?> _askPassphrase({required bool confirmIt}) {
    return showDialog<String>(
      context: context,
      builder: (_) => _PassphraseDialog(confirmIt: confirmIt),
    );
  }

  Future<void> _backup() async {
    final s = context.services;
    final passphrase = await _askPassphrase(confirmIt: true);
    if (passphrase == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final dir = Directory('${(await getTemporaryDirectory()).path}/exports');
      await dir.create(recursive: true);
      final now = s.clock.now();
      final file = await BackupService(s.db)
          .createBackup(passphrase: passphrase, directory: dir, now: now);
      final bytes = await file.readAsBytes();
      await file.delete();
      final shared = await s.platform.shareFiles([
        ShareableFile(
          BackupService.fileNameFor(now),
          bytes,
          'application/octet-stream',
        ),
      ], subject: 'Seizewell encrypted backup');
      if (shared) await s.settings.setLastBackupAt(now);
    } on BackupException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final s = context.services;
    final ok = await confirm(
      context,
      title: 'Restore a backup?',
      message:
          'Everything currently in Seizewell on this phone will be replaced '
          'by the backup.',
      confirmLabel: 'Choose file',
    );
    if (!ok || !mounted) return;
    final picked = await FilePicker.pickFile();
    if (picked == null || !mounted) return;
    final passphrase = await _askPassphrase(confirmIt: false);
    if (passphrase == null || !mounted) return;
    setState(() => _busy = true);
    // The picker may hand back a content URI, so copy the bytes into a
    // private temporary file that SQLCipher can attach.
    final dir = Directory('${(await getTemporaryDirectory()).path}/exports');
    await dir.create(recursive: true);
    final copy = File('${dir.path}/restore.${BackupService.fileExtension}');
    try {
      await copy.writeAsBytes(await picked.readAsBytes(), flush: true);
      final count = await BackupService(s.db)
          .restoreBackup(file: copy, passphrase: passphrase);
      await s.settings.reload();
      if (mounted) {
        showMessage(context, 'Restored ${plural(count, 'seizure')}.');
      }
    } on BackupException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (await copy.exists()) await copy.delete();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = context.services.settings.lastBackupAt;
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            if (_busy) const LinearProgressIndicator(),
            Text(
              'Seizewell never uploads your diary. To move to a new phone or '
              'keep a safe copy, create an encrypted backup file and save it '
              'wherever you like.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              icon: Icons.backup_rounded,
              title: 'Create encrypted backup',
              body: last == null
                  ? 'Protected with a passphrase you choose.'
                  : 'Last backup ${formatDateTime(last)}.',
              onTap: _backup,
            ),
            const SizedBox(height: 12),
            InfoCard(
              icon: Icons.settings_backup_restore_rounded,
              title: 'Restore from backup',
              body: 'Replaces the diary on this phone.',
              onTap: _restore,
            ),
            const SizedBox(height: 20),
            Card(
              color: theme.colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'The backup is a SQLCipher database encrypted with AES-256. '
                  'The key comes from your passphrase, which is never stored. '
                  'If you forget it, the backup cannot be opened by anyone — '
                  'including us.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassphraseDialog extends StatefulWidget {
  const _PassphraseDialog({required this.confirmIt});

  final bool confirmIt;

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.confirmIt) {
      if (_a.text.length < BackupService.minPassphraseLength) {
        setState(
          () => _error =
              'Use at least ${BackupService.minPassphraseLength} characters.',
        );
        return;
      }
      if (_a.text != _b.text) {
        setState(() => _error = 'The passphrases do not match.');
        return;
      }
    }
    Navigator.pop(context, _a.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.confirmIt ? 'Choose a passphrase' : 'Passphrase'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _a,
            autofocus: true,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Passphrase',
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show' : 'Hide',
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (widget.confirmIt) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _b,
              obscureText: _obscure,
              decoration: const InputDecoration(labelText: 'Repeat passphrase'),
              onSubmitted: (_) => _submit(),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Continue')),
      ],
    );
  }
}
