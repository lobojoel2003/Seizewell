import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../actions.dart';
import '../theme.dart';
import '../timer/active_seizure_screen.dart';
import '../widgets/app_logo.dart';
import '../widgets/big_start_button.dart';

/// Shown while the diary is locked. The Start button always works, so a
/// caregiver never has to unlock anything during a seizure.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    unawaited(_autoPrompt());
  }

  /// Offers the fingerprint prompt by itself — unless a seizure is being
  /// timed or a launch from the widget/tile is about to open the timer, where
  /// a system dialog would cover the stopwatch.
  Future<void> _autoPrompt() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final s = context.services;
    if (s.lock.overLockScreen || ActiveSeizureScreen.isOpen) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    if (await s.db.activeSeizure() != null) return;
    if (!mounted || ActiveSeizureScreen.isOpen) return;
    await _unlock();
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    final s = context.services;
    setState(() => _authenticating = true);
    try {
      if (s.lock.overLockScreen) {
        final ok = await s.launch.requestDeviceUnlock();
        if (ok) s.lock.leaveLockScreenMode();
        if (!s.settings.appLockEnabled) s.lock.unlock();
        return;
      }
      final ok = await s.auth.authenticate('Unlock your seizure diary');
      if (ok) s.lock.unlock();
    } finally {
      if (mounted) setState(() => _authenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final theme = Theme.of(context);
    final overLock = s.lock.overLockScreen;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<Seizure?>(
          stream: s.db.watchActiveSeizure(),
          builder: (context, snap) {
            final active = snap.data;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const AppLogo(size: 64),
                    const SizedBox(height: 16),
                    Text(
                      overLock ? 'Seizure timer' : 'Seizewell is locked',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      overLock
                          ? 'Opened from the lock screen. Unlock your phone '
                                'to see the diary.'
                          : 'The timer works without unlocking.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    BigStartButton(
                      size: 200,
                      running: active != null,
                      onPressed: () =>
                          startSeizureTimer(s, Navigator.of(context)),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.tonalIcon(
                      onPressed: _authenticating ? null : _unlock,
                      icon: const Icon(Icons.lock_open_rounded),
                      label: Text(overLock ? 'Unlock phone' : 'Unlock diary'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your diary is encrypted on this phone.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: brandViolet,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
