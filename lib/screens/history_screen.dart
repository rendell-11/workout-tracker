import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'workout_complete_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const _tabs = ['All', 'Workouts', 'Food'];
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final start = weekStart;
    final weekWorkouts = state.history.where((r) => !r.date.isBefore(start)).toList();
    final weekFoods = state.foods.where((f) => !f.date.isBefore(start)).toList();

    final showWorkouts = _tab != 2;
    final showFood = _tab != 1;
    final days = <DateTime>{
      if (showWorkouts) for (final r in state.history) DateTime(r.date.year, r.date.month, r.date.day),
      if (showFood) for (final f in state.foods) DateTime(f.date.year, f.date.month, f.date.day),
    }.toList()
      ..sort((a, b) => b.compareTo(a));

    return PageScaffold(
      title: 'History',
      subtitle: 'Your workout and food logs',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _tab == i ? AppColors.red : AppColors.card,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _tab == i ? AppColors.red : AppColors.border),
                      ),
                      child: Text(_tabs[i].toUpperCase(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          DarkCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const IconBadge(Icons.calendar_month),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('THIS WEEK', style: TextStyle(fontWeight: FontWeight.w800)),
                        Text('${shortDate(start)} – ${shortDate(start.add(const Duration(days: 6)))}',
                            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: StatBox('Workouts', '${weekWorkouts.length}')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatBox('Sets', '${weekWorkouts.fold(0, (n, r) => n + r.doneSets.length)}'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: StatBox('Eaten', fmtNum(Macros.of(weekFoods).calories), unit: 'kcal')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (days.isEmpty) const EmptyState('Nothing logged yet.', icon: Icons.history),
          for (final day in days) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Text('${weekdayNames[day.weekday - 1]}, ${longDate(day)}'.toUpperCase(),
                  style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            if (showWorkouts)
              for (final r in state.history.where((r) => sameDay(r.date, day)))
                _entry(
                  Icons.fitness_center,
                  'Workout completed',
                  '${r.groups.map((g) => g.group).join(', ')} • ${formatDuration(r.duration)}',
                  () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => WorkoutCompleteScreen(record: r, fromHistory: true),
                  )),
                ),
            if (showFood && state.foodsOn(day).isNotEmpty)
              _entry(
                Icons.restaurant,
                'Food tracked',
                '${state.foodsOn(day).length} ${state.foodsOn(day).length == 1 ? 'item' : 'items'} • ${fmtNum(Macros.of(state.foodsOn(day)).calories)} kcal',
                null,
              ),
          ],
        ],
      ),
    );
  }

  Widget _entry(IconData icon, String title, String subtitle, VoidCallback? onTap) {
    return DarkCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
