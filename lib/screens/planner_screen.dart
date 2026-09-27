import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'day_screen.dart';
import 'history_screen.dart';

class PlannerTab extends StatelessWidget {
  const PlannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    AppScope.of(context); // rebuild when plans or history change
    return AppBackground(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Weekly', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.1)),
          const Text.rich(
            TextSpan(children: [
              TextSpan(text: 'Workout ', style: TextStyle(color: AppColors.red)),
              TextSpan(text: 'Planner'),
            ]),
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.1),
          ),
          const SizedBox(height: 6),
          const Text('PLAN • TRACK • STAY CONSISTENT',
              style: TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 20),
          const _WeekStrip(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('DAY', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
                child: const Text('HISTORY'),
              ),
            ],
          ),
          for (var wd = 1; wd <= 7; wd++) _DayTile(weekday: wd),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final start = weekStart;
    final today = DateTime.now();
    return DarkCard(
      child: Column(
        children: [
          Text('${monthNames[start.month - 1]} ${start.year}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final date = start.add(Duration(days: i));
              final isToday = sameDay(date, today);
              return Column(
                children: [
                  Text('MTWTFSS'[i], style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday ? AppColors.red : Colors.transparent,
                    ),
                    child: Text('${date.day}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state.workedOutOn(date) ? AppColors.red : Colors.transparent,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.weekday});
  final int weekday;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final date = dateForWeekday(weekday);
    final done = state.workedOutOn(date);
    final isToday = sameDay(date, DateTime.now());
    final count = state.plans[weekday]!.expand((g) => g.exercises).length;

    return DarkCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      highlighted: isToday,
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => DayScreen(weekday: weekday))),
      child: Row(
        children: [
          Icon(done ? Icons.check_box : Icons.check_box_outline_blank,
              color: done ? AppColors.red : AppColors.muted, size: 22),
          const SizedBox(width: 10),
          Text(weekdayNames[weekday - 1].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700)),
          if (isToday)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(4)),
              child: const Text('TODAY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          const Spacer(),
          Text(count == 0 ? 'Tap to plan' : '$count exercises',
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
