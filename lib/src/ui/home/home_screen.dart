import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../../domain/stats.dart';
import '../actions.dart';
import '../seizure/seizure_editor_screen.dart';
import '../settings/emergency_plan_screen.dart';
import '../settings/privacy_screen.dart';
import '../sleep/sleep_sheet.dart';
import '../theme.dart';
import '../widgets/big_start_button.dart';
import '../widgets/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final theme = Theme.of(context);
    final today = s.clock.now();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seizewell'),
            Text(
              formatDateLong(today),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: Icon(
                Icons.lock_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              label: const Text('On this phone'),
              tooltip: 'Your diary is encrypted and never leaves this phone',
              onPressed: () =>
                  Navigator.of(context).push(PrivacyScreen.route()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<Seizure?>(
        stream: s.db.watchActiveSeizure(),
        builder: (context, activeSnap) {
          final active = activeSnap.data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (active != null) _ActiveBanner(seizure: active),
              const SizedBox(height: 12),
              Center(
                child: BigStartButton(
                  running: active != null,
                  onPressed: () => startSeizureTimer(s, Navigator.of(context)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'One tap starts the clock. Add details later, calmly.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).push(SeizureEditorScreen.route()),
                  icon: const Icon(Icons.edit_calendar_rounded),
                  label: const Text('Log a past seizure'),
                ),
              ),
              const _NeedsDetails(),
              const _Summary(),
              const _RescueAndSleep(),
              const _PlanPrompt(),
            ],
          );
        },
      ),
    );
  }
}

class _ActiveBanner extends StatefulWidget {
  const _ActiveBanner({required this.seizure});
  final Seizure seizure;

  @override
  State<_ActiveBanner> createState() => _ActiveBannerState();
}

class _ActiveBannerState extends State<_ActiveBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final elapsed = s.clock.now().difference(widget.seizure.startedAt);
    return Card(
      color: alertRed,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(20, 6, 12, 6),
        leading: const Icon(Icons.timer_rounded, color: Colors.white),
        title: const Text(
          'Seizure in progress',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          formatStopwatch(elapsed),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFeatures: tabular,
          ),
        ),
        trailing: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: alertRed,
            minimumSize: const Size(80, 44),
          ),
          onPressed: () => openTimer(Navigator.of(context)),
          child: const Text('Open'),
        ),
      ),
    );
  }
}

class _NeedsDetails extends StatelessWidget {
  const _NeedsDetails();

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final theme = Theme.of(context);
    return StreamBuilder<List<SeizureEntry>>(
      stream: s.db.watchNeedingDetails(),
      builder: (context, snap) {
        final list = snap.data ?? const [];
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              list.length == 1
                  ? '1 seizure needs details'
                  : '${list.length} seizures need details',
            ),
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: Column(
                children: [
                  for (final e in list.take(3))
                    ListTile(
                      leading: const Icon(Icons.edit_note_rounded),
                      title: Text(
                        '${formatDayMonth(e.startedAt)}, '
                        '${formatTime(e.startedAt)}',
                      ),
                      subtitle: Text(
                        '${formatDuration(e.duration)}'
                        '${e.seizure.rescueGivenAt != null ? ' · rescue given' : ''}',
                      ),
                      trailing: const Text('Add details'),
                      onTap: () =>
                          Navigator.of(context)
                              .push(SeizureEditorScreen.route(seizureId: e.id)),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final today = s.clock.now();
    return StreamBuilder<List<SeizureEntry>>(
      stream: s.db.watchSeizures(),
      builder: (context, snap) {
        final all = snap.data ?? const <SeizureEntry>[];
        final last = all.isEmpty ? null : all.first;
        final monthStart = DateTime(today.year, today.month);
        final thisMonth = all
            .where((e) => !e.startedAt.isBefore(monthStart))
            .length;
        final free = daysSinceLastSeizure(all, today);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader('At a glance'),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Last seizure',
                    value: last == null ? 'None' : formatDaysAgo(free!),
                    caption: last == null
                        ? 'Nothing logged yet'
                        : '${last.seizure.type.short} · '
                              '${formatDurationShort(last.duration)}',
                    icon: Icons.history_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'This month',
                    value: '$thisMonth',
                    caption: thisMonth == 1 ? 'seizure' : 'seizures',
                    icon: Icons.calendar_month_rounded,
                    highlight: true,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _RescueAndSleep extends StatelessWidget {
  const _RescueAndSleep();

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final now = s.clock.now();
    final today = dateOnly(now);
    return ListenableBuilder(
      listenable: s.settings,
      builder: (context, _) => _build(context, s, now, today),
    );
  }

  Widget _build(
    BuildContext context,
    AppServices s,
    DateTime now,
    DateTime today,
  ) {
    final plan = s.settings.plan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Today'),
        StreamBuilder<SleepLog?>(
          stream: s.db.watchSleepFor(today),
          builder: (context, snap) {
            final log = snap.data;
            return InfoCard(
              icon: Icons.bedtime_rounded,
              iconColor: const Color(0xFF3F6FD8),
              title: log == null
                  ? 'How was last night’s sleep?'
                  : 'Slept ${formatHours(log.hours)} last night',
              body: log == null
                  ? 'Short sleep is a common trigger. It takes five seconds.'
                  : log.quality == null
                  ? null
                  : sleepQualityLabels[log.quality! - 1],
              trailing: log == null
                  ? FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(64, 40),
                      ),
                      onPressed: () => showSleepSheet(context, night: today),
                      child: const Text('Log'),
                    )
                  : null,
              onTap: () => showSleepSheet(context, night: today, existing: log),
            );
          },
        ),
        if (plan.hasRescueMedication) ...[
          const SizedBox(height: 12),
          StreamBuilder<DateTime?>(
            stream: s.db.watchLastRescueDose(),
            builder: (context, snap) {
              final last = snap.data;
              final minGap = plan.minHoursBetweenRescueDoses;
              final next = last != null && minGap != null
                  ? last.add(Duration(hours: minGap))
                  : null;
              final waiting = next != null && next.isAfter(now);
              return InfoCard(
                icon: Icons.medication_rounded,
                iconColor: waiting ? alertRed : null,
                title: plan.rescueMedication,
                body: last == null
                    ? 'No rescue doses logged.'
                    : waiting
                    ? 'Last dose ${formatTime(last)}. Next dose allowed after '
                          '${formatDateTime(next)}.'
                    : 'Last dose ${formatDate(last)} '
                          '(${formatDaysAgo(daysBetween(last, now))}).',
              );
            },
          ),
        ],
      ],
    );
  }
}

class _PlanPrompt extends StatelessWidget {
  const _PlanPrompt();

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    return ListenableBuilder(
      listenable: s.settings,
      builder: (context, _) {
        if (s.settings.plan.isConfigured) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: InfoCard(
            icon: Icons.health_and_safety_rounded,
            iconColor: alertRed,
            title: 'Add your emergency plan',
            body:
                'Rescue medication, who to call and your neurologist’s '
                'steps, shown on the timer when a seizure runs long.',
            onTap: () =>
                Navigator.of(context).push(EmergencyPlanScreen.route()),
          ),
        );
      },
    );
  }
}
