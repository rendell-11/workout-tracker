import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'history_screen.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  const WorkoutCompleteScreen({super.key, required this.record, this.fromHistory = false});
  final WorkoutRecord record;

  /// When opened from History, "Done" just goes back instead of home.
  final bool fromHistory;

  @override
  Widget build(BuildContext context) {
    final r = record;
    final nav = Navigator.of(context);

    return Scaffold(
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.red),
                child: const Icon(Icons.check, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            const Text('WORKOUT COMPLETE',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text('${weekdayNames[r.date.weekday - 1]}, ${longDate(r.date)}',
                textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 20),
            DarkCard(
              child: Column(
                children: [
                  _stat(Icons.timer_outlined, 'Duration', formatDuration(r.duration)),
                  _stat(Icons.fitness_center, 'Exercises', '${r.exercises.length}'),
                  _stat(Icons.repeat, 'Sets', '${r.doneSets.length}'),
                  _stat(Icons.tag, 'Total reps', '${r.totalReps}'),
                  _stat(Icons.scale_outlined, 'Total weight', '${fmtNum(r.volume)} kg'),
                  _stat(Icons.local_fire_department_outlined, 'Calories burned', '${r.caloriesBurned} kcal'),
                  _stat(Icons.star_outline, 'Personal records', '${r.personalRecords}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const DarkCard(
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: AppColors.red, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Great work today!', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('Consistency builds results. See you next session.',
                            style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!fromHistory)
              TextButton(
                onPressed: () => nav.push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
                child: const Text('View history'),
              ),
            PrimaryButton('Done', () => fromHistory ? nav.pop() : nav.popUntil((route) => route.isFirst)),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          IconBadge(icon, size: 30),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
