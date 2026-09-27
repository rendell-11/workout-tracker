import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Charts of training over time: workouts per week and per-exercise progress.
class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  String? _exercise;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final history = state.history;
    final exercises = _exercisesByFrequency(history);
    final selected = exercises.contains(_exercise) ? _exercise! : exercises.firstOrNull;

    return PageScaffold(
      title: 'Progress',
      subtitle: 'Your training over time',
      showBack: false,
      body: history.isEmpty
          ? const EmptyState('Finish a workout to see your progress here.', icon: Icons.show_chart)
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                Row(
                  children: [
                    Expanded(child: StatBox('Workouts', '${history.length}')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatBox('Lifted', _compact(history.fold(0.0, (v, r) => v + r.volume)), unit: 'kg'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: StatBox('PRs', '${history.fold(0, (n, r) => n + r.personalRecords)}')),
                  ],
                ),
                const SizedBox(height: 14),
                DarkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Workouts per week'),
                      const SizedBox(height: 4),
                      const Text('Last 8 weeks', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      const SizedBox(height: 16),
                      SizedBox(height: 170, child: _WeeklyChart(history)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (selected != null)
                  DarkCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('Exercise progress'),
                        const SizedBox(height: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selected,
                            isExpanded: true,
                            dropdownColor: AppColors.cardAlt,
                            borderRadius: BorderRadius.circular(10),
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                            items: [for (final e in exercises) DropdownMenuItem(value: e, child: Text(e))],
                            onChanged: (v) => setState(() => _exercise = v),
                          ),
                        ),
                        _ExerciseProgress(_sessionsFor(history, selected)),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Exercise names from [history], most-trained first.
List<String> _exercisesByFrequency(List<WorkoutRecord> history) {
  final counts = <String, int>{};
  for (final e in history.expand((r) => r.exercises)) {
    counts.update(e.info.name, (n) => n + 1, ifAbsent: () => 1);
  }
  return counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
}

/// One point per session: the heaviest completed set, or the most reps for
/// bodyweight and timed exercises (logged with no weight).
typedef _Session = ({DateTime date, double value, SetEntry top});

List<_Session> _sessionsFor(List<WorkoutRecord> history, String name) {
  final sessions = <_Session>[];
  for (final r in history.reversed) {
    for (final e in r.exercises.where((e) => e.info.name == name)) {
      final sets = e.doneSets.toList();
      final weighted = sets.any((s) => s.weight > 0);
      final top = sets.reduce((a, b) => weighted
          ? (b.weight > a.weight || (b.weight == a.weight && b.reps > a.reps) ? b : a)
          : (b.reps > a.reps ? b : a));
      sessions.add((date: r.date, value: weighted ? top.weight : top.reps.toDouble(), top: top));
    }
  }
  return sessions;
}

String _compact(double v) =>
    v >= 10000 ? '${fmtNum(double.parse((v / 1000).toStringAsFixed(v >= 100000 ? 0 : 1)))}K' : fmtNum(v);

/// A round axis step giving about four gridlines across [range].
double _niceStep(double range) {
  final raw = max(range, 1) / 4;
  final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
  return [1, 2, 2.5, 5, 10].map((m) => m * magnitude).firstWhere((s) => s >= raw);
}

const _axisStyle = TextStyle(color: AppColors.muted, fontSize: 10);

FlGridData get _grid => FlGridData(
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
    );

Widget _leftTitle(double value, TitleMeta meta) =>
    SideTitleWidget(meta: meta, child: Text(fmtNum(value), style: _axisStyle));

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart(this.history);
  final List<WorkoutRecord> history;

  @override
  Widget build(BuildContext context) {
    final weeks = [for (var i = 7; i >= 0; i--) weekStart.subtract(Duration(days: 7 * i))];
    final counts = [
      for (final start in weeks)
        history.where((r) => !r.date.isBefore(start) && r.date.isBefore(start.add(const Duration(days: 7)))).length,
    ];
    final maxY = counts.fold(0, max).clamp(4, 7).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        gridData: _grid.copyWith(horizontalInterval: 1),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < weeks.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: counts[i].toDouble(),
                width: 18,
                color: AppColors.red,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ]),
        ],
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 24, getTitlesWidget: _leftTitle),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                // Every other week keeps the labels from crowding.
                final label = i.isOdd ? '' : i == weeks.length - 1 ? 'This wk' : shortDate(weeks[i]);
                return SideTitleWidget(meta: meta, child: Text(label, style: _axisStyle));
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.cardAlt,
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              'Week of ${shortDate(weeks[group.x])}\n',
              const TextStyle(color: AppColors.muted, fontSize: 11),
              children: [
                TextSpan(
                  text: '${rod.toY.toInt()} workout${rod.toY == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseProgress extends StatelessWidget {
  const _ExerciseProgress(this.sessions);
  final List<_Session> sessions;

  @override
  Widget build(BuildContext context) {
    final weighted = sessions.any((s) => s.top.weight > 0);
    final unit = weighted ? 'kg' : 'reps';
    final first = sessions.first;
    final last = sessions.last;
    final change = last.value - first.value;
    final values = sessions.map((s) => s.value);
    final lo = values.reduce(min);
    final hi = values.reduce(max);
    final step = _niceStep(hi - lo);
    final minY = max(0.0, (lo / step).floor() * step - step);
    final maxY = (hi / step).ceil() * step + step;
    // Days from the first session, so gaps between sessions show as gaps.
    double x(DateTime d) => d.difference(first.date).inHours / 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(children: [
          TextSpan(text: fmtNum(last.value), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          TextSpan(text: ' $unit', style: const TextStyle(color: AppColors.muted, fontSize: 14)),
        ])),
        Text(
          sessions.length < 2
              ? 'First session ${shortDate(first.date)}'
              : '${change >= 0 ? '+' : ''}${fmtNum(change)} $unit since ${shortDate(first.date)}'
                  ' · ${weighted ? 'heaviest set' : 'best set'} per session',
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: max(1, x(last.date)),
              minY: minY,
              maxY: maxY,
              gridData: _grid.copyWith(horizontalInterval: step),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, interval: step, reservedSize: 36, getTitlesWidget: _leftTitle),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: max(1, x(last.date)),
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                      child: Text(shortDate(value == 0 ? first.date : last.date), style: _axisStyle),
                    ),
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (final s in sessions) FlSpot(x(s.date), s.value)],
                  color: AppColors.red,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  isStrokeJoinRound: true,
                  dotData: FlDotData(
                    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.red,
                      strokeWidth: 2,
                      strokeColor: AppColors.card,
                    ),
                  ),
                  belowBarData: BarAreaData(show: true, color: AppColors.red.withValues(alpha: 0.1)),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.cardAlt,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      LineTooltipItem(
                        '${shortDate(sessions[spot.spotIndex].date)}\n',
                        const TextStyle(color: AppColors.muted, fontSize: 11),
                        children: [
                          TextSpan(
                            text: weighted
                                ? '${fmtNum(sessions[spot.spotIndex].top.weight)} kg × ${sessions[spot.spotIndex].top.reps}'
                                : '${sessions[spot.spotIndex].top.reps} reps',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
