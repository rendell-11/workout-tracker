import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'day_workout_screen.dart';
import 'food_tracker_screen.dart';
import 'muscle_select_screen.dart';

/// Choose between the workout plan and the food tracker for one day.
class DayScreen extends StatelessWidget {
  const DayScreen({super.key, required this.weekday});
  final int weekday;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PageScaffold(
      title: weekdayNames[weekday - 1],
      subtitle: longDate(dateForWeekday(weekday)).toUpperCase(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _BigCard(
            title: 'Workouts',
            subtitle: 'Plan & track your workout',
            icon: Icons.fitness_center,
            colors: const [AppColors.red, AppColors.redDark],
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => state.plans[weekday]!.isEmpty
                  ? MuscleSelectScreen(weekday: weekday)
                  : DayWorkoutScreen(weekday: weekday),
            )),
          ),
          const SizedBox(height: 14),
          _BigCard(
            title: 'Food tracker',
            subtitle: 'Log your meals for the day',
            icon: Icons.restaurant,
            colors: const [AppColors.teal, AppColors.tealDark],
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => FoodTrackerScreen(weekday: weekday),
            )),
          ),
        ],
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  const _BigCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.first.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 44, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
