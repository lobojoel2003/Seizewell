import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../seizure/seizure_editor_screen.dart';
import '../sleep/sleep_sheet.dart';
import '../widgets/common.dart';

enum _Tab { seizures, sleep }

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  _Tab _tab = _Tab.seizures;

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<_Tab>(
                segments: const [
                  ButtonSegment(
                    value: _Tab.seizures,
                    label: Text('Seizures'),
                    icon: Icon(Icons.bolt_rounded),
                  ),
                  ButtonSegment(
                    value: _Tab.sleep,
                    label: Text('Sleep'),
                    icon: Icon(Icons.bedtime_rounded),
                  ),
                ],
                selected: {_tab},
                onSelectionChanged: (v) => setState(() => _tab = v.first),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'diary-fab',
        onPressed: () => _tab == _Tab.seizures
            ? Navigator.of(context).push(SeizureEditorScreen.route())
            : showSleepSheet(context, night: s.clock.now()),
        icon: const Icon(Icons.add),
        label: Text(_tab == _Tab.seizures ? 'Log seizure' : 'Log sleep'),
      ),
      body: _tab == _Tab.seizures ? const _SeizureList() : const _SleepList(),
    );
  }
}

class _SeizureList extends StatelessWidget {
  const _SeizureList();

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    return StreamBuilder<List<SeizureEntry>>(
      stream: s.db.watchSeizures(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snap.data!;
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.menu_book_rounded,
            title: 'No seizures logged',
            message:
                'Use the big Start button when a seizure begins, or log one '
                'that already happened with the button below.',
          );
        }
        final items = <Widget>[];
        DateTime? month;
        for (final e in list) {
          final m = DateTime(e.startedAt.year, e.startedAt.month);
          if (m != month) {
            month = m;
            final count = list
                .where(
                  (x) =>
                      x.startedAt.year == m.year &&
                      x.startedAt.month == m.month,
                )
                .length;
            items.add(
              SectionHeader(
                formatMonthYear(m),
                trailing: Text(
                  plural(count, 'seizure'),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            );
          }
          items.add(_SeizureTile(entry: e));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: items,
        );
      },
    );
  }
}

class _SeizureTile extends StatelessWidget {
  const _SeizureTile({required this.entry});

  final SeizureEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = entry.seizure;
    final scheme = theme.colorScheme;
    final day = DateFormat.E().format(entry.startedAt);
    final badges = <Widget>[
      if (s.rescueGivenAt != null)
        const _Badge(icon: Icons.medication_rounded, label: 'Rescue'),
      if (s.emergencyCare)
        const _Badge(icon: Icons.local_hospital_rounded, label: 'ER'),
      if (s.injury) const _Badge(icon: Icons.healing_rounded, label: 'Injury'),
      if (s.duringSleep)
        const _Badge(icon: Icons.bedtime_rounded, label: 'Asleep'),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              Navigator.of(context)
                  .push(SeizureEditorScreen.route(seizureId: entry.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 44,
                  child: Column(
                    children: [
                      Text(
                        day.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${entry.startedAt.day}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TypeDot(s.type),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.detailsCompleted
                                  ? s.type.label
                                  : 'Needs details',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: s.detailsCompleted
                                    ? null
                                    : scheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatTime(entry.startedAt)} · '
                        '${formatDuration(entry.duration, unknown: 'duration unknown')}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (entry.triggers.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.triggers.map((t) => t.name).join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                      if (badges.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, runSpacing: 4, children: badges),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.onErrorContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepList extends StatelessWidget {
  const _SleepList();

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final theme = Theme.of(context);
    return StreamBuilder<List<SleepLog>>(
      stream: s.db.watchSleep(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snap.data!;
        if (logs.isEmpty) {
          return const EmptyState(
            icon: Icons.bedtime_rounded,
            title: 'No sleep logged',
            message:
                'Short or broken sleep is one of the most common seizure '
                'triggers. Logging it helps you and your neurologist see '
                'the pattern.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: logs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final l = logs[i];
            final short = l.hours < 6;
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
                leading: CircleAvatar(
                  backgroundColor: short
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.bedtime_rounded,
                    color: short
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  formatHours(l.hours),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  [
                    'Night ending ${DateFormat.MMMEd().format(l.night)}',
                    if (l.quality != null) sleepQualityLabels[l.quality! - 1],
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    showSleepSheet(context, night: l.night, existing: l),
              ),
            );
          },
        );
      },
    );
  }
}
