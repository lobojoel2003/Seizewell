import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/brand.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../../domain/stats.dart';
import '../report/report_screen.dart';
import '../widgets/common.dart';
import 'heatmap_calendar.dart';
import 'trend_chart.dart';

const insightRanges = <int, String>{
  30: '30 days',
  90: '3 months',
  180: '6 months',
  365: '1 year',
};

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _days = 90;

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: StreamBuilder<List<SeizureEntry>>(
        stream: s.db.watchSeizures(),
        builder: (context, seizuresSnap) => StreamBuilder<List<SleepLog>>(
          stream: s.db.watchSleep(),
          builder: (context, sleepSnap) =>
              StreamBuilder<List<MedicationChangeEntry>>(
                stream: s.db.watchMedicationChanges(),
                builder: (context, changesSnap) {
                  if (!seizuresSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final range = DateRange.lastDays(_days, s.clock.now());
                  final stats = SeizureStats.compute(
                    range: range,
                    seizures: seizuresSnap.data!,
                    previousPeriod: seizuresSnap.data!,
                    sleep: sleepSnap.data ?? const [],
                    prolongedThreshold: s.settings.plan.alertAfter,
                  );
                  return _content(context, stats, changesSnap.data ?? const []);
                },
              ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    SeizureStats stats,
    List<MedicationChangeEntry> changes,
  ) {
    final theme = Theme.of(context);
    final change = stats.changeVsPrevious;
    String? changeCaption;
    if (change != null) {
      final pct = (change * 100).round();
      changeCaption = pct == 0
          ? 'Same as the period before'
          : '${pct < 0 ? '↓' : '↑'} ${pct.abs()}% vs the period before';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<int>(
            segments: [
              for (final e in insightRanges.entries)
                ButtonSegment(value: e.key, label: Text(e.value)),
            ],
            selected: {_days},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() => _days = v.first),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatRange(stats.range.start, stats.range.lastDay),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            StatTile(
              label: 'Seizures',
              value: '${stats.total}',
              caption: changeCaption ?? '${stats.seizureDays} seizure days',
              highlight: true,
            ),
            StatTile(
              label: 'Per 30 days',
              value: stats.perThirtyDays.toStringAsFixed(1),
              caption: 'average',
            ),
            StatTile(
              label: 'Longest',
              value: formatDurationShort(stats.longest),
              caption: 'median ${formatDurationShort(stats.median)}',
            ),
            StatTile(
              label: 'Seizure-free',
              value: plural(stats.longestSeizureFreeDays, 'day'),
              caption: 'longest stretch',
            ),
            StatTile(
              label: '≥ ${stats.prolongedThreshold.inMinutes} min',
              value: '${stats.prolonged}',
              caption: 'prolonged seizures',
            ),
            StatTile(
              label: 'Rescue doses',
              value: '${stats.rescueDoses}',
              caption: '${stats.emergencyCare} needed emergency care',
            ),
          ],
        ),
        const SectionHeader('Calendar', trailing: HeatLegend()),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HeatmapCalendar(stats: stats),
          ),
        ),
        const SectionHeader('By seizure type'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: stats.byType.isEmpty
                ? const Text('No seizures in this period.')
                : _TypeBars(stats: stats),
          ),
        ),
        SectionHeader(
          stats.bucketDays == 1 ? 'Per day' : 'Per week',
          trailing: Text(
            'with medication changes',
            style: theme.textTheme.labelSmall,
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
            child: TrendChart(stats: stats, changes: changes),
          ),
        ),
        const SectionHeader('Triggers'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: stats.byTrigger.isEmpty
                ? const Text('No triggers recorded in this period.')
                : Column(
                    children: [
                      for (final t in stats.byTrigger.take(8))
                        _BarRow(
                          label: t.name,
                          value: t.count,
                          max: stats.byTrigger.first.count,
                          color: theme.colorScheme.secondary,
                          trailing: '${(t.count / stats.total * 100).round()}%',
                        ),
                    ],
                  ),
          ),
        ),
        const SectionHeader('Sleep'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _SleepInsight(stats: stats),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context)
                  .push(ReportScreen.route(initialDays: _days)),
          icon: const Icon(Icons.picture_as_pdf_rounded),
          label: const Text('Create clinic report'),
        ),
      ],
    );
  }
}

class _TypeBars extends StatelessWidget {
  const _TypeBars({required this.stats});

  final SeizureStats stats;

  @override
  Widget build(BuildContext context) {
    final max = stats.byType.map((t) => t.count).reduce(math.max);
    return Column(
      children: [
        for (final t in stats.byType)
          _BarRow(
            label: t.type.label,
            value: t.count,
            max: max,
            color: Color(Brand.typeColor(t.type)),
            trailing: t.medianDuration == null
                ? null
                : formatDurationShort(t.medianDuration),
          ),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    this.trailing,
  });

  final String label;
  final int value;
  final int max;
  final Color color;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Semantics(
        label: '$label: $value${trailing == null ? '' : ', $trailing'}',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null)
                  Text(
                    trailing!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, c) => Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: math.max(6, (c.maxWidth - 36) * value / max),
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$value',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepInsight extends StatelessWidget {
  const _SleepInsight({required this.stats});

  final SeizureStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sl = stats.sleep;
    if (sl.nightsLogged == 0) {
      return const Text(
        'No sleep logged in this period. Log sleep from the Today screen '
        'to see whether short nights come before seizures.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${formatHours(sl.averageHours!)} average',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '${plural(sl.nightsLogged, 'night')} logged',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (sl.seizuresWithSleepData > 0) ...[
          const SizedBox(height: 12),
          Text(
            '${sl.seizuresAfterShortSleep} of ${sl.seizuresWithSleepData} '
            'seizures came after a night under '
            '${SeizureStats.shortSleepHours.toInt()} hours.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}
