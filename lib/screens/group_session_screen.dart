import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'exercise_detail_screen.dart';

/// During a workout: work through one muscle group's exercises.
class GroupSessionScreen extends StatelessWidget {
  const GroupSessionScreen({super.key, required this.weekday, required this.group});
  final int weekday;
  final String group;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final exercises = state.groupPlan(weekday, group).exercises;
    final done = exercises.where((e) => e.completed).length;

    return PageScaffold(
      title: group,
      subtitle: '$done of ${exercises.length} exercises completed',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: exercises.isEmpty ? 0 : done / exercises.length,
              minHeight: 6,
              color: AppColors.red,
              backgroundColor: AppColors.cardAlt,
            ),
          ),
          const SizedBox(height: 16),
          for (final log in exercises)
            DarkCard(
              margin: const EdgeInsets.only(bottom: 10),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ExerciseDetailScreen(log: log, group: group),
              )),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => state.toggleExercise(log),
                    icon: Icon(log.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: log.completed ? AppColors.red : AppColors.muted, size: 28),
                  ),
                  ImagePlaceholder.muscle(group),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.info.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${log.doneSets.length}/${log.sets.length} sets',
                            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
            ),
        ],
      ),
      bottom: PrimaryButton('Finish $group', () => Navigator.of(context).pop()),
    );
  }
}
