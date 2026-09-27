import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Profile
// ---------------------------------------------------------------------------

enum Goal {
  loseWeight,
  gainMuscle,
  bulk,
  maintainWeight,
  improveStrength,
  improveEndurance,
  generalFitness,
}

extension GoalInfo on Goal {
  String get label => switch (this) {
        Goal.loseWeight => 'Lose Weight',
        Goal.gainMuscle => 'Gain Muscle',
        Goal.bulk => 'Bulk',
        Goal.maintainWeight => 'Maintain Weight',
        Goal.improveStrength => 'Improve Strength',
        Goal.improveEndurance => 'Improve Endurance',
        Goal.generalFitness => 'General Fitness',
      };
}

class Profile {
  Profile({
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.goals,
    this.targetWeightKg,
  });

  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final Set<Goal> goals;
  final double? targetWeightKg;

  double get bmi => bmiFor(heightCm, weightKg);

  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'goals': [for (final g in goals) g.name],
        'targetWeightKg': targetWeightKg,
      };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        age: j['age'] as int,
        gender: j['gender'] as String,
        heightCm: (j['heightCm'] as num).toDouble(),
        weightKg: (j['weightKg'] as num).toDouble(),
        goals: {for (final g in j['goals'] as List) Goal.values.byName(g as String)},
        targetWeightKg: (j['targetWeightKg'] as num?)?.toDouble(),
      );
}

/// Body-mass index: weight (kg) / height (m)².
double bmiFor(double heightCm, double weightKg) => weightKg / ((heightCm / 100) * (heightCm / 100));

enum BmiCategory { underweight, normal, overweight, obese }

BmiCategory bmiCategory(double bmi) => bmi < 18.5
    ? BmiCategory.underweight
    : bmi < 25
        ? BmiCategory.normal
        : bmi < 30
            ? BmiCategory.overweight
            : BmiCategory.obese;

// ---------------------------------------------------------------------------
// Exercise library
// ---------------------------------------------------------------------------

class MuscleGroup {
  const MuscleGroup(this.name);
  final String name;
}

const muscleGroups = <MuscleGroup>[
  MuscleGroup('Chest'),
  MuscleGroup('Back'),
  MuscleGroup('Shoulders'),
  MuscleGroup('Triceps'),
  MuscleGroup('Biceps'),
  MuscleGroup('Forearms'),
  MuscleGroup('Full Arms'),
  MuscleGroup('Core'),
  MuscleGroup('Hamstrings'),
  MuscleGroup('Glutes'),
  MuscleGroup('Legs'),
  MuscleGroup('Cardio'),
];

class ExerciseInfo {
  const ExerciseInfo(this.name, this.group, this.equipment, this.description, this.targets);
  final String name;
  final String group;
  final String equipment;
  final String description;
  final String targets;
}

ExerciseInfo? exerciseNamed(String name) => _exercisesByName[name];
final _exercisesByName = {for (final e in exerciseLibrary) e.name: e};

