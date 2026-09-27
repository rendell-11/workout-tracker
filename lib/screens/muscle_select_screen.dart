import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/muscle_icon.dart';
import 'day_workout_screen.dart';

class MuscleSelectScreen extends StatefulWidget {
  const MuscleSelectScreen({super.key, required this.weekday, this.popOnConfirm = false});
  final int weekday;

  /// True when opened from the workout screen to edit groups.
  final bool popOnConfirm;

  @override
  State<MuscleSelectScreen> createState() => _MuscleSelectScreenState();
}

class _MuscleSelectScreenState extends State<MuscleSelectScreen> {
  late final Set<String> _selected =
      AppScope.read(context).plans[widget.weekday]!.map((g) => g.group).toSet();

  void _confirm() {
    AppScope.read(context).setGroups(widget.weekday, _selected);
    final nav = Navigator.of(context);
    if (widget.popOnConfirm) {
      nav.pop();
    } else {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => DayWorkoutScreen(weekday: widget.weekday)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: weekdayNames[widget.weekday - 1],
      subtitle: 'Choose your workout split',
      body: GridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        crossAxisCount: 2,
        childAspectRatio: 3.4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          for (final g in muscleGroups) _chip(g),
        ],
      ),
      bottom: PrimaryButton('Confirm workouts', _selected.isEmpty ? null : _confirm),
    );
  }

  Widget _chip(MuscleGroup g) {
    final selected = _selected.contains(g.name);
    return GestureDetector(
      onTap: () => setState(() => selected ? _selected.remove(g.name) : _selected.add(g.name)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.red : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.check_box : Icons.check_box_outline_blank,
                color: selected ? AppColors.red : AppColors.muted, size: 20),
            const SizedBox(width: 6),
            MuscleIcon(g.name,
                size: 30,
                color: selected ? AppColors.red : Colors.white,
                baseColor: AppColors.muted.withValues(alpha: 0.35)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(g.name.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
