import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/brand.dart';
import '../../domain/stats.dart';

/// Month grids with each day tinted by its number of seizures.
class HeatmapCalendar extends StatelessWidget {
  const HeatmapCalendar({super.key, required this.stats});

  final SeizureStats stats;

  List<DateTime> get _months {
    final r = stats.range;
    final months = <DateTime>[];
    var m = DateTime(r.start.year, r.start.month);
    final last = DateTime(r.lastDay.year, r.lastDay.month);
    while (!m.isAfter(last)) {
      months.add(m);
      m = DateTime(m.year, m.month + 1);
    }
    return months.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth > 560 ? 3 : 2;
        const gap = 16.0;
        final monthWidth = (constraints.maxWidth - gap * (perRow - 1)) / perRow;
        final cell = math.min(20.0, (monthWidth - 6 * 3) / 7);
        return Semantics(
          label:
              'Calendar: ${stats.total} seizures on ${stats.seizureDays} '
              'days between ${DateFormat.yMMMd().format(stats.range.start)} '
              'and ${DateFormat.yMMMd().format(stats.range.lastDay)}.',
          child: ExcludeSemantics(
            child: Wrap(
              spacing: gap,
              runSpacing: 16,
              children: [
                for (final m in _months)
                  SizedBox(
                    width: monthWidth,
                    child: _Month(
                      month: m,
                      stats: stats,
                      cell: cell,
                      dark: dark,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Month extends StatelessWidget {
  const _Month({
    required this.month,
    required this.stats,
    required this.cell,
    required this.dark,
  });

  final DateTime month;
  final SeizureStats stats;
  final double cell;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lead = DateTime(month.year, month.month).weekday - DateTime.monday;
    final rows = ((lead + daysInMonth) / 7).ceil();
    final emptyColor = dark
        ? theme.colorScheme.surfaceContainerHighest
        : Color(Brand.heat.first);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMM().format(month),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        for (var r = 0; r < rows; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Padding(
                    padding: EdgeInsets.only(right: c < 6 ? 3 : 0),
                    child: _cell(r * 7 + c - lead + 1, daysInMonth, emptyColor),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(int dayNum, int daysInMonth, Color emptyColor) {
    if (dayNum < 1 || dayNum > daysInMonth) {
      return SizedBox(width: cell, height: cell);
    }
    final day = DateTime(month.year, month.month, dayNum);
    final inRange = stats.range.contains(day);
    final count = stats.perDay[day] ?? 0;
    return Container(
      width: cell,
      height: cell,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: !inRange
            ? Colors.transparent
            : count == 0
            ? emptyColor
            : Color(Brand.heatFor(count)),
        border: inRange ? null : Border.all(color: emptyColor, width: 1),
        borderRadius: BorderRadius.circular(cell * 0.22),
      ),
      child: count > 1
          ? Text(
              '$count',
              style: TextStyle(
                fontSize: cell * 0.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}

class HeatLegend extends StatelessWidget {
  const HeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('0', style: style),
        for (final c in Brand.heat)
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              color: Color(c),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        const SizedBox(width: 4),
        Text('3+', style: style),
      ],
    );
  }
}
