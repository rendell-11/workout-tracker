import 'dart:async';

import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'exercise_detail_screen.dart';
import 'exercise_picker_screen.dart';
import 'group_session_screen.dart';
import 'muscle_select_screen.dart';
import 'workout_complete_screen.dart';

/// A day's plan. Before starting it's an editor ("Begin workout");
/// once started it shows a live timer ("Done workout").
class DayWorkoutScreen extends StatefulWidget {
  const DayWorkoutScreen({super.key, required this.weekday});
  final int weekday;

  @override
  State<DayWorkoutScreen> createState() => _DayWorkoutScreenState();
}

class _DayWorkoutScreenState extends State<DayWorkoutScreen> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (AppScope.read(context).activeWeekday == widget.weekday) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  void _finish() {
    final state = AppScope.read(context);
    final anyDone = state.plans[widget.weekday]!.expand((g) => g.exercises).any((e) => e.doneSets.isNotEmpty);
    if (!anyDone) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tick off at least one set before finishing.')));
      return;
    }
    final record = state.finishWorkout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => WorkoutCompleteScreen(record: record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final wd = widget.weekday;
    final groups = state.plans[wd]!;
    final active = state.activeWeekday == wd;
    final otherActive = state.activeWeekday != null && !active;
    final total = groups.expand((g) => g.exercises).length;

    return PageScaffold(
      title: weekdayNames[wd - 1],
      subtitle: active ? 'Workout in progress' : 'Choose exercises for each section',
      actions: [
        if (!active)
          IconButton(
            tooltip: 'Edit muscle groups',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MuscleSelectScreen(weekday: wd, popOnConfirm: true),
            )),
          ),
      ],
      body: groups.isEmpty
          ? const EmptyState('No muscle groups yet. Tap the pencil to pick some.')
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [for (final g in groups) _GroupCard(weekday: wd, plan: g, active: active)],
            ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                formatDuration(DateTime.now().difference(state.startedAt!)),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (otherActive)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Another workout is in progress.', style: TextStyle(color: AppColors.muted)),
            ),
          PrimaryButton(
            active ? 'Done workout' : 'Begin workout',
            active
                ? _finish
                : (otherActive || total == 0)
                    ? null
                    : () => state.startWorkout(wd),
          ),
          if (active)
            TextButton(onPressed: state.cancelWorkout, child: const Text('Cancel workout')),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.weekday, required this.plan, required this.active});
  final int weekday;
  final GroupPlan plan;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final nav = Navigator.of(context);
    final done = plan.exercises.where((e) => e.completed).length;

    return DarkCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: active
                ? () => nav.push(MaterialPageRoute(
                      builder: (_) => GroupSessionScreen(weekday: weekday, group: plan.group),
                    ))
                : null,
            child: Row(
              children: [
                IconBadge.muscle(plan.group),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.group.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(
                        '${plan.exercises.length} exercises${active ? ' • $done done' : ''}',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          for (final log in plan.exercises)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Material(
                color: AppColors.cardAlt,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => nav.push(MaterialPageRoute(
                    builder: (_) => ExerciseDetailScreen(log: log, group: plan.group),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Icon(
                          active
                              ? (log.completed ? Icons.check_circle : Icons.radio_button_unchecked)
                              : Icons.fitness_center,
                          color: active && log.completed ? AppColors.red : AppColors.muted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(log.info.name, style: const TextStyle(fontSize: 13))),
                        Text('${log.sets.length} sets', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                        if (active)
                          const SizedBox(width: 12, height: 44)
                        else
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_horiz, color: AppColors.muted),
                            color: AppColors.cardAlt,
                            onSelected: (_) => state.removeExercise(weekday, plan.group, log),
                            itemBuilder: (_) => const [PopupMenuItem(value: 'remove', child: Text('Remove'))],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (!active)
            TextButton.icon(
              onPressed: () => nav.push(MaterialPageRoute(
                builder: (_) => ExercisePickerScreen(weekday: weekday, group: plan.group),
              )),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add exercise'),
            ),
        ],
      ),
    );
  }
}