const exerciseLibrary = <ExerciseInfo>[
  // Chest
  ExerciseInfo('Bench Press', 'Chest', 'Barbell', 'Lie flat, lower the bar to mid-chest, then press to lockout.', 'Chest, shoulders, triceps'),
  ExerciseInfo('Incline Bench Press', 'Chest', 'Barbell', 'Press from a 30–45° incline to bias the upper chest.', 'Upper chest, shoulders'),
  ExerciseInfo('Dumbbell Press', 'Chest', 'Dumbbell', 'Press dumbbells from chest level, bringing them together at the top.', 'Chest, triceps'),
  ExerciseInfo('Incline Dumbbell Press', 'Chest', 'Dumbbell', 'Dumbbell press on an incline bench.', 'Upper chest, shoulders'),
  ExerciseInfo('Dumbbell Fly', 'Chest', 'Dumbbell', 'With a soft elbow bend, open the arms wide and squeeze back up.', 'Chest'),
  ExerciseInfo('Cable Crossover', 'Chest', 'Cable', 'From high pulleys, sweep the handles down and together.', 'Lower chest'),
  ExerciseInfo('Low Cable Fly', 'Chest', 'Cable', 'From low pulleys, sweep the handles up to chest height.', 'Upper chest'),
  ExerciseInfo('Push Up', 'Chest', 'Bodyweight', 'Keep a straight body and lower your chest to the floor.', 'Chest, triceps, core'),
  // Back
  ExerciseInfo('Deadlift', 'Back', 'Barbell', 'Hinge at the hips and stand up with the bar close to your legs.', 'Back, glutes, hamstrings'),
  ExerciseInfo('Barbell Row', 'Back', 'Barbell', 'Hinge forward and row the bar to your lower ribs.', 'Lats, upper back'),
  ExerciseInfo('One-Arm Dumbbell Row', 'Back', 'Dumbbell', 'Brace on a bench and row the dumbbell to your hip.', 'Lats'),
  ExerciseInfo('Lat Pulldown', 'Back', 'Cable', 'Pull the bar to your upper chest, leading with the elbows.', 'Lats, biceps'),
  ExerciseInfo('Seated Cable Row', 'Back', 'Cable', 'Row the handle to your stomach while keeping your chest tall.', 'Mid back, lats'),
  ExerciseInfo('Pull Up', 'Back', 'Bodyweight', 'Hang from a bar and pull your chin over it.', 'Lats, biceps'),
  // Shoulders
  ExerciseInfo('Overhead Press', 'Shoulders', 'Barbell', 'Press the bar from your collarbone to overhead.', 'Front delts, triceps'),
  ExerciseInfo('Dumbbell Shoulder Press', 'Shoulders', 'Dumbbell', 'Seated or standing, press dumbbells overhead.', 'Delts'),
  ExerciseInfo('Lateral Raise', 'Shoulders', 'Dumbbell', 'Raise dumbbells out to the side to shoulder height.', 'Side delts'),
  ExerciseInfo('Rear Delt Fly', 'Shoulders', 'Dumbbell', 'Bent over, raise dumbbells out to the sides.', 'Rear delts'),
  ExerciseInfo('Face Pull', 'Shoulders', 'Cable', 'Pull a rope towards your face, elbows high.', 'Rear delts, upper back'),
  // Triceps
  ExerciseInfo('Tricep Pushdown', 'Triceps', 'Cable', 'Keep elbows pinned and push the bar down to lockout.', 'Triceps'),
  ExerciseInfo('Skull Crusher', 'Triceps', 'Barbell', 'Lying down, lower the bar towards your forehead and extend.', 'Triceps'),
  ExerciseInfo('Overhead Dumbbell Extension', 'Triceps', 'Dumbbell', 'Lower a dumbbell behind your head and extend.', 'Triceps long head'),
  ExerciseInfo('Dips', 'Triceps', 'Bodyweight', 'Lower between parallel bars and press back up.', 'Triceps, chest'),
  // Biceps
  ExerciseInfo('Barbell Curl', 'Biceps', 'Barbell', 'Curl the bar up without swinging your torso.', 'Biceps'),
  ExerciseInfo('Dumbbell Curl', 'Biceps', 'Dumbbell', 'Curl dumbbells with palms facing up.', 'Biceps'),
  ExerciseInfo('Hammer Curl', 'Biceps', 'Dumbbell', 'Curl with palms facing each other.', 'Biceps, brachialis'),
  ExerciseInfo('Cable Curl', 'Biceps', 'Cable', 'Curl a bar attached to a low pulley.', 'Biceps'),
  // Forearms
  ExerciseInfo('Wrist Curl', 'Forearms', 'Dumbbell', 'Forearms on your thighs, curl the weight with your wrists.', 'Forearm flexors'),
  ExerciseInfo('Reverse Curl', 'Forearms', 'Barbell', 'Curl the bar with an overhand grip.', 'Forearms, brachialis'),
  ExerciseInfo("Farmer's Walk", 'Forearms', 'Dumbbell', 'Walk while holding heavy dumbbells at your sides.', 'Grip, traps, core'),
  // Full arms
  ExerciseInfo('Close-Grip Bench Press', 'Full Arms', 'Barbell', 'Bench press with hands shoulder-width apart.', 'Triceps, chest'),
  ExerciseInfo('Chin Up', 'Full Arms', 'Bodyweight', 'Pull up with palms facing you.', 'Biceps, lats'),
  ExerciseInfo('Curl to Press', 'Full Arms', 'Dumbbell', 'Curl the dumbbells, then press them overhead.', 'Biceps, shoulders, triceps'),
  // Core
  ExerciseInfo('Plank', 'Core', 'Bodyweight', 'Hold a straight line from head to heels. Log seconds as reps.', 'Abs, core'),
  ExerciseInfo('Hanging Leg Raise', 'Core', 'Bodyweight', 'Hang from a bar and raise your legs to hip height.', 'Lower abs'),
  ExerciseInfo('Cable Crunch', 'Core', 'Cable', 'Kneel and crunch a rope down towards your knees.', 'Abs'),
  ExerciseInfo('Russian Twist', 'Core', 'Dumbbell', 'Seated, rotate a weight from side to side.', 'Obliques'),
  // Hamstrings
  ExerciseInfo('Romanian Deadlift', 'Hamstrings', 'Barbell', 'Hinge with soft knees until you feel a hamstring stretch.', 'Hamstrings, glutes'),
  ExerciseInfo('Lying Leg Curl', 'Hamstrings', 'Machine', 'Curl the pad towards your glutes.', 'Hamstrings'),
  ExerciseInfo('Good Morning', 'Hamstrings', 'Barbell', 'Bar on your back, hinge forward at the hips.', 'Hamstrings, lower back'),
  // Glutes
  ExerciseInfo('Hip Thrust', 'Glutes', 'Barbell', 'Back on a bench, drive your hips up with the bar across them.', 'Glutes'),
  ExerciseInfo('Cable Kickback', 'Glutes', 'Cable', 'Kick one leg back against the cable.', 'Glutes'),
  ExerciseInfo('Bulgarian Split Squat', 'Glutes', 'Dumbbell', 'Rear foot on a bench, squat down on the front leg.', 'Glutes, quads'),
  // Legs
  ExerciseInfo('Squat', 'Legs', 'Barbell', 'Bar on your back, squat to at least parallel.', 'Quads, glutes'),
  ExerciseInfo('Leg Press', 'Legs', 'Machine', 'Press the platform away without locking your knees.', 'Quads, glutes'),
  ExerciseInfo('Walking Lunge', 'Legs', 'Dumbbell', 'Step forward into a lunge, alternating legs.', 'Quads, glutes'),
  ExerciseInfo('Leg Extension', 'Legs', 'Machine', 'Extend your knees against the pad.', 'Quads'),
  ExerciseInfo('Calf Raise', 'Legs', 'Machine', 'Rise onto your toes and lower slowly.', 'Calves'),
  // Cardio
  ExerciseInfo('Treadmill Run', 'Cardio', 'Machine', 'Log speed as weight and minutes as reps.', 'Heart, legs'),
  ExerciseInfo('Stationary Bike', 'Cardio', 'Machine', 'Log resistance as weight and minutes as reps.', 'Heart, legs'),
  ExerciseInfo('Rowing Machine', 'Cardio', 'Machine', 'Log minutes as reps.', 'Heart, back, legs'),
  ExerciseInfo('Jump Rope', 'Cardio', 'Bodyweight', 'Log minutes as reps.', 'Heart, calves'),
];

