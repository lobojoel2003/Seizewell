import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/brand.dart';
import '../../core/format.dart';
import '../../data/queries.dart';
import '../../domain/stats.dart';
import '../../domain/types.dart';

/// Seizures per day or week, with dashed markers where a medication was
/// started, changed or stopped.
class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.stats, required this.changes});

  final SeizureStats stats;
  final List<MedicationChangeEntry> changes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final buckets = stats.buckets;
    if (buckets.isEmpty) return const SizedBox.shrink();
    final peak = buckets.map((b) => b.count).reduce(math.max);
    final maxY = math.max(2, peak.isOdd ? peak + 1 : peak).toDouble();
    final first = buckets.first.start;
    final inRange =
        changes.where((c) => stats.range.contains(c.change.date)).toList()
          ..sort((a, b) => a.change.date.compareTo(b.change.date));

    double xFor(DateTime d) => daysBetween(first, d) / stats.bucketDays;

    // Which buckets get an x-axis label: month starts for weekly charts,
    // evenly spaced days for daily charts, never closer than [minGap].
    final labelIndexes = <int>{};
    final minGap = math.max(1, (buckets.length / 6).ceil());
    var lastShown = -minGap;
    for (var i = 0; i < buckets.length; i++) {
      final newMonth =
          i == 0 || buckets[i - 1].start.month != buckets[i].start.month;
      final wanted = stats.bucketDays == 1 ? i % minGap == 0 : newMonth;
      if (wanted && i - lastShown >= minGap) {
        labelIndexes.add(i);
        lastShown = i;
      }
    }

    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          child: Semantics(
            label:
                'Chart of seizures per ${stats.bucketDays == 1 ? 'day' : 'week'}'
                ' with ${inRange.length} medication changes marked.',
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (buckets.length - 1).toDouble().clamp(1, double.infinity),
                minY: 0,
                maxY: maxY,
                lineTouchData: const LineTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 2,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: scheme.outlineVariant.withValues(alpha: 0.6),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: maxY / 2,
                      getTitlesWidget: (v, meta) =>
                          Text('${v.round()}', style: labelStyle),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (v, meta) {
                        final i = v.round();
                        if (v != i || !labelIndexes.contains(i)) {
                          return const SizedBox.shrink();
                        }
                        final d = buckets[i].start;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            stats.bucketDays == 1
                                ? DateFormat.MMMd().format(d)
                                : DateFormat.MMM().format(d),
                            style: labelStyle,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  verticalLines: [
                    for (var i = 0; i < inRange.length; i++)
                      VerticalLine(
                        x: xFor(inRange[i].change.date),
                        color: const Color(Brand.amber),
                        strokeWidth: 2,
                        dashArray: [4, 3],
                        label: VerticalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(left: 4, bottom: 2),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFB57600),
                            fontWeight: FontWeight.w800,
                          ),
                          labelResolver: (_) => '${i + 1}',
                        ),
                      ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < buckets.length; i++)
                        FlSpot(i.toDouble(), buckets[i].count.toDouble()),
                    ],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    curveSmoothness: 0.25,
                    color: const Color(Brand.violet),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(Brand.violet).withValues(alpha: 0.28),
                          const Color(Brand.violet).withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (inRange.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var i = 0; i < inRange.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(Brand.amber),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${formatDayMonth(inRange[i].change.date)}  ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: describeChange(inRange[i])),
                        ],
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

String describeChange(MedicationChangeEntry c) {
  final dose = c.change.dose.isEmpty ? '' : ' ${c.change.dose}';
  return switch (c.change.kind) {
    MedicationChangeKind.started => 'Started ${c.medication.name}$dose',
    MedicationChangeKind.doseChanged => '${c.medication.name} changed to$dose',
    MedicationChangeKind.stopped => 'Stopped ${c.medication.name}',
  };
}
