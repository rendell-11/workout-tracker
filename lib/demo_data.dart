import 'dart:math';

import 'models.dart';

/// Starting weight (kg) and reps for each demo exercise. Weight 0 means
/// bodyweight or time-based, which progresses by reps instead.
const _start = <String, (double, int)>{
  'Bench Press': (60, 8),
  'Incline Dumbbell Press': (22, 10),
  'Cable Crossover': (15, 12),
  'Tricep Pushdown': (25, 12),
  'Skull Crusher': (25, 10),
  'Deadlift': (100, 5),
  'Lat Pulldown': (55, 10),
  'Seated Cable Row': (50, 10),
  'Barbell Curl': (30, 10),
  'Hammer Curl': (14, 10),
  'Squat': (80, 6),
  'Leg Press': (140, 10),
  'Calf Raise': (60, 15),
  'Plank': (0, 45),
  'Hanging Leg Raise': (0, 10),
  'Overhead Press': (40, 6),
  'Lateral Raise': (8, 15),
  'Face Pull': (20, 15),
  'Chin Up': (0, 6),
  'Curl to Press': (12, 10),
  'Romanian Deadlift': (70, 8),
  'Lying Leg Curl': (35, 12),
  'Hip Thrust': (80, 10),
  'Treadmill Run': (10, 20),
};

/// Weekday -> muscle group -> exercises. Thursday and Sunday are rest days.
const _split = <int, Map<String, List<String>>>{
  1: {
    'Chest': ['Bench Press', 'Incline Dumbbell Press', 'Cable Crossover'],
    'Triceps': ['Tricep Pushdown', 'Skull Crusher'],
  },
  2: {
    'Back': ['Deadlift', 'Lat Pulldown', 'Seated Cable Row'],
    'Biceps': ['Barbell Curl', 'Hammer Curl'],
  },
  3: {
    'Core': ['Plank', 'Hanging Leg Raise'],
    'Legs': ['Squat', 'Leg Press', 'Calf Raise'],
  },
  5: {
    'Shoulders': ['Overhead Press', 'Lateral Raise', 'Face Pull'],
    'Full Arms': ['Chin Up', 'Curl to Press'],
  },
  6: {
    'Hamstrings': ['Romanian Deadlift', 'Lying Leg Curl'],
    'Glutes': ['Hip Thrust'],
    'Cardio': ['Treadmill Run'],
  },
};

const _weeks = 8;

/// Sets for [name] after [week] weeks of steady progress.
List<SetEntry> _sets(String name, int week, {required bool done}) {
  final (weight, reps) = _start[name]!;
  // ~1.5% heavier per week on weighted lifts, rounded to plate-friendly 2.5 kg
  // (1 kg under 20 kg); an extra rep every two weeks on bodyweight moves.
  final step = weight < 20 ? 1.0 : 2.5;
  final w = weight == 0 ? 0.0 : (weight * (1 + 0.015 * week) / step).round() * step;
  final r = weight == 0 ? reps + week ~/ 2 : reps;
  return [for (var i = 0; i < 3; i++) SetEntry(weight: w, reps: r, done: done)];
}

List<GroupPlan> _groups(int weekday, int week, {required bool done}) => [
      // setGroups keeps groups in library order; match it.
      for (final g in muscleGroups.map((m) => m.name).where(_split[weekday]!.containsKey))
        GroupPlan(g, [
          for (final name in _split[weekday]![g]!) ExerciseLog(exerciseNamed(name)!, _sets(name, week, done: done)),
        ]),
    ];

/// Replaces everything in [state] with a sample profile, weekly split, about
/// eight weeks of workout history and a few days of food, so the app can be
/// explored without logging anything first.
void loadDemoData(AppState state, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final random = Random(7);
  const bodyweight = 82.0;

  state.profile = Profile(
    age: 26,
    gender: 'Male',
    heightCm: 178,
    weightKg: bodyweight,
    goals: {Goal.gainMuscle, Goal.improveStrength},
    targetWeightKg: 85,
  );

  state.plans.updateAll((weekday, _) => _split.containsKey(weekday) ? _groups(weekday, _weeks, done: false) : []);

  final best = <String, double>{};
  final history = <WorkoutRecord>[];
  final startOfToday = DateTime(today.year, today.month, today.day);
  final firstMonday = startOfToday.subtract(Duration(days: today.weekday - 1 + 7 * _weeks));
  for (var day = firstMonday; day.isBefore(startOfToday); day = day.add(const Duration(days: 1))) {
    if (!_split.containsKey(day.weekday)) continue;
    // Skip roughly one session in eight, like a real schedule.
    if (random.nextInt(8) == 0) continue;
    final week = day.difference(firstMonday).inDays ~/ 7;
    final groups = _groups(day.weekday, week, done: true);

    var prs = 0;
    for (final e in groups.expand((g) => g.exercises)) {
      final top = e.sets.first.weight;
      final previous = best[e.info.name];
      if (previous != null && top > previous) prs++;
      if (previous == null || top > previous) best[e.info.name] = top;
    }

    final duration = Duration(minutes: 45 + random.nextInt(30));
    history.add(WorkoutRecord(
      date: day.add(Duration(hours: 17 + random.nextInt(3), minutes: random.nextInt(60))),
      duration: duration,
      groups: groups,
      personalRecords: prs,
      caloriesBurned: (5.0 * bodyweight * duration.inMinutes / 60).round(),
    ));
  }
  state.history
    ..clear()
    ..addAll(history.reversed); // newest first

  state.foods.clear();
  for (var daysAgo = 2; daysAgo >= 0; daysAgo--) {
    final date = startOfToday.subtract(Duration(days: daysAgo));
    state.foods.addAll([
      FoodEntry(date: date, meal: MealType.breakfast, name: 'Oatmeal with banana', quantity: '1 bowl',
          calories: 380, protein: 12, carbs: 68, fat: 7),
      FoodEntry(date: date, meal: MealType.lunch, name: 'Chicken breast & rice', quantity: '1 plate',
          calories: 620, protein: 48, carbs: 70, fat: 12),
      FoodEntry(date: date, meal: MealType.snacks, name: 'Protein shake', quantity: '1 scoop',
          calories: 160, protein: 30, carbs: 5, fat: 2),
      if (daysAgo > 0)
        FoodEntry(date: date, meal: MealType.dinner, name: 'Salmon with vegetables', quantity: '1 plate',
            calories: 540, protein: 38, carbs: 22, fat: 30),
    ]);
  }

  state.touch();
}
