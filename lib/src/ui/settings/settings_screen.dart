import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/settings_store.dart';
import '../report/report_screen.dart';
import '../widgets/common.dart';
import 'about_screen.dart';
import 'backup_screen.dart';
import 'emergency_plan_screen.dart';
import 'export_screen.dart';
import 'privacy_screen.dart';
import 'profile_screen.dart';
import 'triggers_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _toggleLock(BuildContext context, bool on) async {
    final s = context.services;
    if (on) {
      if (!await s.auth.isAvailable()) {
        if (context.mounted) {
          showMessage(
            context,
            'Set up a screen lock or fingerprint on this phone first.',
          );
        }
        return;
      }
      final ok = await s.auth.authenticate('Confirm to turn on the app lock');
      if (!ok) return;
    }
    await s.settings.setAppLockEnabled(on);
  }

  Future<void> _alerts(BuildContext context) async {
    final s = context.services;
    final granted = await s.alerts.requestPermission();
    final precise = await s.alerts.canUsePreciseAlerts();
    if (!context.mounted) return;
    if (!granted) {
      showMessage(
        context,
        'Notifications are off. Turn them on in the phone settings to get '
        'alerts while the timer runs in the background.',
      );
    } else if (!precise) {
      await s.alerts.requestPreciseAlerts();
    } else {
      showMessage(context, 'Alerts are on.');
    }
  }

  Future<void> _deleteAll(BuildContext context) async {
    final s = context.services;
    final ok = await confirm(
      context,
      title: 'Delete everything?',
      message:
          'All seizures, medications, sleep, your emergency plan and '
          'settings will be permanently erased from this phone. This '
          'cannot be undone.',
      confirmLabel: 'Delete everything',
      destructive: true,
    );
    if (!ok) return;
    await s.db.deleteEverything();
    await s.settings.reload();
    if (context.mounted) showMessage(context, 'All data deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListenableBuilder(
        listenable: s.settings,
        builder: (context, _) {
          final st = s.settings;
          Widget tile(
            IconData icon,
            String title, {
            String? subtitle,
            VoidCallback? onTap,
            Widget? trailing,
          }) => ListTile(
            leading: Icon(icon, color: theme.colorScheme.primary),
            title: Text(title),
            subtitle: subtitle == null ? null : Text(subtitle),
            trailing:
                trailing ??
                (onTap == null ? null : const Icon(Icons.chevron_right)),
            onTap: onTap,
          );
          void go(Route<void> r) => Navigator.of(context).push(r);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      st.patientName.isEmpty
                          ? '?'
                          : st.patientName.characters.first.toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(
                    st.patientName.isEmpty
                        ? 'Add patient name'
                        : st.patientName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    st.role.name == 'caregiver'
                        ? 'Logged by a caregiver'
                        : 'Logged by the patient',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => go(ProfileScreen.route()),
                ),
              ),
              const SectionHeader('Care'),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    tile(
                      Icons.health_and_safety_rounded,
                      'Emergency plan',
                      subtitle: st.plan.hasRescueMedication
                          ? '${st.plan.rescueMedication} · warn at '
                                '${formatDuration(st.plan.alertAfter)}'
                          : 'Warn at ${formatDuration(st.plan.alertAfter)}',
                      onTap: () => go(EmergencyPlanScreen.route()),
                    ),
                    tile(
                      Icons.label_rounded,
                      'Triggers',
                      onTap: () => go(TriggersScreen.route()),
                    ),
                    tile(
                      Icons.notifications_active_rounded,
                      'Timer alerts',
                      subtitle: 'Alerts even when the app is in the background',
                      onTap: () => _alerts(context),
                    ),
                  ],
                ),
              ),
              const SectionHeader('Share with your clinic'),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    tile(
                      Icons.picture_as_pdf_rounded,
                      'Clinic report (PDF)',
                      subtitle: 'One page, ${st.paperSize.label}',
                      onTap: () => go(ReportScreen.route()),
                    ),
                    tile(
                      Icons.file_download_rounded,
                      'Export data',
                      subtitle: 'CSV or FHIR',
                      onTap: () => go(ExportScreen.route()),
                    ),
                  ],
                ),
              ),
              const SectionHeader('Privacy & security'),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        Icons.fingerprint_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('App lock'),
                      subtitle: const Text(
                        'The Start button still works while locked',
                      ),
                      value: st.appLockEnabled,
                      onChanged: (v) => _toggleLock(context, v),
                    ),
                    tile(
                      Icons.backup_rounded,
                      'Backup & restore',
                      subtitle: st.lastBackupAt == null
                          ? 'Never backed up'
                          : 'Last backup ${formatDate(st.lastBackupAt!)}',
                      onTap: () => go(BackupScreen.route()),
                    ),
                    tile(
                      Icons.shield_rounded,
                      'How your data is protected',
                      onTap: () => go(PrivacyScreen.route()),
                    ),
                  ],
                ),
              ),
              const SectionHeader('App'),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.dark_mode_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: Text('Theme')),
                          SegmentedButton<AppThemeMode>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(
                                value: AppThemeMode.system,
                                label: Text('Auto'),
                              ),
                              ButtonSegment(
                                value: AppThemeMode.light,
                                label: Text('Light'),
                              ),
                              ButtonSegment(
                                value: AppThemeMode.dark,
                                label: Text('Dark'),
                              ),
                            ],
                            selected: {st.themeMode},
                            onSelectionChanged: (v) => st.setThemeMode(v.first),
                          ),
                        ],
                      ),
                    ),
                    tile(
                      Icons.info_outline_rounded,
                      'About Seizewell',
                      subtitle: 'Version ${s.info.display}',
                      onTap: () => go(AboutScreen.route()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
                onPressed: () => _deleteAll(context),
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Delete all data'),
              ),
            ],
          );
        },
      ),
    );
  }
}