// ---------------------------------------------------------------------------
// Workout plans and records
// ---------------------------------------------------------------------------

class SetEntry {
  SetEntry({this.weight = 0, this.reps = 0, this.done = false});
  double weight;
  int reps;
  bool done;

  SetEntry copy() => SetEntry(weight: weight, reps: reps, done: done);

  Map<String, dynamic> toJson() => {'weight': weight, 'reps': reps, 'done': done};

  factory SetEntry.fromJson(Object j) => switch (j) {
        // Plans saved before history was persisted stored sets as [weight, reps].
        [final num w, final int r] => SetEntry(weight: w.toDouble(), reps: r),
        Map() => SetEntry(
            weight: (j['weight'] as num).toDouble(),
            reps: j['reps'] as int,
            done: j['done'] as bool? ?? false,
          ),
        _ => throw FormatException('Bad set: $j'),
      };
}

class ExerciseLog {
  ExerciseLog(this.info, [List<SetEntry>? sets]) : sets = sets ?? [SetEntry()];
  final ExerciseInfo info;
  final List<SetEntry> sets;

  bool get completed => sets.isNotEmpty && sets.every((s) => s.done);
  Iterable<SetEntry> get doneSets => sets.where((s) => s.done);

  ExerciseLog copy() => ExerciseLog(info, sets.map((s) => s.copy()).toList());

