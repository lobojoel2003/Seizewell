import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../seizure/seizure_editor_screen.dart';
import '../theme.dart';
import 'active_seizure_screen.dart';

/// Shown right after "Seizure ended": confirms what was saved and offers to
/// add details now or later.
class SeizureEndedScreen extends StatelessWidget {
  const SeizureEndedScreen({super.key, required this.seizureId});

  final int seizureId;

  static Route<void> route(int id) => PageRouteBuilder<void>(
    fullscreenDialog: true,
    pageBuilder: (_, _, _) => SeizureEndedScreen(seizureId: id),
    transitionsBuilder: (_, a, _, child) =>
        FadeTransition(opacity: a, child: child),
  );

  Future<void> _resume(BuildContext context, Seizure s) async {
    final services = context.services;
    final navigator = Navigator.of(context);
    await services.db.resumeSeizure(s.id);
    final active = await services.db.activeSeizure();
    if (active == null) return;
    unawaited(services.alerts.seizureStarted(active, services.settings.plan));
    await navigator.pushReplacement(ActiveSeizureScreen.route());
  }

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: brandNight,
        body: SafeArea(
          child: FutureBuilder<Seizure>(
            future: services.db.seizureById(seizureId),
            builder: (context, snap) {
              final s = snap.data;
              if (s == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              final duration = s.endedAt!.difference(s.startedAt);
              return ListenableBuilder(
                listenable: services.lock,
                builder: (context, _) {
                  final locked = services.lock.locked;
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFFB9F6CA),
                          size: 72,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Seizure recorded',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatDuration(duration),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFeatures: tabular,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${formatTime(s.startedAt)} – ${formatTime(s.endedAt!)}'
                          '${s.rescueGivenAt != null ? ' · rescue medication given' : ''}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          locked
                              ? 'It is saved. Unlock Seizewell later to add '
                                    'the type, triggers and notes.'
                              : 'Take your time. You can add the type, '
                                    'triggers and notes now or later.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const Spacer(flex: 2),
                        if (!locked)
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: brandDeep,
                              minimumSize: const Size.fromHeight(60),
                            ),
                            onPressed: () => Navigator.of(context)
                                .pushReplacement(
                                  SeizureEditorScreen.route(seizureId: s.id),
                                ),
                            child: const Text('Add details now'),
                          ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            minimumSize: const Size.fromHeight(56),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(locked ? 'Done' : 'Later'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                          onPressed: () => _resume(context, s),
                          child: const Text('Not over — resume the timer'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