  Map<String, dynamic> toJson() => {'name': info.name, 'sets': [for (final s in sets) s.toJson()]};

  /// Null when the exercise is no longer in the library.
  static ExerciseLog? fromJson(Map<String, dynamic> j) {
    final info = exerciseNamed(j['name'] as String);
    if (info == null) return null;
    return ExerciseLog(info, [for (final s in j['sets'] as List) SetEntry.fromJson(s as Object)]);
  }
}

class GroupPlan {
  GroupPlan(this.group, [List<ExerciseLog>? exercises]) : exercises = exercises ?? [];
  final String group;
  final List<ExerciseLog> exercises;

  GroupPlan copy() => GroupPlan(group, exercises.map((e) => e.copy()).toList());

  Map<String, dynamic> toJson() => {'group': group, 'exercises': [for (final e in exercises) e.toJson()]};

  factory GroupPlan.fromJson(Map<String, dynamic> j) => GroupPlan(j['group'] as String, [
        for (final e in j['exercises'] as List)
          if (ExerciseLog.fromJson(e as Map<String, dynamic>) case final log?) log,
      ]);
}

class WorkoutRecord {
  WorkoutRecord({
    required this.date,
    required this.duration,
    required this.groups,
    required this.personalRecords,
    required this.caloriesBurned,
  });

  final DateTime date;
  final Duration duration;
  final List<GroupPlan> groups;
  final int personalRecords;
  final int caloriesBurned;

  Iterable<ExerciseLog> get exercises =>
      groups.expand((g) => g.exercises).where((e) => e.doneSets.isNotEmpty);
  Iterable<SetEntry> get doneSets => exercises.expand((e) => e.doneSets);
  int get totalReps => doneSets.fold(0, (sum, s) => sum + s.reps);
  double get volume => doneSets.fold(0.0, (sum, s) => sum + s.weight * s.reps);

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'durationSeconds': duration.inSeconds,
        'groups': [for (final g in groups) g.toJson()],
        'personalRecords': personalRecords,
        'caloriesBurned': caloriesBurned,
      };

  factory WorkoutRecord.fromJson(Map<String, dynamic> j) => WorkoutRecord(
        date: DateTime.parse(j['date'] as String),
        duration: Duration(seconds: j['durationSeconds'] as int),
        groups: [for (final g in j['groups'] as List) GroupPlan.fromJson(g as Map<String, dynamic>)],
        personalRecords: j['personalRecords'] as int,
        caloriesBurned: j['caloriesBurned'] as int,
      );
}

// ---------------------------------------------------------------------------
// Food
// ---------------------------------------------------------------------------

enum MealType { breakfast, lunch, dinner, snacks }

extension MealInfo on MealType {
  String get label => switch (this) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snacks => 'Snacks',
      };

  IconData get icon => switch (this) {
        MealType.breakfast => Icons.free_breakfast_outlined,
        MealType.lunch => Icons.lunch_dining_outlined,
        MealType.dinner => Icons.dinner_dining_outlined,
        MealType.snacks => Icons.cookie_outlined,
      };
}

class FoodEntry {
  FoodEntry({
    required this.date,
    required this.meal,
    required this.name,
    required this.quantity,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  final DateTime date;
  final MealType meal;
  final String name;
  final String quantity;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'meal': meal.name,
        'name': name,
        'quantity': quantity,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory FoodEntry.fromJson(Map<String, dynamic> j) => FoodEntry(
        date: DateTime.parse(j['date'] as String),
        meal: MealType.values.byName(j['meal'] as String),
        name: j['name'] as String,
        quantity: j['quantity'] as String,
        calories: (j['calories'] as num).toDouble(),
        protein: (j['protein'] as num).toDouble(),
        carbs: (j['carbs'] as num).toDouble(),
        fat: (j['fat'] as num).toDouble(),
      );
}

class Macros {
  const Macros(this.calories, this.protein, this.carbs, this.fat);
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  factory Macros.of(Iterable<FoodEntry> items) => items.fold(
        const Macros(0, 0, 0, 0),
        (m, f) => Macros(m.calories + f.calories, m.protein + f.protein, m.carbs + f.carbs, m.fat + f.fat),
      );
}

// ---------------------------------------------------------------------------
// App state
// ---------------------------------------------------------------------------

/// Holds app state. Everything except an in-progress workout is saved to the
/// device after each change and restored by [load].
class AppState extends ChangeNotifier {
  AppState([this._prefs]);

  /// Creates the state with everything saved from the last launch.
  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppState(prefs).._restore();
  }

  final SharedPreferences? _prefs;

  Profile? profile;

  /// Weekday (1 = Monday … 7 = Sunday) -> planned muscle groups.
  final Map<int, List<GroupPlan>> plans = {for (var d = 1; d <= 7; d++) d: []};
  final List<WorkoutRecord> history = [];
  final List<FoodEntry> foods = [];

  int? activeWeekday;
  DateTime? startedAt;

  void touch() => notifyListeners();

  @override
  void notifyListeners() {
    super.notifyListeners();
    save();
  }

  /// Saves everything. Call after changing a set's weight or reps in place.
  void save() {
    final prefs = _prefs;
    if (prefs == null) return;
    final p = profile;
    p == null ? prefs.remove('profile') : prefs.setString('profile', jsonEncode(p.toJson()));
    prefs
      ..setString('plans', jsonEncode({
        for (final MapEntry(key: day, value: groups) in plans.entries)
          '$day': [for (final g in groups) g.toJson()],
      }))
      ..setString('history', jsonEncode([for (final r in history) r.toJson()]))
      ..setString('foods', jsonEncode([for (final f in foods) f.toJson()]));
  }

  /// Each section is read on its own so one unreadable entry doesn't lose the rest.
  void _restore() {
    void read(String key, void Function(Object json) apply) {
      final raw = _prefs?.getString(key);
      if (raw == null) return;
      try {
        apply(jsonDecode(raw) as Object);
      } on Object catch (e) {
        debugPrint('Ignoring unreadable saved $key: $e');
      }
    }

    read('profile', (j) => profile = Profile.fromJson(j as Map<String, dynamic>));
    read('plans', (j) {
      for (final MapEntry(:key, :value) in (j as Map<String, dynamic>).entries) {
        plans[int.parse(key)] = [for (final g in value as List) GroupPlan.fromJson(g as Map<String, dynamic>)];
      }
      // A workout left running when the app closed isn't resumed; clear its ticks.
      for (final s in plans.values.expand((g) => g).expand((g) => g.exercises).expand((e) => e.sets)) {
        s.done = false;
      }
    });
    read('history', (j) => history.addAll([for (final r in j as List) WorkoutRecord.fromJson(r as Map<String, dynamic>)]));
    read('foods', (j) => foods.addAll([for (final f in j as List) FoodEntry.fromJson(f as Map<String, dynamic>)]));
  }

  void saveProfile(Profile p) {
    profile = p;
    notifyListeners();
  }

  GroupPlan groupPlan(int weekday, String group) =>
      plans[weekday]!.firstWhere((g) => g.group == group);

  void setGroups(int weekday, Set<String> groups) {
    final current = plans[weekday]!;
    plans[weekday] = [
      for (final g in muscleGroups.map((m) => m.name).where(groups.contains))
        current.firstWhere((p) => p.group == g, orElse: () => GroupPlan(g)),
    ];
    notifyListeners();
  }

  void setExercises(int weekday, String group, List<ExerciseInfo> selected) {
    final plan = groupPlan(weekday, group);
    final existing = {for (final e in plan.exercises) e.info.name: e};
    plan.exercises
      ..clear()
      ..addAll(selected.map((i) => existing[i.name] ?? ExerciseLog(i, _lastSetsFor(i.name))));
    notifyListeners();
  }

  /// Prefills a newly added exercise with the sets from its last session.
  List<SetEntry>? _lastSetsFor(String name) {
    for (final r in history) {
      for (final e in r.exercises) {
        if (e.info.name == name) {
          return e.doneSets.map((s) => SetEntry(weight: s.weight, reps: s.reps)).toList();
        }
      }
    }
    return null;
  }

  void removeExercise(int weekday, String group, ExerciseLog log) {
    groupPlan(weekday, group).exercises.remove(log);
    notifyListeners();
  }

  void addSet(ExerciseLog log) {
    final last = log.sets.isEmpty ? null : log.sets.last;
    log.sets.add(SetEntry(weight: last?.weight ?? 0, reps: last?.reps ?? 0));
    notifyListeners();
  }

  void removeSet(ExerciseLog log, SetEntry set) {
    log.sets.remove(set);
    notifyListeners();
  }

  void toggleExercise(ExerciseLog log) {
    final value = !log.completed;
    for (final s in log.sets) {
      s.done = value;
    }
    notifyListeners();
  }

  void startWorkout(int weekday) {
    activeWeekday = weekday;
    startedAt = DateTime.now();
    notifyListeners();
  }

  void cancelWorkout() {
    for (final e in plans[activeWeekday]!.expand((g) => g.exercises)) {
      for (final s in e.sets) {
        s.done = false;
      }
    }
    activeWeekday = null;
    startedAt = null;
    notifyListeners();
  }

  WorkoutRecord finishWorkout() {
    final weekday = activeWeekday!;
    final now = DateTime.now();
    final duration = now.difference(startedAt!);
    final groups = plans[weekday]!.map((g) => g.copy()).toList();

    var prs = 0;
    for (final e in groups.expand((g) => g.exercises)) {
      if (e.doneSets.isEmpty) continue;
      final best = e.doneSets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
      final previous = _bestWeight(e.info.name);
      if (previous != null && best > previous) prs++;
    }

    // Rough estimate: MET 5 (moderate weight training) × body weight × hours.
    final kg = profile?.weightKg ?? 70;
    final calories = (5.0 * kg * duration.inSeconds / 3600).round();

    final record = WorkoutRecord(
      date: now,
      duration: duration,
      groups: groups,
      personalRecords: prs,
      caloriesBurned: calories,
    );
    history.insert(0, record);

    for (final e in plans[weekday]!.expand((g) => g.exercises)) {
      for (final s in e.sets) {
        s.done = false;
      }
    }
    activeWeekday = null;
    startedAt = null;
    notifyListeners();
    return record;
  }

  double? _bestWeight(String name) {
    double? best;
    for (final s in history.expand((r) => r.exercises).where((e) => e.info.name == name).expand((e) => e.doneSets)) {
      if (best == null || s.weight > best) best = s.weight;
    }
    return best;
  }

  bool workedOutOn(DateTime date) => history.any((r) => sameDay(r.date, date));

  List<FoodEntry> foodsOn(DateTime date, [MealType? meal]) => foods
      .where((f) => sameDay(f.date, date) && (meal == null || f.meal == meal))
      .toList();

  void addFood(FoodEntry entry) {
    foods.add(entry);
    notifyListeners();
  }

  void removeFood(FoodEntry entry) {
    foods.remove(entry);
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  /// Use in build methods; rebuilds when state changes.
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Use in callbacks and initState; does not subscribe to changes.
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

// ---------------------------------------------------------------------------
// Date & formatting helpers
// ---------------------------------------------------------------------------

const weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

DateTime get weekStart {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.subtract(Duration(days: today.weekday - 1));
}

DateTime dateForWeekday(int weekday) => weekStart.add(Duration(days: weekday - 1));

String longDate(DateTime d) => '${monthNames[d.month - 1]} ${d.day}, ${d.year}';
String shortDate(DateTime d) => '${monthNames[d.month - 1].substring(0, 3)} ${d.day}';

String formatDuration(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}

String fmtNum(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
